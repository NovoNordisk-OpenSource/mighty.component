#' Retrieve mighty standard component
#' @param standard standard
#' @export
get_standard <- function(standard) {
  template <- system.file(
    "components",
    standard,
    package = "mighty.standards"
  ) |>
    paste0(".mustache")

  if (!file.exists(template)) {
    cli::cli_abort("Component {template} not found")
  }

  mighty_standard$new(template = readLines(template))
}

#' Retrieve rendered mighty standard component
#' @param standard standard
#' @param params list of input parameters
#' @export
get_rendered_standard <- function(standard, params) {
  x <- get_standard(standard)
  do.call(what = x$render, args = params)
}
