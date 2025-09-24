#' @noRd
valid_types <- function() {
  c(
    "column",
    "row",
    "bds"
  )
}

#' @noRd
valid_origins <- function() {
  c(
    "Assigned",
    "Collected",
    "Derived",
    "Not Available",
    "Other",
    "Predecessor",
    "Protocol"
  )
}

#' @noRd
assert_choice <- function(x, choices, arg = deparse(substitute(x))) {
  if (!x %in% choices) {
    cli::cli_abort("@{arg} must be one of {.val {choices}}")
  }
  return(x)
}
