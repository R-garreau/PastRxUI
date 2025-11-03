box::use(
  bs4Dash[actionButton, box],
  shiny[column, dateInput, div, fluidRow, h4, numericInput, selectInput, tabPanel, tagList, tags, textInput, icon, NS, moduleServer, reactive, observeEvent],
  shinyTime[timeInput],
  rhandsontable[rHandsontableOutput, renderRHandsontable, hot_to_r, rhandsontable],
)

#' @export
ui <- function(id, translator) {
  ns <- NS(id)
  
  tabPanel(
    translator$t("Administration"),
    fluidRow(
      box( # This section control the data regarding the serum level
      title = tagList(icon("syringe"), translator$t("Informations TDM")),
        status = "olive",
        width = 4,
        solidHeader = TRUE,
        dateInput(ns("tdm_date_input"), label = translator$t("Date du prélèvement"), format = "yyyy-mm-dd", value = Sys.Date(), language = "fr"),
        timeInput(ns("tdm_time_input"), label = translator$t("Heure du prélèvement"), value = Sys.time(), seconds = FALSE),
        numericInput(ns("concentration_value"), label = translator$t("Concentration"), value = 0),
        column(width = 4, actionButton(ns("make_tdm_history"), translator$t("Ajouter donnée TDM"), style = "background-color: #3d9970; color: white;"))
      ),
      tags$div(
        rHandsontableOutput(ns("tdm_history"))
      )
    )
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Initialize empty administration table
    # output$administration_table <- renderRHandsontable({
    #   df <- data.frame(
    #     Date = character(0),
    #     Time = character(0),
    #     Dose = numeric(0),
    #     Route = character(0),
    #     Duration = numeric(0),
    #     stringsAsFactors = FALSE
    #   )
    #   rhandsontable(df, rowHeaders = NULL) 
    # })
    
    # # Return reactive values for use by other modules
    # return(reactive({
    #   list(
    #     weight = input$weight,
    #     height = input$height,
    #     creatinine = input$creatinine,
    #     renal_formula = input$renal_formula,
    #     albumin = input$albumin,
    #     bilirubin = input$bilirubin,
    #     infusion_site = input$infusion_site,
    #     drug_form = input$drug_form,
    #     concentration = input$concentration,
    #     start_date = input$start_date,
    #     start_time = input$start_time,
    #     administration_data = if (!is.null(input$administration_table)) {
    #       hot_to_r(input$administration_table)
    #     } else {
    #       data.frame()
    #     }
    #   )
    # }))
  })
}
