#' Retrieve mighty standard component
#' @param standard standard
#' @export
get_standard <- function(standard) {
  template <- find_standard(standard)
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

#' List all available standards
#' @export
list_standards <- function() {
  templates <- system.file(
    "components",
    package = "mighty.standards"
  ) |> 
    list.files()

  gsub(pattern = "\\.mustache$", replacement = "", x = templates)
}

#' @noRd
find_standard <- function(standard) {
  path <- system.file(
    "components",
    paste0(standard, ".mustache"),
    package = "mighty.standards"
  )

  if (path == "") {
    cli::cli_abort("Component {standard} not found")
  }

  path
}
