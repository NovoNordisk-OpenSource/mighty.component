clear_repo_cache <- function() {
  paths <- as.list(repo_cache)
  unlink(unlist(paths), recursive = TRUE)
  rm(list = ls(repo_cache), envir = repo_cache)
}

local_mock_gh_tarball <- function(
  tarball,
  sha = \(ref) paste0("sha-", ref),
  env = parent.frame()
) {
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")
  clear_repo_cache()
  withr::defer(clear_repo_cache(), envir = env)

  calls <- new.env(parent = emptyenv())
  calls$download <- 0L
  calls$resolve <- 0L

  local_mocked_bindings(
    gh = function(endpoint, ..., ref = NULL, .destfile = NULL) {
      if (!is.null(.destfile)) {
        calls$download <- calls$download + 1L
        return(file.copy(from = tarball, to = .destfile, overwrite = TRUE))
      }
      if (grepl(pattern = "/commits/", x = endpoint, fixed = TRUE)) {
        calls$resolve <- calls$resolve + 1L
        return(list(message = sha(ref)))
      }
      stop("Unexpected gh::gh() call: ", endpoint, call. = FALSE)
    },
    .package = "gh",
    .env = env
  )

  invisible(calls)
}
