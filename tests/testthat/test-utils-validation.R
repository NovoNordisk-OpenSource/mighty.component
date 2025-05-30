test_that("type checks", {
  assert_type("derivation") |>
    expect_no_condition() |>
    expect_equal("derivation")

  assert_type("illegal type") |>
    expect_error()
})
