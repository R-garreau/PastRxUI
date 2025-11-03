# Description
#
# This script contains functions to name the file generated for Bestdose
# or Tucuxi (not available at the moment).
# General name structure is :
# Example : For John Doe treated by amikacin in Croix Rousse hospital,
# The name of a .mb2 file would be : AMDOEJ.mb2
# The name of a non .mb2 file woule be : AMIJHDO_CRO_2023-01-01
# The name_file function identifies the source software from the file extension
# The name_file.mb2 function extracts data from Bestdose datafiles
# The name_file.tucuxi function will extract data from Tucuxi datafiles


#' @title name_file
#' @description
#' name_file purpose is to identify the file extension and call the right subfunctions
#' to open and extract data from file
#'
#' @param first_name patient first name
#' @param last_name patient last name
#' @param drug correspond to the drug for which MIPD is performed
#' @param hospital correspond to the hospital the patient is in
#' @param ext correspond to the file extension

name_file <- function(first_name,
                      last_name,
                      hospital,
                      drug,
                      ext = ".mb2") {
  if (ext != ".mb2") {
    filename <- paste0(
      toupper(substr(drug, start = 1, stop = 3)),
      toupper(substr(first_name, start = 1, stop = 2)),
      toupper(substr(last_name, start = 1, stop = 2)), "_",
      toupper(substr(hospital, start = 1, stop = 3)), "_",
      Sys.Date(), ext
    )
  }

  if (ext == ".mb2") {
    filename <- paste0(
      toupper(substr(drug, start = 1, stop = 2)),
      toupper(substr(last_name, start = 1, stop = 4)),
      toupper(substr(first_name, start = 1, stop = 1)),
      ext
    )
  }


  return(filename)
}

#' @title report_auto_path_gereration
#'
#' @description
#' This function generate automatic path to save file created based on workspace
#' and file name
#'
#' @param workspace_path the root path where all report are saved
#' @param drug correspond to the drug actually given to the patient
#' @param first_name patient first name
#' @param last_name patient last name

report_auto_path_gereration <- function(
    workspace_path,
    drug,
    first_name,
    last_name) {
  # Classic way of naming file is Last name first and first name
  expected_directory <- paste(last_name, first_name)
  expected_path <- paste0(workspace_path, "/", drug, "/", expected_directory)

  # check if directory exist, if not create a new one with specific name
  patient_dir_exist <- dir.exists(expected_path)

  if (!patient_dir_exist) {
    dir.create(expected_path)
  }

  return(expected_path)
}
