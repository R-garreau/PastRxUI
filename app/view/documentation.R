box::use(
  shiny[includeMarkdown, tabPanel, moduleServer, NS, tags],
  bs4Dash[tabsetPanel],
)

#' Documentation Tab UI
#'
#' @param translator shiny.i18n Translator object
#' @export
ui <- function(id, i18n) {
  ns <- NS(id)

  tabPanel(
    i18n$translate("Documentation"),
    tags$div(
      style = "height: 80vh; overflow-y: auto;",
      tabsetPanel(
        id = ns("documentation_tabs"),
        vertical = TRUE,
        type = "pills",
        tabPanel(
          title = "Functionality",
          tags$div(
            style = "padding: 20px;",
            includeMarkdown("app/documentation/added_functionality.md")
          )
        ),
        tabPanel(
          title = "Options Explanation",
          tags$div(
            style = "padding: 20px;",
            includeMarkdown("app/documentation/options_explanation.md")
          )
        )
      )
    )
  )
}


#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Placeholder for future server logic
  })
}
