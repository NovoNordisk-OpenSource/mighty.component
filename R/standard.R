#' Retrieve mighty standard component
#' @param standard standard
#' @export
get_standard <- function(standard, library) {
  template <- find_standard(standard, library)
  mighty_standard$new(template = readLines(template))
}

#' Retrieve rendered mighty standard component
#' @param standard standard
#' @param params list of input parameters
#' @export
get_rendered_standard <- function(standard, params, library) {
  x <- get_standard(standard, library)
  do.call(what = x$render, args = params)
}

#' List all available standards
#' @export
list_standards <- function(library) {
  templates <- system.file(
    "components",
    package = library
  ) |> 
    list.files()

  gsub(pattern = "\\.mustache$", replacement = "", x = templates)
}

#' @noRd
find_standard <- function(standard, library) {
  if (!standard %in% list_standards(library)) {
    cli::cli_abort("Component {template} not found")
  }

  system.file(
    "components",
    paste0(standard, ".mustache"),
    package = "mighty.standards"
  )
}
