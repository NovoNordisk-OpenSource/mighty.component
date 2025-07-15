#' Retrieve mighty standard component
#' @description
#' Retrieve either the generalized standard component (template) or
#' the rendered standard component with code that is ready to use.
#'
#' * `get_standard()`: Returns an object of class `mighty_component`
#' * `get_rendered_standard()`: Returns an object of class `mighty_component_rendered`
#'
#' When rendering the standard the required list of parameters depends on the standard.
#' Check the documentation of the specific standard for details.
#'
#' @param standard `character` name of the standard component to retrieve.
#' @param params named `list` of input parameters. Passed along to `mighty_component$render()`.
#' @seealso [list_standards()], [mighty_component], [mighty_component_rendered]
#' @examples
#' get_standard("ady")
#'
#' get_rendered_standard("ady", list(variable = "ASTDY", date = "ASTDT"))
#' @rdname get_standard
#' @export
get_standard <- function(standard) {
  template <- find_standard(standard)
  mighty_component$new(template = readLines(template))
}

#' @rdname get_standard
#' @export
get_rendered_standard <- function(standard, params) {
  x <- get_standard(standard)
  do.call(what = x$render, args = params)
}

#' List all available standards
#' @description
#' List all available mighty standard components.
#'
#' @returns `character` vector of standard names
#' @examples
#' available_standards <- list_standards()
#' cat(available_standards, sep = "\n")
#'
#' @export
list_standards <- function() {
  templates <- standard_path() |>
    list.files()

  gsub(pattern = "\\.mustache$", replacement = "", x = templates)
}

#' @noRd
standard_path <- function() {
  # TODO: Point to new path when implemented
  system.file("components", package = "mighty.standards")
}

#' @noRd
find_standard <- function(standard) {
  path <- paste0(standard_path(), "/", standard, ".mustache")

  if (!file.exists(path)) {
    cli::cli_abort("Component {standard} not found")
  }

  path
}


#' Retrieve rendered mighty standard component
#' @export
get_rendered_component <- function(standard, ...) {
  file_type <- tolower(tools::file_ext(standard))

  switch(
    file_type,
    "r" = get_rendered_custom(standard),
    # TODO: add error handling for when the specified local custom mustache is not found
    "mustache" = mighty_component$new(template = readLines(standard)),
    get_rendered_standard(standard, ...)
  )
}


get_rendered_custom <- function(path) {
  code_string <- readLines(path) |>
    paste0(collapse = "\n")

  mighty_component$new(
    template = c(
      extract_function_metadata(code_string),
      extract_function_body(code_string)
    )
  )$render()
}

extract_function_body <- function(code_string) {
  # We can't just use body() to extract the fn's body, because for if-else
  # blocks it produces strings that are not formatted properly as R code
  fn_nm <- code_string |> parse(text = _) |> _[[1]][[2]]

  # This function relies on extracting source code from function objects using
  # their 'srcref' attribute (source reference). However, srcref attributes are
  # fragile and may be lost or unavailable in certain execution contexts,
  # possibly including the following:

  # 1. R CMD check and package building processes
  # 2. CI/CD pipelines running R in batch mode
  # 3. Some testthat execution contexts (particularly IDE test runners)
  # 4. R sessions started with --vanilla or custom .Rprofile settings

  # Without srcref, the function returns empty strings, causing the function to
  # fail silently.

  # The keep.source=TRUE option attempts to ensure that when functions are defined,
  # R preserves the original source code as srcref attributes.

  # TODO:  Refactoring to have a robust
  # fallback (e.g., using deparse()) when srcref is unavailable

  # TODO: proper validation checks of custom components - e.g. cannot have
  # multiple return statements, must end with return(.self), etc
  old_keep_source <- getOption("keep.source")
  options(keep.source = TRUE)
  withr::defer(options(keep.source = old_keep_source))

  parse(text = code_string) |>
    eval()

  fn_nm |>
    get() |>
    attr("srcref") |>
    paste(collapse = "\n") |>
    remove_function_header() |>
    remove_function_return()
}

extract_function_metadata <- function(code_string) {
  metadata <- code_string |> strsplit(split = "\\n") |> unlist()
  metadata <- grep(pattern = "^#\\'", x = trimws(metadata), value = TRUE)
}


remove_function_header <- function(f_string) {
  # grep_pattern <- "function\\(\\s*\\.self\\s*(,\\s*\\w+)*\\s*\\)\\s*\\{"
  grep_pattern <- "function\\(\\s*(.*?)\\)\\s*?\\{"

  # When there are function definitions embedded in a node, we need to allow
  # those to remain
  gsub(pattern = grep_pattern, replacement = "", x = f_string)
}

remove_function_return <- function(f_string) {
  # TODO: check for when the return statement is broken up by linebreaks
  grep_pattern <- "return\\(.*?\\)(?s:.*)\\}"
  gsub(
    pattern = grep_pattern,
    replacement = "",
    x = f_string,
    perl = TRUE
  )
}
