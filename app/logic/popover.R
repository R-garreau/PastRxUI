box::use(
  bs4Dash[addPopover, removePopover],
)

#' initialize popovers
#' @param session Shiny session
#' @export
init_popovers <- function(type, session) {
  if (type == "patient_information") {
    patient_information_popovers(session)
  }
}

#' remove popovers
#' @param session Shiny session
#' @export
remove_popovers <- function(type, session) {
  if (type == "patient_information") {
    remove_patient_information_popovers(session)
  }
}

#' add popovers to patient information fields
#' @param session Shiny session
#' @export

patient_information_popovers <- function(session) {
  addPopover(
    id = "first_name",
    session = session,
    options = list(
      title = "First Name",
      placement = "right",
      html = TRUE,
      trigger = "hover",
      content = "Enter the patient's first name here."
    )
  )
  
  # addPopover(
  #   session = session,
  #   id = "last_name",
  #   title = "Last Name",
  #   content = "Enter the patient's last name here.",
  #   placement = "right",
  #   trigger = "hover",
  #   options = list(container = "body")
  # )
}

#' remove popovers from patient information fields
#' @param session Shiny session
#' @export
remove_patient_information_popovers <- function(session) {
  removePopover(id = "first_name", session = session)
  # removePopover(id = "last_name", session = session)
}
