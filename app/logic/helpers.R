# Helper utility functions for PastRxUI

#' Format date and time for BestDose MB2 file
#'
#' @param date Date object
#' @param time POSIXct time object
#' @return Character string in format "YYYY/MM/DD HH:MM"
#' @export
date_time_format <- function(date, time) {
  paste(format(date, "%Y/%m/%d"), format(time, "%H:%M"))
}

#' Calculate age from birthdate
#'
#' @param birthdate Date object
#' @param reference_date Date object for age calculation (default: Sys.Date())
#' @return Numeric age in years
#' @export
calc_age <- function(birthdate, reference_date = Sys.Date()) {
  age <- as.numeric(difftime(reference_date, birthdate, units = "days")) / 365.25
  return(floor(age))
}
