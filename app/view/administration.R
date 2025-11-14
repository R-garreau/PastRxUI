box::use(
  bs4Dash[actionButton, box],
  dplyr[bind_rows],
  rhandsontable[rHandsontableOutput, rhandsontable, renderRHandsontable, hot_to_r],
  shiny[column, conditionalPanel, dateInput, fluidRow, icon, moduleServer, NS, numericInput, observeEvent, reactiveValues, req, selectInput, tabPanel, tagList, tags, hr, updateSelectInput],
  shinyTime[timeInput],
  shinyWidgets[checkboxGroupButtons, prettyCheckbox],
  stats[setNames],
)

box::use(
  app/logic/utils[date_time_format],
  app/logic/fun_weight_formula[weight_formula],
  app/logic/validators[validate_unique_times],
)

#' @export
ui <- function(id, i18n) {
  ns <- NS(id)

  tabPanel(
    i18n$translate("Administration"),
    fluidRow(
			column(
				width = 4,
				box(
  			  title = tagList(shiny::icon("vials"), i18n$translate("Lab Values")),
  			  status = "info",
  			  width = 12,
  			  solidHeader = TRUE,

  			  # Weight section
  			  fluidRow(
  			    column(width = 3, numericInput(ns("weight"), i18n$translate("Weight"), min = 0, max = 250, step = 1, value = 70)),
  			    column(width = 4, offset = 1, dateInput(ns("weight_date"), i18n$translate("Date"), format = "yyyy-mm-dd", value = Sys.Date(), language = i18n$get_key_translation())),
  			    column(width = 4, timeInput(ns("weight_time"), i18n$translate("Time (hh:mm)"), value = Sys.time(), seconds = FALSE))
  			  ),
  			  fluidRow(
  			    column(width = 3, numericInput(ns("height"), i18n$translate("Height"), min = 0, max = 230, step = 1, value = 170)),
  			    column(width = 4, offset = 1, selectInput(ns("weight_formula_selection"), i18n$translate("Weight Formula"), choices = c("TBW", "IBW", "LBW", "ABW"), selected = "TBW")),
  			    column(width = 3, offset = 1, actionButton(ns("add_weight"), i18n$translate("Add Weight"), style = "margin-top: 30px;", status = "success", width = "100%"))
  			  ),
  			  hr(),

  			  # Renal function section
  			  fluidRow(
  			    column(width = 8, 
  			      fluidRow(
  			        column(width = 6, numericInput(ns("creatinine"), i18n$translate("Creatinine"), min = 0, max = 300, step = 1, value = 60)),
  			        column(width = 6, selectInput(
  			          ns("eGFR"),
  			          label = i18n$translate("Renal Formula"),
  			          choices = c("Cockcroft-Gault" = "CG", "MDRD" = "MDRD", "CKD-EPI" = "CKD-EPI", "UVP" = "UVP"),
  			          selected = "CG"
  			        ))
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
          selectInput(
            ns("administration_route"),
            i18n$translate("Administration Route"),
            choices = c("Intravenous" = "IV", "Intramuscular" = "IM", "Oral" = "PO", "Continuous Infusion" = "CI"),
            selected = "IV"
          ),

          # Continuous infusion panel
          conditionalPanel(
            condition = sprintf("input['%s'] == 'CI'", ns("administration_route")),
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
            condition = sprintf("input['%s'] != 'CI'", ns("administration_route")),
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
            column(width = 4,actionButton(ns("make_dosing_history"), i18n$translate("Add Dosing"), status = "success", style = paste("margin-top: 30px;"), width = "100%")),
            column(width = 4,numericInput(ns("multiple_dose_admin"), i18n$translate("Multiple Doses"), min = 1, max = 50, step = 1, value = 1, width = "100%")),
            column(width = 4,
              conditionalPanel(
                condition = sprintf("input['%s'] > 1", ns("multiple_dose_admin")),
                numericInput(ns("multiple_dose_interval"), i18n$translate("Dose Interval"), min = 0.5, step = 0.5, value = 24, width = "100%")
              )
            )
          )
        )
    	),
    	column( ## Dataframe output generated in body_tdm_input ----
    	  width	= 6, 
    	  rHandsontableOutput(ns("weight_history")),
				rHandsontableOutput(ns("dosing_history"))
			), 
      column(width = 1, 
        box(
          title = tagList(shiny::icon("file-prescription"), "Tool Box"),
          status = "olive",
          width = 12,
          solidHeader = TRUE,
          collapsible = FALSE,
          headerBorder = TRUE,
          background = "white",
          fluidRow(
            shinyWidgets::prettyCheckbox(
              inputId = ns("weight_type_selection"), label = "Use Mod Weight", value = FALSE,
              status = "success", fill = FALSE, outline = TRUE,
              shape = "curve", animation = "jelly"
            ),
            shinyWidgets::prettyCheckbox(
              inputId = ns("bsa_selection"), label = "Use BSA", value = FALSE,
              status = "success", fill = FALSE, outline = TRUE,
              shape = "curve", animation = "jelly"
            ),
            shinyWidgets::prettyCheckbox(
              inputId = ns("african"), label = "Africain", value = FALSE,
              status = "success", fill = FALSE, outline = TRUE,
              shape = "curve", animation = "jelly"
            ),
            shinyWidgets::prettyCheckbox(
              inputId = ns("mg_dl_unit"), label = "creat (mg/dL)", value = FALSE,
              status = "success", fill = FALSE, outline = TRUE,
              shape = "curve", animation = "jelly"
            ),
            shinyWidgets::prettyCheckbox(
              inputId = ns("weight_lbs_unit"), label = "Poids (lbs)", value = FALSE,
              status = "success", fill = FALSE, outline = TRUE,
              shape = "curve", animation = "jelly"
            ),
            shinyWidgets::prettyCheckbox(
              inputId = ns("denorm_ccr"), label = "CRCL denorm", value = FALSE,
              status = "success", fill = FALSE, outline = TRUE,
              shape = "curve", animation = "jelly"
            )
          )
        )
      )
    )
  )
}

#' @export
server <- function(id, i18n = NULL, patient_data = NULL) {
  moduleServer(id, function(input, output, session) {
    

    # Reactive values to store patient information _________________________________________
    patient_info <- reactiveValues(
    dosing_history = data.frame(
      Admin_date = character(),
      Route = character(),
      Infusion_rate = numeric(),
      Infusion_duration = numeric(),
      Dose = numeric(),
      Creatinin_Clearance = numeric(),
      creatinine = numeric()
    ),
    weight_history = data.frame(
      Weight_date = character(),
      Weight_value = numeric(),
      mod_weight_type = character(),
      tbw = numeric(),
      bsa = numeric()
    )
  )


    # Weight history when click on "Add Weight" _______________________________________________
    observeEvent(input$add_weight, {
      req(patient_data)
      p_data <- patient_data()
      
      # calculate the weight and BSA based on the selected formula
    weight_metric <- weight_formula(
      input$weight,
      input$height,
      p_data$sex,
      weight_unit = ifelse(input$weight_lbs_unit, "lbs", "kg"),
      weight_formula = input$weight_formula_selection,
      bsa_formula = "dubois",
      capped = FALSE
    )

    # create output data frame
    new_row_weight <- data.frame(
      Weight_date = date_time_format(input$weight_date, input$weight_time),
      Weight_value = weight_metric$weight,
      mod_weight_type = input$weight_formula_selection,
      tbw = input$weight,
      bsa = weight_metric$bsa
    )
    # increment the data frame by adding a row with the new information provided
    patient_info$weight_history <- bind_rows(patient_info$weight_history, new_row_weight)

    validate_unique_times(patient_info$weight_history$Weight_date, "weight")
    })



    ## Dosing history when click on "Add Dosing" _______________________________________________
    observeEvent(input$make_dosing_history, {
      # Add new dosing entry
      new_dosing <- data.frame(
        Admin_date = paste(as.character(input$date_administration), format(input$administration_time, "%H:%M:%S")),
        Route = input$administration_route,
        Infusion_rate = ifelse(input$administration_route == "CI", input$syringe_speed, NA),
        Infusion_duration = ifelse(input$administration_route != "CI", input$administration_duration, NA),
        Dose = ifelse(input$administration_route != "CI", input$dose_input, input$syringe_dose),
        Creatinin_Clearance = NA,  # Placeholder, calculation can be added
        creatinine = NA  # Placeholder, can be filled with actual value
      )
      patient_info$dosing_history <- rbind(patient_info$dosing_history, new_dosing)

      # Render updated dosing history table
      output$dosing_history <- renderRHandsontable({ rhandsontable(patient_info$dosing_history, rowHeaders = NULL) })
    })

    # Render updated weight history table
      output$weight_history <- renderRHandsontable({ rhandsontable(patient_info$weight_history, rowHeaders = NULL) })



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