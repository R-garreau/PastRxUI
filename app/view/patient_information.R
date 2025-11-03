box::use(
  shiny[column, dateInput, fluidPage, fluidRow, selectInput, selectizeInput, 
        tagList, textInput, tags, icon],
  bs4Dash[tabItem, box],
)

#' Patient Information Tab UI
#'
#' @param translator shiny.i18n Translator object
#' @export
patient_information_ui <- function(translator) {
  tabItem(
    tabName = "information",
    fluidPage(
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
              column(width = 6, textInput(inputId = "first_name", label = translator$t("Prénom"), width = "100%")),
              column(width = 6, textInput(inputId = "last_name", label = translator$t("Nom"), width = "100%"))
            ),
            fluidRow(
              tags$style(type = "text/css", ".datepicker { z-index: 99999 !important; }"),
              column(width = 6, dateInput("birthdate", label = translator$t("Date de naissance"), 
                                         format = "yyyy-mm-dd", value = Sys.Date(), language = "fr")),
              column(width = 6, selectInput(inputId = "sex", label = translator$t("Sexe"), 
                                           choices = c(translator$t("Masculin"), translator$t("Féminin"))))
            ),
            fluidRow(
              column(width = 6, selectizeInput(inputId = "hospital", label = translator$t("Hôpital"), 
                                              choices = c("HCL", "CHU"), options = list(create = TRUE))),
              column(width = 6, textInput(inputId = "ward", label = translator$t("Service")))
            ),
            fluidRow(
              column(width = 6, selectInput(inputId = "drug", label = translator$t("Médicament"), 
                                           choices = c("Amikacin", "Vancomycin", "Gentamicin"), width = "100%")),
              column(width = 6, textInput(inputId = "phone_number", label = translator$t("Numéro de téléphone")))
            )
          )
        )
      )
    )
  )
}