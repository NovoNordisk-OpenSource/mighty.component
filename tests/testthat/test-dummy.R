test_that("dummy works", {
  pharmaverseadam::adsl |>
    dummy(adlb = pharmaverseadam::adlb) |>
    expect_no_error() |>
    expect_named(c(names(pharmaverseadam::adsl), "ALBBLGRP")) |>
    with(any(is.null(ALBBLGRP))) |>
    expect_false()

  mtcars |>
    dummy(adlb = pharmaverseadam::adlb) |>
    expect_error()

  pharmaverseadam::adsl |>
    dummy(mtcars) |>
    expect_error()
})
