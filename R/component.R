#' Retrieve mighty code component
#' @description
#' Retrieve a mighty code component, supporting
#' both built-in standards and custom components from local files.
#'
#' * `get_component()`: Returns an object of class `mighty_component`
#' containing the standard or custom component.
#' * `get_rendered_component()`: Returns an object of class `mighty_component_rendered`
#' containing the rendered code component
#'
#' When rendering a component the required list of parameters depends on the individual component.
#' Check the documentation of the specific standard, or the local component, for details.
#'
#' @details Processes different component types based on file extension or
#' component name:
#'
#' * *No extension*: Looks for built-in standard components with that name.
#' * `.R`: Extracts and renders custom functions.
#' * `.mustache`: Creates components from the template files.
#'
#' @param component `character` specifying either a standard component name
#' or path to a custom component file (R or Mustache template).
#' @param params named `list` of input parameters. Passed along to `mighty_component$render()`.
#' @seealso [get_standard()], [get_rendered_standard()], [mighty_component], [mighty_component_rendered]
#' @examples
#' get_component("ady")
#'
#' get_rendered_component("ady", list(variable = "ASTDY", date = "ASTDT"))
#'
#' @rdname get_component
#' @export
get_component <- function(component) {
  file_type <- tolower(tools::file_ext(component))

  if (file_type != "" && !file.exists(component)) {
    cli::cli_abort("Component {.file {component}} not found")
  }

  switch(
    file_type,
    "r" = get_custom_r_function(component),
    "mustache" = mighty_component$new(
      template = readLines(component),
      id = component
    ),
    get_standard(component)
  )
}

#' @rdname get_component
#' @export
get_rendered_component <- function(component, params = list()) {
  x <- get_component(component)
  do.call(what = x$render, args = params)
}
