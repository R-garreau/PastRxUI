# function that write the administration history for bestdose

#' @title administration_history
#'
#' @description
#' this function writes the full administration history as entered in the app
#'
#' @param df df is a (N by 6) dataframe input that contain date and time, administration route, infusion rate, infusion duration, dose and creatinine clearance

administration_history <- function(df) {

   output <- 0 # initialize output

   for (i in seq_len(nrow(df))) {
      conc_n <- paste0(
         df[i, 1], # administration day and time
         strrep(" ", 2), df[i, 2], # administration route
         strrep(" ", 3), format(round(df[i, 3], 2), nsmall = 2), strrep("0", 12 - nchar(format(round(df[i, 3], 2), nsmall = 2))),  # infusion rate
         strrep(" ", 5), format(round(df[i, 4], 2), nsmall = 2), strrep("0", 10 - nchar(format(round(df[i, 4], 2), nsmall = 2))), # infusion duration
         strrep(" ", 3), format(round(df[i, 5], 2), nsmall = 2), strrep("0", 12 - nchar(format(round(df[i, 5], 2), nsmall = 2))), # Dose
         strrep(" ", 4), format(round(df[i, 6], 2), nsmall = 2), strrep("0", 11 - nchar(format(round(df[i, 6], 2), nsmall = 2)))  # CCR
      )
      # NOTE in case mb2 file test crash for no apparent reason, keep in mind that those two function produce an extra empty line that might be worth investigating
      if (output != 0) {
         output <- paste0(output, "\n", conc_n, "  ")
      }

      if (output == 0) {
         output <- paste0(conc_n, "  ")
      }
   }

   return(output)
}

#' @title serum_level_history
#'
#' @description
#' this function writes the full drug level history as entered in the app
#'
#' @param df df is a (N by 2) dataframe input that contain date, time and concentration level

# function that get all the level history from a datatable
serum_level_history <- function(df) {
   output <- 0

   for (i in seq_len(nrow(df))) {
      # code to write 1 line with reported level
      conc_n <- paste0(
         # serum level day and time
         df[i, 1],
         # code for the space between serum level and day.
         ifelse(df[i, 2] < 10, strrep(" ", 8), strrep(" ", 7)),
         # round every number to a 1 decimal number,
         format(round(df[i, 2], 1), nsmall = 1),
         # Repeat 0 n times depending on the number of character in the decimal format created with the line above
         ifelse(df[i, 2] < 10,
            strrep("0", (8 - nchar(format(round(df[i, 2], 1), nsmall = 1)))),
            strrep("0", (9 - nchar(format(round(df[i, 2], 1), nsmall = 1))))
         )
      )

      if (output != 0) {
         output <- paste0(output, "\n", conc_n, "                       !Date-time, value, comment")
      }

      if (output == 0) {
         output <- paste0(conc_n, "                       !Date-time, value, comment")
      }


   }

   return(output)
}

#' @title weight_history
#'
#' @description
#' this function writes the full weight history as entered in the app
#'
#' @param df df is a (N by 2) dataframe input that contain date, time and measured weight
#'

weight_history <- function(df) {
   output <- 0

   for (i in seq_len(nrow(df))) {
      # code to write 1 line with reported level
      weight_n <- paste0(                                                                       # weight day and time
         df[i, 1],
         dplyr::case_when(                                                                      # if weight is > 100 kg total nchar should be 11, 10 if > 100 and 9 if > 10kg
            df[i, 2] > 100 ~ strrep(" ", 5),
            df[i, 2] < 10 ~ strrep(" ", 7),
            .default = strrep(" ", 6)
         ),
         # code for the space between weight and date of measurement.
         format(round(df[i, 2], 1), nsmall = 1),                                                # round weight to a 1 decimal value
         dplyr::case_when(                                                                      # if weight is > 100 kg total nchar should be 11, 10 if > 100 and 9 if > 10kg
            df[i, 2] > 100 ~ strrep("0", (11 - nchar(format(round(df[i, 2], 1), nsmall = 1)))),
            df[i, 2] < 10 ~ strrep("0", (9 - nchar(format(round(df[i, 2], 1), nsmall = 1)))),
            .default = strrep("0", (10 - nchar(format(round(df[i, 2], 1), nsmall = 1))))
         )
      )

      # we start to check if output is not 0.
      # Checking for output == 0 and != 0 would make both condition TRUE for the first iteration and then create an extra line
      if (output != 0) {
         output <-
            paste0(output, "\n", weight_n, "                       !Date-time, value, comment")
      }

      # write the first weight
      if (output == 0) {
         output <- paste0(weight_n, "                       !Date-time, value, comment")
      }
   }
   return(output)
}

#' @title write_mb2
#' @description Function that write the mb2 file

#' @param first_name patient first name
#' @param last_name patient last name
#' @param sex is the patient's sex
#' @param hospital hospital
#' @param ward were the patient is hospitalized
#' @param room he is in
#' @param height patient height
#' @param birthdate patient birthdate
#' @param weight_number is the number of time the patient weight was taken
#' @param drug_name Name of drug
#' @param date_next_dose Date of the next dose
#' @param time_next_dose Time of the next dose
#' @param dose_number argument used to calculate the number of dose entered for a given patient (will be removed in next version)
#' @param concentration_number argument calculated based on the number of row in the level_data (will be removed in next version)
#' @param administration_data a (N by 6) dataframe input that contain date and time, administration route, infusion rate, infusion duration, dose and creatinine clearance
#' @param weight_data correspond to a N by 2 dataframe that containt the time and the measured weight of a patient
#' @param level_data a (N by 2) dataframe that have date/time and drug level
#' @param ... correspond to non accessible argument
#' @param custom_header is only intended for function testing

write_mb2 <- function(last_name,
                      first_name,
                      sex,
                      hospital,
                      ward,
                      room,
                      height,
                      birthdate,
                      weight_number,
                      drug_name,
                      date_next_dose,
                      time_next_dose,
                      dose_number,
                      concentration_number,
                      weight_data,
                      administration_data,
                      level_data,
                      ...,
                      custom_header = NULL) {

   # header of the .mb2 file
   mb2_header <- paste0("PASTRx Version: 1.2.0.27.     ", format(Sys.Date(), "%Y/%m/%d"), " ", format(Sys.time(), "%H:%M"), strrep(" ", 9), "!version, date this file written.")

   ## Patient info ----
   # NOTE the .0 after input$height is set for compatibility with PastrX format
   mb2_patient_info <- paste0(
      "\n   1      ", format(Sys.time(), "%Y/%m/%d %H:%M"), "    ", format(date_next_dose, "%Y/%m/%d"),
      " ", format(time_next_dose, "%H:%M"), "         !Format key, created on, date of next regimen\n",

      # third line (about first and last name and sex)
      substr(last_name, start = 1, stop = 20), strrep(" ", (20 - nchar(substr(last_name, start = 1, stop = 20)))), # max length for last name = 20 characters
      substr(first_name, start = 1, stop = 12), strrep(" ", (12 - nchar(substr(first_name, start = 1, stop = 12)))), # max length for first name = 12 characters
      ifelse(sex == "Female", "F", "M"),
      "N Unknown genetic grou! Last, First, Ethnic grp., Gender(F/M), Dialysis(D/N)\n",

      # fourth line (hospital, height and birth date)
      substr(hospital, start = 1, stop = 10), strrep(" ", (10 - nchar(substr(hospital, start = 1, stop = 10)))), # max length for hospital name = 10 characters
      substr(ward, start = 1, stop = 10), strrep(" ", (10 - nchar(substr(ward, start = 1, stop = 10)))), # max length for ward name = 10 characters
      substr(room, start = 1, stop = 7), strrep(" ", (7 - nchar(substr(room, start = 1, stop = 7)))), # max length for room name = 10 characters
      "in ", height, ".0 100 ", birthdate, "     !Chart,Ward,Room,cm/in,hgt(cm), muscle %,Birth(yr/mn/dy)"
   )

   ## Variable definition ----
   # Handle the part with weight definition in PasterX file, nothing needs to be changed
   mb2_weight <- paste0(
      "\n   2                                                   !no. of Effects\n",
      dplyr::case_when(
         weight_number > 9 ~ strrep(" ", 2),
         .default = strrep(" ", 3)
      ),
      weight_number, " Weight", strrep(" ", 29), "M3020          !No. samples, name, units, Metric indicator\n",
      "   0.0000000         250.0000000", strrep(" ", 23), "!Minimum, Maximum values\n",
      "kg                 1.0000      7", strrep(" ", 23), "!unit str, conversion factor, precision\n",
      "lbs                2.2046      6", strrep(" ", 23), "!unit str, conversion factor, precision\n"
   )

   ## weight input ----
   mb2_weight_input <- ifelse(nrow(weight_data) == 0, "", weight_history(weight_data))

   ## renal function definition ----
   mb2_creat_setup <- paste0(ifelse(nrow(weight_data) == 0, "", "\n"),
      "   0 SCr                                M2030          !No. samples, name, units, Metric indicator\n",
      "   0.0000000          30.0000000                       !Minimum, Maximum values\n",
      "mg/dL              1.0000      7                       !unit str, conversion factor, precision\n",
      "ug/mL             10.0000      6                       !unit str, conversion factor, precision\n",
      "uM/L              88.4000      5                       !unit str, conversion factor, precision\n"
   )


   # number of drug
   mb2_number_of_drug <- paste0("   1", strrep(" ", 51), "!No. of drugs\n")

   # define drug subject to MIPD
   mb2_drug_information <-
      paste0(drug_name, strrep(" ", (23 - nchar(drug_name))),     # dynamic definition of drugname and space
             "0.00000",                                           # definition of MIC (not supported at the moment)
             dplyr::case_when(
                dose_number >= 10 ~ strrep(" ", 4),
                dose_number >= 100 ~ strrep(" ", 3),
                .default = strrep(" ", 5)
             ),
             dose_number,
             dplyr::case_when(
                concentration_number >= 10 ~ strrep(" ", 2),
                concentration_number >= 100 ~ strrep(" ", 1),
                .default = strrep(" ", 3)
             ),
             concentration_number,
             strrep(" ", 15), "!Drug name, MIC,# dose entries,# Serum entries\n")

   # Dose unit conversion section
   mb2_dose_unit <-
      paste0(
         "1", strrep(" ", 54), "!Dose units(0 = 0.001:ug, 1 = 1.0:mg, 2 = 1000.:gm)\n",
         "1", strrep(" ", 54), "!Dose units display(0 = 0.001:ug, 1 = 1.0:mg, 2 = 1000.:gm)\n",
         "!  Date-time     route       rate          time          dose          CCr     *=calc  *=actual\n"
      )

   # serum unit definition ----
   # set the serum level unit in the output .mb2 file
   mb2_serum_level_unit <- paste0(
      ifelse(nrow(administration_data) == 0, "", "\n"),
      "ug/mL", strrep(" ", 50), "!Serum level units\n",
      "ug/mL", strrep(" ", 50), "!Serum level units display\n"

   )

   # Dose input from TDM section ----
   mb2_dose <- ifelse(
      nrow(administration_data) == 0,
      mb2_serum_level_unit,
      paste0(administration_history(administration_data), mb2_serum_level_unit)
   )


   # set the number of covariate in the .mb2 file
   mb2_covariate_record <-
      paste0(
         ifelse(nrow(level_data) == 0, "", "\n"),
         "   0", strrep(" ", 51), "!No. of Covariate records"
      )

   ## Add serum level from app if some exist.
   mb2_serum_level <- ifelse(
      nrow(level_data) == 0,
      mb2_covariate_record,
      paste0(serum_level_history(level_data), mb2_covariate_record)
   )


   # this is only used to change the first line in file testing, it is not available to the regular user
   if (!is.null(custom_header)) {
      mb2_header <- custom_header
   }

   # write the document ____________________________________________ ----
   mb2_file <- paste0(
      mb2_header,
      mb2_patient_info,
      mb2_weight,
      mb2_weight_input,
      mb2_creat_setup,
      mb2_number_of_drug,
      mb2_drug_information,
      mb2_dose_unit,
      mb2_dose,
      mb2_serum_level
   )

   return(as.character(mb2_file))
}
