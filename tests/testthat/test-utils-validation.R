test_that("type checks", {
  assert_type("column") |>
    expect_no_condition() |>
    expect_equal("column")

  assert_type("illegal type") |>
    expect_error()
})

test_that("origin checks", {
  assert_origin("Derived") |>
    expect_no_condition() |>
    expect_equal("Derived")

  assert_origin(NULL) |>
    expect_no_condition() |>
    expect_null()

  assert_origin("illegal origin") |>
    expect_error()
})
