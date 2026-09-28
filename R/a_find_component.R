#' Find mighty code component
#' @description
#' Look up a component in one or more repos. Unlike [get_component()],
#' returns `NULL` instead of raising an error when the component is not found.
#'
#' @param component `character` component name, or path to a component file
#' (`.R` or `.mustache`) when `repos` is `NULL` or missing.
#' @param repos Where to look. One of:
#' * `NULL` or missing: `component` is a file path.
#' * `character` vector of repo specs, in priority order. See [mighty_repo()].
#' * A `mighty_repo_class` object.
#' * A `list` of repo specs or `mighty_repo_class` objects, in priority order.
#' * A [mighty_repos()] collection.
#'
#' Character vectors and lists are converted with [mighty_repos()]. To look up
#' several components, create the collection once and reuse it, so GitHub
#' refs are only resolved once.
#' @param ... Not used.
#' @returns A [mighty_component] object, or `NULL` if not found.
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' find_component("ady", repos = path)
#'
#' find_component("does_not_exist", repos = path)
#' @seealso [get_component()], [list_components()]
#' @export
find_component <- S7::new_generic(
  name = "find_component",
  dispatch_args = c("component", "repos"),
  fun = function(component, repos, ...) {
    check_string(component, allow_empty = FALSE)
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, S7::new_S3_class("NULL"))
) <- function(component, repos) {
  find_component(
    component = basename(component),
    repos = dirname(component)
  )
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, S7::class_missing)
) <- function(component, repos) {
  find_component(component = component, repos = NULL)
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, S7::class_list)
) <- function(component, repos) {
  find_component(component = component, repos = mighty_repos(repos = repos))
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, S7::class_character)
) <- function(component, repos) {
  find_component(component = component, repos = mighty_repos(repos = repos))
}
