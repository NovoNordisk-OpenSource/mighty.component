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
  path <- if (file.exists(component)) component else file.path(folder, component)

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

#' @noRd
search_github <- function(component, source) {
  rlang::check_installed("gh")

  parsed <- parse_github_source(source)

  if (is.null(parsed)) {
    return(NULL)
  }

  path <- c(
    parsed$subdir,
    tools::file_path_sans_ext(component)
  ) |>
    paste(collapse = "/")

  resp <- tryCatch(
    expr = gh::gh(
      "GET /repos/{owner}/{repo}/contents/{path}",
      owner = parsed$username,
      repo = parsed$repo,
      path = path,
      ref = parsed$ref
    ),
    error = \(e) NULL
  )

  if (is.null(resp) && !is.null(parsed$subdir)) {
    resp <- tryCatch(
      expr = gh::gh(
        "GET /repos/{owner}/{repo}/contents/{path}",
        owner = parsed$username,
        repo = parsed$repo,
        path = parsed$subdir,
        ref = parsed$ref
      ),
      error = \(e) NULL
    )
  }

  files <- vapply(resp, \(x) x[["name"]], character(1))

  pattern <- paste0("^", component, "(|\\.R|\\.mustache)$")
  keep <- grepl(pattern, files)

  if (!any(keep)) {
    return(NULL)
  }

  assert_single_match(files[keep])

  matched <- resp[keep][[1]]
  raw <- jsonlite::base64_dec(gh::gh(matched$url)$content)

  list(
    name = matched$name,
    type = tolower(tools::file_ext(matched$name)),
    path = matched$download_url,
    content = strsplit(rawToChar(raw), "\n", fixed = TRUE)[[1]]
  )
}
