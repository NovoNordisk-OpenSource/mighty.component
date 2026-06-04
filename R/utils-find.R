#' @noRd
find_component <- function(component, repos = ".") {
  for (repo in repos) {
    result <- if (dir.exists(repo)) {
      search_folder(component, folder = repo)
    } else {
      search_github(component, source = repo)
    }

    if (!is.null(result)) {
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
clear_repo_cache <- function() {
  paths <- as.list(repo_cache)
  unlink(unlist(paths), recursive = TRUE)
  rm(list = ls(repo_cache), envir = repo_cache)
}

#' @noRd
ensure_repo_local <- function(owner, repo, subdir = NULL, ref = NULL) {
  key <- paste0(owner, "/", repo, "@", ref %||% "HEAD")

  if (exists(key, envir = repo_cache)) {
    path <- repo_cache[[key]]
  } else {
    tarfile <- tempfile(fileext = ".tar.gz")
    on.exit(unlink(tarfile), add = TRUE)

    gh::gh(
      "GET /repos/{owner}/{repo}/tarball/{ref}",
      owner = owner,
      repo = repo,
      ref = ref %||% "",
      .destfile = tarfile
    )

    exdir <- tempfile("mighty_repo_")
    utils::untar(tarfile, exdir = exdir)

    # Discover the top-level directory (don't assume naming)
    top_dir <- list.dirs(exdir, recursive = FALSE)
    path <- top_dir[[1]]

    repo_cache[[key]] <- path
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
    http_error_404 = \(e) NULL,
    error = \(e) {
      cli::cli_abort("Failed to query {.val {source}}: {conditionMessage(e)}")
    }
  )

  if (is.null(local_path)) {
    return(NULL)
  }

  # Try subdirectory convention: component lives in subdir/component_name/
  result <- search_folder(
    component,
    folder = file.path(local_path, tools::file_path_sans_ext(component))
  )

  # Fall back to flat listing (only when subdir was specified, matching prior behavior)
  if (is.null(result) && !is.null(parsed$subdir)) {
    result <- search_folder(component, folder = local_path)
  }

  result
}
