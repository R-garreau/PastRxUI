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
#' 
#' @export 

name_file <- function(first_name,
                      last_name,
                      hospital,
                      drug,
                      ext = ".mb2") {


    filename <- paste0(
      toupper(substr(drug, start = 1, stop = 2)),
      toupper(substr(last_name, start = 1, stop = 4)),
      toupper(substr(first_name, start = 1, stop = 1)),
      ext
    )


  return(filename)
}