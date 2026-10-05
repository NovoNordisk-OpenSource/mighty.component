#' @noRd
check_string <- function(
  x,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (rlang::is_string(x) && nzchar(x)) {
    return(invisible(NULL))
  }

  cli::cli_abort(
    "{.arg {arg}} must be a single string, not {.obj_type_friendly {x}}.",
    call = call
  )
}

#' @noRd
check_number_whole <- function(
  x,
  min,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  is_whole <- is.numeric(x) &&
    length(x) == 1 &&
    is.finite(x) &&
    x == trunc(x)

  if (is_whole && x >= min) {
    return(invisible(NULL))
  }

  cli::cli_abort(
    "{.arg {arg}} must be a whole number larger than or equal to {min},
    not {.obj_type_friendly {x}}.",
    call = call
  )
}

#' @noRd
check_number_positive <- function(
  x,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
) {
  if (is.numeric(x) && length(x) == 1 && is.finite(x) && x > 0) {
    return(invisible(NULL))
  }

  cli::cli_abort(
    "{.arg {arg}} must be a positive number, not {.obj_type_friendly {x}}.",
    call = call
  )
}

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
