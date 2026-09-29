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

zephyr::create_option(
  name = "max_tries",
  default = 3L,
  desc = "Maximum number of attempts for GitHub and URL requests. Transient errors (HTTP 5xx and network failures) are retried; other errors are not." # nolint: line_length_linter
)
