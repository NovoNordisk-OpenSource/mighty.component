#' GitHub component repo
#' @description
#' A component repo hosted on GitHub. The repository tarball is downloaded and
#' extracted to a temporary directory when the object is created, so all
#' lookups afterwards are local.
#'
#' `spec` is a `remotes`-style repository reference: `owner/repo`,
#' `owner/repo/subdir`, `owner/repo@ref` or a combination.
#' @param spec `character(1)` GitHub repository reference. See description.
#' @export
mighty_repo_github <- S7::new_class(
  name = "mighty_repo_github",
  parent = mighty_repo_local,
  properties = list(
    owner = S7::class_character,
    repo = S7::class_character,
    subdir = S7::class_character,
    ref = S7::class_character
  ),
  constructor = function(spec) {
    parsed <- parse_github_source(spec)

    if (is.null(parsed)) {
      cli::cli_abort("{.arg spec} {.val {spec}} is not a valid GitHub source.")
    }

    S7::new_object(
      mighty_repo_local(
        path = download_repo(
          owner = parsed$username,
          repo = parsed$repo,
          subdir = parsed$subdir,
          ref = parsed$ref
        )
      ),
      owner = parsed$username,
      repo = parsed$repo,
      subdir = parsed$subdir %||% character(0),
      ref = parsed$ref %||% character(0)
    )
  }
)

#' @noRd
S7::method(list_components, mighty_repo_github) <- function(
  repos,
  remove_ext = TRUE
) {
  files <- repos@path |>
    list.files(
      pattern = "\\.(R|mustache)$",
      recursive = TRUE
    ) |>
    basename()

  files <- files[!startsWith(x = files, prefix = "test-")]

  if (remove_ext) {
    files <- tools::file_path_sans_ext(files)
  }

  unique(files)
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, mighty_repo_github)
) <- function(component, repos) {
  nested <- file.path(repos@path, component)

  if (dir.exists(nested)) {
    found <- find_component(
      component = component,
      repos = mighty_repo_local(path = nested)
    )

    if (!is.null(found)) {
      return(found)
    }
  }

  find_component(
    component = component,
    repos = mighty_repo_local(path = repos@path)
  )
}

#' @noRd
parse_github_source <- function(spec) {
  rlang::check_installed("remotes")

  tryCatch(
    expr = spec |>
      remotes::parse_repo_spec() |>
      as.list() |>
      lapply(\(x) {
        if (nzchar(x)) x else NULL
      }),
    error = \(e) NULL
  )
}

#' @noRd
download_repo <- function(owner, repo, subdir = NULL, ref = NULL) {
  rlang::check_installed("gh")

  zephyr::msg_verbose(
    message = c(
      ">" = "Downloading repo {.val {owner}/{repo}@{ref %||% 'HEAD'}}"
    )
  )

  tarfile <- tempfile(fileext = ".tar.gz")
  on.exit(unlink(tarfile), add = TRUE)

  args <- list(
    endpoint = if (is.null(ref)) {
      "GET /repos/{owner}/{repo}/tarball"
    } else {
      "GET /repos/{owner}/{repo}/tarball/{ref}"
    },
    owner = owner,
    repo = repo,
    .destfile = tarfile
  )

  if (!is.null(ref)) {
    args$ref <- ref
  }

  tryCatch(
    expr = do.call(gh::gh, args),
    error = \(e) {
      cli::cli_abort(
        "Failed to query {.val {owner}/{repo}@{ref %||% 'HEAD'}}:
        {conditionMessage(e)}",
        parent = e
      )
    }
  )

  exdir <- tempfile("mighty_repo_")
  tar_result <- tryCatch(
    expr = suppressWarnings(utils::untar(tarfile, exdir = exdir)),
    error = \(e) 1L
  )

  if (tar_result != 0L) {
    cli::cli_abort(
      "Failed to extract repository archive for
      {.val {owner}/{repo}@{ref %||% 'HEAD'}}.
      The repository may not exist or may require authentication."
    )
  }

  # Discover the top-level directory (don't assume naming)
  top_dir <- list.dirs(path = exdir, recursive = FALSE)

  if (length(top_dir) == 0L) {
    cli::cli_abort(
      "Repository archive for {.val {owner}/{repo}@{ref %||% 'HEAD'}}
      extracted to an empty directory."
    )
  }

  if (is.null(subdir)) top_dir[[1]] else file.path(top_dir[[1]], subdir)
}
