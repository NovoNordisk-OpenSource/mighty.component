#' Component repos
#' @description
#' * `mighty_repo()`: Create a component repo from a spec.
#' * `mighty_repo_class`: Abstract parent class of all component repos. It has
#'   one property, `@path`: the location holding the components (directory or
#'   base URL), as a single non-empty string. It cannot be created directly.
#'
#' Specs have the form `type::path`. Supported types:
#' * `local`: A local directory, e.g. `local::inst/examples`.
#'   A spec without a prefix is treated as local.
#' * `github`: A GitHub repository, e.g. `github::owner/repo/subdir@ref`.
#'   See [mighty_repo_github()].
#' * `url`: Raw files under a base URL, e.g. `url::https://host/components`.
#'   See [mighty_repo_url()].
#'
#' @param spec `character(1)` repo spec. See description.
#' @returns `mighty_repo()`: An object inheriting from `mighty_repo_class`.
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' mighty_repo(path)
#' mighty_repo(paste0("local::", path))
#' @seealso [mighty_repo_local()], [mighty_repo_github()], [mighty_repo_url()]
#' @export
mighty_repo <- function(spec) {
  check_string(spec)

  type <- if (grepl(pattern = "::", x = spec, fixed = TRUE)) {
    sub(pattern = "::.*", replacement = "", x = spec)
  } else {
    "local"
  }

  path <- sub(pattern = "^[^:]*::", replacement = "", x = spec)

  switch(
    EXPR = type,
    local = mighty_repo_local(path = path),
    github = mighty_repo_github(spec = path),
    url = mighty_repo_url(url = path),
    api = mighty_repo_api(url = path),
    cli::cli_abort("Unknown repo type {.val {type}} in {.val {spec}}.")
  )
}

#' @rdname mighty_repo
#' @usage NULL
#' @export
mighty_repo_class <- S7::new_class(
  name = "mighty_repo_class",
  properties = list(
    path = S7::new_property(
      class = S7::class_character,
      validator = \(value) {
        validate_string(value)
      }
    )
  ),
  abstract = TRUE
)

#' @noRd
validate_string <- function(value) {
  if (length(value) != 1 || is.na(value) || !nzchar(value)) {
    "must be a single non-empty string"
  }
}
