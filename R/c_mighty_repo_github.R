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

    if (!is.null(parsed$pull) || !is.null(parsed$release)) {
      cli::cli_abort(c(
        "Pull request and release references are not supported in
        {.val {spec}}.",
        i = "Use {.code @<ref>} with a branch, tag, or commit."
      ))
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
S7::method(format, mighty_repo_github) <- function(x, ...) {
  paste0(
    "github::",
    paste(c(x@owner, x@repo, x@subdir), collapse = "/"),
    "@",
    x@sha
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

# Session cache: maps "owner/repo@sha" -> extracted repo root
repo_cache <- new.env(parent = emptyenv())

#' @noRd
resolve_sha <- function(owner, repo, ref = NULL) {
  rlang::check_installed("gh")

  ref <- ref %||% "HEAD"

  res <- tryCatch(
    expr = gh_with_retry(
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

#' Report a warning via `zephyr::msg_verbose()` and muffle it
#'
#' Defined at package level so zephyr resolves the package verbosity option.
#' @noRd
muffle_warning_verbose <- function(w) {
  zephyr::msg_verbose(message = c("!" = "{conditionMessage(w)}"))
  invokeRestart("muffleWarning")
}

#' @noRd
download_repo <- function(owner, repo, sha) {
  rlang::check_installed("gh")

  zephyr::msg_verbose(
    message = c(">" = "Downloading repo {.val {owner}/{repo}@{sha}}")
  )

  tarfile <- tempfile(fileext = ".tar.gz")
  on.exit(unlink(tarfile), add = TRUE)

  tryCatch(
    expr = gh_with_retry(
      endpoint = "GET /repos/{owner}/{repo}/tarball/{ref}",
      owner = owner,
      repo = repo,
      ref = sha,
      .destfile = tarfile,
      .overwrite = TRUE
    ),
    error = \(e) {
      cli::cli_abort(
        "Failed to query {.val {owner}/{repo}@{sha}}: {conditionMessage(e)}",
        parent = e
      )
    }
  )

  exdir <- tempfile("mighty_repo_")
  tar_result <- tryCatch(
    expr = withCallingHandlers(
      expr = utils::untar(tarfile = tarfile, exdir = exdir),
      warning = muffle_warning_verbose
    ),
    error = \(e) 1L
  )

  if (tar_result != 0L) {
    cli::cli_abort(
      "Failed to extract repository archive for {.val {owner}/{repo}@{sha}}.
      The repository may not exist or may require authentication."
    )
  }

  # Discover the top-level directory (don't assume naming)
  top_dir <- list.dirs(path = exdir, recursive = FALSE)

  if (length(top_dir) == 0L) {
    cli::cli_abort(
      "Repository archive for {.val {owner}/{repo}@{sha}}
      extracted to an empty directory."
    )
  }

  top_dir[[1]]
}

#' Call `gh::gh()` and retry transient errors
#'
#' Waits `2^(attempt - 1)` seconds between attempts. The number of attempts is
#' set by the `github_max_tries` option.
#' @noRd
gh_with_retry <- function(...) {
  max_tries <- github_max_tries()

  for (attempt in seq_len(max_tries)) {
    res <- tryCatch(expr = gh::gh(...), error = identity)

    if (!inherits(res, "error")) {
      return(res)
    }

    if (attempt == max_tries || !is_transient_gh_error(res)) {
      stop(res)
    }

    wait <- 2^(attempt - 1)
    report_retry(e = res, wait = wait, attempt = attempt, max_tries = max_tries)
    retry_wait(seconds = wait)
  }
}

#' @noRd
github_max_tries <- function() {
  max_tries <- zephyr::get_option(
    name = "github_max_tries",
    .envir = "mighty.component"
  )

  rlang::check_number_whole(
    x = max_tries,
    min = 1,
    arg = "mighty.component.github_max_tries"
  )

  max_tries
}

#' Transient errors are HTTP 5xx responses and network failures
#' @noRd
is_transient_gh_error <- function(e) {
  inherits(e, "httr2_failure") ||
    any(grepl(pattern = "^http_error_5[0-9]{2}$", x = class(e)))
}

#' Defined at package level so zephyr resolves the package verbosity option.
#' @noRd
report_retry <- function(e, wait, attempt, max_tries) {
  zephyr::msg_verbose(
    message = c(
      "!" = "GitHub request failed ({conditionMessage(e)}).
      Retrying in {wait}s (attempt {attempt + 1}/{max_tries})."
    )
  )
}

#' @noRd
retry_wait <- function(seconds) {
  Sys.sleep(seconds)
}
