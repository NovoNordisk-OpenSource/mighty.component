test_that("get_rendered_component returns rendered custom code component with valid inputs", {
  # ARRANGE -------------------------------------------------------------------
  tmp_file <- withr::local_tempdir() |>
    file.path("ady.R")
  # Create a mock mustache template
  c(
    "
    #' Analysis relative day
#' @id ady
#' @description
#' Derives the relative day compared to the treatment start date.
#' @type derivation
#' @depends .self A
#' @outputs B
    hello <- function(a){
    print('hello')
    if(a){
    return(NULL)
    } else{
      return(1)
      }

  }"
  ) |>
    writeLines(con = tmp_file)
  # ACT ---------------------------
  x <- get_rendered_component(tmp_file)

  # ASSERT
  expect_s3_class(x, "mighty_standard_rendered")
  expect_snapshot_value(x$code, style = "json2")
  expect_equal(x$type, "derivation")
  expect_equal(x$depends, "A")
  expect_equal(x$outputs, "B")
})

test_that("get_rendered_component returns rendered STANDARD code component with valid inputs", {
  # ARRANGE -------------------------------------------------------------------
  # ACT ---------------------------
  x <- get_rendered_component(
    "ady",
    library = "mighty.standards",
    params = list(
      date = "date_var",
      variable = "out_var"
    )
  )

  # ASSERT ---------------------------
  expect_s3_class(x, "mighty_standard_rendered")
  expect_snapshot_value(x$code, style = "json2")
  expect_equal(x$type, "derivation")
  expect_equal(x$depends, c("date_var", "TRTSDT"))
  expect_equal(x$outputs, "out_var")
})

test_that("get_rendered_component errors in edge case where .mustache is part of the input name", {
  # ARRANGE -------------------------------------------------------------------
  # ACT & ASSERT ---------------------------
  x <- get_rendered_component(
    "ady.mustache",
    library = "mighty.standards",
    params = list(
      date = "date_var",
      variable = "out_var"
    )
  ) |> expect_error(
    regexp = "Component ady.mustache not found in mighty.standards"
  )
})
