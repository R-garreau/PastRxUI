# Contains Helper functions for selectInput choices

box::use( 
  stats[setNames],
)



#' Get Drug Choices for information
#' @return A character vector of drug choices
#' @export
getDrugs <- function() {
  drug_choices <- c(
    "Amikacin",
    "Amoxicillin",
    "Busulfan",
    "Caspofungin",
    "Cefazolin",
    "Cefepim",
    "Cefiderocol",
    "Cefotaxim",
    "Cefoxitin",
    "Ceftazidim",
    "Ceftolozan",
    "Ceftriaxon",
    "Ciclosporin",
    "Ciprofloxacin",
    "Dalbavancin",
    "Daptomycin",
    "Ertapenem",
    "Fluconazole",
    "Gentamicin",
    "Imipenem",
    "Levofloxacin",
    "Linezolid",
    "Meropenem",
    "Ofloxacin",
    "Piperacillin",
    "Tedizolid",
    "Teicoplanin",
    "Tobramycin",
    "Vancomycin",
    "Voriconazole"
  )
  return(drug_choices)
}

getRenalFormulas <- function() {
  renal_formula_choices <- c(
    "Cockcroft-Gault" = "cockcroft_gault",
    "MDRD" = "mdrd",
    "CKD-EPI" = "ckd_epi"
  )
  return(renal_formula_choices)
}

#' Get Weight Formula Choices for selectInput
#' @param i18n Optional translation object
#' @return A named character vector of weight formula choices
#' @export
getWeightFormulas <- function(i18n = NULL) {
  weight_choices <- c("TBW", "IBW", "LBW", "ABW")

  return(weight_choices)
}
