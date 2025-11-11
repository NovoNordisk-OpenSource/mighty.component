test_that("Testing workflow works", {
  x <- test_component(
    component = test_path("_components", "test_coverage.mustache"),
    params = list(x = 1, y = 1),
    check_coverage = !covr::in_covr()
  )

  expect_snapshot(x)

  test_eval(input = data.frame(z = 1), component = x) |>
    expect_equal(
      data.frame(z = 3)
    )

  test_eval(input = data.frame(z = 10), component = x) |>
    expect_equal(
      data.frame(z = 10)
    )
})

test_that("Objects are passed along correctly", {
  skip("TODO: Implement in code")

  x <- test_component(
    component = test_path("_components", "test_component.mustache"),
    params = list(x1 = 1, x2 = 3)
  )

  expect_snapshot(x)

  Y <- data.frame(B = 1)

  test_eval(
    input = data.frame(A = 1),
    component = x
  ) |>
    expect_equal(-3)
})

test_that("Error with no test code coverage", {
  local({
    test_component(
      component = test_path("_components", "test_component.mustache"),
      params = list(x1 = 1, x2 = 3)
    )
  }) |>
    expect_error("ALL LINES MUST BE COVERED")
})
