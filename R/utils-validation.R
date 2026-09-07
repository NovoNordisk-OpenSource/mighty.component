#' @noRd
assert_single_match <- function(x) {
  if (length(x) > 1) {
    cli::cli_abort("Multiple matches found: {x}")
  }

  invisible(x)
}

valid_types <- function() {
  c("column", "row", "parameter", "internal")
}

assert_type <- function(type) {
  types <- valid_types()
  if (!type %in% types) {
    cli::cli_abort("@type must be one of {.val {types}}")
  }
  type
}

valid_origins <- function() {
  c("Assigned", "Collected", "Derived", "Not Available", "Other", "Predecessor", "Protocol")
}

assert_origin <- function(origin) {
  origins <- valid_origins()
  if (!origin %in% origins) {
    cli::cli_abort("@origin must be one of {.val {origins}}")
  }
  origin
}
