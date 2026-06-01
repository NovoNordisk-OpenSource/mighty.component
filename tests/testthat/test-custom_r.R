test_that("correct error handling", {
  readLines(test_path("_components", "illegal_param.R")) |>
    get_custom_r(id = "illegal_param.R") |>
    expect_error("@param.+ not allowed")

  readLines(test_path("_components", "illegal_mustache.R")) |>
    get_custom_r(id = "illegal_mustache.R") |>
    expect_error("mustache.+ not allowed")
})
