#' Retrieve mighty standard component
#' @description
#' Retrieve either the generalized standard component (template) or
#' the rendered standard component with code that is ready to use.
#'
#' * `get_standard()`: Returns an object of class `mighty_component`
#' * `get_rendered_standard()`: Returns an object of class `mighty_component_rendered`
#'
#' When rendering the standard the required list of parameters depends on the standard.
#' Check the documentation of the specific standard for details.
#'
#' @param standard `character` name of the standard component to retrieve.
#' @param params named `list` of input parameters. Passed along to `mighty_component$render()`.
#' @seealso [list_standards()], [mighty_component], [mighty_component_rendered]
#' @examples
#' get_standard("ady")
#'
#' get_rendered_standard("ady", list(variable = "ASTDY", date = "ASTDT"))
#' @rdname get_standard
#' @export
get_standard <- function(standard) {
  template <- find_standard(standard)
  mighty_component$new(template = readLines(template))
}

#' @rdname get_standard
#' @export
get_rendered_standard <- function(standard, params) {
  x <- get_standard(standard)
  do.call(what = x$render, args = params)
}

#' List all available standards
#' @description
#' List all available mighty standard components.
#'
#' @returns `character` vector of standard names
#' @examples
#' available_standards <- list_standards()
#' cat(available_standards, sep = "\n")
#'
#' @export
list_standards <- function() {
  templates <- standard_path() |>
    list.files()

  gsub(pattern = "\\.mustache$", replacement = "", x = templates)
}

#' @noRd
standard_path <- function() {
  # TODO: Point to new path when implemented
  system.file("components", package = "mighty.standards")
}

#' @noRd
find_standard <- function(standard) {
  path <- paste0(standard_path(), "/", standard, ".mustache")

  if (!file.exists(path)) {
    cli::cli_abort("Component {standard} not found")
  }

  path
}
