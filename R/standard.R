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
#' @inheritParams get_component
#' @seealso [list_standards()], [mighty_component], [mighty_component_rendered]
#' @examples
#' get_standard("ady")
#'
#' get_rendered_standard("ady", list(domain = "advs", variable = "ASTDY", date = "ASTDT"))
#' @rdname get_standard
#' @export
get_standard <- function(standard) {
  template <- find_standard(standard)
  mighty_component$new(
    template = readLines(template),
    id = standard
  )
}

#' @rdname get_standard
#' @export
get_rendered_standard <- function(standard, params = list()) {
  x <- get_standard(standard)
  do.call(what = x$render, args = params)
}

#' List all available standards
#' @description
#' List all available mighty standard components.
#'
#' @param as Format to list the standards in.
#' Default `character` just lists the names,
#' while `list` and `tibble` show more detailed information.
#' @returns `character` vector of standard names
#' @examples
#' # Simple character list of all standard ids:
#' list_standards()
#'
#' # Tibble for an easy overview
#' list_standards(as = "tibble")
#'
#' # List (only showing first 2):
#' list_standards(as = "list") |>
#'   head(2) |>
#'   str()
#' @export
list_standards <- function(as = c("character", "list", "tibble")) {
  as <- rlang::arg_match(as)

  switch(
    EXPR = as,
    character = gsub(
      pattern = "\\.mustache$",
      replacement = "",
      x = list.files(standard_path())
    ),
    list = list_standards(as = "character") |>
      lapply(FUN = get_standard) |>
      lapply(
        FUN = get_fields,
        fields = c(
          "id",
          "title",
          "description",
          "params",
          "depends",
          "outputs",
          "code"
        )
      ),
    tibble = {
      rlang::check_installed("tibble")
      rlang::check_installed("tidyr")

      list_standards("list") |>
        tibble::enframe(name = NULL) |>
        tidyr::unnest_wider(col = "value")
    }
  )
}

#' @noRd
standard_path <- function() {
  system.file("components", package = "mighty.component")
}

#' @noRd
get_fields <- function(x, fields) {
  lapply(X = fields, FUN = \(field) x[[field]]) |>
    stats::setNames(fields)
}

#' @noRd
find_standard <- function(standard) {
  path <- paste0(standard_path(), "/", standard, ".mustache")

  if (!file.exists(path)) {
    cli::cli_abort("Component {.field {standard}} not found")
  }

  path
}
