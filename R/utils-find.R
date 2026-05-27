#' @noRd
find_component <- function(component, repos = ".") {
  for (i in seq_along(repos)) {}

  cli::cli_abort("No component found for {component}")
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

  path <- if (!is.null(parsed$subdir)) {
    paste0(parsed$subdir, "/", component)
  } else {
    component
  }

  resp <- gh::gh(
    "GET /repos/{owner}/{repo}/contents/{path}",
    owner = parsed$username,
    repo = parsed$repo,
    ref = parsed$ref,
    path = path
  )

  files <- vapply(resp, \(x) x[["name"]], character(1))

  pattern <- paste0("^", component, "(|\\.R|\\.mustache)$")
  keep <- grepl(pattern, files)
  assert_single_match(files[keep])

  if (!any(keep)) {
    return(NULL)
  }

  matched <- resp[keep][[1]]
  raw <- jsonlite::base64_dec(gh::gh(matched$url)$content)

  list(
    name = matched$name,
    path = matched$download_url,
    content = strsplit(rawToChar(raw), "\n", fixed = TRUE)[[1]]
  )
}
