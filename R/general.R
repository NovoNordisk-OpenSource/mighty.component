#' Predecessor
#' @description
#' Creates a new column based on a predecessort columns.
#'
#' @param .self `data.frame` Input
#' @param x `data.frame` Data the predecessor is from. If `NULL` (default), the column is already in `.self`.
#' @param old Variable to use in `x`
#' @param new `character` name of new variable
#' @type predecessor
#' @depends .self USUBJID
#' @depends x USUBJID
#' @depends x {old}
#' @outputs {new}
#' @returns `.self` with added subject level Albumin grouping at baseline
#' @examples
#' pharmaverseadam::advs |>
#'   dplyr::select(USUBJID, PARAMCD, AVAL) |>
#'   predecessor(x = pharmaverse::adsl, old = ARM)
#'
#' @export
predecessor <- function(.self, x = .self, old, new = old) {

  .self <- .self |>
    dplyr::left_join(
      y = dplyr::select(x, USUBJID, "{{new}}" := {{old}}),
      by = "USUBJID"
    )

  return(.self)
}

