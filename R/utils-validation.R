valid_types <- function() {
  c("predecessor", "derivation", "row", "assigned")
}

assert_type <- function(type) {
  types <- valid_types()
  if (!type %in% types) {
    cli::cli_abort("@type must be one of {.val {types}}. Found {.code {type}}")
  }
  return(type)
}
