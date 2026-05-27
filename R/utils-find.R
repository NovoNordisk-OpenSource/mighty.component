#' @noRd
assert_single_match <- function(x) {
  if (length(x) > 1) {
    cli::cli_abort("Multiple matches found: {x}")
  }

  invisible(x)
}

#' @noRd
search_folder <- function(component, folder = NULL) {
  if (is.null(folder)) {
    folder <- "."
  }

  pattern <- paste0("^", component, "(|\\.R|\\.mustache)$")

  paths <- list.files(path = folder, pattern = pattern, full.names = TRUE)
  assert_single_match(paths)

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

  parsed <- remotes::parse_repo_spec(source)

  list(
    owner = parsed$username,
    repo = parsed$repo,
    ref = if (nzchar(parsed$ref)) parsed$ref else NULL,
    path = if (nzchar(parsed$subdir)) parsed$subdir else ""
  )
}

#' @noRd
search_github <- function(component, source) {
  rlang::check_installed("gh")

  parsed <- parse_github_source(source)

  path <- if (nzchar(parsed$path)) {
    paste0(parsed$path, "/", component)
  } else {
    component
  }

  resp <- gh::gh(
    "GET /repos/{owner}/{repo}/contents/{path}",
    owner = parsed$owner,
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
