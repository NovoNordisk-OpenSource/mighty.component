test_that("general testing workflow", {
  x <- get_test_component(
    component = test_path("_components", "ady_local.mustache"),
    params = list(domain = "adlb", variable = "ADY2", date = "ADT")
  )

  x$assign("adlb", head(pharmaverseadam::adlb, 5)) |>
    expect_invisible()

  x$ls() |>
    expect_visible() |>
    expect_equal("adlb")

  x$get("adlb") |>
    names() |>
    intersect("ADY2") |>
    expect_length(0)

  x$percent_coverage |>
    expect_equal(0)

  x$eval() |>
    expect_invisible()

  x$get("adlb") |>
    expect_visible() |>
    names() |>
    expect_contains("ADY2")

  x$percent_coverage |>
    expect_equal(100)

  x$line_coverage |>
    expect_s3_class("data.frame")

  x$check_coverage() |>
    expect_no_error()

  x$line_coverage$value |>
    min() |>
    expect_equal(1)
})

test_that("Error with no test code coverage", {
  local({
    get_test_component(
      component = test_path("_components", "test_component.mustache"),
      params = list(domain = "a", x1 = 1, x2 = 3)
    )
  }) |>
    expect_error("All lines in component must be covered by unit tests")
})
