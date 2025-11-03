box::use(
  bs4Dash[dashboardBody, dashboardHeader, dashboardPage, bs4DashNavbar, dashboardSidebar, tabsetPanel],
  shiny[actionButton, column, div, downloadButton, downloadHandler, fluidPage, icon, moduleServer, NS, observeEvent, reactive, reactiveVal, selectInput, tagList, tags],
  shiny.i18n[Translator, usei18n, update_lang],
  shinyjs[useShinyjs],
)

box::use(
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
          # Language selector with flag icons
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
          # Save file button
          tags$li(
            class = "dropdown",
            downloadButton(
              ns("save_file"),
              i18n$t("Sauvegarder"),
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
    # Store i18n in session userData for child modules
    #session$userData$i18n <- i18n
    
    # Call module servers
    patient_info_data <- patient_information$server("patient_info", i18n)
    admin_data <- administration$server("admin", i18n)
    tdm_values <- tdm_data$server("tdm_data", i18n)

    # # Combine all module data into a single reactive
    # patient_data <- reactive({
    #   p_info <- patient_info_data()
    #   a_data <- admin_data()
    #   t_data <- tdm_values()
      
    #   list(
    #     name = paste(p_info$first_name, p_info$last_name),
    #     birthdate = p_info$birthdate,
    #     sex = p_info$sex,
    #     hospital = p_info$hospital,
    #     ward = p_info$ward,
    #     drug = p_info$drug,
    #     phone = p_info$phone_number,
    #     weight = a_data$weight,
    #     height = a_data$height,
    #     creatinine = a_data$creatinine,
    #     renal_formula = a_data$renal_formula,
    #     albumin = a_data$albumin,
    #     bilirubin = a_data$bilirubin,
    #     administration_data = a_data$administration_data,
    #     dosing_history = t_data$dosing_history,
    #     tdm_history = t_data$tdm_history,
    #     weight_history = t_data$weight_history
    #   )
    # })
    
    # Handle language change
    observeEvent(input$language, {
      update_lang(input$language)
      #session$reload()
    })
    
    # # Handle file download
    # output$save_file <- downloadHandler(
    #   filename = function() {
    #     data <- patient_data()
    #     paste0(data$name, "_", format(Sys.Date(), "%Y%m%d"), ".txt")
    #   },
    #   content = function(file) {
    #     data <- patient_data()
        
    #     # Format patient data for export
    #     output_text <- paste0(
    #       "=== Patient Information ===\n",
    #       "Name: ", data$name, "\n",
    #       "Birthdate: ", data$birthdate, "\n",
    #       "Sex: ", data$sex, "\n",
    #       "Hospital: ", data$hospital, "\n",
    #       "Ward: ", data$ward, "\n",
    #       "Drug: ", data$drug, "\n",
    #       "Phone: ", data$phone, "\n\n",
    #       "=== TDM Data ===\n",
    #       "Dosing History:\n",
    #       paste(capture.output(print(data$dosing_history)), collapse = "\n"), "\n\n",
    #       "TDM History:\n",
    #       paste(capture.output(print(data$tdm_history)), collapse = "\n"), "\n\n",
    #       "Weight History:\n",
    #       paste(capture.output(print(data$weight_history)), collapse = "\n")
    #     )
        
    #     writeLines(output_text, file)
    #   }
    # )
    
    # TODO: Add additional server logic for:
    # - Patient data updates from UI inputs
    # - Dosing history management
    # - TDM data management
    # - Weight tracking
    # - Renal function calculator
    # - File loading functionality
  })
}
