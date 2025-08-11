test_that("get_rendered_component, custom code component as function multiple depends", {
  # ACT ---------------------------
  x <- get_rendered_component(
    component = test_path("_components", "ady.R")
  )

  # ASSERT
  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot(x)
  expect_equal(x$type, "derivation")
  expect_equal(
    x$depends,
    data.frame(domain = c(".self", "lb"), column = c("A", "A"))
  )
  expect_equal(x$outputs, "B")
})


test_that("get_rendered_component custom local mustache template with params", {
  # ACT ---------------------------
  x <- get_rendered_component(
    component = test_path("_components", "ady_local.mustache"),
    params = list(
      date = "date_var",
      variable = "out_var"
    )
  )

  # ASSERT
  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot(x)
  expect_equal(x$type, "derivation")
  expect_equal(
    x$depends,
    data.frame(domain = rep(".self", 2), column = c("date_var", "TRTSDT"))
  )
  expect_equal(x$outputs, "out_var")
})


test_that("get_rendered_component returns rendered STANDARD code component with valid inputs", {
  # ARRANGE -------------------------------------------------------------------
  # ACT ---------------------------
  y <- get_rendered_component(
    component = "ady",
    params = list(
      date = "date_var",
      variable = "out_var"
    )
  )

  # ASSERT ---------------------------
  expect_s3_class(y, "mighty_component_rendered")
  expect_snapshot(y)
  expect_equal(y$type, "derivation")
  expect_equal(
    y$depends,
    data.frame(domain = rep(".self", 2), column = c("date_var", "TRTSDT"))
  )
  expect_equal(y$outputs, "out_var")
})

test_that("Error when any parameter insufficiently parameterized" , {
  template <- c(
  "#' @param variable ",
  "#' @param date ",
  "#' @type derivation",
  "#' @depends .self {{ date }}",
  "#' @depends .self TRTSDT",
  "#' @outputs {{ variable }}",
  "print('hello')"
)

expect_error(mighty.standards::mighty_component$new(template), "All `@params` tags must have both a name and description")
})
