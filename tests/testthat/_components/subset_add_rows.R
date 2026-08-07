#' @title Add rows (custom R)
#' @description
#' Custom .R version of adding new rows derived from existing ones.
#' @type row
#' @depends ADLB LBTEST
#' @outputs LBTEST
#' @code
new_rows <- ADLB |>
  dplyr::filter(LBTEST == "Microcytes") |>
  dplyr::mutate(LBTEST = "Microcytes (new)")

ADLB <- rbind(ADLB, new_rows)
