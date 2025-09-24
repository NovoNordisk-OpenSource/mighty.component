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

test_that("Custom R file with single function definition succeeds", {
  # ARRANGE -----------------------------------------------------------------
  r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @depends ADLB AGE
#' @outputs C
#' @code
hello <- function() {
  # code comments
  ADLB <- ADLB |> 
    dplyr::filter(AGE > 60)
  return(ADLB)
}
"

  path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con = path)

  # ACT ---------------------------
  actual <- expect_no_error(get_rendered_component(path))

  # ASSERT -----------------------------------------------------------------
  expect_snapshot(actual$code)
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

test_that("No existing mustache file", {
  get_component("my/fake/file.mustache") |>
    expect_error("not found")

  get_rendered_component("my/other/fake/file.mustache", list()) |>
    expect_error("not found")
})
