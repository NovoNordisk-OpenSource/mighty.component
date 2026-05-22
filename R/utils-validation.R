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
  if (is.null(origin)) return(NULL)
  origins <- valid_origins()
  if (!origin %in% origins) {
    cli::cli_abort("@origin must be one of {.val {origins}}")
  }
  origin
}
