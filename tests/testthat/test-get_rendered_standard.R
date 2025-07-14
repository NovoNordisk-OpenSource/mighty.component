test_that("get_rendered_component, custom code component multiple depends", {
  # ARRANGE -------------------------------------------------------------------
  tmp_file <- withr::local_tempdir() |>
    file.path("ady.R")
  # Create a mock mustache template
  c(
    "
    #' Analysis relative day
#' @description
#' Derives the relative day compared to the treatment start date.
#' @param a text about a
#' @type derivation
#' @depends .self A
#' @depends lb A
#' @outputs B
    hello <- function(a){
    'hello' |> 
      print()
    if(a){
    NULL
    } else{
      a <- 1
      }
      return(.self)

  }"
  ) |>
    writeLines(con = tmp_file)
  # ACT ---------------------------
  x <- get_rendered_component(tmp_file)

  # ASSERT
  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot_value(x$code, style = "json2")
  expect_equal(x$type, "derivation")
  expect_equal(x$depends, data.frame(domain = c(".self", "lb"), column = c("A", "A")))
  expect_equal(x$outputs, "B")
})



test_that("get_rendered_component returns rendered STANDARD code component with valid inputs", {
  # ARRANGE -------------------------------------------------------------------
  # ACT ---------------------------
  x <- get_rendered_standard(
    "ady",
    params = list(
      date = "date_var",
      variable = "out_var"
    )
  )

  # ASSERT ---------------------------
  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot_value(x$code, style = "json2")
  expect_equal(x$type, "derivation")
  expect_equal(x$depends, data.frame(domain = rep(".self", 2), column = c("date_var", "TRTSDT")))
  expect_equal(x$outputs, "out_var")
})

