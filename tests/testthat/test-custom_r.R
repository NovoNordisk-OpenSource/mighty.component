test_that("correct error handling", {
  test_path("_components", "illegal_param.R") |>
    get_custom_r() |>
    expect_error("@param.+ not allowed")

  test_path("_components", "illegal_mustache.R") |>
    get_custom_r() |>
    expect_error("mustache.+ not allowed")
})
