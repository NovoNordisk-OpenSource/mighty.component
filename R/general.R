#' Predecessor
#' @description
#' Creates new column(s) based on a predecessor column(s).
#'
#' @param .self `data.frame` Input data set
#' @param source `data.frame` Data set the predecessor is from
#' @param variable `character` Name of variable(s) to use from `source`
#' @param by `character` name of variables to merge by
#' @type predecessor
#' @depends .self USUBJID
#' @depends source USUBJID
#' @depends source {variable}
#' @outputs {variable}
#' @returns `.self` with added predecessor variable
#' @examples
#' pharmaverseadam::advs |>
#'   dplyr::select(USUBJID, PARAMCD, AVAL) |>
#'   predecessor(source = pharmaverseadam::adsl, variable = "ACTARM")
#' 
#' pharmaverseadam::advs |>
#'   dplyr::select(USUBJID, PARAMCD, AVAL) |>
#'   predecessor(source = pharmaverseadam::adsl, variable = c("AGE", "AGEU"))
#'
#' @export
predecessor <- function(.self, source, variable, by = "USUBJID") {
  .self <- .self |>
    dplyr::left_join(
      y = dplyr::select(source, tidyselect::all_of(by), tidyselect::all_of(variable)),
      by = by
    )

  return(.self)
}

#' Assign
#' @description
#' Assigns a single value to an entire column.
#'
#' @param .self `data.frame` Input data set
#' @param variable `character` Name of variable to create or modify
#' @param value Value to assign to the variable
#' @type derivation
#' @depends nothing not
#' @outputs {variable}
#' @returns `.self` with added or modified variable
#' @examples
#' pharmaverseadam::adsl |>
#'   dplyr::select(USUBJID) |>
#'   assigned(variable = "STUDYID", value = "STUDY001")
#'
#' @export
assigned <- function(.self, variable, value) {
  .self <- .self |>
    dplyr::mutate({{ variable }} := value)

  return(.self)
}