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

test_that("test", {
  component <- test_path("_components", "test_component.mustache") |>
    get_rendered_component(params = list(x1 = 15, x2 = 35))

  component$code |>
    expect_equal(".self$NEWVAR <- 15 * Y$B + .self$A - 35")

  env <- new.env(parent = baseenv())

  assign(
    x = "Y",
    value = data.frame(B = c(3, 2, 10)),
    envir = env
  )

  eval_method(
    x = component,
    method = "test",
    args = list(
      input = data.frame(A = c(1, 5, 6)),
      expected = data.frame(
        A = c(1, 5, 6),
        NEWVAR = c(11, 0, 121)
      ),
      envir = env
    )
  )

  env$.self |>
    expect_null()
})

test_that("msr_test_coverage", {
  test_path("_components", "test_component.mustache") |>
    get_rendered_component(params = list(x1 = 5, x2 = 3)) |>
    eval_method(method = "test_coverage") |>
    expect_equal(0)
})
