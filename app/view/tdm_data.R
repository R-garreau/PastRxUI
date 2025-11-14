box::use(
  bs4Dash[actionButton, box],
  rhandsontable[hot_to_r, rhandsontable, rHandsontableOutput, renderRHandsontable],
  shiny[column, dateInput, div, fluidRow, h4, icon, moduleServer, NS, numericInput, observeEvent, reactive, selectInput, tabPanel, tagList, tags, textInput],
    shinyTime[timeInput],
)

#' @export
ui <- function(id, i18n) {
  ns <- NS(id)
  
  tabPanel(
    i18n$t("Données TDM"),
    fluidRow(
      box( # This section control the data regarding the serum level
      title = tagList(icon("syringe"), i18n$t("Informations TDM")),
        status = "info",
        width = 4,
        solidHeader = TRUE,
        dateInput(ns("tdm_date_input"), label = i18n$t("Date du prélèvement"), format = "yyyy-mm-dd", value = Sys.Date(), language = "fr"),
        timeInput(ns("tdm_time_input"), label = i18n$t("Heure du prélèvement"), value = Sys.time(), seconds = FALSE),
        numericInput(ns("concentration_value"), label = i18n$t("Concentration"), value = 0),
        column(width = 4, actionButton(ns("make_tdm_history"), i18n$t("Ajouter donnée TDM"), style = "background-color: #3d9970; color: white;"))
      ),
      tags$div(
        rHandsontableOutput(ns("tdm_history"))
      )
    )
  )
}

#' @export
server <- function(id, i18n = NULL) {
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
