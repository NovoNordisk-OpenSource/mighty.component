assert_type <- function(type) {
  types <- c("predecessor", "derivation", "row")
  if (!type %in% types) {
    cli::cli_abort("@type must be one of {.val {types}}")
  }
  return(type)
}
