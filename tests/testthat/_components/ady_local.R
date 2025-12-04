#' @title Analysis relative day
#' @description
#' Derives the relative day compared to the treatment start date.
#' @type derivation
#' @depends domain date_var
#' @depends domain TRTSDT
#' @outputs out_var
#' @code
domain <- domain |>
  dplyr::mutate(
    out_var = admiral::compute_duration(
      start_date = TRTSDT,
      end_date = date_var,
      in_unit = "days",
      out_unit = "days",
      add_one = TRUE
    )
  )
