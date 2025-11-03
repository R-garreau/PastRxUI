box::use(
  bs4Dash[dashboardBody, dashboardFooter, dashboardHeader, dashboardPage, dashboardSidebar, menuItem, sidebarMenu, tabItems],
  shiny[actionButton, column, div, fileInput, fluidRow, h5, icon, moduleServer, NS, observeEvent, reactiveValues, tagList, tags, uiOutput],
  shiny.i18n[Translator],
  shinyjs[useShinyjs],
)

box::use(
  app/view/patient_information[patient_information_ui],
  app/view/settings[settings_ui],
  app/view/tdm_data,
)

# Initialize translator
translator <- Translator$new(translation_json_path = "app/static/translations.json")
translator$set_translation_language("fr") # French as default

#' @export
ui <- function(id) {
  ns <- NS(id)
  # Header
  # app_header <- dashboardHeader(
  #   title = a(
  #     href = "https://lbbe.univ-lyon1.fr/fr/equipe-evaluation-et-modelisation-des-effets-therapeutiques",
  #     target = "_blank",
  #     img(src = "https://i.ibb.co/1v3Kcwc/lymit-app-logo-olive.png", title = "Lymit", style = "height: 5%; width: 100%;")
  #   ),
  #   tags$li(
  #     class = "dropdown",
  #     tags$a(
  #       href = "#",
  #       class = "dropdown-toggle",
  #       `data-toggle` = "dropdown",
  #       tags$span("Useful Tools", class = "hidden-xs"),
  #       tags$i(class = "fa fa-duotone fa-link fa-lg")
  #     ),
  #     tags$ul(
  #       id = "left-align-dropdown",
  #       class = "dropdown-menu pull-right",
  #       tags$li(
  #         tags$a(
  #           href = "https://www.eucast.org/mic_and_zone_distributions_and_ecoffs",
  #           target = "_blank",
  #           img(src = "https://www.nosoinfo.be/nosoinfos/wp-content/uploads/2022/09/eucast.jpg", style = "width:100%; height:auto;")
  #         )
  #       ),
  #       tags$li(
  #         tags$a(
  #           href = "https://www.ddi-predictor.org",
  #           target = "_blank",
  #           img(src = "https://www.ddi-predictor.org/images/ddi-predictor-logo.png", style = "width:100%; height:auto;")
  #         )
  #       )
  #     )
  #   )
  # )
  
  tagList(
    useShinyjs(),
    dashboardPage(
      dark = FALSE,
      scrollToTop = TRUE,
      help = FALSE,
      skin = "olive",
      header = dashboardHeader(),
      sidebar = dashboardSidebar(
        status = "olive",
        customArea = div(class = "sidebar-content", h5("Version 1.3.0"), style = "color: #3d9970; text-align: center;"),
        sidebarMenu(
          menuItem(translator$t("Informations du patient"), tabName = "information", icon = icon("person-half-dress")),
          menuItem(translator$t("Données TDM"), tabName = "tdm_data", icon = icon("flask")),
          menuItem(translator$t("Paramètres"), tabName = "settings", icon = icon("gear"))
        ),
        div(
          style = "position: absolute; bottom: 20px; left: 0; width: 100%; text-align: center;",
          actionButton(ns("reload_app"), translator$t("Recharger l'application"), style = "background-color: #3d9970; color: white;")
        )
      ),
      body = dashboardBody(
        tabItems(
          patient_information_ui(translator),
          tdm_data$ui(ns("tdm_data"), translator),
          settings_ui(translator)
        )
      ),
      footer = dashboardFooter(
        left = fluidRow(
          tags$style(".shiny-file-input-progress {display: none}"),
          column(width = 2, div(fileInput(ns("load_file"), translator$t("Charger fichier patient")))),
          column(width = 2, div(actionButton(ns("create_new_patient"), translator$t("Créer nouveau patient"), 
                                             style = "background-color: #3d9970; color: white; margin-top: 30px;")))
        ),
        right = uiOutput(ns("saveFileButton")),
        fixed = FALSE
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Call TDM data module server
    tdm_data$server("tdm_data")
    
    # Reactive values to store data
    patient_data <- reactiveValues(
      dosing_history = data.frame(),
      tdm_history = data.frame(),
      weight_history = data.frame()
    )
    
    # TODO: Add server logic here for handling:
    # - File loading (load_file)
    # - Patient data updates
    # - Dosing history (make_dosing_history)
    # - TDM data (make_tdm_history)
    # - Weight tracking
    # - Renal function calculator (renal_formula_calculator)
    # - File saving (saveFileButton)
    # - New patient creation (create_new_patient)
    # - App reload (reload_app)
    
    # Placeholder for reload functionality
    observeEvent(input$reload_app, {
      session$reload()
    })
  })
}
