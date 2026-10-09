#' Find a component
#' @description
#' Find a component in one or more repos. Returns `NULL` if no repo contains
#' it, while [get_component()] raises an error. Local repo directories must
#' exist, otherwise an error is raised.
#'
#' @param component `character(1)` Component name. If `repos` is `NULL`, path
#' to a component file.
#' @param repos Where to look. One of:
#' * `NULL` (default): `component` is a file path.
#' * `character` vector of repo specs, in priority order. See [mighty_repo()].
#' * A `mighty_repo_class` object.
#' * A `list` of repo specs or `mighty_repo_class` objects, in priority order.
#' * A [mighty_repos()] collection.
#'
#' Character vectors and lists are converted once with [mighty_repos()].
#' @returns A [mighty_component] object, or `NULL` if no repo contains the
#' component.
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' find_component("ady", repos = path)
#'
#' find_component("does_not_exist", repos = path)
#' @seealso [get_component()], [list_components()]
#' @export
find_component <- function(component, repos = NULL) {
  check_string(component)

  if (is.null(repos)) {
    repos <- dirname(component)
    component <- basename(component)
  }

  if (
    !S7::S7_inherits(repos, mighty_repo_class) &&
      !S7::S7_inherits(repos, mighty_repos)
  ) {
    repos <- mighty_repos(repos = repos)
  }

  repo_find_component(repos = repos, component = component)
}

#' Find a component in repos
#' @noRd
repo_find_component <- S7::new_generic(
  name = "repo_find_component",
  dispatch_args = "repos",
  fun = function(repos, component) {
    S7::S7_dispatch()
  }
)
