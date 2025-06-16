#' Treatment-emergent flag
#' @description
#' Derives treatment emergent analysis flag.
#'
#' @param .self `data.frame` Input data set
#' @param end_window Passed along to `admiral::end_window()`
#' @type derivation
#' @depends .self ASTDT
#' @depends .self AENDT
#' @depends .self TRTSDT
#' @depends .self TRTEDT
#' @outputs TRTEMFL
#' @returns `.self` with added treatment emergent analysis flag.
#' @examples
#' pharmaverseadam::adae |>
#'   dplyr::select(ASTDT, AENDT, TRTSDT, TRTEDT) |>
#'   trtemfl()
#'
#' @export
trtemfl <- function(.self) {
  .self <- .self |>
    admiral::derive_var_trtemfl(
      start_date = ASTDT, 
      end_date = AENDT,
      trt_start_date = TRTSDT,
      trt_end_date = TRTEDT,
      end_window = 30
    )

  return(.self)
}
