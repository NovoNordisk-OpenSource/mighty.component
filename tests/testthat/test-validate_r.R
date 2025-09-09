test_that("Custom R compotnent with multiple return()s fails ", {
  
# ARRANG -----------------------------------------------------------------
r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @depends A B
#' @outputs C
#' @code
hello <- function(a) {
  if(a){
  f <- function(b){return(NULL)}
  return(1)
  } else {
  return(2)
  }
}
"

path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con=path)
  
  # ACT ---------------------------
  expect_error(validate_r(
    r, path), "Multiple `return()` statments found in function `hello` defined in file")
})

test_that("Custom R file with multiple function definitions fails ", {
  
# ARRANG -----------------------------------------------------------------
r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @depends A B
#' @outputs C
#' @code
hello <- function(a) {
  NULL
}

hello_2 <- function(a) {
  NULL
}
"

path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con=path)
  
  # ACT ---------------------------
  expect_error(validate_r(
    r, path), "Only one function definition per file allowed")
})
