#' Validate mustache template for mighty component
#' @description
#' Validates that a mustache template follows the required structure and
#' conventions for mighty standard components.
#'
#' @param template `character` vector containing the template lines
#' @param id `character` optional component ID for better error messages
#' @details
#' The function validates:
#' - Required tags: @title, @description, @type, @code
#' - Tag content is not empty
#' - @type is one of the valid types
#' - @param tags have both name and description
#' - @depends tags have both domain and column
#' - @outputs tags are not empty
#'
#' @return Invisible NULL if validation passes, otherwise throws an error
#' @noRd
validate_template <- function(template, id = NULL) {
  # Simple error helper
  abort_with_context <- function(msg) {
    if (!is.null(id)) {
      cli::cli_abort(c(
        "Template validation failed for {.field {id}}:",
        "x" = msg
      ))
    } else {
      cli::cli_abort(msg)
    }
  }

  # Basic input validation
  if (!is.character(template)) {
    abort_with_context("{.arg template} must be a character vector")
  }

  if (length(template) == 0) {
    abort_with_context("{.arg template} must not be empty")
  }

  # For easier regex matching
  template_text <- paste(template, collapse = "\n")

  # Check for required tags
  required_tags <- c("title", "description", "type", "code")
  for (tag in required_tags) {
    pattern <- paste0("#'\\s*@", tag)
    if (!grepl(pattern, template_text)) {
      abort_with_context("Missing required tag: {.code @{tag}}")
    }
  }

  # Use existing parsing functions for content validation
  title <- tryCatch(
    get_tag(template, "title"),
    error = function(e) {
      abort_with_context(conditionMessage(e))
    }
  )
  if (nchar(trimws(title)) == 0) {
    abort_with_context("{.code @title} cannot be empty")
  }

  description <- tryCatch(
    get_tag(template, "description"),
    error = function(e) {
      abort_with_context(conditionMessage(e))
    }
  )
  if (nchar(trimws(description)) == 0) {
    abort_with_context("{.code @description} cannot be empty")
  }

  # Validate @type
  get_tag(template, "type") |> 
    assert_type()

  # Check for empty @code section using simple logic
  code_line <- grep("^#'\\s*@code", template)
  if (length(code_line) > 0) {
    code_content <- utils::tail(template, n = -code_line[[1]])
    if (length(code_content) == 0 || all(nchar(trimws(code_content)) == 0)) {
      abort_with_context("{.code @code} section cannot be empty")
    }
  }


  # Check @param format (must have both name and description)
  param_lines <- grep("#'\\s*@param", template, value = TRUE)
  for (line in param_lines) {
    clean_line <- gsub("#'\\s*@param\\s*", "", line)
    parts <- trimws(strsplit(clean_line, "\\s+")[[1]])
    if (length(parts) < 2 || any(nchar(parts[1:2]) == 0)) {
      abort_with_context(
        "Invalid {.code @param} tag: {.val {clean_line}}. Must have both name and description"
      )
    }
  }

  # Check @depends format (must have both domain and column)
  depends_lines <- grep("#'\\s*@depends", template, value = TRUE)
  for (line in depends_lines) {
    clean_line <- gsub("#'\\s*@depends\\s*", "", line)
    parts <- trimws(strsplit(clean_line, "\\s+")[[1]])
    if (length(parts) < 2 || any(nchar(parts[1:2]) == 0)) {
      abort_with_context(
        "Invalid {.code @depends} tag: {.val {clean_line}}. Must have both domain and column"
      )
    }
  }

  # Check @outputs format (cannot be empty)
  outputs_lines <- grep("#'\\s*@outputs", template, value = TRUE)
  for (line in outputs_lines) {
    clean_line <- gsub("#'\\s*@outputs\\s*", "", line)
    if (nchar(trimws(clean_line)) == 0) {
      abort_with_context("{.code @outputs} tag cannot be empty")
    }
  }

  invisible(NULL)
}
