#' GitHub component repo
#' @description
#' A component repo hosted on GitHub. When the object is created, `ref` is
#' resolved to a commit SHA and the repository tarball for that commit is
#' downloaded and extracted to a temporary directory. Tarballs are cached per
#' commit for the session, so all lookups afterwards are local.
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
    ref = S7::class_character,
    sha = S7::class_character
  ),
  constructor = function(spec) {
    parsed <- parse_github_source(spec)

    if (is.null(parsed)) {
      cli::cli_abort("{.arg spec} {.val {spec}} is not a valid GitHub source.")
    }

    sha <- resolve_sha(
      owner = parsed$username,
      repo = parsed$repo,
      ref = parsed$ref
    )

    path <- cached_download(
      owner = parsed$username,
      repo = parsed$repo,
      sha = sha
    )

    if (!is.null(parsed$subdir)) {
      path <- file.path(path, parsed$subdir)

      if (!dir.exists(path)) {
        cli::cli_abort(
          "Subdirectory {.path {parsed$subdir}} not found in
          {.val {parsed$username}/{parsed$repo}@{sha}}."
        )
      }
    }

    S7::new_object(
      mighty_repo_local(path = path),
      owner = parsed$username,
      repo = parsed$repo,
      subdir = parsed$subdir %||% character(0),
      ref = parsed$ref %||% character(0),
      sha = sha
    )
  }
)

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

# Session cache: maps "owner/repo@sha" -> extracted repo root
repo_cache <- new.env(parent = emptyenv())

#' @noRd
resolve_sha <- function(owner, repo, ref = NULL) {
  rlang::check_installed("gh")

  ref <- ref %||% "HEAD"

  res <- tryCatch(
    expr = gh::gh(
      endpoint = "GET /repos/{owner}/{repo}/commits/{ref}",
      owner = owner,
      repo = repo,
      ref = ref,
      .accept = "application/vnd.github.sha"
    ),
    error = \(e) {
      cli::cli_abort(
        "Failed to resolve {.val {owner}/{repo}@{ref}}: {conditionMessage(e)}",
        parent = e
      )
    }
  )

  res$message
}

#' @noRd
cached_download <- function(owner, repo, sha) {
  key <- paste0(owner, "/", repo, "@", sha)

  if (is.null(repo_cache[[key]])) {
    repo_cache[[key]] <- download_repo(owner = owner, repo = repo, sha = sha)
  } else {
    zephyr::msg_verbose(
      message = c(">" = "Using cached repo {.val {key}}")
    )
  }

  repo_cache[[key]]
}

#' @noRd
download_repo <- function(owner, repo, sha) {
  rlang::check_installed("gh")

  key <- paste0(owner, "/", repo, "@", sha)

  zephyr::msg_verbose(
    message = c(">" = "Downloading repo {.val {key}}")
  )

  tarfile <- tempfile(fileext = ".tar.gz")
  on.exit(unlink(tarfile), add = TRUE)

  tryCatch(
    expr = gh::gh(
      endpoint = "GET /repos/{owner}/{repo}/tarball/{ref}",
      owner = owner,
      repo = repo,
      ref = sha,
      .destfile = tarfile
    ),
    error = \(e) {
      cli::cli_abort(
        "Failed to query {.val {key}}: {conditionMessage(e)}",
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
      "Failed to extract repository archive for {.val {key}}.
      The repository may not exist or may require authentication."
    )
  }

  # Discover the top-level directory (don't assume naming)
  top_dir <- list.dirs(path = exdir, recursive = FALSE)

  if (length(top_dir) == 0L) {
    cli::cli_abort(
      "Repository archive for {.val {key}} extracted to an empty directory."
    )
  }

  top_dir[[1]]
}
