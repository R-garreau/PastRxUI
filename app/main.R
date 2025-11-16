box::use(
  bs4Dash[bs4DashNavbar, dashboardBody, dashboardPage,  dashboardSidebar, tabsetPanel],
  dplyr[select],
  shiny.i18n[Translator, update_lang, usei18n],
  shiny[
    downloadButton, downloadHandler, fileInput, fluidPage, icon, moduleServer, NS,
    observeEvent, reactive, reactiveVal, req, selectInput, showNotification,
    tagList, tags, updateDateInput, updateSelectInput, updateSelectizeInput, updateTextInput
  ],
  shinyWidgets[dropdownButton, materialSwitch],
  utils[zip],
)

box::use(
  app / logic / fun_name_file[name_file],
  app / logic / fun_write_mb2[write_mb2],
  app / logic / mb2_read[read_mb2],
  app / logic / mb2_json_io[get_json_filename, mb2_json_read, mb2_json_write],
  app / view / administration,
  app / view / patient_information,
  app / view / tdm_data,
)

# Initialize translator
i18n <- Translator$new(translation_json_path = "app/translations/translations.json")
i18n$set_translation_language("fr") # English as default

#' @export
ui <- function(id) {
  ns <- NS(id)

  dashboardPage(
    dark = NULL,
    help = NULL,
    skin = "info",
    header = bs4DashNavbar(
      title = tagList(
        tags$img(
          src = "static/BD_shortlogo.png",
          height = "80px",
          style = "margin-right: 5px;"
        ), tags$h3("PastRx")
      ),
      leftUi = tagList(
        tags$li(
          class = "dropdown",
          style = "display: flex; align-items: center; margin-top: 22px; margin-left: 50px;",
          tags$style(".shiny-file-input-progress {display: none}"),
          fileInput(
            ns("load_file"),
            label = NULL,
            accept = c(".mb2", ".json"),
            buttonLabel = i18n$translate("Load"),
            placeholder = "",
            width = "300px"
          )
        ),
        tags$li(
          class = "dropdown",
          style = "display: flex; align-items: center;",
          downloadButton(
            ns("save_file"),
            i18n$translate("Save"),
            style = "background-color: #3d9970; color: white; margin-left: 10px;"
          )
        )
      ),
      rightUi = tagList(
        tags$li(
          class = "dropdown",
          style = "margin-right: 20px; margin-top: 10px;",
          materialSwitch(
            ns("help_toggle"),
            label = i18n$translate("Help Mode"),
            inline = TRUE,
            status = "warning",
            value = FALSE
          )
        ),
        tags$li(
          class = "dropdown",
          style = "margin-right: 20px;",
          dropdownButton(
            inputId = ns("mb2_settings"),
            label = i18n$translate("Settings"),
            status = "danger",
            size = "sm",
            circle = FALSE,
            icon = icon("gear"),
            width = "300px",
            tags$h3(i18n$translate("Settings")),
            selectInput(ns("weight_type_selection"), label = i18n$translate("Weight Type"), choices = c("Total Weight" = "TBW", "Modified weight" = "mod_weight", "Body Surface Area" = "BSA"), selected = "TBW"),
            selectInput(ns("language"), label = i18n$translate("Language"), choices = c("🇺🇸 en" = "en", "🇫🇷 fr" = "fr"), selected = i18n$get_key_translation(), width = "150px")
          )
        )
      )
    ),
    sidebar = dashboardSidebar(disable = TRUE),
    body = dashboardBody(
      usei18n(i18n),
      fluidPage(
        tabsetPanel(
          id = ns("main_tabs"),
          type = "tabs",
          patient_information$ui(ns("patient_info"), i18n),
          administration$ui(ns("admin"), i18n),
          tdm_data$ui(ns("tdm_data"), i18n)
        )
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Handle language change
    observeEvent(input$language, {
      i18n$set_translation_language(input$language)
      update_lang(input$language, session)
    })

    # Reactive value to store loaded file data
    loaded_file_data <- reactiveVal(NULL)

    # Call module servers with loaded_data reactive
    admin_data <- administration$server("admin", i18n = i18n, patient_data, reactive(loaded_file_data()))
    tdm_values <- tdm_data$server("tdm_data", i18n = i18n, reactive(loaded_file_data()))
    patient_data <- patient_information$server("patient_info", i18n = i18n, admin_data, tdm_values, reactive(input$weight_type_selection), help_mode = reactive(input$help_toggle))


    # Handle file download
    output$save_file <- downloadHandler(
      filename = function() {
        req(patient_data())
        p_data <- patient_data()
        base_name <- name_file(
          first_name = p_data$first_name,
          last_name = p_data$last_name,
          hospital = p_data$hospital,
          drug = p_data$drug,
          ext = ""
        )
        paste0(base_name, ".zip")
      },
      content = function(file) {
        # Require data from modules - only patient data is mandatory
        req(patient_data())

        p_data <- patient_data()
        a_data <- admin_data()
        tdm_data <- tdm_values()

        # Validate that we have at least patient data
        if (is.null(p_data) || is.null(a_data) || is.null(tdm_data)) {
          showNotification(i18n$translate("Please fill in all required data before saving"), type = "error")
          return()
        }

        # Create copies of the data for MB2 file writing
        mb2_tdm_history <- tdm_data
        mb2_dosing_history <- a_data$dosing_history

        # Determine correction factor
        correction_factor <- 1

        # Check if concentration correction should be applied only for MB2 file
        if (nrow(mb2_tdm_history) > 0 && max(mb2_tdm_history$concentration) > 100) {
          mb2_tdm_history$concentration <- mb2_tdm_history$concentration / 10
          mb2_dosing_history$Dose <- mb2_dosing_history$Dose / 10
          mb2_dosing_history$Infusion_rate <- mb2_dosing_history$Infusion_rate / 10
          correction_factor <- 10
          showNotification(i18n$translate("All concentration and dose will be divided by 10 in the MB2 file"), type = "warning")
        }

        # Update weight history to select the appropriate weight type
        # Priority: BSA > Mod Weight > TBW (default when both unchecked)
        weight_history_data <- a_data$weight_history
        if (input$weight_type_selection == "BSA") {
          selected_weight_data <- select(weight_history_data, .data$Weight_date, .data$bsa)
        } else if (input$weight_type_selection == "mod_weight") {
          selected_weight_data <- select(weight_history_data, .data$Weight_date, .data$Weight_value)
        } else {
          # Both unchecked - default to TBW
          selected_weight_data <- select(weight_history_data, .data$Weight_date, .data$tbw)
          showNotification(i18n$translate("No weight type selected, using TBW as default"), type = "message")
        }

        # Write the MB2 file content
        mb2_content <- write_mb2(
          first_name = p_data$first_name,
          last_name = p_data$last_name,
          sex = p_data$sex,
          hospital = p_data$hospital,
          ward = p_data$ward,
          room = "",
          height = a_data$height,
          birthdate = format(p_data$birthdate, "%Y/%m/%d"),
          drug_name = p_data$drug,
          date_next_dose = a_data$date_next_dose,
          time_next_dose = a_data$time_next_dose,
          weight_number = nrow(weight_history_data),
          dose_number = nrow(mb2_dosing_history),
          concentration_number = nrow(mb2_tdm_history),
          weight_data = selected_weight_data,
          administration_data = mb2_dosing_history,
          level_data = mb2_tdm_history,
          mic_value = 0
        )

        # Create JSON with complete app state
        settings_list <- list(
          weight_type = input$weight_type_selection,
          creatinine_unit = ifelse(a_data$mg_dl_unit, "mg/dL", "uM/L"),
          african = a_data$african,
          denorm_ccr = a_data$denorm_ccr,
          weight_lbs_unit = a_data$weight_lbs_unit,
          mg_dl_unit = a_data$mg_dl_unit
        )

        json_content <- mb2_json_write(
          patient_data = p_data,
          admin_data = a_data,
          tdm_data = tdm_data,
          settings = settings_list,
          correction_factor = correction_factor
        )

        # Create temporary directory for files
        temp_dir <- tempdir()

        # Generate base filename
        base_filename <- name_file(
          first_name = p_data$first_name,
          last_name = p_data$last_name,
          hospital = p_data$hospital,
          drug = p_data$drug,
          ext = ""
        )

        # Write both files to temp directory
        mb2_file <- file.path(temp_dir, paste0(base_filename, ".mb2"))
        json_file <- file.path(temp_dir, paste0(base_filename, ".json"))

        writeLines(mb2_content, mb2_file)
        writeLines(json_content, json_file)

        # Create zip file
        zip(
          zipfile = file,
          files = c(mb2_file, json_file),
          flags = "-j" # junk (don't record) directory names
        )

        # Clean up temp files
        file.remove(mb2_file)
        file.remove(json_file)

        showNotification(
          i18n$translate("Files saved successfully! (MB2 + JSON in ZIP)"),
          type = "message",
          duration = 3
        )
      }
    )

    # Load file observer - handles both MB2 and JSON files
    observeEvent(input$load_file, {
      req(input$load_file)

      # Determine file type
      file_ext <- tolower(tools::file_ext(input$load_file$name))

      if (file_ext == "json") {
        # Loading JSON file directly
        tryCatch(
          {
            app_state <- mb2_json_read(input$load_file$datapath)

            # Update all inputs from JSON state
            updateTextInput(session, "patient_info-first_name", value = app_state$patient$first_name)
            updateTextInput(session, "patient_info-last_name", value = app_state$patient$last_name)
            updateTextInput(session, "patient_info-ward", value = app_state$patient$ward)
            updateDateInput(session, "patient_info-birthdate", value = app_state$patient$birthdate)
            updateSelectInput(session, "patient_info-sex", selected = app_state$patient$sex)
            updateSelectInput(session, "patient_info-drug", selected = app_state$patient$drug)
            updateSelectizeInput(session, "patient_info-hospital",
              selected = app_state$patient$hospital,
              choices = c("HCL", "CHU", app_state$patient$hospital)
            )

            # Update settings
            if (!is.null(app_state$settings$weight_type)) {
              updateSelectInput(session, "weight_type_selection", selected = app_state$settings$weight_type)
            }

            # Create loaded data structure from JSON
            loaded_data <- list(
              patient_first_name = app_state$patient$first_name,
              patient_last_name = app_state$patient$last_name,
              ward = app_state$patient$ward,
              birthdate = app_state$patient$birthdate,
              sex = app_state$patient$sex,
              drug_name = app_state$patient$drug,
              hospital = app_state$patient$hospital,
              weight_df = app_state$weight_history,
              dose_df = app_state$dosing_history,
              level_df = app_state$tdm_history,
              settings = app_state$settings
            )

            loaded_file_data(loaded_data)

            showNotification(
              paste(
                i18n$translate("File loaded successfully"),
                "Weight:", nrow(app_state$weight_history), "entries,",
                "Dosing:", nrow(app_state$dosing_history), "entries,",
                "TDM:", nrow(app_state$tdm_history), "values"
              ),
              type = "message",
              duration = 5
            )
          },
          error = function(e) {
            showNotification(
              paste(i18n$translate("Error loading file"), e$message),
              type = "error",
              duration = 10
            )
          }
        )
      } else if (file_ext == "mb2") {
        # Loading MB2 file
        tryCatch(
          {
            # Read the MB2 file
            data_file <- read_mb2(input$load_file$datapath)

            # Check if corresponding JSON file exists
            json_path <- get_json_filename(input$load_file$datapath)
            json_loaded <- FALSE

            if (file.exists(json_path)) {
              tryCatch(
                {
                  app_state <- mb2_json_read(json_path)

                  # Update all inputs from JSON state
                  updateTextInput(session, "patient_info-first_name", value = app_state$patient$first_name)
                  updateTextInput(session, "patient_info-last_name", value = app_state$patient$last_name)
                  updateTextInput(session, "patient_info-ward", value = app_state$patient$ward)
                  updateDateInput(session, "patient_info-birthdate", value = app_state$patient$birthdate)
                  updateSelectInput(session, "patient_info-sex", selected = app_state$patient$sex)
                  updateSelectInput(session, "patient_info-drug", selected = app_state$patient$drug)
                  updateSelectizeInput(session, "patient_info-hospital",
                    selected = app_state$patient$hospital,
                    choices = c("HCL", "CHU", app_state$patient$hospital)
                  )

                  # Update settings
                  if (!is.null(app_state$settings$weight_type)) {
                    updateSelectInput(session, "weight_type_selection", selected = app_state$settings$weight_type)
                  }

                  # Create loaded data with full state from JSON
                  full_data <- data_file
                  full_data$weight_df <- app_state$weight_history
                  full_data$dose_df <- app_state$dosing_history
                  full_data$level_df <- app_state$tdm_history
                  full_data$settings <- app_state$settings

                  loaded_file_data(full_data)
                  json_loaded <- TRUE

                  showNotification(
                    paste(
                      "MB2 file loaded successfully with settings from JSON!",
                      "Weight:", nrow(app_state$weight_history), "entries,",
                      "Dosing:", nrow(app_state$dosing_history), "entries,",
                      "TDM:", nrow(app_state$tdm_history), "values"
                    ),
                    type = "message",
                    duration = 5
                  )
                },
                error = function(e) {
                  showNotification(
                    i18n$translate("JSON file not found or invalid. Loading MB2 file only."),
                    type = "error",
                    duration = 7
                  )
                }
              )
            }

            # Fallback to MB2 only if JSON not found or failed
            if (!json_loaded) {
              # Update Patient Information tab inputs
              updateTextInput(session, "patient_info-first_name", value = data_file$patient_first_name)
              updateTextInput(session, "patient_info-last_name", value = data_file$patient_last_name)
              updateTextInput(session, "patient_info-ward", value = data_file$ward)
              updateDateInput(session, "patient_info-birthdate", value = as.Date(data_file$birthdate))
              updateSelectInput(session, "patient_info-sex", selected = data_file$sex)
              updateSelectInput(session, "patient_info-drug", selected = data_file$drug_name)
              updateSelectizeInput(session, "patient_info-hospital",
                selected = data_file$hospital,
                choices = c("HCL", "CHU", data_file$hospital)
              )

              # Trigger module data loading by setting the reactive
              loaded_file_data(data_file)

              # Show success notifications
              showNotification(
                paste(
                  i18n$translate("File loaded successfully"),
                  "Weight:", nrow(data_file$weight_df), "entries,",
                  "Dosing:", nrow(data_file$dose_df), "entries,",
                  "TDM:", nrow(data_file$level_df), "values"
                ),
                type = "message",
                duration = 5
              )
            }
          },
          error = function(e) {
            showNotification(
              paste(i18n$translate("Error loading file"), e$message),
              type = "error",
              duration = 10
            )
          }
        )
      } else {
        showNotification(
          i18n$translate("Unsupported file format. Please select a .mb2 or .json file."),
          type = "error",
          duration = 5
        )
      }
    })
  })
}
