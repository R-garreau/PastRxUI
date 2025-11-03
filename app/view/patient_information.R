box::use(
  shiny[column, dateInput, fluidRow, selectInput, selectizeInput, tabPanel, tagList, textInput, tags, icon, NS, moduleServer, reactive],
  bs4Dash[box],
)

#' Patient Information Tab UI
#'
#' @param id Module ID
#' @param translator shiny.i18n Translator object
#' @export
ui <- function(id, translator) {
  ns <- NS(id)
  
  tabPanel(
    translator$t("Informations du patient"),
    fluidRow(
        column(
          width = 3,
          box(
            title = tagList(icon("circle-h"), translator$t("Informations générales")),
            status = "olive",
            width = 12,
            solidHeader = TRUE,
            collapsible = FALSE,
            fluidRow(
              column(width = 6, textInput(inputId = ns("first_name"), label = translator$t("Prénom"), width = "100%")),
              column(width = 6, textInput(inputId = ns("last_name"), label = translator$t("Nom"), width = "100%"))
            ),
            fluidRow(
              tags$style(type = "text/css", ".datepicker { z-index: 99999 !important; }"),
              column(width = 6, dateInput(ns("birthdate"), label = translator$t("Date de naissance"), format = "yyyy-mm-dd", value = Sys.Date(), language = "fr")),
              column(width = 6, selectInput(inputId = ns("sex"), label = translator$t("Sexe"), choices = c(translator$t("Masculin"), translator$t("Féminin"))))
            ),
            fluidRow(
              column(width = 6, selectizeInput(inputId = ns("hospital"), label = translator$t("Hôpital"), choices = c("HCL", "CHU"), options = list(create = TRUE))),
              column(width = 6, textInput(inputId = ns("ward"), label = translator$t("Service")))
            ),
            fluidRow(
              column(width = 6, selectInput(inputId = ns("drug"), label = translator$t("Médicament"), choices = c("Amikacin", "Vancomycin", "Gentamicin"), width = "100%")),
              column(width = 6, textInput(inputId = ns("phone_number"), label = translator$t("Numéro de téléphone")))
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
server <- function(id) {
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