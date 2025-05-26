#' Treatment-emergent flag
#' @description
#' Derives treatment emergent analysis flag.
#'
#' @param .self `data.frame` Input data set
#' @type derivation
#' @depends .self ASTDT
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
    dplyr::mutate(
      TRTEMFL = dplyr::case_when(
        .data$ASTDT < .data$TRTSDT ~ NA_character_,
        .data$TRTEDT < .data$ASTDT ~ NA_character_,
        TRUE ~ "Y"
      )
    )
  
  return(.self)
}
