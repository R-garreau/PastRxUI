box::use(
  bs4Dash[actionButton, box, tabItem],
  rhandsontable[rHandsontableOutput],
  shiny[column, conditionalPanel, dateInput, fluidPage, fluidRow, icon, moduleServer, 
        NS, numericInput, reactiveValues, selectInput, tagList, tags],
  shinyTime[timeInput],
  shinyWidgets[checkboxGroupButtons],
)



#' @export
ui <- function(id, translator) {
  ns <- NS(id)

  tabItem(
    tabName = "tdm_data",
    fluidPage(
      fluidRow(
        box( # This section handle all covariate data
          title = tagList(icon("vials"), translator$t("Valeurs biologiques")),
          status = "olive",
          width = 4,
          solidHeader = TRUE,
          fluidRow(
            column(width = 3, numericInput(ns("weight"), label = translator$t("Poids"), min = 0, max = 250, step = 1, value = 70)),
            column(width = 2, offset = 1, numericInput(ns("height"), label = translator$t("Taille"), min = 0, max = 230, step = 1, value = 170)),
            column(width = 5, selectInput(ns("weight_formula_selection"), translator$t("Formule de poids"), choices = c("TBW", "IBW", "AJBW", "LBW"), selected = "TBW"))
          ),
          fluidRow(
            column(width = 8,
              numericInput(ns("creatinine"), translator$t("Créatinine"), min = 0, max = 300, step = 1, value = 60),
              selectInput(ns("eGFR"), label = translator$t("Formule rénale"), choices = c("CG", "MDRD", "CKD_2009", "CKD_2021", "UVP"), selected = "CG"),
              conditionalPanel(
                condition = "input.eGFR == 'UVP' ",
                numericInput(ns("urine_creatinine"), translator$t("Créatinine urinaire"), value = 0),
                numericInput(ns("urine_output"), translator$t("Débit urinaire"), value = 0)
              )
            ),
            column(width = 3, offset = 1,
              checkboxGroupButtons(
                ns("unit_value"),
                label = "",
                status = "info",
                direction = "vertical",
                choiceNames = c("African", "mg/dL", "lbs", "denorm_ccr"),
                choiceValues = c("African", "mg/dL", "lbs", "denorm_ccr"), 
                individual = TRUE,
                size = "sm",
                justified = TRUE,
                checkIcon = list(
                  yes = icon("square-check"),
                  no = icon("square")
                )
              )
            )
          )
        ),
        box( # This section handle all administration related data
          title = tagList(icon("pills"), translator$t("Administration du médicament")),
          status = "olive",
          width = 4,
          solidHeader = TRUE,
          selectInput(ns("administration_route"), translator$t("Voie d'administration"), 
                            choices = c("IV", "IM", "PO", "CI"), selected = "IV"),
          conditionalPanel(
            condition = "input.administration_route == 'CI' ",
            fluidRow(
              column(width = 6, dateInput(ns("start_date_CI"), translator$t("Date de début de perfusion"), Sys.Date(), format = "yyyy-mm-dd", language = "fr")),
              column(width = 6, timeInput(ns("start_time_CI"), translator$t("Heure de fin de perfusion"), seconds = FALSE))
            ),
            fluidRow(
              column(width = 6, dateInput(ns("end_date_CI"), translator$t("Date de fin de perfusion"), 
                                                        Sys.Date(), format = "yyyy-mm-dd", language = "fr")),
              column(width = 6, timeInput(ns("end_time_CI"), translator$t("Heure de fin de perfusion"), seconds = FALSE))
            ),
            fluidRow(
              column(width = 6, numericInput(ns("syringe_volume"), translator$t("Volume de la seringue"), value = 50)),
              column(width = 6, numericInput(ns("syringe_dose"), translator$t("Dose de la seringue"), value = 2000))
            ),
            numericInput("syringe_speed", translator$t("Vitesse de perfusion"), value = 2)
          ),
          conditionalPanel(
            condition = "input.administration_route != 'CI'",
            fluidRow(
              column(width = 6, dateInput(ns("date_administration"), translator$t("Date d'administration"), Sys.Date(), format = "yyyy-mm-dd", language = "fr")),
              column(width = 6, timeInput(ns("administration_time"), label = translator$t("Heure d'administration"), value = Sys.time(), seconds = FALSE))
            ),
            fluidRow(
              column(width = 6, numericInput(ns("dose_input"), label = translator$t("Dose"), value = 0)),
              column(width = 6, numericInput(ns("administration_duration"), label = translator$t("Durée d'administration"), value = 0.5, step = 0.1))
            )
          ),
          fluidRow(
            column(width = 6, dateInput(ns("date"), label = translator$t("Date de la prochaine dose"), format = "yyyy-mm-dd", value = Sys.Date(), language = "fr")),
            column(width = 6, timeInput(ns("time"), label = translator$t("Heure de la prochaine dose"), seconds = FALSE, value = Sys.time()))
          ),
          fluidRow(
            column(width = 4, actionButton(ns("make_dosing_history"), translator$t("Ajouter dose"), style = "background-color: #3d9970; color: white; margin-top: 30px;", width = "100%")),
            column(width = 4, numericInput(ns("multiple_dose_admin"), translator$t("Doses multiples"), min = 1, max = 50, step = 1, value = 1, width = "100%")),
            column(width = 4, numericInput(ns("multiple_dose_interval"), translator$t("Intervalle entre doses"), min = 0.5, step = 0.5, value = 24, width = "100%"))
          )
        ),
        box( # This section control the data regarding the serum level
          title = tagList(icon("syringe"), translator$t("Informations TDM")),
          status = "olive",
          width = 4,
          solidHeader = TRUE,
          dateInput(ns("tdm_date_input"), label = translator$t("Date du prélèvement"), format = "yyyy-mm-dd", value = Sys.Date(), language = "fr"),
          timeInput(ns("tdm_time_input"), label = translator$t("Heure du prélèvement"), value = Sys.time(), seconds = FALSE),
          numericInput(ns("concentration_value"), label = translator$t("Concentration"), value = 0),
          fluidRow(
            column(width = 4, actionButton(ns("make_tdm_history"), translator$t("Ajouter donnée TDM"), style = "background-color: #3d9970; color: white;")),
            column(width = 4, actionButton(ns("renal_formula_calculator"), translator$t("Calculateur rénal"), style = "background-color: #3d9970; color: white;"))
          )
        )
      ),
      fluidRow( ## Dataframe output generated in body_tdm_input ----
        box(
          title = tagList(icon("prescription"), translator$t("Données d'administration")),
          width = 12,
          status = "olive",
          solidHeader = TRUE,
          background = "white",
          collapsible = TRUE,
          fluidRow(
            box(
              title = translator$t("Historique des doses"), 
              width = 5,
               status = "gray", 
               collapsible = FALSE, 
               boxToolSize = "md",              
               solidHeader = TRUE, 
               rHandsontableOutput(ns("dosing_history"))
            ),
            box(
              title = translator$t("Historique TDM"),
              width = 3,
              status = "gray",
              collapsible = FALSE,
              boxToolSize = "md",
              solidHeader = TRUE,
              rHandsontableOutput(ns("tdm_history"))
            ),
            box(
              title = translator$t("Historique du poids"),
              width = 4,
              status = "gray",
              collapsible = FALSE,
              boxToolSize = "md",
              solidHeader = TRUE,
              rHandsontableOutput(ns("weight_history"))
            )
          )
        )
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Reactive values for TDM data
    tdm_data <- reactiveValues(
      dosing_history = data.frame(),
      tdm_history = data.frame(),
      weight_history = data.frame()
    )
    
    # TODO: Add server logic for TDM module
  })
}