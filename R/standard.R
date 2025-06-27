#' Retrieve mighty standard component
#' @param standard standard
#' @export
get_standard <- function(standard, library) {
  template <- find_standard(standard, library)
  mighty_standard$new(template = readLines(template))
}

#' Retrieve rendered mighty standard component
#' @param standard standard
#' @param params list of input parameters
#' @export
get_rendered_standard <- function(standard, params, library) {
  x <- get_standard(standard, library)
  do.call(what = x$render, args = params)
}

#' List all available standards
#' @export
list_standards <- function(library) {
  switch(
    get_source_type(library),
    "templates" = list_all_templates(library),
    "dir" = list_all_R_functions_in_dir(library),
    "file" = list_all_R_functions_in_file(library),
    cli::cli_abort( 
      "Unsupported source type for library: {.path {library}}"
    )

  )
}

#' @noRd
find_standard <- function(standard, library) {
  if (!standard %in% list_standards(library)) {
    cli::cli_abort("Component {template} not found")
  }

  system.file(
    "components",
    paste0(standard, ".mustache"),
    package = "mighty.standards"
  )
}

get_source_type <- function(library) {
  if (dir.exists(library)) {
    return("dir")
  }
  if (grepl(pattern = "\\.[Rr]$", library)) {
    return("file")
  }
  return("templates")
}


list_all_templates <- function(library) {
  templates <- system.file(
    "components",
    package = library
  ) |>
    list.files()

  templates <- gsub(pattern = "\\.mustache$", replacement = "", x = templates) |> 
    setNames(rep(library, length(templates)))
}

list_all_R_functions_in_dir <- function(path_dir) {
  r_files <- list.files(path_dir, pattern = "\\.[Rr]$", full.names = TRUE)
  if (length(r_files) == 0) {
    cli::cli_abort("No R files found in {.path {path_dir}}")
  }
  lapply(r_files, list_all_R_functions_in_file) |>
    unlist(use.names = TRUE)
}

list_all_R_functions_in_file <- function(path_file) {
  if (!file.exists(path_file)) {
    cli::cli_abort(c(
      "File does not exist: {.path {path_file}}"
    ))
  }

  temp_env <- new.env()
  source(path_file, local = temp_env, keep.source = TRUE)
  function_names <- ls(temp_env)

  # Name attribute needed so that error on duplicates can give informative message
  function_names |>
    setNames(rep(path_file, length(function_names)))
}
