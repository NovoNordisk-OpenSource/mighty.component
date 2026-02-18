test_that("print", {
  test_path("_components", "test_component.mustache") |>
    get_rendered_component(params = list(domain = "domain", x1 = 5, x2 = 3)) |>
    print() |>
    expect_snapshot()
})

test_that("stream", {
  component <- test_path("_components", "test_component.mustache") |>
    get_rendered_component(params = list(domain = "domain", x1 = 5, x2 = 3))

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

test_that("validation runs automatically when rendering component with invalid code", {
  # Template with mustache parameters
  invalid_template <- c(
    "#' @title title",
    "#' @description Desc",
    "#' @param domain the data set being changes",
    "#' @param dataset The dataset to join",
    "#' @param join_type The type of join function",
    "#' @type derivation",
    "#' @depends {{ domain }} USUBJID",
    "#' @outputs NEWVAR",
    "#' @code",
    "{{ domain }} <- {{ domain }} |>",
    "  dplyr::{{ join_type }}({{ dataset }})"
  )

  component <- mighty_component$new(
    template = invalid_template,
    id = "test_invalid"
  )

  component$render(
    domain = "x",
    dataset = "other_data",
    join_type = "left_join"
  ) |>
    expect_error(
      "Component validation failed"
    )
  component$render(
    domain = "x",
    dataset = "other_data",
    join_type = "left_join"
  ) |>
    expect_error(
      "Implicit.*join"
    )
})
