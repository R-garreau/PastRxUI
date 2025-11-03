# Description
#
# this function is dedicated to transform a dose/24h into a infusion speed
# when patient are treated by continuous infusion.
# it is also possible to calculate the total dose to give to a patient based on the infusion
# speed and the syringe volume


#' @title calculate_inf_speed
#'
#' @description
#' this small helper function help the user calculated the speed of the continuous
#' infusion given the daily dose required and the volume of the electronic
#' syringe.
#'
#' @param total_daily_dose total daily amount given to the patient
#' @param sp_dose correspond to the amount of drug in the electronic device. Must be in mg.
#' @param sp_volume correspond to the total volume in the electronic syringe. Must be in mL, default is set at 50mL
#' @param start_date correspond to the date it started. must be a date format
#' @param start_time correspond to the time at which the infusion began.
#' @param end_date correspond to the date it started. must be a date format
#' @param end_time correspond to the time at which the infusion ended.
#' @param rounding if TRUE round the dose to have closer round dose

calculate_inf_speed <- function(total_daily_dose,
                                sp_dose = 2000,
                                sp_volume = 50,
                                start_date,
                                start_time,
                                end_date,
                                end_time,
                                rounding = FALSE) {

   # calc the total infusion time
   inf_time <- continuous_infusion_time(
      end_date = end_date,
      end_time = end_time,
      start_date = start_date,
      start_time = start_time
   )

   # calculate infusion speed
   inf_speed <- total_daily_dose * sp_volume / inf_time / sp_dose

   # round the infusion speed if asked and calculate the total new dose
   if (isTRUE(rounding)) {
      inf_speed <- round(inf_speed, digits = 1)
   }

   return(inf_speed)
}


#' @title calculate_daily_dose
#'
#' @description calculate_daily_dose is a function that return the total daily that
#' need to be given to a patient based on the infusion speed and the volume of
#' the electronic syringe
#'
#' @param sp_dose correspond to the amount of drug in the electronic device. Must be in mg.
#' @param sp_volume correspond to the total volume in the electronic syringe. Must be in mL, default is set at 50mL
#' @param sp_speed correspond to the perfusion speed (in mL/h)
#' @param start_date correspond to the date it started. must be a date format
#' @param start_time correspond to the time at which the infusion began.
#' @param end_date correspond to the date it started. must be a date format
#' @param end_time correspond to the time at which the infusion ended.
#' @param inf_time correspond to the total infusion duration. Default value is NULL. it is also calculated using the other argument
#' @param rounding if TRUE round the dose to have closer round dose


calculate_daily_dose <- function(sp_dose,
                                 sp_volume = 50,
                                 sp_speed,
                                 start_date,
                                 start_time,
                                 end_date,
                                 end_time,
                                 inf_time = NULL,
                                 rounding = FALSE) {
   if (is.null(inf_time)) {
      inf_time <- continuous_infusion_time(end_date = end_date, end_time = end_time, start_date = start_date, start_time = start_time)
   }
   # calculate the total daily dose base on infusion speed
   # correspond D = Concentration (Dose/Volume) * total volume infused (speed * time)
   total_daily_dose <- sp_dose * sp_speed * inf_time / sp_volume
   return(total_daily_dose)
}


#' @title continuous_infusion_duration
#'
#' @description
#' short helper function that help calculate the duration of a continuous
#' infusion given the start and end time point.
#'
#' @param start_date correspond to the date it started. must be a date format
#' @param start_time correspond to the time at which the infusion began.
#' @param end_date correspond to the date it started. must be a date format
#' @param end_time correspond to the time at which the infusion ended.


continuous_infusion_time <- function(start_date,
                                     start_time,
                                     end_date,
                                     end_time) {

   end_time_inf <- paste(format(end_date, "%Y/%m/%d"), format(end_time, "%H:%M"))
   start_time_inf <- paste(format(start_date, "%Y/%m/%d"), format(start_time, "%H:%M"))

   inf_time <- difftime(end_time_inf, start_time_inf, units = "hours")
   return(as.numeric(inf_time))
}
