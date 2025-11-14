
box::use(
  testthat[test_that, expect_equal, expect_true, expect_type],
)

box::use(
  app/logic/fun_weight_formula[weight_formula],
  app/logic/utils[calc_age]
)

testthat::test_that("weight_formula return the right output", {

  test_weight_formula <- weight_formula(weight = 70, height = 170, sex = "Female", weight_unit = "kg", weight_formula = "IBW", bsa_formula = "dubois")

  # expect type of the output to be a list of length 3 with names weight, bsa and bmi
  testthat::expect_type(test_weight_formula, "list")
  testthat::expect_length(test_weight_formula, 3)
  testthat::expect_named(test_weight_formula, c("weight", "bsa", "bmi"))

  # test unit = kg
  testthat::expect_equal(test_weight_formula$weight, 61.4)
  testthat::expect_equal(test_weight_formula$bsa, 1.8)
  testthat::expect_equal(test_weight_formula$bmi, 24.2)

  # test unit = lbs
  test_weight_formula <- weight_formula(weight = 31.758, height = 170, sex = "Female", weight_unit = "lbs", weight_formula = "IBW", bsa_formula = "dubois")
  testthat::expect_equal(test_weight_formula$weight, 61.4)
  testthat::expect_equal(test_weight_formula$bsa, 1.8)
  testthat::expect_equal(test_weight_formula$bmi, 24.2)

  # test unit = lbs with capped = TRUE
  test_weight_formula <- weight_formula(weight = 31.758, height = 200, sex = "Female", weight_unit = "lbs", weight_formula = "IBW", bsa_formula = "dubois", capped = TRUE)
  testthat::expect_equal(test_weight_formula$bsa, 2)

  #test mosteller formula
  test_weight_formula <- weight_formula(weight = 70, height = 170, sex = "Female", weight_unit = "kg", weight_formula = "IBW", bsa_formula = "mosteller")
  testthat::expect_equal(test_weight_formula$bsa, 1.8)
})
