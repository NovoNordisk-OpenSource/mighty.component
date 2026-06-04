clear_repo_cache <- function() {
  paths <- as.list(repo_cache)
  unlink(unlist(paths), recursive = TRUE)
  rm(list = ls(repo_cache), envir = repo_cache)
}

local_mock_gh_tarball <- function(tarball, env = parent.frame()) {
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")
  clear_repo_cache()
  withr::defer(clear_repo_cache(), envir = env)
  local_mocked_bindings(
    gh = function(...) {
      args <- list(...)
      file.copy(tarball, args$.destfile)
    },
    .package = "gh",
    .env = env
  )
}
