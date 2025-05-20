test_that("dummy works", {
  pharmaverseadam::adsl |>
    dummy(adlb = pharmaverseadam::adlb) |>
    expect_no_error() |>
    names() |>
    expect_contains("ALBBLGRP")

  mtcars |>
    dummy(adlb = pharmaverseadam::adlb) |>
    expect_error()

  pharmaverseadam::adsl |>
    dummy(mtcars) |>
    expect_error()
})
