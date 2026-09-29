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

test_that("check_string passes for a non-empty string", {
  check_string("a") |>
    expect_no_error() |>
    expect_invisible()
})

test_that("check_string errors for anything else", {
  x <- c("a", "b")
  check_string(x) |>
    expect_error("`x` must be a single string, not a character vector")

  check_string(character(0)) |>
    expect_error("must be a single string")
  check_string(NA_character_) |>
    expect_error("must be a single string")
  check_string("") |>
    expect_error('must be a single string, not `""`', fixed = TRUE)
  check_string(1) |>
    expect_error("must be a single string, not a number")
})

test_that("check_number_whole passes for whole numbers from min", {
  check_number_whole(1, min = 1) |>
    expect_no_error() |>
    expect_invisible()

  check_number_whole(3L, min = 1) |>
    expect_no_error()
})

test_that("check_number_whole errors for anything else", {
  x <- 0
  check_number_whole(x, min = 1) |>
    expect_error("`x` must be a whole number larger than or equal to 1")

  check_number_whole(1.5, min = 1) |>
    expect_error("must be a whole number")
  check_number_whole(Inf, min = 1) |>
    expect_error("must be a whole number")
  check_number_whole(NA_real_, min = 1) |>
    expect_error("must be a whole number")
  check_number_whole(c(1, 2), min = 1) |>
    expect_error("must be a whole number")
  check_number_whole("a", min = 1) |>
    expect_error("must be a whole number")
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
