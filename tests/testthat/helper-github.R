clear_repo_cache <- function() {
  paths <- as.list(repo_cache)
  unlink(unlist(paths), recursive = TRUE)
  rm(list = ls(repo_cache), envir = repo_cache)
}
