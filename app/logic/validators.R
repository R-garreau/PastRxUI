#' Initialize all input validators
#'
#' @param input Shiny input object
#' @return List of enabled validators
#' @noRd
initialize_validators <- function(input) {
  validators <- list()

  # Birthdate validation
  validators$iv <- create_birthdate_validator()

  # Renal function validation
  validators$renal_iv <- create_renal_validator(input)

  # BestDose route validation
  validators$bd_iv <- create_bestdose_route_validator()

  # Drug validation
  validators$drug_validator <- create_drug_validator()

  # Report validation
  validators$report_validator <- create_report_validator()

  return(validators)
}

#' Create birthdate validator
#' @return InputValidator object
#' @noRd
create_birthdate_validator <- function() {
  iv <- InputValidator$new()
  iv$add_rule("birthdate", ~ if (. == Sys.Date()) "Enter the real birthdate")
  iv$enable()
  return(iv)
}

#' Create renal function validator
#' @param input Shiny input object
#' @return InputValidator object
#' @noRd
create_renal_validator <- function(input) {
  renal_iv <- InputValidator$new()
  renal_iv$condition(~ input$eGFR == "schwartz")
  renal_iv$add_rule("eGFR", ~ if (calc_age(input$birthdate) < 18) "Warning. Schwartz is only valid for patient < 18 years")
  renal_iv$enable()
  return(renal_iv)
}

#' Create BestDose route validator
#' @return InputValidator object
#' @noRd
create_bestdose_route_validator <- function() {
  bd_iv <- InputValidator$new()
  bd_iv$add_rule("administration_route", ~ if (. == "SC") "Subcutaneous Route isn't supported by BestDose, Use IM instead")
  bd_iv$enable()
  return(bd_iv)
}

#' Create drug validator
#' @return InputValidator object
#' @noRd
create_drug_validator <- function() {
  drug_validator <- InputValidator$new()
  drug_validator$add_rule("drug", ~ if (. == "") "Please select a drug before saving")
  drug_validator$add_rule("first_name", sv_required())
  drug_validator$add_rule("last_name", sv_required())
  drug_validator$add_rule("ward", sv_required())
  drug_validator$enable()
  return(drug_validator)
}

#' Create report validator
#' @return InputValidator object
#' @noRd
create_report_validator <- function() {
  report_validator <- InputValidator$new()
  report_validator$add_rule("pharmacologist", sv_required(message = "Value Required to create report"))
  report_validator$add_rule("medical_indication", sv_required(message = "Value Required to create report"))
  report_validator$enable()
  return(report_validator)
}


#' Validate unique times and show warning if duplicates found
#'
#' @param time_vector Vector of time values to check
#' @param time_type String describing the type of time (e.g., "administration", "weight", "concentration")
#' @noRd
validate_unique_times <- function(time_vector, time_type) {
  if (!is_unique(time_vector)) {
    message <- paste0(
      "Some ", time_type, " times are identical and may cause a crash when using BestDose. Please fix it"
    )
    if (time_type == "administration") {
      message <- "Some administration time are identical and may cause a crash when using BestDose"
    } else if (time_type == "weight") {
      message <- "Some weight measurement have identical time. Please fix it as this may cause a crash when using BestDose"
    } else if (time_type == "concentration") {
      message <- "Some concentrations have identical sampling time. This may cause a crash when using BestDose. Please fix it"
    }
     # replace with a shiny modal notify(content = message, type = "warning")
  }
}