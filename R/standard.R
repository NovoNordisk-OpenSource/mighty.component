#' Retrieve mighty standard component
#' @param standard standard
#' @export
get_standard <- function(standard, package) {
  template <- find_standard(standard, package)
  mighty_standard$new(template = readLines(template))
}

#' Retrieve rendered mighty standard component
#' @param standard standard
#' @param params list of input parameters
#' @export
get_rendered_standard <- function(standard, params, package) {
  x <- get_standard(standard, package)
  do.call(what = x$render, args = params)
}

#' List all available standards
#' @export
list_standards <- function(package) {
  templates <- system.file(
    "components",
    package = package
  ) |> 
    list.files()

  gsub(pattern = "\\.mustache$", replacement = "", x = templates)
}

#' @noRd
find_standard <- function(standard, package) {
  if (!standard %in% list_standards(package)) {
    cli::cli_abort("Component {template} not found")
  }

  system.file(
    "components",
    paste0(standard, ".mustache"),
    package = "mighty.standards"
  )
}
