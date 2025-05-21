test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})

pharmaverseadam::advs |>
   dplyr::select(USUBJID, PARAMCD, AVAL) |>
   predecessor(x = pharmaverseadam::adsl, old = "ARM", new = "c")
