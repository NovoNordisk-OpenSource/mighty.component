local_component_repo <- function(files, env = parent.frame()) {
  path <- withr::local_tempdir(.local_envir = env)

  templates <- c(
    mustache = test_path("_components", "ady_local.mustache"),
    R = test_path("_components", "ady_local.R")
  )

  for (file in files) {
    ext <- tools::file_ext(file)
    if (!ext %in% names(templates)) {
      stop("Unsupported component file extension: ", file, call. = FALSE)
    }
    target <- file.path(path, file)
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    file.copy(from = templates[[ext]], to = target)
  }

  path
}
