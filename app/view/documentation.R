box::use(
  shiny[includeMarkdown, NS, tags, tabPanel, moduleServer],
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
    tabsetPanel(
      id = ns("documentation_tabs"),
      vertical = TRUE,
      tabPanel(
        title = "Functionality",
        tags$div(
          includeMarkdown("app/documentation/added_functionality.md")
        )
      ),
      tabPanel(
        title = "Options Explanation",
        tags$div(
          includeMarkdown("app/documentation/options_explanation.md")
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
