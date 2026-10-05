#' Collection of component repos
#' @description
#' An ordered collection of component repos. Lookups search the repos in
#' order, and the first match wins.
#'
#' Each element of `repos` is either a repo spec, passed to [mighty_repo()],
#' or an object inheriting from `mighty_repo_class`. Repos are created once
#' when the collection is created.
#'
#' @param repos `character` vector of repo specs, a single
#' `mighty_repo_class` object, or a `list` of repo specs and
#' `mighty_repo_class` objects.
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' repos <- mighty_repos(repos = c(path, paste0("local::", path)))
#' repos
#'
#' find_component(component = "ady", repos = repos)
#' @seealso [find_component()], [list_components()]
#' @export
mighty_repos <- S7::new_class(
  name = "mighty_repos",
  parent = S7::class_list,
  constructor = function(repos = character(0)) {
    if (S7::S7_inherits(repos, mighty_repo_class)) {
      repos <- list(repos)
    }

    repos <- lapply(
      X = as.list(repos),
      FUN = as_mighty_repo,
      call = rlang::current_env()
    )
    S7::new_object(repos)
  },
  validator = \(self) {
    validate_repos(self)
  }
)

#' @noRd
as_mighty_repo <- function(repo, call = rlang::caller_env()) {
  if (S7::S7_inherits(repo, mighty_repo_class)) {
    return(repo)
  }

  if (!rlang::is_string(repo)) {
    cli::cli_abort(
      "Each repo must be a string or a {.cls mighty_repo_class} object,
      not {.obj_type_friendly {repo}}.",
      call = call
    )
  }

  mighty_repo(spec = repo)
}

#' @noRd
validate_repos <- function(self) {
  is_repo <- vapply(
    X = self,
    FUN = \(repo) S7::S7_inherits(repo, mighty_repo_class),
    FUN.VALUE = logical(1)
  )

  if (!all(is_repo)) {
    "must only contain <mighty_repo_class> objects"
  }
}

#' @noRd
S7::method(format, mighty_repos) <- function(x, ...) {
  vapply(X = x, FUN = format, FUN.VALUE = character(1))
}

#' @noRd
S7::method(print, mighty_repos) <- function(x, ...) {
  cli::cli_text("{.cls mighty_repos} {length(x)} repo{?s}")
  if (length(x)) {
    cli::cli_ol(format(x))
  }

  invisible(x)
}

#' @noRd
S7::method(repo_find_component, mighty_repos) <- function(repos, component) {
  for (repo in repos) {
    res <- repo_find_component(repos = repo, component = component)

    if (!is.null(res)) {
      zephyr::msg_verbose(
        message = c(">" = "Found {.val {component}} in {.val {format(repo)}}")
      )
      return(res)
    }
  }
}

#' @noRd
S7::method(component_ids, mighty_repos) <- function(repos) {
  lapply(X = repos, FUN = \(repo) component_ids(repos = repo)) |>
    unlist() |>
    unique() |>
    as.character()
}
