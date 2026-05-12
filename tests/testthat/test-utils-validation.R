test_that("type checks", {
  assert_type("column") |>
    expect_no_condition() |>
    expect_equal("column")

  assert_type("row") |>
    expect_no_condition() |>
    expect_equal("row")

  assert_type("parameter") |>
    expect_no_condition() |>
    expect_equal("parameter")

  assert_type("internal") |>
    expect_no_condition() |>
    expect_equal("internal")

  assert_type("derivation") |>
    expect_error()

  assert_type("illegal type") |>
    expect_error()
})

test_that("origin checks", {
  assert_origin("Assigned") |>
    expect_no_condition() |>
    expect_equal("Assigned")

  assert_origin("Collected") |>
    expect_no_condition() |>
    expect_equal("Collected")

  assert_origin("Derived") |>
    expect_no_condition() |>
    expect_equal("Derived")

  assert_origin("Not Available") |>
    expect_no_condition() |>
    expect_equal("Not Available")

  assert_origin("Other") |>
    expect_no_condition() |>
    expect_equal("Other")

  assert_origin("Predecessor") |>
    expect_no_condition() |>
    expect_equal("Predecessor")

  assert_origin("Protocol") |>
    expect_no_condition() |>
    expect_equal("Protocol")

  assert_origin(NULL) |>
    expect_no_condition() |>
    expect_null()

  assert_origin("illegal origin") |>
    expect_error()
})
