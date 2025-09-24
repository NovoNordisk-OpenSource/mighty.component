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
  # Basic input validation
  validate_basic_inputs(template, id)

  # Validate required tags exist and have content
  validate_required_tags(template, id)

  # Validate tag formats
  validate_tag_formats(template, id)

  # Validate parameter consistency
  validate_parameter_consistency(template, id)

  invisible(NULL)
}

#' Error helper with context
#' @param msg error message
#' @param id optional component ID
#' @noRd
abort_with_context <- function(msg, id = NULL) {
  if (!is.null(id)) {
    cli::cli_abort(c(
      "\nTemplate validation failed for {.field {id}}:",
      "x" = msg
    ), .envir = parent.frame())
  } else {
    cli::cli_abort(msg, .envir = parent.frame())
  }
}


#' Validate basic input requirements
#' @param template character vector
#' @param id optional component ID
#' @noRd
validate_basic_inputs <- function(template, id = NULL) {
  if (!is.character(template)) {
    abort_with_context("{.arg template} must be a character vector", id)
  }

  if (length(template) == 0) {
    abort_with_context("{.arg template} must not be empty", id)
  }
}

#' Validate required tags are present and have content
#' @param template character vector
#' @param id optional component ID
#' @noRd
validate_required_tags <- function(template, id = NULL) {
  template_text <- paste(template, collapse = "\n")

  # Check for required tags
  required_tags <- c("title", "description", "type", "code")
  for (tag in required_tags) {
    pattern <- paste0("#'\\s*@", tag)
    if (!grepl(pattern, template_text)) {
      abort_with_context("Missing required tag: {.code @{tag}}", id)
    }
  }

  # Validate tag content using existing parsing functions
  validate_tag_content(template, "title", id)
  validate_tag_content(template, "description", id)

  # Validate @type
  tryCatch({
    get_tag(template, "type") |> assert_type()
  }, error = function(e) {
    abort_with_context(conditionMessage(e), id)
  })

  # Validate @code section
  validate_code_section(template, id)
}

#' Validate individual tag content is not empty
#' @param template character vector
#' @param tag_name character
#' @param id optional component ID
#' @noRd
validate_tag_content <- function(template, tag_name, id = NULL) {
  content <- tryCatch(
    get_tag(template, tag_name),
    error = function(e) {
      abort_with_context(conditionMessage(e), id)
    }
  )

  if (nchar(trimws(content)) == 0) {
    abort_with_context("{.code @{tag_name}} cannot be empty", id)
  }
}

#' Validate @code section is not empty
#' @param template character vector
#' @param id optional component ID
#' @noRd
validate_code_section <- function(template, id = NULL) {
  code_line <- grep("^#'\\s*@code", template)
  if (length(code_line) > 0) {
    code_content <- utils::tail(template, n = -code_line[[1]])
    if (length(code_content) == 0 || all(nchar(trimws(code_content)) == 0)) {
      abort_with_context("{.code @code} section cannot be empty", id)
    }
  }
}

#' Validate format of @param, @depends, and @outputs tags
#' @param template character vector
#' @param id optional component ID
#' @noRd
validate_tag_formats <- function(template, id = NULL) {
  # Check @depends format (must have both domain and column)
  depends_lines <- grep("#'\\s*@depends", template, value = TRUE)
  for (line in depends_lines) {
    clean_line <- gsub("#'\\s*@depends\\s*", "", line)
    parts <- trimws(strsplit(clean_line, "\\s+")[[1]])
    if (length(parts) < 2 || any(nchar(parts[1:2]) == 0)) {
      abort_with_context(
        "Invalid {.code @depends} tag: {.val {clean_line}}. Must have both domain and column",
        id
      )
    }
  }

  # Check @outputs format (cannot be empty)
  outputs_lines <- grep("#'\\s*@outputs", template, value = TRUE)
  for (line in outputs_lines) {
    clean_line <- gsub("#'\\s*@outputs\\s*", "", line)
    if (nchar(trimws(clean_line)) == 0) {
      abort_with_context("{.code @outputs} tag cannot be empty", id)
    }
  }

  # Check @param format (must have both name and description)
  param_lines <- grep("#'\\s*@param", template, value = TRUE)
  for (line in param_lines) {
    clean_line <- gsub("#'\\s*@param\\s*", "", line)
    parts <- trimws(strsplit(clean_line, "\\s+")[[1]])
    if (length(parts) < 2 || any(nchar(parts[1:2]) == 0)) {
      abort_with_context(
        "Invalid {.code @param} tag: {.val {clean_line}}. Must have both name and description",
        id
      )
    }
  }
}

#' Validate that parameters required by template are documented
#' @param template character vector
#' @param id optional component ID
#' @noRd
validate_parameter_consistency <- function(template, id = NULL) {
  code_line <- grep("^#'\\s*@code", template)
  code_content <- if (length(code_line) > 0) {
    utils::tail(template, n = -code_line[[1]])
  } else {
    character(0)
  }

  # Get lines with potential parameters
  depends_lines <- grep("#'\\s*@depends", template, value = TRUE)
  outputs_lines <- grep("#'\\s*@outputs", template, value = TRUE)

  lines_with_potential_params <- c(code_content, depends_lines, outputs_lines)
  
  required_params <- extract_mustache_params(lines_with_potential_params)

  supplied_params <- tryCatch({
    template |> get_tags("param") |> tags_to_params() |> getElement("name")
  }, error = function(e) {
    character(0)
  })

  missing <- setdiff(required_params, supplied_params)
  if (length(missing) > 0) {
    abort_with_context(
      "{cli::qty(missing)}{.val {missing}} {?is/are} missing from {.code @param}, but {?it/they} {?is/are} referenced in {.code @depends}, {.code @outputs}, or {.code @code}. 
      \nEither add the needed `@param` tags or remove the whisker variable{?s} from the offending section(s)",
      id
    )
  }
}

#' Extract parameter names from mustache template syntax
#' @param lines character vector of lines to search
#' @return character vector of parameter names
#' @noRd
extract_mustache_params <- function(lines) {
  if (length(lines) == 0) {
    return(character(0))
  }

  pattern_full <- "\\{\\{\\s*[A-Za-z0-9_.]+\\s*\\}\\}"
  full_matches <- regmatches(
    lines,
    gregexpr(pattern_full, lines, perl = TRUE)
  )

  # Strip the braces and whitespace
  required_params <- unlist(lapply(full_matches, function(m) {
    gsub("^\\{\\{\\s*|\\s*\\}\\}$", "", m)
  })) |>
    unique()

  # Filter out special mustache placeholders
  required_params[required_params != "."]
}
