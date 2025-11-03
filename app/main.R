box::use(
  bs4Dash[dashboardBody, dashboardPage, bs4DashNavbar, dashboardSidebar, tabsetPanel],
  shiny[downloadButton, downloadHandler, fluidPage, moduleServer, NS, observeEvent, reactive, reactiveValues, selectInput, tagList, tags],
  shiny.i18n[Translator, usei18n, update_lang],
)

box::use(
  app/logic[name_file, write_mb2],
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
        Concentration = numeric(),
        stringsAsFactors = FALSE
      ))
    )
    
    # Call module servers
    patient_data <- patient_information$server("patient_info", i18n)
    admin_data <- administration$server("admin", i18n, patient_data, shared_data)
    tdm_values <- tdm_data$server("tdm_data", i18n, shared_data)
    
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
        req(patient_data(), admin_data(), tdm_values())
        
        p_data <- patient_data()
        a_data <- admin_data()
        t_data <- tdm_values()
        
        # Select weight data (use modified weight if available, otherwise TBW)
        weight_data <- a_data$weight_history
        if (nrow(weight_data) > 0) {
          weight_data <- weight_data[, c("Weight_date", "Weight_value")]
          names(weight_data) <- c("Weight_date", "weight")
        } else {
          weight_data <- data.frame(Weight_date = character(), weight = numeric())
        }
        
        # Prepare administration data
        admin_df <- a_data$dosing_history
        if (nrow(admin_df) > 0) {
          admin_df <- admin_df[, c("Admin_date", "Route", "Infusion_rate", "Infusion_duration", "Dose", "Creatinin_Clearance")]
        } else {
          admin_df <- data.frame(
            Admin_date = character(),
            Route = character(),
            Infusion_rate = numeric(),
            Infusion_duration = numeric(),
            Dose = numeric(),
            Creatinin_Clearance = numeric()
          )
        }
        
        # Prepare TDM data
        tdm_df <- t_data$tdm_history
        if (nrow(tdm_df) == 0) {
          tdm_df <- data.frame(tdm_time = character(), Concentration = numeric())
        }
        
        # Get next dose info from patient data inputs
        # For now, use current date/time as placeholder
        next_dose_date <- Sys.Date()
        next_dose_time <- Sys.time()
        
        # Write MB2 file
        mb2_content <- write_mb2(
          last_name = p_data$last_name,
          first_name = p_data$first_name,
          sex = p_data$sex,
          hospital = p_data$hospital,
          ward = p_data$ward,
          room = "",
          phone_number = p_data$phone_number,
          height = 170, # Default, should come from admin module
          birthdate = format(p_data$birthdate, "%Y/%m/%d"),
          drug_name = p_data$drug,
          date_next_dose = next_dose_date,
          time_next_dose = next_dose_time,
          weight_number = nrow(weight_data),
          dose_number = nrow(admin_df),
          concentration_number = nrow(tdm_df),
          weight_data = weight_data,
          administration_data = admin_df,
          level_data = tdm_df
        )
        
        writeLines(mb2_content, file)
        
        shiny::showNotification(
          "File saved successfully!",
          type = "message",
          duration = 3
        )
      }
    )
  })
}
