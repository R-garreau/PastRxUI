box::use(
 testthat[test_that, expect_equal, expect_true, expect_type],
)

box::use(
  app/logic/mb2_read[read_mb2],
)


# Test of the read_mb2 subfunction

testthat::test_that("read_mb2 function correctly reads input file", {
   # Provide the path to the sample input file
   file_path_1 <- testthat::test_path("testdata/Amikacine_loading_test.mb2.txt")

   # Call the function to read the file
   result_test1 <- read_mb2(file_path_1)

   # Test various aspects of the result
   testthat::expect_equal(result_test1[["patient_first_name"]], "John")
   testthat::expect_equal(result_test1[["patient_last_name"]], "Doe")
   testthat::expect_equal(result_test1[["hospital"]], "GHE")
   testthat::expect_equal(result_test1[["height"]], "163.0") 
   testthat::expect_equal(result_test1[["birthdate"]], "1969/06/18")

   # Check the number of rows in dose_df and level_df
   testthat::expect_equal(nrow(result_test1[["dose_df"]]), 3)
   testthat::expect_equal(nrow(result_test1[["level_df"]]), 2)
   testthat::expect_equal(nrow(result_test1[["weight_df"]]), 1)
   
   # Check the new fields
   testthat::expect_true("mic_value" %in% names(result_test1))
   testthat::expect_true("indication" %in% names(result_test1))
   testthat::expect_true("identified_bacteria" %in% names(result_test1))
   testthat::expect_equal(class(result_test1[["mic_value"]]), "numeric")
})


testthat::test_that("read_mb2 function correctly reads input file", {
   # Provide the path to the sample input file
   file_path_4 <- testthat::test_path("testdata/CEFE_BOUG.mb2")

   # Call the function to read the file
   result_test4 <- read_mb2(file_path_4)

   # Test various aspects of the result
   testthat::expect_equal(result_test4[["patient_last_name"]], "Doe")
   testthat::expect_equal(result_test4[["patient_first_name"]], "John")
   testthat::expect_equal(result_test4[["height"]], "170.0")
   testthat::expect_equal(result_test4[["hospital"]], "CHLA")
   testthat::expect_equal(result_test4[["birthdate"]], "2022/11/30")
   testthat::expect_equal(result_test4[["sex"]], "Male")
   testthat::expect_equal(result_test4[["ward"]], "Rea")
   testthat::expect_equal(result_test4[["room"]], "")

   # Check the number of rows in dose_df and level_df
   testthat::expect_equal(nrow(result_test4[["dose_df"]]), 5)
   testthat::expect_equal(nrow(result_test4[["level_df"]]), 1)
   testthat::expect_equal(nrow(result_test4[["weight_df"]]), 2)
   testthat::expect_equal(result_test4[["weight_df"]][1, 2], 73.0000000)

})