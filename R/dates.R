#' Analysis start date
#' @description
#' Derives analysis start date based on (incomplete) dates given as
#' character 
#'
#' @param .self `data.frame` Input data set
#' @param dtc `character` Name of date variable
#' @type derivation
#' @depends .self {dtc}
#' @outputs ASTDT
#' @outputs ASTDTF
#' @returns `.self` with added analysis start date variables
#' @examples
#' x <- pharmaversesdtm::ae |> 
#'   dplyr::select(USUBJID, AESTDTC) |> 
#'   astdt("AESTDTC")
#' 
#' print(x)
#' 
#' x |> 
#'   dplyr::filter(!is.na(ASTDTF)) |> 
#'   print()
#' @export
astdt <- function(.self, dtc) {
  .self <- .self |> 
    dplyr::mutate(
      ASTDT = admiral::convert_dtc_to_dt(
        dtc = .data[[dtc]], 
        highest_imputation = "M", 
        date_imputation = "first"
      ),
      ASTDTF = admiral::compute_dtf(
        dtc = .data[[dtc]], 
        dt = .data$ASTDT
      )
    )
  
  return(.self)
}

#' Analysis end date
#' @description
#' Derives analysis end date based on (incomplete) dates given as
#' character 
#'
#' @param .self `data.frame` Input data set
#' @param dtc `character` Name of date variable
#' @type derivation
#' @depends .self {dtc}
#' @outputs AENDT
#' @outputs AENDTF
#' @returns `.self` with added analysis end date variables
#' @examples
#' x <- pharmaversesdtm::ae |> 
#'   dplyr::select(USUBJID, AEENDTC) |> 
#'   aendt("AEENDTC")
#' 
#' print(x)
#' 
#' x |> 
#'   dplyr::filter(!is.na(AENDTF)) |> 
#'   print()
#' @export
aendt <- function(.self, dtc) {
  .self <- .self |> 
    dplyr::mutate(
      AENDT = admiral::convert_dtc_to_dt(
        dtc = .data[[dtc]], 
        highest_imputation = "M", 
        date_imputation = "last"
      ),
      AENDTF = admiral::compute_dtf(
        dtc = .data[[dtc]], 
        dt = .data$AENDT
      )
    )
  
  return(.self)
}

#' Analysis relative day
#' @description
#' Derives the relative day compated to the treatment start date.
#' 
#' @param .self `data.frame` Input data set
#' @param date `character` Name of date variable to use
#' @depends .self {date}
#' @depends .self TRTSDT
#' @outputs {date}Y
#' @returns `.self` with added analysis relative day
#' @examples
#' pharmaverseadam::adae |> 
#'   dplyr::select(USUBJID, TRTSDT, ASTDT) |> 
#'   ady("ASTDT")
#' 
#' @export
ady <- function(.self, date) {
  dy <- stringr::str_replace(string = date, pattern = "T$", replacement = "Y")

  .self <- .self |> 
    dplyr::mutate(
      {{dy}} := admiral::compute_duration(
        start_date = .data$TRTSDT, 
        end_date = .data[[date]], 
        in_unit = "days", 
        out_unit = "days", 
        add_one = TRUE
      )
    )

  return(.self)
}
