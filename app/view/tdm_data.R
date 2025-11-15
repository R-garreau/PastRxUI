box::use(
  bs4Dash[actionButton, box],
  rhandsontable[hot_to_r, rhandsontable, rHandsontableOutput, renderRHandsontable],
  shiny[column, dateInput, div, fluidRow, icon, moduleServer, NS, numericInput, observeEvent, reactive, reactiveVal, req, tabPanel, tagList, tags],
  shinyTime[timeInput],
)

box::use(
  app / logic / utils[date_time_format],
)

#' @export
ui <- function(id, i18n) {
  ns <- NS(id)

  tabPanel(
    i18n$translate("TDM Data"),
    fluidRow(
      box( # This section control the data regarding the serum level
        title = tagList(icon("syringe"), i18n$translate("TDM Information")),
        status = "info",
        width = 4,
        solidHeader = TRUE,
        dateInput(ns("tdm_date_input"), label = i18n$translate("TDM Date"), format = "yyyy-mm-dd", value = Sys.Date(), language = "fr"),
        timeInput(ns("tdm_time_input"), label = i18n$translate("TDM Time"), value = Sys.time(), seconds = FALSE),
        numericInput(ns("concentration_value"), label = i18n$translate("Concentration Value"), value = 0),
        column(width = 4, actionButton(ns("make_tdm_history"), i18n$translate("Add TDM Data"), style = "background-color: #3d9970; color: white;"))
      ),
      tags$div(
        rHandsontableOutput(ns("tdm_history"))
      )
    )
  )
}

#' @export
server <- function(id, i18n = NULL, loaded_data = NULL) {
  moduleServer(id, function(input, output, session) {
    # Reactive value to store TDM history
    tdm_reactive <- reactiveVal(data.frame(
      tdm_time = character(),
      concentration = numeric()
    ))

    # Load data when loaded_data changes
    observeEvent(loaded_data(), {
      req(loaded_data())
      data <- loaded_data()

      if (!is.null(data$level_df) && nrow(data$level_df) > 0) {
        tdm_reactive(data$level_df)
        output$tdm_history <- renderRHandsontable({
          rhandsontable(data$level_df, rowHeaders = NULL)
        })
      }
    })

    observeEvent(input$make_tdm_history, {
      # Get existing data from the table
      existing_data <- if (!is.null(input$tdm_history)) {
        hot_to_r(input$tdm_history)
      }

      # Create new entry
      new_entry <- data.frame(
        tdm_time = date_time_format(input$tdm_date_input, input$tdm_time_input),
        concentration = input$concentration_value
      )

      # Combine existing data with new entry
      updated_data <- rbind(existing_data, new_entry)

    })

    # Render the updated table
    output$tdm_history <- renderRHandsontable({ rhandsontable(updated_data, rowHeaders = NULL) })

    # Initialize empty administration table
    output$administration_table <- renderRHandsontable({
      tdm_history <- data.frame(
        tdm_time = character(),
        concentration = numeric()
      )
      rhandsontable(tdm_history, rowHeaders = NULL)
    })

    # Return reactive values for use by other modules
    return(reactive({
      if (!is.null(input$tdm_history)) {
        hot_to_r(input$tdm_history)
      } else {
        data.frame(
          tdm_time = character(),
          concentration = numeric()
        )
      }
    }))
  })
}
