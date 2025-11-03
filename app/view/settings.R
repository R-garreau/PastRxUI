box::use(
  shiny[fluidPage, h3, p],
  bs4Dash[tabItem],
)

#' Settings Tab UI
#'
#' @param translator shiny.i18n Translator object
#' @export
settings_ui <- function(translator) {
  tabItem(
    tabName = "settings",
    fluidPage(
      h3(translator$t("Paramètres")),
      p(translator$t("Ce menu est en cours de développement."))
    )
  )
}