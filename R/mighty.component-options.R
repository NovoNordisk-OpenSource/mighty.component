#' @title Options for mighty.component
#' @name mighty.component-options
#' @description
#' `r zephyr::list_options(as = "markdown", .envir = "mighty.component")`
NULL

#' @title Internal parameters for reuse in functions
#' @name mighty.component-options-params
#' @eval zephyr::list_options(as = "params", .envir = "mighty.component")
#' @details
#' See [mighty.component-options] for more information.
#' @keywords internal
NULL

zephyr::create_option(
  name = "verbosity_level",
  default = NA_character_,
  desc = "Verbosity level for functions in mighty.component. See [zephyr::verbosity_level] for details." # nolint: line_length_linter
)
