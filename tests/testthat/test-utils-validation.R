test_that("assert_single_match passes for length 0", {
  assert_single_match(character(0)) |>
    expect_no_error() |>
    expect_invisible()
})

test_that("assert_single_match passes for length 1", {
  assert_single_match("one") |>
    expect_no_error() |>
    expect_invisible()
})

test_that("assert_single_match errors for length > 1", {
  assert_single_match(c("a", "b")) |>
    expect_error("Multiple matches")
})

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

  assert_origin("illegal origin") |>
    expect_error()
})
