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
  desc = "Maximum number of attempts for GitHub and URL requests. See [mighty_repo_github()] and [mighty_repo_url()] for which errors are retried." # nolint: line_length_linter
)

zephyr::create_option(
  name = "timeout",
  default = 5,
  desc = "Maximum number of seconds per URL request attempt. See [mighty_repo_url()]." # nolint: line_length_linter
)

#' @noRd
get_max_tries <- function() {
  max_tries <- zephyr::get_option(
    name = "max_tries",
    .envir = "mighty.component"
  )

  check_number_whole(
    x = max_tries,
    min = 1,
    arg = "mighty.component.max_tries"
  )

  max_tries
}

#' @noRd
get_timeout <- function() {
  timeout <- zephyr::get_option(
    name = "timeout",
    .envir = "mighty.component"
  )

  check_number_positive(
    x = timeout,
    arg = "mighty.component.timeout"
  )

  timeout
}
