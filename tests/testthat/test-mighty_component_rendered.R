test_that("print", {
  test_path("_components", "test_component.mustache") |>
    get_rendered_component(params = list(x1 = 5, x2 = 3)) |>
    print() |>
    expect_snapshot()
})

test_that("stream", {
  component <- test_path("_components", "test_component.mustache") |>
    get_rendered_component(params = list(x1 = 5, x2 = 3))

  script <- withr::local_tempfile(fileext = ".R")

  component |>
    eval_method(
      method = "stream",
      args = list(path = script)
    ) |>
    expect_invisible() |>
    expect_equal(component)

  readLines(script) |>
    expect_equal(component$code)
})

test_that("eval", {
  component <- test_path("_components", "test_eval.mustache") |>
    get_rendered_component(params = list(x1 = 5, x2 = 3))

  component$code |>
    expect_equal("x + 5 + 5 * 3")

  env <- new.env(parent = baseenv())

  component |>
    eval_method(method = "eval", args = list(envir = env)) |>
    expect_error()

  assign(x = "x", value = 27, envir = env)

  component |>
    eval_method(method = "eval", args = list(envir = env)) |>
    expect_equal(47)
})
