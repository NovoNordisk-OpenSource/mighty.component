test_that("correct error handling", {
  readLines(test_path("_components", "illegal_param.R")) |>
    check_custom_r() |>
    expect_error("@param.+ not allowed")

  readLines(test_path("_components", "illegal_mustache.R")) |>
    check_custom_r() |>
    expect_error("mustache.+ not allowed")
})

test_that("valid code is returned invisibly", {
  code <- readLines(test_path("_components", "ady_local.R"))

  check_custom_r(code = code) |>
    expect_invisible() |>
    expect_equal(expected = code)
})
