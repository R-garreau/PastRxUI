box::use(
  bs4Dash[dashboardBody, dashboardPage, bs4DashNavbar, dashboardSidebar, tabsetPanel],
  dplyr[select],
  shiny[downloadButton, downloadHandler, fileInput, fluidPage, icon,moduleServer, NS,
        observeEvent, reactive, reactiveVal, req, selectInput, showNotification,
        tagList, tags, updateDateInput, updateSelectInput, updateSelectizeInput, updateTextInput],
  shiny.i18n[Translator, usei18n, update_lang],
  shinyWidgets[dropdownButton]
)

box::use(
  app / logic / fun_name_file[name_file],
  app / logic / fun_write_mb2[write_mb2],
  app / logic / mb2_read[read_mb2],
  app / view / administration,
  app / view / patient_information,
  app / view / tdm_data,
)

# Initialize translator
i18n <- Translator$new(translation_json_path = "app/static/translations.json", automatic = FALSE)
i18n$set_translation_language("en") # English as default

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
            accept = ".mb2",
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
        name_file(
          first_name = p_data$first_name,
          last_name = p_data$last_name,
          hospital = p_data$hospital,
          drug = p_data$drug,
          ext = ".mb2"
        )
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

        # Check if concentration correction should be applied only for MB2 file
        if (nrow(mb2_tdm_history) > 0 && max(mb2_tdm_history$concentration) > 100) {
          mb2_tdm_history$concentration <- mb2_tdm_history$concentration / 10
          mb2_dosing_history$Dose <- mb2_dosing_history$Dose / 10
          mb2_dosing_history$Infusion_rate <- mb2_dosing_history$Infusion_rate / 10
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
          phone_number = p_data$phone_number,
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
          mic_value = 0 # TODO: Get MIC value from inputs
        )

        writeLines(mb2_content, file)

        showNotification(
          "File saved successfully!",
          type = "message",
          duration = 3
        )
      }
    )

    # Load file observer - MB2 file loading
    observeEvent(input$load_file, {
      req(input$load_file)

      tryCatch(
        {
          # Read the MB2 file
          data_file <- read_mb2(input$load_file$datapath)

          # Update Patient Information tab inputs
          updateTextInput(session, "patient_info-first_name", value = data_file$patient_first_name)
          updateTextInput(session, "patient_info-last_name", value = data_file$patient_last_name)
          updateTextInput(session, "patient_info-ward", value = data_file$ward)
          updateTextInput(session, "patient_info-phone_number", value = "")
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
              "File loaded successfully!",
              "Weight:", nrow(data_file$weight_df), "entries,",
              "Dosing:", nrow(data_file$dose_df), "entries,",
              "TDM:", nrow(data_file$level_df), "values"
            ),
            type = "message",
            duration = 5
          )
        },
        error = function(e) {
          showNotification(
            paste("Error loading file:", e$message),
            type = "error",
            duration = 10
          )
        }
      )
    })
  })
}
