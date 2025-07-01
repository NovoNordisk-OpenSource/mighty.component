test_that("get_rendered_standard returns rendered standard with valid inputs", {
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
#'
#' @param .self `data.frame` Input data set
#' @param date `character` Name of date variable to use
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
})

