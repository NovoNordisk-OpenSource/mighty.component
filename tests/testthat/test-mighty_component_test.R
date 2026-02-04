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
  x <- test_component(
    component = test_path("_components", "test_component.mustache"),
    params = list(x1 = 1, x2 = 3),
    check_coverage = FALSE
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
    expect_error("All lines in component must be covered by unit tests")
})

test_that("my component", {
  skip()

  x <- get_test_component("my_component", param = list(...)) # --> associated callr R session

  # Setup requirements
  x$assign("adsl", pharmaverseadam::adsl)
  x$assign("advs", pharmaverseadam::advs |> dplyr::select(-AVISIT))

  x$eval() # --> runs and tracks coverage

  x$get("advs") |> # --> gets outpuit
    expect_something()
})
