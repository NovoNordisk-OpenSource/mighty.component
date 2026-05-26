#' @noRd
assert_single_match <- function(names, paths, contents) {
  if (length(names) == 0) {
    return(NULL)
  }

  if (length(names) == 1) {
    return(list(name = names, path = paths, content = contents[[1]]))
  }

  cli::cli_abort("Multiple matches found: {names}")
}

#' @noRd
search_folder <- function(component, folder = NULL) {
  if (is.null(folder)) {
    folder <- "."
  }

  pattern <- paste0("^", component, "(|\\.R|\\.mustache)$")

  paths <- list.files(path = folder, pattern = pattern, full.names = TRUE)
  names <- basename(paths)
  contents <- lapply(paths, readLines)

  assert_single_match(names, paths, contents)
}

#' @noRd
parse_github_source <- function(source) {
  rlang::check_installed("remotes")

  parsed <- remotes::parse_repo_spec(source)

  list(
    owner = parsed$username,
    repo  = parsed$repo,
    ref   = if (nzchar(parsed$ref)) parsed$ref else NULL,
    path  = if (nzchar(parsed$subdir)) parsed$subdir else ""
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
    repo  = parsed$repo,
    ref   = parsed$ref,
    path  = path
  )

  names <- vapply(resp, \(x) x[["name"]], character(1))
  paths <- vapply(resp, \(x) x[["download_url"]], character(1))
  urls <- vapply(resp, \(x) x[["url"]], character(1))

  pattern <- paste0("^", component, "(|\\.R|\\.mustache)$")
  keep <- grepl(pattern, names)

  contents <- lapply(urls[keep], \(url) {
    raw <- jsonlite::base64_dec(gh::gh(url)$content)
    strsplit(rawToChar(raw), "\n", fixed = TRUE)[[1]]
  })

  assert_single_match(names[keep], paths[keep], contents)
}
