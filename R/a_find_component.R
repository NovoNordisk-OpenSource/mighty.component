#' Find mighty code component
#' @description
#' Look up a component in one or more repos. Unlike [get_component()],
#' returns `NULL` instead of raising an error when no repo contains the
#' component. Each repo directory must exist, otherwise an error is raised.
#'
#' @param component `character` component name, or path to a component file
#' (`.R` or `.mustache`) when `repos` is `NULL`. The directory of the path must
#' exist.
#' @param repos Where to look. One of:
#' * `NULL` (default): `component` is a file path.
#' * `character` vector of repo specs, in priority order. See [mighty_repo()].
#' * A `mighty_repo_class` object.
#' * A `list` of repo specs or `mighty_repo_class` objects, in priority order.
#' * A [mighty_repos()] collection.
#'
#' Character vectors and lists are converted with [mighty_repos()]. GitHub
#' refs are resolved once per session. See [mighty_repo_github()] and
#' [mighty_repo_url()].
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
