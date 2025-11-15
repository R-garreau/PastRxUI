box::use(
  bs4Dash[actionButton, box],
  DT[datatable, dataTableOutput, renderDataTable],
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
      column(width = 4, dataTableOutput(ns("tdm_history")))
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
      }
    })

    # Add new TDM entry when button is clicked
    observeEvent(input$make_tdm_history, {
      # Get existing data
      existing_data <- tdm_reactive()

      # Create new entry
      new_entry <- data.frame(
        tdm_time = date_time_format(input$tdm_date_input, input$tdm_time_input),
        concentration = input$concentration_value
      )

      # Combine existing data with new entry
      updated_data <- rbind(existing_data, new_entry)
      tdm_reactive(updated_data)
    })

    # Observer to sync manual edits from tdm_history table
    observeEvent(input$tdm_history_cell_edit, {
      info <- input$tdm_history_cell_edit
      if (!is.null(info)) {
        current_data <- tdm_reactive()
        current_data[info$row, info$col] <- info$value
        tdm_reactive(current_data)
      }
    })

    # Observer to delete tdm_history rows
    observeEvent(input$delete_tdm_row, {
      row_to_delete <- input$delete_tdm_row
      if (!is.null(row_to_delete) && row_to_delete > 0 && row_to_delete <= nrow(tdm_reactive())) {
        current_data <- tdm_reactive()
        tdm_reactive(current_data[-row_to_delete, , drop = FALSE])
      }
    })

    # Render the TDM history table
    output$tdm_history <- renderDataTable({
      if (nrow(tdm_reactive()) > 0) {
        data_with_delete <- tdm_reactive()
        data_with_delete$Delete <- sprintf(
          '<button class="btn btn-danger btn-sm" onclick="Shiny.setInputValue(\'%s\', %d, {priority: \'event\'})"><i class="fa fa-trash"></i></button>',
          session$ns("delete_tdm_row"),
          seq_len(nrow(data_with_delete))
        )
        datatable(
          data_with_delete,
          class = "cell-border stripe",
          editable = list(target = "cell", disable = list(columns = ncol(data_with_delete) - 1)),
          colnames = c("Date", "Concentration", "Delete"),
          rownames = FALSE,
          escape = FALSE,
          options = list(
            pageLength = 10,
            scrollX = TRUE,
            dom = 't',
            columnDefs = list(list(orderable = FALSE, targets = ncol(data_with_delete) - 1))
          )
        )
      } else {
        datatable(
          tdm_reactive(),
          class = "cell-border stripe",
          colnames = c("Date", "Concentration", "Delete"),
          editable = TRUE,
          rownames = FALSE,
          options = list(
            pageLength = 10,
            scrollX = TRUE,
            dom = 't'
          )
        )
      }
    })

    # Return reactive values for use by other modules
    return(reactive({
      tdm_reactive()
    }))
  })
}
