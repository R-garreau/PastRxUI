box::use(
  bs4Dash[box],
  shiny[column, dateInput, fluidRow, icon, moduleServer, NS, observeEvent, reactive, reactiveValues, selectInput, selectizeInput, tabPanel, tagList, tags, textInput, updateSelectInput],
  stats[setNames],
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
              column(width = 6, selectInput(inputId = ns("drug"), label = i18n$translate("Drug"), choices = c("Amikacin", "Vancomycin", "Gentamicin"), width = "100%")),
              column(width = 6, textInput(inputId = ns("phone_number"), label = i18n$translate("Phone Number")))
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
server <- function(id, i18n = NULL) {
  moduleServer(id, function(input, output, session) {
    
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