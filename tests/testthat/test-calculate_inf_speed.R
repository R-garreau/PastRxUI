box::use(
   testthat[
      expect_equal,
      expect_true,
      expect_false
   
   ]
)
box::use(
   app/logic/fun_calculate_inf_speed[calculate_inf_speed,
                                  calculate_daily_dose,
                                  continuous_infusion_time]
)

testthat::test_that("calc_inf_speed return the right value", {

   expect_inf_speed_rounded <-
      calculate_inf_speed(total_daily_dose = 2000, start_date = Sys.Date(),
                          start_time = Sys.time(), end_date = (Sys.Date() + 1),
                          end_time = Sys.time(),  rounding = TRUE)

   expect_inf_speed_not_rounded <-
      calculate_inf_speed(
         total_daily_dose = 2000,
         start_date = Sys.Date(),
         start_time = Sys.time(),
         end_date = Sys.Date() + 1,
         end_time = Sys.time()
      )

   expect_inf_speed_40mL <-
      calculate_inf_speed(
         total_daily_dose = 2000,
         start_date = Sys.Date(),
         start_time = Sys.time(),
         end_date = Sys.Date() + 1,
         end_time = Sys.time(),
         sp_volume = 40
      )

   expect_inf_speed_20h <-
      calculate_inf_speed(
         total_daily_dose = 2000,
         start_date = as.Date(strsplit(as.character(Sys.time()), " ")[[1]][1]),
         start_time = Sys.time(),
         end_date = as.Date(strsplit(as.character(Sys.time() + 72000), " ")[[1]][1]),
         end_time = Sys.time() + 72000
      )

   # test when inf speed rounded
   testthat::expect_equal(expect_inf_speed_rounded, 2.1)

   # test if not rounded
   testthat::expect_equal(expect_inf_speed_not_rounded, 2.083333333333)

   # test changinf volume and time
   testthat::expect_equal(expect_inf_speed_20h, 2.5)
   testthat::expect_equal(expect_inf_speed_40mL, 1.66666666667)

})

testthat::test_that("calculate daily dose works", {
   expect_calc_daily_dose1 <-
      calculate_daily_dose(sp_dose = 2000, sp_volume = 50, sp_speed = 2,
                           start_date = Sys.Date(), start_time = Sys.time(),
                           end_date = Sys.Date() + 1, end_time = Sys.time())

   expect_calc_daily_dose2 <-
      calculate_daily_dose(sp_dose = 2400, sp_volume = 48, sp_speed = 2,
                           start_date = Sys.Date(), start_time = Sys.time(),
                           end_date = Sys.Date() + 1, end_time = Sys.time())

   expect_calc_daily_dose3 <- calculate_daily_dose(sp_dose = 2000, sp_volume = 50, sp_speed = 2, inf_time = 24)

   testthat::expect_equal(expect_calc_daily_dose1, 1920)
   testthat::expect_equal(expect_calc_daily_dose2, 2400)
   testthat::expect_equal(expect_calc_daily_dose3, 1920)
})


testthat::test_that("continuous_infusion_time return the right time output", {
   inf_time1 <-
      continuous_infusion_time(
         start_date = Sys.Date(), start_time = Sys.time(),
         end_date = Sys.Date(), end_time = Sys.time()
      )

   inf_time2 <-
      continuous_infusion_time(
         start_date = Sys.Date(), start_time = Sys.time(),
         end_date = Sys.Date() + 1, end_time = Sys.time()
      )

   inf_time3 <-
      continuous_infusion_time(
         start_date = as.Date(strsplit(as.character(Sys.time()), " ")[[1]][1]),
         start_time = Sys.time(),
         end_date = as.Date(strsplit(as.character(Sys.time() + 72000), " ")[[1]][1]),
         end_time = Sys.time() + 72000
      )

   testthat::expect_equal(inf_time1, 0)
   testthat::expect_equal(inf_time2, 24)
   testthat::expect_equal(inf_time3, 20)
})