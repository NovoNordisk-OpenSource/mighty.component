test_that("Custom R component with multiple return()s fails ", {
  # ARRANGE -----------------------------------------------------------------
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
  return(1)
  } else {
  return(2)
  }
}
"
  path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con = path)

  # ACT ------------------ ---------
  expect_error(
    validate_r(
      r,
      path
    ),
    "i Only one `return\\(\\)` is allowed in the top-level function body"
  )
})

test_that("Nested function `return()`s are allowed", {
  # ARRANGE -----------------------------------------------------------------
  r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @depends A B
#' @outputs C
#' @code
hello <- function() {
  f1 <- function()return(FALSE)
  return(TRUE)
}
"
  path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con = path)

  # ACT ------------------ ---------
  expect_no_error(
    validate_r(
      r,
      path
    )
  )
})



test_that("Custom R including code outside the function def fails ", {
  # ARRANGE -----------------------------------------------------------------
  r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @depends A B
#' @outputs C
#' @code
hello <- function(a) {
return(TRUE)
}
TRUE
"
  path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con = path)

  # ACT ------------------ ---------
  expect_error(
    validate_r(
      r,
      path
    ),
    "Multiple top-level expressions found in"
  )
})

test_that("Custom R file with multiple function definitions fails ", {
  # ARRANGE -----------------------------------------------------------------
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
  writeLines(r, con = path)

  # ACT ---------------------------
  expect_error(
    validate_r(
      r,
      path
    ),
    "Each file must contain exactly one function definition"
  )
})

test_that("Custom R file trying to use parameters fails ", {
  # ARRANG -----------------------------------------------------------------
  r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @param A Dummy 
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
  expect_error(
    validate_r(r, path),
    "x Parameters are not supported for custom R components"
  )
})

test_that("Custom R file with no function defined fails", {
  # ARRANG -----------------------------------------------------------------
  r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @depends A B
#' @outputs C
#' @code
ADLB <- ADLB |> 
  dplyr::filter(B == TRUE)
"

  path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con = path)

  # ACT ---------------------------
  expect_error(
    validate_r(
      r,
      path
    ),
    "Expected a single top-level function definition in"
  )
})

test_that("Custom R file with no function defined fails", {
  # ARRANG -----------------------------------------------------------------
  r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @depends A B
#' @outputs C
#' @code
"

  path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con = path)

  # ACT ---------------------------
  expect_error(
    validate_r(
      r,
      path
    ),
    "No top-level function definition found in"
  )
})

test_that("Invalid R code fails", {
  # ARRANG -----------------------------------------------------------------
  r <- "
#' @title TITLES
#' @description
#' short desc.
#' @type derivation
#' @depends A B
#' @outputs C
#' @code
ADLB <- ADLB |>+
  dplyr::filter(B == TRUE)
"

  path <- withr::local_tempfile(fileext = ".R")
  writeLines(r, con = path)

  # ACT ---------------------------
  expect_error(
    validate_r(
      r,
      path
    ),
    "Failed to parse R code in"
  )
})

