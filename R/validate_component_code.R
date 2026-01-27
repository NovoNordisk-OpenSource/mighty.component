#' Validate component code
#'
#' @param code Character string of R code to validate
#' @param validators List of validator functions to run
#' @return Invisible NULL on success, throws error if validation fails
#' @noRd
validate_component_code <- function(code, validators = default_validators()) {
  xml <- parse(text = code, keep.source = TRUE) |>
    xmlparsedata::xml_parse_data() |>
    xml2::read_xml()

  all_violations <- validators |>
    lapply(\(validator_fn) validator_fn(xml)) |>
    Filter(f = Negate(is.null))

  if (length(all_violations) > 0) {
    abort_validation_errors(all_violations)
  }

  invisible(NULL)
}

#' @noRd
default_validators <- function() {
  list(
    validate_implicit_join
  )
}


#' Create a validation violation result
#'
#' Constructor for validation violation results.
#'
#' @param message Character string describing the overall issue
#' @param details Character string with detailed explanation
#' @param violations List of individual violations, each with `line_number` and `function_name`
#' @return A list
#' @noRd
new_validation_violation <- function(message, details, violations) {
  list(
    message = message,
    details = details,
    violations = violations
  )
}


#' Abort with formatted validation error messages
#'
#' @param all_violations List of violation groups, one per validator. Each group
#'   is a list with: `message` (overall issue), `details` (explanation), and
#'   `violations` (list of individual occurrences with `line_number` and `function_name`)
#' @noRd
abort_validation_errors <- function(all_violations) {
  violation_messages <- lapply(all_violations, format_violation_group)

  cli::cli_abort(c(
    "Component validation failed:",
    unlist(violation_messages, recursive = FALSE)
  ))
}


#' Format a single violation group into cli message parts
#'
#' @param v A violation object with message, details, and violations
#' @return Character vector with cli formatting names
#' @noRd
format_violation_group <- function(v) {
  violation_lines <- vapply(
    v$violations,
    function(violation) {
      sprintf("Line %d: %s", violation$line_number, violation$function_name)
    },
    character(1)
  )

  c(
    "",
    stats::setNames(v$message, "!"),
    stats::setNames(v$details, "x"),
    stats::setNames(violation_lines, rep("i", length(violation_lines)))
  )
}
