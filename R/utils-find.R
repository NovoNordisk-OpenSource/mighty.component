#' @noRd
find_component <- function(component, repos = ".") {
  for (repo in repos) {
    result <- if (dir.exists(repo)) {
      search_folder(component, folder = repo)
    } else {
      search_github(component, source = repo)
    }

    if (!is.null(result)) {
      zephyr::msg_verbose(
        message = c(">" = "Found {.val {component}} in {.val {repo}}")
      )
      return(result)
    }
  }

  cli::cli_abort("Component {.val {component}} not found.")
}

#' @noRd
assert_single_match <- function(x) {
  if (length(x) > 1) {
    cli::cli_abort("Multiple matches found: {x}")
  }

  invisible(x)
}

#' @noRd
search_folder <- function(component, folder = ".") {
  path <- if (file.exists(component)) {
    component
  } else {
    file.path(folder, component)
  }

  if (file.exists(path)) {
    return(list(
      name = basename(path),
      type = tolower(tools::file_ext(path)),
      path = path,
      content = readLines(path)
    ))
  }

  if (!dir.exists(folder)) {
    return(NULL)
  }

  paths <- list.files(
    path = folder,
    pattern = paste0("^", component, "(|\\.R|\\.mustache)$"),
    full.names = TRUE
  ) |>
    assert_single_match()

  if (length(paths) == 0) {
    return(NULL)
  }

  list(
    name = basename(paths),
    type = tolower(tools::file_ext(paths)),
    path = paths,
    content = readLines(paths)
  )
}

#' @noRd
parse_github_source <- function(source) {
  rlang::check_installed("remotes")

  tryCatch(
    expr = source |>
      remotes::parse_repo_spec() |>
      as.list() |>
      lapply(\(x) {
        if (nzchar(x)) x else NULL
      }),
    error = \(e) NULL
  )
}

# Package-level cache: maps "owner/repo@ref" -> local extracted path
repo_cache <- new.env(parent = emptyenv())

#' @noRd
ensure_repo_local <- function(owner, repo, subdir = NULL, ref = NULL) {
  key <- paste0(owner, "/", repo, "@", ref %||% "HEAD")

  if (exists(key, envir = repo_cache)) {
    zephyr::msg_verbose(
      message = c(">" = "Using cached repo {.val {key}}")
    )
    path <- repo_cache[[key]]
  } else {
    zephyr::msg_verbose(
      message = c(">" = "Downloading repo {.val {key}}")
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
    if (!is.null(ref)) args$ref <- ref
    do.call(gh::gh, args)

    exdir <- tempfile("mighty_repo_")
    tar_result <- tryCatch(
      suppressWarnings(utils::untar(tarfile, exdir = exdir)),
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
    top_dir <- list.dirs(exdir, recursive = FALSE)

    if (length(top_dir) == 0L) {
      cli::cli_abort(
        "Repository archive for {.val {key}} extracted to an empty directory." 
      )
    }

    path <- top_dir[[1]]

    repo_cache[[key]] <- path
    zephyr::msg_verbose(
      message = c(">" = "Successfully downloaded and cached {.val {key}}")
    )
  }

  if (!is.null(subdir)) file.path(path, subdir) else path
}

#' @noRd
search_github <- function(component, source) {
  rlang::check_installed("gh")

  parsed <- parse_github_source(source)

  if (is.null(parsed)) {
    return(NULL)
  }

  local_path <- tryCatch(
    ensure_repo_local(
      owner = parsed$username,
      repo = parsed$repo,
      subdir = parsed$subdir,
      ref = parsed$ref
    ),
    error = \(e) {
      cli::cli_abort(
        "Failed to query {.val {source}}: {conditionMessage(e)}",
        parent = e
      )
    }
  )

  # Guard: component name must resolve to a directory, not a file
  component_dir <- file.path(local_path, tools::file_path_sans_ext(component))
  if (file.exists(component_dir) && !dir.exists(component_dir)) {
    cli::cli_abort(
      "{.arg repos} source {.val {source}} is not a directory."
    )
  }

  # Try subdirectory convention: component lives in subdir/component_name/
  result <- search_folder(component, folder = component_dir)

  # Fall back to flat listing (only when subdir was specified, matching prior behavior)
  if (is.null(result) && !is.null(parsed$subdir)) {
    result <- search_folder(component, folder = local_path)
  }

  result
}
