## NAMESPACE dependecies declaration -------------
#' @importFrom dplyr case_when
#' @importFrom stringr str_ends
#' @importFrom cgwtools lsdata
#' @importFrom rvest html_elements read_html html_text html_attr html_element
#' @importFrom openxlsx write.xlsx read.xlsx
#' @importFrom shinyFiles shinyDirChoose shinyDirButton
#' @importFrom fs path_home
#' @import officer
#' @import bs4Dash
#' @import rhandsontable
#' @import shinyjs
#' @import shinySelect
#' @import shinyTime
#' @import shinyvalidate
#' @import yaml
#' @import utils
NULL

# utility function -----------

# Description
#
#

#' @title date_time_format
#' @description
#' date_time_format is a small helper function whose goal is to
#' format a date and time input into a specific output (YYYY/MM/DD HH:MM)
#'
#' @param date can take any date value. Default value is Sys.Date()
#' @param time can take any time value. Default value is Sys.time()
#' @export 

date_time_format <- function(date = Sys.Date(),
                             time = Sys.time()) {
  output <- paste(format(date, "%Y/%m/%d"), format(time, "%H:%M"))
  return(output)
}

#' is_unique
#'
#' @description
#' This function will return TRUE if values of vector are unique
#'
#' @param vector correspond to the input vector
#' @export 

is_unique <- function(vector) {
  return(!any(duplicated(vector)))
}

#' combine_input
#'
#' @description
#' This function is a small helper that combine all value in a vector in single set of string
#' It is only used to display report while there are multiple input.
#' This prevent unecessary repetition of text while generating report
#'
#' @param var is the variable of interest
#'

combine_input <- function(var) {
  if (length(var) > 1) {
    for (i in seq_along(var)) {
      new_var <- ifelse(i == 1, var[i], paste(new_var, ";", var[i]))
    }
  }

  # if there is only one info keep as is.
  if (length(var) == 1) {
    new_var <- var
  }

  # if is null return empty character
  if (is.null(var)) {
    new_var <- "NA"
  }

  return(new_var)
}


#' calc_age
#'
#' calculate the age
#'
#' @export

calc_age <- function(birthdate) {
  age <- as.numeric(round((difftime(Sys.Date(), birthdate, units = "days") / 365.25), digits = 0))
  return(age)
}
