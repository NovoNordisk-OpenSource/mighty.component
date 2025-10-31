#' @noRd
get_custom_r <- function(path) {
  code <- readLines(path)

  if (any(grepl(pattern = "^#' @param", x = code))) {
    cli::cli_abort(
      c(
        "{.code @param} tags not allowed for custom components",
        i = "use mustache component template instead"
      )
    )
  } else if (any(grepl(pattern = "\\{\\{|\\}\\}", x = code))) {
    cli::cli_abort(
      c(
        "Use of mustache patterns {{{{ or }}}} are not allowed in custom components",
        i = "use mustache component template instead"
      )
    )
  }

  mighty_component$new(
    template = code,
    id = path
  )
}
