box::use(
  bs4Dash[actionButton, box],
  rhandsontable[rHandsontableOutput],
  shiny[column, conditionalPanel, dateInput, fluidRow, icon, moduleServer, NS, numericInput, reactiveValues, selectInput, tabPanel, tagList, tags, hr],
  shinyTime[timeInput],
  shinyWidgets[checkboxGroupButtons],
)

#' @export
ui <- function(id, i18n) {
  ns <- NS(id)

  tabPanel(
    i18n$translate("Administration"),
    fluidRow(
			column(
				width = 5,
				box(
  			  title = tagList(shiny::icon("vials"), i18n$translate("Lab Values")),
  			  status = "info",
  			  width = 12,
  			  solidHeader = TRUE,

  			  # Weight section
  			  fluidRow(
  			    column(width = 3, numericInput(ns("weight"), i18n$translate("Weight"), min = 0, max = 250, step = 1, value = 70)),
  			    column(width = 4, offset = 1, dateInput(ns("weight_date"), "Date", format = "yyyy-mm-dd", value = Sys.Date(), language = i18n$get_key_translation())),
  			    column(width = 4, timeInput(ns("weight_time"), "Time (hh:mm)", value = Sys.time(), seconds = FALSE))
  			  ),
  			  fluidRow(
  			    column(width = 3, numericInput(ns("height"), i18n$translate("Height"), min = 0, max = 230, step = 1, value = 170)),
  			    column(width = 4, offset = 1, selectInput(ns("weight_formula_selection"), i18n$translate("Weight Formula"), choices = c("TBW", "IBW", "LBW", "ABW"), selected = "TBW")),
  			    column(width = 3, offset = 1, actionButton(ns("add_weight"), "Add Weight", style = paste("margin-top: 30px;"), width = "100%"))
  			  ),
  			  hr(),

  			  # Renal function section
  			  fluidRow(
  			    column(width = 8, 
  			      fluidRow(
  			        column(width = 6, numericInput(ns("creatinine"), i18n$translate("Creatinine"), min = 0, max = 300, step = 1, value = 60)),
  			        column(width = 6, selectInput(ns("eGFR"), label = i18n$translate("Renal Formula"), choices = c("CG", "MDRD", "CKD-EPI", "UVP"), selected = "CG"))
  			      ),
  			      conditionalPanel(
  			        condition = "input.eGFR == 'UVP' ",
  			        fluidRow(
  			          column(width = 6, numericInput(ns("urine_creatinine"), i18n$translate("Urinary Creatinine"), value = 0)),
  			          column(width = 6, numericInput(ns("urine_output"), i18n$translate("Urinary Output"), value = 0))
  			        )
  			      )
  			    ),
  			    column(width = 3, 
  			      offset = 1,
  			      actionButton(ns("renal_formula_calculator"), i18n$translate("Renal Calculator"), icon = icon("calculator"))
  			    )
  			  )
  			),
				  box(
    title = tagList(shiny::icon("pills"), i18n$translate("Drug Administration")),
    status = "info",
    width = 12,
    solidHeader = TRUE,
    selectInput(ns("administration_route"), i18n$translate("Administration Route"), choices = c("IV", "IM", "PO", "CI"), selected = "IV"),

    # Continuous infusion panel
    conditionalPanel(
      condition = "input.administration_route == 'CI' ",
      fluidRow(
        column(width = 6,dateInput(ns("start_date_CI"), i18n$translate("Infusion Start Date"), Sys.Date(), format = "yyyy-mm-dd", language = i18n$get_key_translation())),
        column(width = 6,timeInput(ns("start_time_CI"), i18n$translate("Infusion Start Time"), seconds = FALSE))
      ),
      fluidRow(
        column(width = 6,dateInput(ns("end_date_CI"), i18n$translate("Infusion End Date"), Sys.Date(), format = "yyyy-mm-dd", language = i18n$get_key_translation())),
        column(width = 6,timeInput(ns("end_time_CI"), i18n$translate("Infusion End Time"), seconds = FALSE))
      ),
      fluidRow(
        column(width = 6,numericInput(ns("syringe_volume"), i18n$translate("Syringe Volume"), value = 50)),
        column(width = 6,numericInput(ns("syringe_dose"), i18n$translate("Syringe Dose"), value = 2000))
      ),
      numericInput(ns("syringe_speed"), i18n$translate("Infusion Speed"), value = 2)
    ),

    # Regular administration panel
    conditionalPanel(
      condition = "input.administration_route != 'CI'",
      fluidRow(
        column(width = 6,dateInput(ns("date_administration"), i18n$translate("Administration Date"), Sys.Date(), format = "yyyy-mm-dd", language = i18n$get_key_translation())),
        column(width = 6,timeInput(ns("administration_time"), label = i18n$translate("Administration Time"), value = Sys.time(), seconds = FALSE))
      ),
      fluidRow(
        column(width = 6,numericInput(ns("dose_input"), label = i18n$translate("Dose"), value = 0)),
        column(width = 6,numericInput(ns("administration_duration"), label = i18n$translate("Administration Duration"), value = 0.5, step = 0.1))
      )
    ),

    # Next dose section
    fluidRow(
      column(width = 6,dateInput(ns("date"), label = i18n$translate("Next Dose Date"), format = "yyyy-mm-dd", value = Sys.Date(), language = i18n$get_key_translation())),
      column(width = 6,timeInput(ns("time"), label = i18n$translate("Next Dose Time"), seconds = FALSE, value = Sys.time()))
    ),

    # Multiple dose controls
    fluidRow(
      column(width = 4,actionButton(ns("make_dosing_history"), i18n$translate("Add Dosing"), style = paste("margin-top: 30px;"), width = "100%")),
      column(width = 4,numericInput(ns("multiple_dose_admin"), i18n$translate("Multiple Doses"), min = 1, max = 50, step = 1, value = 1, width = "100%")),
      column(width = 4,
        conditionalPanel(
          condition = "input.multiple_dose_admin > 1",
          numericInput(ns("multiple_dose_interval"), i18n$translate("Dose Interval"), min = 0.5, step = 0.5, value = 24, width = "100%")
        )
      )
    )
  )
      	# box( # This section handle all administration related data
      	#   title = tagList(icon("pills"), i18n$translate("Administration du médicament")),
      	#   status = "info",
      	#   width = 12,
      	#   solidHeader = TRUE,
      	#   selectInput(ns("administration_route"), i18n$translate("Voie d'administration"), choices = c("IV", "IM", "PO", "CI"), selected = "IV"),
      	#   conditionalPanel(
      	#     condition = sprintf("input['%s'] == 'CI'", ns("administration_route")),
      	#     fluidRow(
      	#       column(width = 6, dateInput(ns(ns("start_date_CI"), i18n$translate("Date de début de perfusion"), Sys.Date(), format = "yyyy-mm-dd", language = "fr")),
      	#       column(width = 6, timeInput(ns("start_time_CI"), i18n$translate("Heure de début"), seconds = FALSE))
      	#     ),
      	#     fluidRow(
      	#       column(width = 6, dateInput(ns(ns("end_date_CI"), i18n$translate("Date de fin de perfusion"), Sys.Date(), format = "yyyy-mm-dd", language = "fr")),
      	#       column(width = 6, timeInput(ns("end_time_CI"), i18n$translate("Heure de fin de perfusion"), seconds = FALSE))
      	#     ),
      	#     fluidRow(
      	#       column(width = 6, numericInput(ns("syringe_volume"), i18n$translate("Volume de la seringue"), value = 50)),
      	#       column(width = 6, numericInput(ns("syringe_dose"), i18n$translate("Dose de la seringue"), value = 2000))
      	#     ),
      	#     numericInput(ns("syringe_speed"), i18n$translate("Vitesse de perfusion"), value = 2)
      	#   ),
      	#   conditionalPanel(
      	#     condition = sprintf("input['%s'] != 'CI'", ns("administration_route")),
      	#     fluidRow(
      	#       column(width = 6, dateInput(ns(ns("date_administration"), i18n$translate("Date d'administration"), Sys.Date(), format = "yyyy-mm-dd", language = "fr")),
      	#       column(width = 6, timeInput(ns("administration_time"), label = i18n$translate("Heure d'administration"), value = Sys.time(), seconds = FALSE))
      	#     ),
      	#     fluidRow(
      	#       column(width = 6, numericInput(ns("dose_input"), label = i18n$translate("Dose"), value = 0)),
      	#       column(width = 6, numericInput(ns("administration_duration"), label = i18n$translate("Durée d'administration"), value = 0.5, step = 0.1))
      	#     )
      	#   ),
      	#   fluidRow(
      	#     column(width = 6, dateInput(ns(ns("date"), label = i18n$translate("Date de la prochaine dose"), format = "yyyy-mm-dd", value = Sys.Date(), language = "fr")),
      	#     column(width = 6, timeInput(ns("time"), label = i18n$translate("Heure de la prochaine dose"), seconds = FALSE, value = Sys.time()))
      	#   ),
      	#   fluidRow(
      	#     column(width = 4, actionButton(ns("make_dosing_history"), i18n$translate("Ajouter dose"), style = "background-color: #3d9970; color: white; margin-top: 30px;", width = "100%")),
      	#     column(width = 4, numericInput(ns("multiple_dose_admin"), i18n$translate("Doses multiples"), min = 1, max = 50, step = 1, value = 1, width = "100%")),
      	#     column(width = 4, numericInput(ns("multiple_dose_interval"), i18n$translate("Intervalle entre doses"), min = 0.5, step = 0.5, value = 24, width = "100%"))
      	#   )
      	# )
    	),
    	column( ## Dataframe output generated in body_tdm_input ----
    	  width	= 6, 
    	  rHandsontableOutput(ns("weight_history")),
				rHandsontableOutput(ns("dosing_history"))
			)
    )
  )
}

#' @export
server <- function(id, i18n = NULL) {
  moduleServer(id, function(input, output, session) {
    # # Reactive values for TDM data
    # data <- reactiveValues(
    #   dosing_history = data.frame(),
    #   weight_history = data.frame()
    # )
    
    # # TODO: Add server logic for TDM module
    
    # # Return reactive values for use by other modules
    # return(reactive({
    #   list(
    #     dosing_history = data$dosing_history,
    #     weight_history = data$weight_history
    #   )
    # }))
  })
}