
#' @title weight_formula
#'
#' @description
#' this function calculated different weight indicator, such as
#' the Ideal Body weigh (IBW) or the adjusted bodyweight (AJBW)
#' # selected formula :
#' IBW : Devine BJ. Gentamicin therapy. DICP. 1974; 8:650–5.
#' AJBW : Schwartz GJ, et al. J Pediatr. 1984; 104: 371-7.
#' LBW : Janmahasatian S, et al. Clin Pharmacokinet. 2005; 44:1051-65.
#' BSA :
#' - Dubois, Arch Intern Med. 1916; 17:863-871
#' - Mosteller, N Engl J Med. 1987; 317:1098.
#'
#' @param weight correspond to the total body weigt in kg or lbs
#' @param height correspond to the patient height (only in cm)
#' @param sex correspond to the patient sex
#' @param weight_unit should be either kg or lbs
#' @param weight_formula correspond to the formula used. Can take value in c(IBW, AJBW, LBW)
#' @param bsa_formula correspond to the formula used to calculate bsa. At the moment the only formula supported is Dubois
#' @param capped define if the body surface area should be capped at a maximum of 2m² (False by default)
#'
#' @return the weight calculated with the selected formula
#'
#' @author Romain Garreau
#' @noRd



weight_formula <- function(
  weight,
  height,
  sex,
  weight_unit = c("kg", "lbs"),
  weight_formula = c("NONE", "IBW", "AJBW", "LBW"),
  bsa_formula = c("dubois", "mosteller"),
  capped = FALSE
) {

  # set weight in kg
  weight <- ifelse(weight_unit == "lbs", weight * 2.20462, weight)
  bmi <- weight / (height / 100) ^ 2

  # calculate size in feet and inches
  height_inch <- (height - 152.4) / 2.54 # 5 feet in cm = 5 * 30.48 ; 1" = 2.54 cm

  # calculate IBW based on Devine weight_formula
  ibw <- ifelse(sex == "Female", 45.5, 50) + 2.3 * ifelse(height_inch > 0, height_inch, 0)
  # calculate adjusted bodyweight
  ajbw <- ibw + 0.4 * (weight - ibw)

  # calculate the Free Fat Mass (Janmahasatian and green, 2005)
  ffm <- 9270 * weight / (ifelse(sex == "Female", 8780 + 244 * bmi, 6680 + 216 * bmi))

  # select the output
  mod_weight <- dplyr::case_when(
    weight_formula == "IBW" ~ ibw,
    weight_formula == "AJBW" ~ ajbw,
    weight_formula == "LBW" ~ ffm,
    TRUE ~ weight
  )

  # body surface area calculation
  if (bsa_formula == "dubois") bsa <- 0.007184 * height^0.725 * weight^0.425
  if (bsa_formula == "mosteller") bsa <- sqrt((height * weight) / 3600)

  # cap the body surface area at 2m²
  if (capped && bsa > 2) bsa <- 2

  return(list(
    weight = round(mod_weight, digits = 1),
    bsa = round(bsa, 1),
    bmi = round(bmi, 1)
  ))
}
