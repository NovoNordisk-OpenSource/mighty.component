#' List components in repos
#' @description
#' List all available mighty components (`.R` and `.mustache` files)
#' in the given repos.
#'
#' A component is either a file directly in the repo, or a file named after
#' its directory one level down (`<name>/<name>.R`). Files starting with
#' `test-` are not listed.
#'
#' @param repos Where to look. One of:
#' * `character` vector of repo specs. See [mighty_repo()].
#' * A `mighty_repo_class` object.
#' * A `list` of repo specs or `mighty_repo_class` objects.
#' @param ... Not used.
#' @returns `character` vector of unique component names (without extension).
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' list_components(path)
#' @seealso [get_component()], [find_component()], [mighty_repo()]
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
