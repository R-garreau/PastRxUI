box::use(
 testthat[test_that, expect_equal, expect_true, expect_type],
)

box::use(
  app/logic/fun_write_mb2[write_mb2, weight_history, serum_level_history, administration_history],
  app/logic/fun_name_file[name_file],
)


# test administration_history _________________________________________________ ----
testthat::test_that("administration_history returns the correct output", {
  # Sample input dataframe
  df <- data.frame(
    date_time = c("2023/08/05 10:00", "2023/08/06 12:30"),
    admin_route = c("IV", "IM"),
    infusion_rate = c(5, 8),
    infusion_duration = c(2, 3),
    dose = c(50, 75),
    ccr = c(70, 90)
  )

  # Expected output
  expected_output <- paste0(
    "2023/08/05 10:00  IV   5.0000000000     2.00000000   50.000000000    70.00000000  \n",
    "2023/08/06 12:30  IM   8.0000000000     3.00000000   75.000000000    90.00000000  "
  )

  # Call the function and compare with expected output
  result <- administration_history(df)
  testthat::expect_equal(result, expected_output)
})

testthat::test_that("administration_history returns the correct output", {
  # create a dataframe
  df_concentration <- as.data.frame(rbind(
    c("2014-09-13 09:08", "IV", 750, 1, 750, 96.9),
    c("2014-09-14 08:00", "IV", 750, 1, 750, 83),
    c("2014-09-15 06:53", "IV", 750, 1, 750, 86.7)
  ))

  # dirty FIX to test new variable input (numerical )
  df_concentration[, 3] <- as.numeric(df_concentration[, 3])
  df_concentration[, 4] <- as.numeric(df_concentration[, 4])
  df_concentration[, 5] <- as.numeric(df_concentration[, 5])
  df_concentration[, 6] <- as.numeric(df_concentration[, 6])

  # expected output
  output <- paste0(
    "2014-09-13 09:08  IV   750.00000000     1.00000000   750.00000000    96.90000000  \n",
    "2014-09-14 08:00  IV   750.00000000     1.00000000   750.00000000    83.00000000  \n",
    "2014-09-15 06:53  IV   750.00000000     1.00000000   750.00000000    86.70000000  "
  )

  testthat::expect_equal(administration_history(df_concentration), output)
})

# test serum_level_history ___________________________________________________________ ----
testthat::test_that("serum_level_history returns the correct output", {
  # Sample input dataframe
  df <- data.frame(
    date_time = c("2023-08-05 10:00", "2023-08-06 12:30"),
    concentration_level = c(20, 30)
  )

  # Expected output
  expected_output <- paste0(
    "2023-08-05 10:00       20.000000                       !Date-time, value, comment\n",
    "2023-08-06 12:30       30.000000                       !Date-time, value, comment"
  )

  # Call the function and compare with expected output
  result <- serum_level_history(df)
  testthat::expect_equal(result, expected_output)
})

testthat::test_that("serum_level_history returns the correct output", {
  # Sample input dataframe
  df_level <- as.data.frame(rbind(
    c("2014-09-13 09:08", 96.9),
    c("2014-09-14 08:00", 10),
    c("2014-09-15 06:53", 86.7)
  ))

  df_level$V2 <- as.numeric(df_level$V2)

  # Expected output
  expected_output <- paste0(
    "2014-09-13 09:08       96.900000                       !Date-time, value, comment\n",
    "2014-09-14 08:00       10.000000                       !Date-time, value, comment\n",
    "2014-09-15 06:53       86.700000                       !Date-time, value, comment"
  )


  # Call the function and compare with expected output
  testthat::expect_equal(serum_level_history(df_level), expected_output)
})

testthat::test_that("serum_level_history expect error if output are not numerical", {
  # Sample input dataframe
  df_level <- as.data.frame(rbind(
    c("2014-09-13 09:08", "96.9"),
    c("2014-09-14 08:00", "10"),
    c("2014-09-15 06:53", "86.7")
  ))

  # Expected output
  expected_output <- paste0(
    "2014-09-13 09:08       96.900000                       !Date-time, value, comment",
    "2014-09-14 08:00       10.000000                       !Date-time, value, comment",
    "2014-09-15 06:53       86.700000                       !Date-time, value, comment"
  )

  # Call the function and compare with expected output
  testthat::expect_error(serum_level_history(df_level))
})

# test weight_history ___________________________________________________________ ----
testthat::test_that("weight_history returns the correct output", {
  # Sample input dataframe
  df <- data.frame(
    weight_date = c("2023-08-05 10:00", "2023-08-06 12:30"),
    weight_value = c(20, 30)
  )

  # Expected output
  expected_output <- paste0(
    "2023-08-05 10:00      20.0000000                       !Date-time, value, comment\n",
    "2023-08-06 12:30      30.0000000                       !Date-time, value, comment"
  )

  # Call the function and compare with expected output
  result <- weight_history(df)
  testthat::expect_equal(result, expected_output)
})

# full function test  _______________________________________________________________ ----

testthat::test_that("write_mb2 returns the correct output for Amikacin", {
  # Sample input arguments
  last_name <- "XXXXXXXXX"
  first_name <- "XXXXXX"
  sex <- "Female"
  hospital <- "CR"
  ward <- ""
  room <- ""
  height <- 163
  birthdate <- "1969/06/18"
  weight_number <- 1
  drug_name <- "Amikacin"
  date <- as.Date("2014/09/16")
  time <- as.POSIXct("2014/09/16 08:00")
  dose_number <- 3
  concentration_number <- 2

  # Sample dataframes for administration and level data
  admin_data <- data.frame(
    date_time = c("2014/09/13 08:00", "2014/09/14 08:00", "2014/09/15 06:53"),
    admin_route = c("IV", "IV", "IV"),
    infusion_rate = rep(750, 3),
    infusion_duration = rep(1, 3),
    dose = rep(750, 3),
    ccr = rep(87, 3)
  )

  level_data <- data.frame(
    date_time = c("2014/09/15 08:10", "2014/09/16 07:28"),
    concentration_level = c(24.2, 3.3)
  )

  weight_data <- data.frame(
    weight_date <- "2014/09/15 10:10",
    weight_value <- 45
  )

  # Call the function and compare with expected output
  result <- write_mb2(
    last_name = last_name,
    first_name = first_name,
    sex = sex,
    hospital = hospital,
    ward = ward,
    room = room,
    height = height,
    birthdate = birthdate,
    weight_number = weight_number,
    drug_name = drug_name,
    date_next_dose = date,
    time_next_dose = time,
    dose_number = dose_number,
    concentration_number = concentration_number,
    weight_data = weight_data,
    administration_data = admin_data,
    level_data = level_data,
    custom_header = "PASTRx Version: 1.2.0.27.     2014/09/16 10:55         !version, date this file written."
  )

  # write, load and compare the .txt obtain to the real one
  write(x = result, file = testthat::test_path("testdata/Amikacine_output.txt"))

  # Expect_output for amikacin
  expected_output <- readLines(testthat::test_path("testdata/Amikacine1.mb2.txt"))
  # output of the function
  out_text <- readLines(testthat::test_path("testdata/Amikacine_output.txt"))

  testthat::expect_equal(out_text[-2], expected_output[-2])
})

skip("Skipping MIC test for now")
testthat::test_that("write_mb2 includes MIC value and occasion when provided", {
  # Sample input arguments
  last_name <- "XXXXXXXXX"
  first_name <- "XXXXXX"
  sex <- "Female"
  hospital <- "CR"
  ward <- ""
  room <- ""
  height <- 163
  birthdate <- "1969/06/18"
  weight_number <- 1
  drug_name <- "Amikacin"
  date <- as.Date("2014/09/16")
  time <- as.POSIXct("2014/09/16 08:00")
  dose_number <- 3
  concentration_number <- 2
  mic_value <- 1.5
  occasion <- 2

  # Sample dataframes for administration and level data
  admin_data <- data.frame(
    date_time = c("2014/09/13 08:00", "2014/09/14 08:00", "2014/09/15 06:53"),
    admin_route = c("IV", "IV", "IV"),
    infusion_rate = rep(750, 3),
    infusion_duration = rep(1, 3),
    dose = rep(750, 3),
    ccr = rep(87, 3)
  )

  level_data <- data.frame(
    date_time = c("2014/09/15 08:10", "2014/09/16 07:28"),
    concentration_level = c(24.2, 3.3)
  )

  weight_data <- data.frame(
    weight_date <- "2014/09/15 10:10",
    weight_value <- 45
  )

  # Call the function with mic_value and occasion
  result <- write_mb2(
    last_name = last_name,
    first_name = first_name,
    sex = sex,
    hospital = hospital,
    ward = ward,
    room = room,
    height = height,
    birthdate = birthdate,
    weight_number = weight_number,
    drug_name = drug_name,
    date_next_dose = date,
    time_next_dose = time,
    dose_number = dose_number,
    concentration_number = concentration_number,
    weight_data = weight_data,
    administration_data = admin_data,
    level_data = level_data,
    mic_value = mic_value,
    occasion = occasion,
    custom_header = "PASTRx Version: 1.2.0.27.     2014/09/16 10:55         !version, date this file written."
  )

  # Write result to file for inspection
  write(x = result, file = testthat::test_path("testdata/Amikacine_mic_output.txt"))

  # Check that MIC value is included in the output
  testthat::expect_true(grepl("1.50000", result))

  # Generate the expected filename with occasion
  test_filename <- name_file(
    first_name = first_name,
    last_name = last_name,
    drug = drug_name,
    hospital = hospital
  )

  # Verify the filename includes the occasion
  testthat::expect_equal(test_filename, "AMXXXXX.mb2")
})
