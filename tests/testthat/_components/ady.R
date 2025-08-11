#' @title Analysis relative day
#' @description
#' Derives the relative day compared to the treatment start date.
#' @type derivation
#' @depends .self A
#' @depends lb A
#' @outputs B
hello <- function(a) {
  "hello" |>
    print()
  if (a) {
    NULL
  } else {
    a <- 1
  }
  return(.self)
}
