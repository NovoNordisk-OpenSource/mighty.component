#' List components in repos
#' @description
#' List all available mighty components in the given repos. See
#' [mighty_repo()] for the component layout. Files starting with `test-` are
#' not listed.
#'
#' @param repos Where to look. One of:
#' * `character` vector of repo specs. See [mighty_repo()].
#' * A `mighty_repo_class` object.
#' * A `list` of repo specs or `mighty_repo_class` objects.
#' * A [mighty_repos()] collection.
#'
#' Character vectors and lists are converted once with [mighty_repos()], so
#' GitHub refs are only resolved once. See [mighty_repo_url()].
#' @param as Format to list the components in:
#' * `"character"`: component names (filenames without extension).
#' * `"list"`: metadata for each component.
#' * `"tibble"`: metadata for each component as a tibble. Requires the
#'   `tibble` and `tidyr` packages.
#'
#' When a component exists in several repos, the metadata is taken from the
#' first repo, as in [find_component()].
#' @returns Depending on `as`:
#' * `"character"`: `character` vector of unique component names.
#' * `"list"`: `list` with one element per component, each a named `list` with
#'   `id`, `title`, `description`, `type`, `origin`, `method`, `params`,
#'   `depends`, `outputs` and `code`.
#' * `"tibble"`: tibble with one row per component and the same columns.
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' list_components(path)
#'
#' list_components(path, as = "list") |>
#'   str(max.level = 2)
#' @seealso [get_component()], [find_component()], [mighty_repo()]
#' @export
list_components <- function(repos, as = c("character", "list", "tibble")) {
  as <- rlang::arg_match(as)

  if (as == "tibble") {
    rlang::check_installed(c("tibble", "tidyr"))
  }

  if (
    !S7::S7_inherits(repos, mighty_repo_class) &&
      !S7::S7_inherits(repos, mighty_repos)
  ) {
    repos <- mighty_repos(repos = repos)
  }

  ids <- component_ids(repos = repos)

  if (as == "character") {
    return(ids)
  }

  components <- withr::with_options(
    new = list(mighty.component.verbosity_level = "quiet"),
    code = lapply(
      X = ids,
      FUN = \(id) {
        repo_find_component(repos = repos, component = id) |>
          component_fields()
      }
    )
  )

  if (as == "list") {
    return(components)
  }

  if (!length(components)) {
    return(empty_components_tibble())
  }

  components |>
    tibble::enframe(name = NULL) |>
    tidyr::unnest_wider(col = "value")
}

#' @noRd
component_fields <- function(x) {
  fields <- c(
    "id",
    "title",
    "description",
    "type",
    "origin",
    "method",
    "params",
    "depends",
    "outputs",
    "code"
  )

  lapply(X = fields, FUN = \(field) x[[field]]) |>
    stats::setNames(fields)
}

#' @noRd
empty_components_tibble <- function() {
  tibble::tibble(
    id = character(0),
    title = character(0),
    description = character(0),
    type = character(0),
    origin = character(0),
    method = character(0),
    params = list(),
    depends = list(),
    outputs = list(),
    code = list()
  )
}

#' Unique component names in repos
#' @noRd
component_ids <- S7::new_generic(
  name = "component_ids",
  dispatch_args = "repos"
)
