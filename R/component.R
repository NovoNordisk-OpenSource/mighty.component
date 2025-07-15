#' Retrieve rendered mighty code component
#' @description Retrieves and renders a mighty code component, supporting
#' both built-in standards and custom components from local files.
#'
#' @details Processes different component types based on file extension or
#' component name. For R files, extracts and renders custom functions. For
#' Mustache templates, creates components from template files. For standard
#' names, retrieves and renders built-in standard components.
#'
#' @param code_component Character string specifying either a standard component name
#'   or path to a custom component file (R or Mustache template)
#' @param params named `list` of input parameters. Passed along to `mighty_component$render()`
#' @seealso [get_rendered_standard()], [mighty_component], [mighty_component_rendered]
#' @returns An object of class `mighty_component_rendered` containing the
#'   rendered code template
#' @examples
#' get_rendered_component("ady", list(variable = "ASTDY", date = "ASTDT"))
#' @export
get_rendered_component <- function(code_component, params = NULL) {
  file_type <- tolower(tools::file_ext(code_component))

  switch(
    file_type,
    "r" = get_rendered_custom(code_component),
    # TODO: add error handling for when the specified local custom mustache is not found
    "mustache" = {
      component <- mighty_component$new(template = readLines(code_component))
      do.call(what = component$render, args = params)
    },
    get_rendered_standard(code_component, params)
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
  fn_nm <- parse(text = code_string)[[1]][[2]]

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
