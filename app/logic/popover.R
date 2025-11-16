box::use(
  bs4Dash[addPopover, removePopover],
)

#' initialize popovers
#' @param session Shiny session
#' @export
init_popovers <- function(type, session) {
  if (type == "patient_information") {
    patient_information_popovers(session)
  } else if (type == "administration") {
    administration_popovers(session)
  }
}

#' remove popovers
#' @param session Shiny session
#' @export
remove_popovers <- function(type, session) {
  if (type == "patient_information") {
    remove_patient_information_popovers(session)
  } else if (type == "administration") {
    remove_administration_popovers(session)
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

#' add popovers to administration fields
#' @param session Shiny session
#' @export
administration_popovers <- function(session) {
  addPopover(
    id = "eGFR",
    session = session,
    options = list(
      title = "Renal Formula",
      placement = "right",
      html = TRUE,
      trigger = "hover",
      content = "Renal function is calculated based on the weight type selected and not the TBW."
    )
  )
  
  addPopover(
    id = "mg_dl_unit",
    session = session,
    options = list(
      title = "Creatinine Unit",
      placement = "right",
      html = TRUE,
      trigger = "hover",
      content = "Check to enter creatinine in mg/dL instead of μmol/L."
    )
  )
  
  addPopover(
    id = "weight_lbs_unit",
    session = session,
    options = list(
      title = "Weight Unit",
      placement = "right",
      html = TRUE,
      trigger = "hover",
      content = "Check to enter weight in lbs instead of kg."
    )
  )
}

#' remove popovers from patient information fields
#' @param session Shiny session
#' @export
remove_patient_information_popovers <- function(session) {
  removePopover(id = "first_name", session = session)
  # removePopover(id = "last_name", session = session)
}

#' remove popovers from administration fields
#' @param session Shiny session
#' @export
remove_administration_popovers <- function(session) {
  removePopover(id = "eGFR", session = session)
  removePopover(id = "mg_dl_unit", session = session)
  removePopover(id = "weight_lbs_unit", session = session)
}
