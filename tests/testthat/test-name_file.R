box::use(
 testthat[test_that, expect_equal, expect_true, expect_type],
)

box::use(
  app/logic/fun_name_file[name_file],
)

testthat::test_that("name_file function correctly return the right output", {

   test_file_mb2 <- name_file(
      first_name = "Jhon",
      last_name = "Doe",
      drug = "Dalbavancine",
      hospital = "Lyon sud",
      ext = ".mb2"
   )


   testthat::expect_equal(test_file_mb2, paste0("DADOEJ.mb2"))

})
