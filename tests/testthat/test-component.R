test_that("get_rendered_component, custom code component from R script", {
  x <- get_rendered_component(
    component = test_path("_components", "ady_local.R")
  )

  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot(x)
  expect_equal(x$type, "derivation")
  expect_equal(
    x$depends,
    data.frame(domain = rep("domain", 2), column = c("date_var", "TRTSDT"))
  )
  expect_equal(x$outputs, "out_var")
})


test_that("get_rendered_component custom local mustache template with params", {
  x <- get_rendered_component(
    component = test_path("_components", "ady_local.mustache"),
    params = list(
      domain = "domain",
      date = "date_var",
      variable = "out_var"
    )
  )

  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot(x)
  expect_equal(x$type, "derivation")
  expect_equal(
    x$depends,
    data.frame(domain = rep("domain", 2), column = c("date_var", "TRTSDT"))
  )
  expect_equal(x$outputs, "out_var")
})


test_that("get_rendered_component returns rendered STANDARD code component with valid inputs", {
  y <- get_rendered_component(
    component = "ady",
    params = list(
      domain = "domain",
      date = "date_var",
      variable = "out_var"
    )
  )

  expect_s3_class(y, "mighty_component_rendered")
  expect_snapshot(y)
  expect_equal(y$type, "derivation")
  expect_equal(
    y$depends,
    data.frame(domain = rep("domain", 2), column = c("date_var", "TRTSDT"))
  )
  expect_equal(y$outputs, "out_var")
})

test_that("error handling", {
  get_component("my/fake/file.mustache") |>
    expect_error("not found")

  get_rendered_component("my/other/fake/file.mustache", list()) |>
    expect_error("not found")
})

test_that("Error when any parameter insufficiently parameterized", {
  template <- c(
    "#' @title Mistake in parameters",
    "#' @description This is a test component with missing parameters.",
    "#' @param variable",
    "#' @param date ",
    "#' @type derivation",
    "#' @depends .self {{ date }}",
    "#' @depends .self TRTSDT",
    "#' @outputs {{ variable }}",
    "print('hello')"
  )

  expect_error(
    object = mighty.component::mighty_component$new(
      template = template,
      id = "test_error"
    ),
    regexp = "Missing description for `variable` and `date`"
  )
})
