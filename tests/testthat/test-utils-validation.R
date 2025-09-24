test_that("type checks", {
  assert_choice("Derived", valid_origins()) |>
    expect_no_condition() |>
    expect_equal("Derived")

  assert_choice("illegal origin", valid_origins()) |>
    expect_error()

  assert_choice("row", valid_types()) |>
    expect_no_condition() |>
    expect_equal("row")

  assert_choice("illegal type", valid_types()) |>
    expect_error()
})
