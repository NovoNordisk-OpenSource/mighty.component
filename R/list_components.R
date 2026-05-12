#' List components in directories
#' @description
#' List all available mighty components (`.R` and `.mustache` files)
#' in the specified directories.
#'
#' @param path `character` vector of directory paths to search for components.
#' @param as Format to list the components in.
#' Default `character` lists component IDs (filenames without extension),
#' while `list` and `tibble` show detailed component metadata.
#' @returns Depending on `as`:
#' * `character`: vector of component IDs
#' * `list`: list of component metadata (id, title, description, params, depends, outputs, code)
#' * `tibble`: tibble with one row per component
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' list_components(path)
#'
#' list_components(path, as = "list") |> str(max.level = 1)
#' @seealso [get_component()]
#' @export
list_components <- function(path, as = c("character", "list", "tibble")) {
  as <- rlang::arg_match(as)

  missing <- path[!dir.exists(path)]
  if (length(missing) > 0) {
    cli::cli_abort("Director{?y/ies} not found: {.path {missing}}")
  }

  files <- unlist(lapply(path, function(p) {
    list.files(p, pattern = "\\.(R|mustache)$", full.names = TRUE)
  }))

  switch(
    EXPR = as,
    character = tools::file_path_sans_ext(basename(files)),
    list = lapply(files, function(f) {
      comp <- get_component(f)
      get_fields(comp, c("id", "title", "description", "params", "depends", "outputs", "code"))
    }),
    tibble = {
      rlang::check_installed("tibble")
      rlang::check_installed("tidyr")

      list_components(path, as = "list") |>
        tibble::enframe(name = NULL) |>
        tidyr::unnest_wider(col = "value")
    }
  )
}

#' @noRd
get_fields <- function(x, fields) {
  lapply(X = fields, FUN = \(field) x[[field]]) |>
    stats::setNames(fields)
}
