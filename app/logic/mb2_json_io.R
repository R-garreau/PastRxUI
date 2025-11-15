box::use(
  jsonlite[toJSON, fromJSON, prettify],
)

#' @title save_mb2_json
#' @description
#' Saves the complete application state to a JSON file including:
#' - All settings (weight type, creatinine unit, african american, denorm crcl)
#' - Correction factor (1 or 10) for concentration/dose
#' - Full weight history with units
#' - Full dosing history with creatinine values and units
#' - TDM history
#' - Patient information
#'
#' @param patient_data List containing patient information
#' @param admin_data List containing administration data
#' @param tdm_data Data frame containing TDM history
#' @param settings List containing app settings
#' @param correction_factor Numeric value (1 or 10) indicating if concentration/dose were corrected
#' @return JSON string containing all app state
#' @export

mb2_json_write <- function(patient_data, admin_data, tdm_data, settings, correction_factor = 1) {
  # Create comprehensive state object
  app_state <- list(
    metadata = list(
      version = "1.0.0",
      created_date = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
      app_name = "PastRx TDM"
    ),
    settings = list(
      weight_type = settings$weight_type,
      weight_lbs = settings$weight_lbs_unit,
      creatinine_unit = settings$creatinine_unit,
      african = settings$african,
      denorm_ccr = settings$denorm_ccr,
      creat_mg_dl = settings$mg_dl_unit
    ),
    correction = list(
      factor = correction_factor,
      applied = correction_factor != 1,
      description = if (correction_factor == 10) "Concentrations and doses divided by 10" else "No correction applied"
    ),
    patient = list(
      first_name = patient_data$first_name,
      last_name = patient_data$last_name,
      sex = patient_data$sex,
      birthdate = as.character(patient_data$birthdate),
      hospital = patient_data$hospital,
      ward = patient_data$ward,
      drug = patient_data$drug
    ),
    weight_history = if (!is.null(admin_data$weight_history) && nrow(admin_data$weight_history) > 0) {
      # Add weight unit column
      admin_data$weight_history$weight_unit <- settings$weight_lbs_unit
      admin_data$weight_history
    } else {
      data.frame()
    },
    dosing_history = if (!is.null(admin_data$dosing_history) && nrow(admin_data$dosing_history) > 0) {
      # Add creatinine unit to dosing history
      dosing_with_units <- admin_data$dosing_history
      dosing_with_units$creatinine_unit <- settings$creatinine_unit
      dosing_with_units
    } else {
      data.frame()
    },
    tdm_history = if (!is.null(tdm_data) && nrow(tdm_data) > 0) {
      tdm_data
    } else {
      data.frame()
    },
    administration_settings = list(
      height = admin_data$height,
      date_next_dose = as.character(admin_data$date_next_dose),
      time_next_dose = as.character(admin_data$time_next_dose)
    )
  )

  # Convert to pretty JSON
  json_string <- toJSON(app_state, pretty = TRUE, auto_unbox = TRUE, dataframe = "rows")

  return(as.character(json_string))
}

#' @title load_mb2_json
#' @description
#' Loads the complete application state from a JSON file
#'
#' @param json_file_path Path to the JSON file
#' @return List containing all app state data
#' @export

mb2_json_read <- function(json_file_path) {
  # Check if file exists
  if (!file.exists(json_file_path)) {
    stop("JSON file not found: ", json_file_path)
  }

  # Read and parse JSON
  app_state <- fromJSON(json_file_path, simplifyDataFrame = TRUE)

  # Validate version compatibility (optional)
  if (!is.null(app_state$metadata$version)) {
    # Future version checks can be added here
  }

  # Convert date fields back to proper types
  if (!is.null(app_state$patient$birthdate)) {
    app_state$patient$birthdate <- as.Date(app_state$patient$birthdate)
  }

  if (!is.null(app_state$administration_settings$date_next_dose)) {
    app_state$administration_settings$date_next_dose <- as.Date(app_state$administration_settings$date_next_dose)
  }

  # Ensure data frames are properly formatted
  if (is.null(app_state$weight_history) || length(app_state$weight_history) == 0) {
    app_state$weight_history <- data.frame(
      Weight_date = character(),
      Weight_value = numeric(),
      mod_weight_type = character(),
      tbw = numeric(),
      bsa = numeric(),
      weight_unit = logical()
    )
  }

  if (is.null(app_state$dosing_history) || length(app_state$dosing_history) == 0) {
    app_state$dosing_history <- data.frame(
      Admin_date = character(),
      Route = character(),
      Infusion_rate = numeric(),
      Infusion_duration = numeric(),
      Dose = numeric(),
      Creatinin_Clearance = numeric(),
      creatinine = numeric(),
      creatinine_unit = character()
    )
  }

  if (is.null(app_state$tdm_history) || length(app_state$tdm_history) == 0) {
    app_state$tdm_history <- data.frame(
      tdm_time = character(),
      concentration = numeric()
    )
  }

  return(app_state)
}


#' @title get_json_filename
#' @description
#' Generates a JSON filename based on the MB2 filename
#'
#' @param mb2_filename The MB2 filename
#' @return JSON filename (replaces .mb2 with .json)
#' @export

get_json_filename <- function(mb2_filename) {
  gsub("\\.mb2$", ".json", mb2_filename, ignore.case = TRUE)
}
