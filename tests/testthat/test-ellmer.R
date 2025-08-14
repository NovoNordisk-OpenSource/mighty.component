test_that("method params give consistent output`", {
  ady <- test_path("_components", "ady_local.mustache") |>
    get_component()

  params <- eval_method(x = ady, method = "tool") |>
    expect_no_condition()

  params(variable = "a") |>
    expect_error("argument .* is missing")

  params(variable = "a", date = "b") |>
    expect_equal(
      list(
        id = test_path("_components", "ady_local.mustache"),
        params = list(
          variable = "a",
          date = "b"
        )
      )
    )
})

test_that("method render give consistent output`", {
  ady <- test_path("_components", "ady_local.mustache") |>
    get_component()

  render <- eval_method(
    x = ady,
    method = "tool",
    args = list("render")
  ) |>
    expect_no_condition()

  render(variable = "a") |>
    expect_error("argument .* is missing")

  render(variable = "a", date = "b") |>
    expect_equal(
      ady$render(variable = "a", date = "b")$template
    )
})

test_that("method eval give consistent output`", {
  component <- test_path("_components", "test_eval.mustache") |>
    get_component()

  evaltool <- eval_method(
    x = component,
    method = "tool",
    args = list("eval")
  ) |>
    expect_no_condition()

  evaltool(x1 = 1) |>
    expect_error("argument .* is missing")

  evaltool(x1 = "a", x2 = 1) |>
    expect_error("object 'x' not found")

  test_env <- withr::local_environment(
    env = parent.frame()
  )

  test_env$x <- 1

  withr::with_environment(
    env = test_env,
    code = {
      evaltool(x1 = "a", x2 = 1) |>
        expect_error("object 'a' not found")

      evaltool(x1 = 1, x2 = 2) |>
        expect_equal(8)
    }
  )
})
