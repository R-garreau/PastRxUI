box::use(
  bs4Dash[box, removePopover],
  shiny[column, dateInput, fluidRow, icon, moduleServer, NS, observeEvent, reactive, renderText, req, selectInput, selectizeInput, tabPanel, tagList, tags, textInput, verbatimTextOutput],
)

box::use(
  app / logic / selectInput_helpers[getDrugs],
  app / logic / fun_write_mb2[write_mb2],
  app / logic / popover[init_popovers, remove_popovers]
)

#' Patient Information Tab UI
#'
#' @param id Module ID
#' @export
ui <- function(id, i18n) {
  ns <- NS(id)

  tabPanel(
    i18n$translate("Patient Information"),
    fluidRow(
      column(
        width = 3,
        box(
          title = tagList(icon("circle-h"), i18n$translate("General Information")),
          status = "info",
          width = 12,
          solidHeader = TRUE,
          collapsible = FALSE,
          fluidRow(
            column(width = 6, textInput(inputId = ns("first_name"), label = i18n$translate("First Name"), width = "100%")),
            column(width = 6, textInput(inputId = ns("last_name"), label = i18n$translate("Last Name"), width = "100%"))
          ),
          fluidRow(
            tags$style(type = "text/css", ".datepicker { z-index: 99999 !important; }"),
            column(width = 6, dateInput(ns("birthdate"), label = i18n$translate("Birth Date"), format = "yyyy-mm-dd", value = Sys.Date(), language = "fr")),
            column(width = 6, selectInput(inputId = ns("sex"), label = i18n$translate("Sex"), choices = c("Male", "Female")))
          ),
          fluidRow(
            column(width = 6, selectizeInput(inputId = ns("hospital"), label = i18n$translate("Hospital"), choices = c("HCL", "CHU"), options = list(create = TRUE))),
            column(width = 6, textInput(inputId = ns("ward"), label = i18n$translate("Ward")))
          ),
          fluidRow(
            column(width = 6, selectizeInput(inputId = ns("drug"), label = i18n$translate("Drug"), choices = getDrugs(), width = "100%"))
          )
        )
      ),
      column(
        width = 9,
        box(
          title = tagList(icon("file-lines"), i18n$translate("MB2 File Preview")),
          status = "info",
          height = "65vh",
          width = 12,
          solidHeader = TRUE,
          collapsible = TRUE,
          tags$div(
            style = "max-height: 60vh; overflow-y: auto; overflow-x: auto;",
            verbatimTextOutput(ns("mb2_preview"))
          )
        )
      )
    )
  )
}

#' Patient Information Tab Server
#'
#' @param id Module ID
#' @export
server <- function(id, i18n = NULL, admin_data = NULL, tdm_data = NULL, weight_type = NULL, help_mode = FALSE) {
  moduleServer(id, function(input, output, session) {
    
    # Watch for help mode changes and add/remove popovers
    observeEvent(help_mode(), {
      req(help_mode())
      if (help_mode()) {
        init_popovers("patient_information", session)
      } else {
        remove_popovers("patient_information", session = session)
      }
    }, ignoreNULL = FALSE)

    # Reactive for MB2 file preview
    output$mb2_preview <- renderText({
      # Only generate preview if we have basic patient data
      if (is.null(input$first_name) || input$first_name == "" || is.null(input$last_name) || input$last_name == "") {
        return("Enter patient information to see MB2 file preview...")
      }

      # Get data from other modules if available
      a_data <- if (!is.null(admin_data)) admin_data() else NULL
      tdm <- if (!is.null(tdm_data)) tdm_data() else NULL
      wt_type <- if (!is.null(weight_type)) weight_type() else "TBW"

      # Prepare default values for missing data
      weight_history <- if (!is.null(a_data) && !is.null(a_data$weight_history)) {
        a_data$weight_history
      } else {
        data.frame(
          Weight_date = character(), Weight_value = numeric(),
          mod_weight_type = character(), tbw = numeric(),
          bsa = numeric(), weight_unit = character()
        )
      }

      dosing_history <- if (!is.null(a_data) && !is.null(a_data$dosing_history)) {
        a_data$dosing_history
      } else {
        data.frame(
          Admin_date = character(), Route = character(),
          Infusion_rate = numeric(), Infusion_duration = numeric(),
          Dose = numeric(), Creatinin_Clearance = numeric(),
          creatinine = numeric(), creat_unit = character()
        )
      }

      tdm_history <- if (!is.null(tdm)) {
        tdm
      } else {
        data.frame(tdm_time = character(), concentration = numeric())
      }

      # Select weight data based on weight type
      if (nrow(weight_history) > 0) {
        if (wt_type == "BSA") {
          selected_weight_data <- weight_history[, c("Weight_date", "bsa")]
          names(selected_weight_data) <- c("Weight_date", "Weight_value")
        } else if (wt_type == "mod_weight") {
          selected_weight_data <- weight_history[, c("Weight_date", "Weight_value")]
        } else {
          selected_weight_data <- weight_history[, c("Weight_date", "tbw")]
          names(selected_weight_data) <- c("Weight_date", "Weight_value")
        }
      } else {
        selected_weight_data <- data.frame(Weight_date = character(), Weight_value = numeric())
      }

      # Get height and dates with defaults
      height_val <- if (!is.null(a_data) && !is.null(a_data$height)) a_data$height else 170
      next_dose_date <- if (!is.null(a_data) && !is.null(a_data$date_next_dose)) {
        a_data$date_next_dose
      } else {
        Sys.Date()
      }
      next_dose_time <- if (!is.null(a_data) && !is.null(a_data$time_next_dose)) {
        a_data$time_next_dose
      } else {
        Sys.time()
      }

      # Generate MB2 content
      tryCatch(
        {
          mb2_content <- write_mb2(
            first_name = input$first_name,
            last_name = input$last_name,
            sex = input$sex,
            hospital = input$hospital,
            ward = input$ward,
            room = "",
            height = height_val,
            birthdate = format(input$birthdate, "%Y/%m/%d"),
            drug_name = input$drug,
            date_next_dose = next_dose_date,
            time_next_dose = next_dose_time,
            weight_number = nrow(selected_weight_data),
            dose_number = nrow(dosing_history),
            concentration_number = nrow(tdm_history),
            weight_data = selected_weight_data,
            administration_data = dosing_history,
            level_data = tdm_history,
            mic_value = 0
          )

          mb2_content
        },
        error = function(e) {
          paste("Error generating preview:", e$message)
        }
      )
    })

    # Return reactive values for use by other modules
    return(reactive({
      list(
        first_name = input$first_name,
        last_name = input$last_name,
        birthdate = input$birthdate,
        sex = input$sex,
        hospital = input$hospital,
        ward = input$ward,
        drug = input$drug,
        phone_number = input$phone_number
      )
    }))
  })
}
