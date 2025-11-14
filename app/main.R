box::use(
  bs4Dash[dashboardBody, dashboardPage, bs4DashNavbar, dashboardSidebar, tabsetPanel],
  dplyr[select],
  shiny[downloadButton, downloadHandler, fileInput, fluidPage, moduleServer, NS, observeEvent, reactive, reactiveValues, req, selectInput, showNotification, tagList, tags],
  shiny.i18n[Translator, usei18n, update_lang],
)

box::use(
  app/logic/fun_name_file[name_file],
  app/logic/mb2_read[read_mb2],
  app/logic/fun_update_data[update_data],
  app/logic/fun_write_mb2[write_mb2],
  app/view/administration,
  app/view/patient_information,
  app/view/tdm_data,
)

# Initialize translator
i18n <- Translator$new(translation_json_path = "app/static/translations.json", automatic = FALSE)
i18n$set_translation_language("fr") # French as default

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
      rightUi = tagList(
        tags$li(
          class = "dropdown",
          selectInput(
            ns("language"),
            label = NULL,
            choices = i18n$get_languages(),
            selected = i18n$get_key_translation(),
            width = "150px"
          )
        ),
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
    
    # Shared reactive data storage
    shared_data <- reactiveValues(
      dosing_history = shiny::reactiveVal(data.frame(
        Admin_date = character(),
        Route = character(),
        Infusion_rate = numeric(),
        Infusion_duration = numeric(),
        Dose = numeric(),
        Creatinin_Clearance = numeric(),
        creatinine = numeric(),
        stringsAsFactors = FALSE
      )),
      weight_history = shiny::reactiveVal(data.frame(
        Weight_date = character(),
        Weight_value = numeric(),
        mod_weight_type = character(),
        tbw = numeric(),
        bsa = numeric(),
        stringsAsFactors = FALSE
      )),
      tdm_history = shiny::reactiveVal(data.frame(
        tdm_time = character(),
        concentration = numeric(),
        stringsAsFactors = FALSE
      ))
    )
    
    # Call module servers
    patient_data <- patient_information$server("patient_info", i18n)
    admin_data <- administration$server("admin", i18n, patient_data)
    tdm_values <- tdm_data$server("tdm_data", i18n)
    
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
        if (a_data$bsa_selection) {
          selected_weight_data <- select(weight_history_data, .data$Weight_date, .data$bsa)
        } else if (a_data$weight_type_selection) {
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
      
      tryCatch({
        # Read the MB2 file
        data_file <- read_mb2(input$load_file$datapath)
        
        # Call the function to process and update data from the file
        update_functions <- update_data(input$load_file$datapath)
        update_patient_data <- update_functions[["update_patient_data"]]
        update_tdm_history <- update_functions[["update_tdm_history"]]
        
        # Update the input fields that are not dataframe
        update_patient_data(data_file, session)
        dose_level_data <- update_tdm_history(data_file)
        
        # TODO: Update module data with loaded values
        # Note: This requires the modules to expose methods for updating their internal state
        # For now, the patient information will be updated via the session updates
        
        showNotification(
          "File loaded successfully. Note: Concentrations are not automatically corrected if above 100.",
          type = "warning",
          duration = 5
        )
        
        showNotification(
          "Legacy file loading - please verify all data after loading.",
          type = "message",
          duration = 5
        )
      }, error = function(e) {
        showNotification(
          paste("Error loading file:", e$message),
          type = "error",
          duration = 10
        )
      })
    })

  })
}
