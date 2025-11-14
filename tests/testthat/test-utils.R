box::use(
 testthat[test_that, expect_equal, expect_true, expect_type],
)

box::use(
  app/logic/utils[date_time_format, is_unique, combine_input, calc_age],
)


testthat::test_that("date_time_format function correctly return the right output", {
  # Call the function to read the file
  test <- date_time_format(as.Date("2023-10-01"))

  # Test various aspects of the result
  testthat::expect_equal(date_time_format(), paste(format(Sys.Date(), "%Y/%m/%d"), format(Sys.time(), "%H:%M")))
  testthat::expect_equal(test, paste("2023/10/01", format(Sys.time(), "%H:%M")))
})

testthat::test_that("is_unique return the right output", {
  testthat::expect_false(is_unique(c(1, 1, 2, 1, 3)))
  testthat::expect_true(is_unique(c(1, 2, 3, 4, 5)))
})

# test unit for combine input
testthat::test_that("combine_input works with character input of length 1", {
  result <- combine_input("a")
  testthat::expect_equal(result, "a")
})

testthat::test_that("combine_input works with character input of length > 1", {
  result <- combine_input(c("a", "b", "c"))
  testthat::expect_equal(result, "a ; b ; c")
})


testthat::test_that("combine_input works without any input", {
  result <- combine_input(NULL)
  testthat::expect_equal(result, "NA")
})

# Create a test file (typically named test-<your_function_name>.R)
test_that("calc_age calculates age correctly", {
  # Test with a known birthdate
  expect_equal(calc_age(as.Date("2000-01-01")), round(as.numeric(difftime(Sys.Date(), as.Date("2000-01-01"), units = "days") / 365.25), digits = 0))
  
  # Test with today's date
  expect_equal(calc_age(Sys.Date()), 0)

  # Test with a very old date
  expect_equal(calc_age(as.Date("1900-01-01")), round(as.numeric(difftime(Sys.Date(), as.Date("1900-01-01"), units = "days") / 365.25), digits = 0))
})