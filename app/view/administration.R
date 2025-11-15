box::use(
  bs4Dash[actionButton, box],
  dplyr[arrange, bind_rows, case_when],
  DT[datatable, dataTableOutput, renderDataTable],
  shiny[br, column, conditionalPanel, dateInput, div, fluidRow, icon, moduleServer, NS, numericInput, observeEvent, reactive, reactiveValues, req, selectInput, tabPanel, tagList, hr, uiOutput],
  shinyTime[timeInput],
  shinyWidgets[dropdownButton, prettyCheckbox],
)

box::use(
  app / logic / utils[calc_age, date_time_format],
  app / logic / fun_weight_formula[weight_formula],
  app / logic / validators[validate_unique_times],
  app / logic / fun_renal_function[renal_function],
  app / logic / fun_calculate_inf_speed[continuous_infusion_time, calculate_daily_dose],
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
          title = tagList(shiny::icon("vials"), i18n$translate("Covariates")),
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
            column(
              width = 8,
              fluidRow(
                column(width = 6, numericInput(ns("creatinine"), i18n$translate("Creatinine"), min = 0, max = 300, step = 1, value = 60)),
                column(width = 6, selectInput(
                  ns("eGFR"),
                  label = i18n$translate("Renal Formula"),
                  choices = c("Cockcroft-Gault" = "CG", "MDRD" = "MDRD", "CKD-EPI (2009)" = "CKD_2009", "CKD-EPI (2021)" = "CKD_2021", "Schwartz" = "schwartz", "UVP" = "UVP", "None" = "none"),
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
              column(width = 6, dateInput(ns("start_date_CI"), i18n$translate("Infusion Start Date"), Sys.Date(), format = "yyyy-mm-dd", language = i18n$get_key_translation())),
              column(width = 6, timeInput(ns("start_time_CI"), i18n$translate("Infusion Start Time"), seconds = FALSE))
            ),
            fluidRow(
              column(width = 6, dateInput(ns("end_date_CI"), i18n$translate("Infusion End Date"), Sys.Date(), format = "yyyy-mm-dd", language = i18n$get_key_translation())),
              column(width = 6, timeInput(ns("end_time_CI"), i18n$translate("Infusion End Time"), seconds = FALSE))
            ),
            fluidRow(
              column(width = 6, numericInput(ns("syringe_volume"), i18n$translate("Syringe Volume"), value = 50)),
              column(width = 6, numericInput(ns("syringe_dose"), i18n$translate("Syringe Dose"), value = 2000))
            ),
            numericInput(ns("syringe_speed"), i18n$translate("Infusion Speed"), value = 2)
          ),

          # Regular administration panel
          conditionalPanel(
            condition = sprintf("input['%s'] != 'CI'", ns("administration_route")),
            fluidRow(
              column(width = 6, dateInput(ns("date_administration"), i18n$translate("Administration Date"), Sys.Date(), format = "yyyy-mm-dd", language = i18n$get_key_translation())),
              column(width = 6, timeInput(ns("administration_time"), label = i18n$translate("Administration Time"), value = Sys.time(), seconds = FALSE))
            ),
            fluidRow(
              column(width = 6, numericInput(ns("dose_input"), label = i18n$translate("Dose"), value = 0)),
              column(
                width = 6,
                conditionalPanel(
                  condition = sprintf("input['%s'] == 'IV'", ns("administration_route")),
                  numericInput(ns("administration_duration"), label = i18n$translate("Administration Duration"), value = 0.5, step = 0.1)
                )
              ) # ,
              # column(width = 6, numericInput(ns("administration_duration"), label = i18n$translate("Administration Duration"), value = 0.5, step = 0.1))
            )
          ),

          # Multiple dose controls
          fluidRow(
            column(width = 4, numericInput(ns("multiple_dose_admin"), i18n$translate("Multiple Doses"), min = 1, max = 50, step = 1, value = 1, width = "100%")),
            column(
              width = 4,
              conditionalPanel(
                condition = sprintf("input['%s'] > 1", ns("multiple_dose_admin")),
                numericInput(ns("multiple_dose_interval"), i18n$translate("Dose Interval"), min = 0.5, step = 0.5, value = 24, width = "100%")
              )
            ),
            column(width = 4, actionButton(ns("make_dosing_history"), i18n$translate("Add Dosing"), status = "success", style = paste("margin-top: 30px;"), width = "100%"))
          )
        ),
        box(
          title = tagList(shiny::icon("info"), i18n$translate("Additional Settings")),
          status = "info",
          width = 12,
          solidHeader = TRUE,
          fluidRow(
            column(width = 4, dateInput(ns("date"), label = i18n$translate("Next Dose Date"), format = "yyyy-mm-dd", value = Sys.Date(), language = i18n$get_key_translation())),
            column(width = 4, timeInput(ns("time"), label = i18n$translate("Next Dose Time"), seconds = FALSE, value = Sys.time())),
            column(
              width = 3,
              offset = 1,
              dropdownButton(
                label = i18n$translate("Renal Calculator"),
                status = "info",
                size = "sm",
                circle = FALSE,
                icon = icon("calculator"),
                width = "300px",
                fluidRow(
                  column(
                    width = 8,
                    numericInput(ns("weight_calculator"), i18n$translate("Weight for Renal Calc."), value = 70),
                    numericInput(ns("creatinine_calculator"), i18n$translate("Creatinine for Renal Calc."), value = 60)
                  ),
                  column(
                    width = 4,
                    uiOutput(ns("renal_calc_output"))
                  )
                )
              ),

              # options
              dropdownButton(
                label = i18n$translate("options"),
                status = "info",
                size = "sm",
                circle = FALSE,
                icon = icon("gear"),
                width = "300px",
                column(
                  width = 12,
                  prettyCheckbox(inputId = ns("african"), label = "Africain", value = FALSE, status = "success", fill = FALSE, outline = TRUE, shape = "curve", animation = "jelly"),
                  prettyCheckbox(inputId = ns("mg_dl_unit"), label = "creat (mg/dL)", value = FALSE, status = "success", fill = FALSE, outline = TRUE, shape = "curve", animation = "jelly"),
                  prettyCheckbox(inputId = ns("weight_lbs_unit"), label = "Poids (lbs)", value = FALSE, status = "success", fill = FALSE, outline = TRUE, shape = "curve", animation = "jelly"),
                  prettyCheckbox(inputId = ns("denorm_ccr"), label = "CRCL denorm", value = FALSE, status = "success", fill = FALSE, outline = TRUE, shape = "curve", animation = "jelly")
                )
              )
            )
          )
        )
      ),
      column( ## Dataframe output generated in body_tdm_input ----
        width = 8,
        column(width = 12, div(style = "height: 20vh; overflow-y: auto; overflow-x: auto;", dataTableOutput(ns("weight_history")))),
        br(),
        column(width = 12, div(style = "height: 60vh; overflow-y: auto; overflow-x: auto;", dataTableOutput(ns("dosing_history"))))
      )
    )
  )
}

#' @export
server <- function(id, i18n = NULL, patient_data = NULL, loaded_data = NULL) {
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
        creatinine = numeric(),
        creat_unit = character()
      ),
      weight_history = data.frame(
        Weight_date = character(),
        Weight_value = numeric(),
        mod_weight_type = character(),
        tbw = numeric(),
        bsa = numeric(),
        weight_unit = character()
      )
    )

    # Load data when loaded_data changes
    observeEvent(loaded_data(), {
      req(loaded_data())
      data <- loaded_data()

      if (!is.null(data$weight_df) && nrow(data$weight_df) > 0) {
        patient_info$weight_history <- data$weight_df
      }

      if (!is.null(data$dose_df) && nrow(data$dose_df) > 0) {
        patient_info$dosing_history <- data$dose_df
      }
    })


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
        bsa = weight_metric$bsa,
        weight_unit = ifelse(input$weight_lbs_unit, "lbs", "kg")
      )
      # increment the data frame by adding a row with the new information provided
      patient_info$weight_history <- bind_rows(patient_info$weight_history, new_row_weight)

      validate_unique_times(patient_info$weight_history$Weight_date, "weight")
    })


    ## Dosing history when click on "Add Dosing" _______________________________________________
    observeEvent(input$make_dosing_history, {
      req(patient_data)
      p_data <- patient_data()

      # Step 1 : retrieve weight
      weight_metric <- weight_formula(
        input$weight,
        input$height,
        p_data$sex,
        weight_unit = ifelse(input$weight_lbs_unit, "lbs", "kg"),
        weight_formula = input$weight_formula_selection,
        bsa_formula = "dubois",
        capped = FALSE
      )

      # step 2 : calculate creatinine clearance
      renal_clearance <- renal_function(
        sex = p_data$sex,
        age = calc_age(p_data$birthdate),
        weight = weight_metric$weight,
        height = input$height,
        creat = input$creatinine,
        ethnicity = ifelse(input$african, "African", "Other"),
        formula = input$eGFR,
        creat_unit = ifelse(input$mg_dl_unit, "mg/dL", "uM/L"),
        urine_creat = input$urine_creatinine,
        urine_output = input$urine_output
      )

      # Step 3 : Caclulation infusion parameters if CI

      # Electric infusion pump parameters
      cont_infusion_dur <- continuous_infusion_time(
        input$start_date_CI,
        input$start_time_CI,
        input$end_date_CI,
        input$end_time_CI
      )

      daily_dose <- calculate_daily_dose(
        sp_dose = input$syringe_dose,
        sp_volume = input$syringe_volume,
        sp_speed = input$syringe_speed,
        start_date = input$start_date_CI,
        start_time = input$start_time_CI,
        end_date = input$end_date_CI,
        end_time = input$end_time_CI
      )

      # Infusion rate calculation basded on route
      infusion_rate <- case_when(
        input$administration_route == "CI" ~ round(daily_dose / cont_infusion_dur, digits = 8),
        input$administration_route == "IV" ~ round(input$dose_input / max(input$administration_duration, 0.001), digits = 8),
        TRUE ~ 0
      )

      # calculate infusion duration based on route
      infusion_duration <- case_when(
        input$administration_route == "CI" ~ cont_infusion_dur,
        input$administration_route == "IV" ~ input$administration_duration,
        TRUE ~ 0
      )
      # Handle multiple doses
      num_doses <- max(1, input$multiple_dose_admin)
      interval_hours <- if (num_doses > 1) input$multiple_dose_interval else 0

      # Create multiple dose entries if needed
      for (dose_idx in 0:(num_doses - 1)) {
        # Calculate time offset for this dose
        time_offset_hours <- dose_idx * interval_hours

        # Adjust administration time based on offset
        if (input$administration_route == "CI") {
          admin_datetime <- as.POSIXct(paste(input$start_date_CI, format(input$start_time_CI, "%H:%M:%S")))
        } else {
          admin_datetime <- as.POSIXct(paste(input$date_administration, format(input$administration_time, "%H:%M:%S")))
        }

        # Add offset
        admin_datetime <- admin_datetime + (time_offset_hours * 3600)

        new_dosing <- data.frame(
          Admin_date = format(admin_datetime, "%Y/%m/%d %H:%M:%S"),
          Route = ifelse(input$administration_route == "CI", "IV", input$administration_route),
          Infusion_rate = infusion_rate,
          Infusion_duration = infusion_duration,
          Dose = ifelse(input$administration_route == "CI", daily_dose, input$dose_input),
          Creatinin_Clearance = ifelse("denorm_ccr" %in% input$unit_value, renal_clearance * weight_metric$bsa, renal_clearance),
          creatinine = input$creatinine,
          creat_unit = ifelse(input$mg_dl_unit, "mg/dL", "µM")
        )

        patient_info$dosing_history <- bind_rows(patient_info$dosing_history, new_dosing)
      }

      # Sort by date after adding
      patient_info$dosing_history <- arrange(patient_info$dosing_history, Admin_date)
    })

    # Observer to sync manual edits from dosing_history table
    observeEvent(input$dosing_history_cell_edit, {
      info <- input$dosing_history_cell_edit
      if (!is.null(info)) {
        patient_info$dosing_history[info$row, info$col] <- info$value
        # Sort by date/time
        patient_info$dosing_history <- arrange(patient_info$dosing_history, Admin_date)
      }
    })

    # Observer to delete dosing_history rows
    observeEvent(input$delete_dosing_row, {
      row_to_delete <- input$delete_dosing_row
      if (!is.null(row_to_delete) && row_to_delete > 0 && row_to_delete <= nrow(patient_info$dosing_history)) {
        patient_info$dosing_history <- patient_info$dosing_history[-row_to_delete, , drop = FALSE]
      }
    })

    # Observer to sync manual edits from weight_history table
    observeEvent(input$weight_history_cell_edit, {
      info <- input$weight_history_cell_edit
      if (!is.null(info)) {
        patient_info$weight_history[info$row, info$col] <- info$value
        # Sort by date/time
        patient_info$weight_history <- arrange(patient_info$weight_history, Weight_date)
      }
    })

    # Observer to delete weight_history rows
    observeEvent(input$delete_weight_row, {
      row_to_delete <- input$delete_weight_row
      if (!is.null(row_to_delete) && row_to_delete > 0 && row_to_delete <= nrow(patient_info$weight_history)) {
        patient_info$weight_history <- patient_info$weight_history[-row_to_delete, , drop = FALSE]
      }
    })

    # Render updated dosing history table
    output$dosing_history <- renderDataTable({
      if (nrow(patient_info$dosing_history) > 0) {
        data_with_delete <- patient_info$dosing_history
        data_with_delete$Delete <- sprintf(
          '<button class="btn btn-danger btn-sm" onclick="Shiny.setInputValue(\'%s\', %d, {priority: \'event\'})"><i class="fa fa-trash"></i></button>',
          session$ns("delete_dosing_row"),
          seq_len(nrow(data_with_delete))
        )
        datatable(
          data_with_delete,
          class = "cell-border stripe",
          editable = list(target = "cell", disable = list(columns = ncol(data_with_delete) - 1)),
          colnames = c("Date", "Route", "Infusion Rate", "Infusion Duration", "Dose", "Creatinine Clearance", "Creatinine", "Creatinine Unit", "Delete"),
          rownames = FALSE,
          escape = FALSE,
          options = list(
            pageLength = 20,
            scrollX = TRUE,
            scrollY = "50vh",
            dom = "t",
            columnDefs = list(list(orderable = FALSE, targets = ncol(data_with_delete) - 1))
          )
        )
      } else {
        datatable(
          patient_info$dosing_history,
					class = "cell-border stripe",
					colnames = c("Date", "Route", "Infusion Rate", "Infusion Duration", "Dose", "Creatinine Clearance", "Creatinine", "Creatinine Unit", "Delete"),
          editable = TRUE,
          rownames = FALSE,
          options = list(
            pageLength = 20,
            scrollX = TRUE,
            scrollY = "50vh",
            dom = "t"
          )
        )
      }
    })
    # Render updated weight history table
    output$weight_history <- renderDataTable({
      if (nrow(patient_info$weight_history) > 0) {
        data_with_delete <- patient_info$weight_history
        data_with_delete$Delete <- sprintf(
          '<button class="btn btn-danger btn-sm" onclick="Shiny.setInputValue(\'%s\', %d, {priority: \'event\'})"><i class="fa fa-trash"></i></button>',
          session$ns("delete_weight_row"),
          seq_len(nrow(data_with_delete))
        )
        datatable(
          data_with_delete,
          class = "cell-border stripe",
          editable = list(target = "cell", disable = list(columns = ncol(data_with_delete) - 1)),
          colnames = c("Date", "Weight Value", "Weight Used", "Total Weight", "BSA (m²)", "Unit", "Delete"),
          rownames = FALSE,
          escape = FALSE,
          options = list(
            pageLength = 20,
            scrollX = TRUE,
            scrollY = "15vh",
            dom = "t",
            columnDefs = list(list(orderable = FALSE, targets = ncol(data_with_delete) - 1))
          )
        )
      } else {
        datatable(
          patient_info$weight_history,
					class = "cell-border stripe",
					colnames = c("Date", "Weight Value", "Weight Used", "Total Weight", "BSA (m²)", "Unit", "Delete"),
          editable = TRUE,
          rownames = FALSE,
          options = list(
            pageLength = 20,
            scrollX = TRUE,
            scrollY = "15vh",
            dom = "t"
          )
        )
      }
    })

    # Return reactive containing all administration data needed by main module
    return(reactive({
      list(
        dosing_history = patient_info$dosing_history,
        weight_history = patient_info$weight_history,
        bsa_selection = input$bsa_selection,
        weight_type_selection = input$weight_type_selection,
        height = input$height,
        date_next_dose = input$date,
        time_next_dose = input$time,
        # Settings for JSON export
        african = input$african,
        mg_dl_unit = input$mg_dl_unit,
        weight_lbs_unit = input$weight_lbs_unit,
        denorm_ccr = input$denorm_ccr
      )
    }))
  })
}
