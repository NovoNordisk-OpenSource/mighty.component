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
#' * `list`: list of component metadata
#'   (id, title, description, params, depends, outputs, code)
#' * `tibble`: tibble with one row per component
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' list_components(path)
#'
#' list_components(path, as = "list") |> str(max.level = 1)
#' @seealso [get_component()]
#' @export
list_components <- S7::new_generic(
  name = "list_components",
  dispatch_args = "repos"
)


#' @noRd
S7::method(list_components, S7::class_list) <- function(repos) {
  out <- vector(mode = "list", length = length(repos))

  for (i in seq_along(repos)) {
    out[[i]] <- list_components(repos = repos[[i]])
  }

  unique(unlist(out))
}

#' @noRd
S7::method(list_components, S7::class_character) <- function(repos) {
  if (length(repos) > 1L) {
    return(
      list_components(repos = as.list(repos))
    )
  }

  list_components(
    repos = mighty_repo(repos)
  )
}
