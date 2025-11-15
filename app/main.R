box::use(
  bs4Dash[dashboardBody, dashboardPage, bs4DashNavbar, dashboardSidebar, tabsetPanel],
  dplyr[select],
  shiny[
    downloadButton, downloadHandler, fileInput, fluidPage, icon, moduleServer, NS,
    observeEvent, reactive, reactiveVal, req, selectInput, showNotification,
    tagList, tags, updateDateInput, updateSelectInput, updateSelectizeInput, updateTextInput
  ],
  shiny.i18n[Translator, usei18n, update_lang],
  shinyWidgets[dropdownButton],
  utils[zip]
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
i18n <- Translator$new(translation_json_path = "app/static/translations.json", automatic = FALSE)
i18n$set_translation_language("fr") # English as default

#' @export
ui <- function(id) {
  ns <- NS(id)

  usei18n(i18n)

  dashboardPage(
    dark = FALSE,
    help = FALSE,
    skin = "info",
    header = bs4DashNavbar(
      title = "PastRx TDM",
      leftUi = tagList(
        tags$li(
          class = "dropdown",
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
            selectInput(ns("language"), label = i18n$translate("Language"), choices = i18n$get_languages(), selected = i18n$get_key_translation(), width = "150px")
          )
        )
      ),
      rightUi = tagList(
        tags$li(
          class = "dropdown",
          fileInput(
            ns("load_file"),
            label = NULL,
            accept = c(".mb2", ".json"),
            buttonLabel = i18n$translate("Load"),
            placeholder = "",
            width = "150px"
          )
        ),
        tags$li(
          class = "dropdown",
          downloadButton(
            ns("save_file"),
            i18n$translate("Save"),
            style = "background-color: #3d9970; color: white; margin-left: 10px;"
          )
        )
      )
    ),
    sidebar = dashboardSidebar(disable = TRUE),
    body = dashboardBody(
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
    # Reactive value to store loaded file data
    loaded_file_data <- reactiveVal(NULL)

    # Call module servers with loaded_data reactive
    patient_data <- patient_information$server("patient_info", i18n)
    admin_data <- administration$server("admin", i18n, patient_data, reactive(loaded_file_data()))
    tdm_values <- tdm_data$server("tdm_data", i18n, reactive(loaded_file_data()))

    # Handle language change
    observeEvent(input$language, {
      update_lang(input$language)
    })

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
          showNotification("Please fill in all required data before saving", type = "error")
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
          showNotification("All concentration and dose will be divided by 10 in the MB2 file", type = "warning")
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
          showNotification("No weight type selected, using TBW as default", type = "message")
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

        json_content <- mb2_json_write()(
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
          "Files saved successfully! (MB2 + JSON in ZIP)",
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
              settings = app_state$settings,
              correction_factor = if (!is.null(app_state$correction$applied) && app_state$correction$applied) 1 else app_state$correction$factor
            )

            loaded_file_data(loaded_data)

            showNotification(
              paste(
                "JSON file loaded successfully!",
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
              paste("Error loading JSON file:", e$message, "- Please check the file format or load the MB2 file instead."),
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

                  # Apply correction for divided-by-10 values if needed
                  if (!is.null(app_state$correction$applied) && app_state$correction$applied == TRUE) {
                    correction_multiplier <- app_state$correction$factor

                    # Correct concentration values in TDM history
                    if (!is.null(app_state$tdm_history) && nrow(app_state$tdm_history) > 0) {
                      app_state$tdm_history$concentration <- app_state$tdm_history$concentration * correction_multiplier
                    }

                    # Correct dose and infusion rate in dosing history
                    if (!is.null(app_state$dosing_history) && nrow(app_state$dosing_history) > 0) {
                      app_state$dosing_history$Dose <- app_state$dosing_history$Dose * correction_multiplier
                      app_state$dosing_history$Infusion_rate <- app_state$dosing_history$Infusion_rate * correction_multiplier
                    }
                  }

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
                    paste("JSON file corrupted or not found. Loading MB2 file only."),
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
                  "MB2 file loaded successfully!",
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
              paste("Error loading MB2 file:", e$message),
              type = "error",
              duration = 10
            )
          }
        )
      } else {
        showNotification(
          "Unsupported file format. Please upload a .mb2 or .json file.",
          type = "error",
          duration = 5
        )
      }
    })
  })
}
