#' @importFrom roxygen2 roxy_tag_parse roxy_tag_rd
NULL

#' @export
roxy_tag_parse.roxy_tag_type <- function(x) {
  roxygen2::tag_markdown(x)
}

#' @export
roxy_tag_rd.roxy_tag_type <- function(x, base_path, env) {
  assert_type(x$val)
  value <- list(type = x$val)
  roxygen2::rd_section("mighty", value)
}

#' @export
roxy_tag_parse.roxy_tag_depends <- function(x) {
  roxygen2::tag_two_part(x, "dataset", "variable")
}

#' @export
roxy_tag_rd.roxy_tag_depends <- function(x, base_path, env) {
  value <- list(depends = x$val)
  roxygen2::rd_section("mighty", value)
}

#' @export
roxy_tag_parse.roxy_tag_outputs <- function(x) {
  roxygen2::tag_markdown(x)
}

#' @export
roxy_tag_rd.roxy_tag_outputs <- function(x, base_path, env) {
  value <- list(outputs = x$val)
  roxygen2::rd_section("mighty", value)
}

#' @export
merge.rd_section_mighty <- function(x, y, ...) {
  value <- c(x$value, y$value)
  roxygen2::rd_section(x$type, value)
}

itemize <- function(x) {
  c(
    "\\itemize{",
    paste("\\item", x),
    "}"
  )
}

escape_brackets <- function(x) {
  x |>
    stringr::str_replace_all(
      pattern = stringr::fixed("{"),
      replacement = stringr::fixed("\\{")
    ) |>
    stringr::str_replace_all(
      pattern = stringr::fixed("}"),
      replacement = stringr::fixed("\\}")
    )
}

#' @export
format.rd_section_mighty <- function(x, ...) {
  value <- x$value
  nm <- names(value)

  depends <- value[nm %in% "depends"] |>
    vapply(FUN = paste, FUN.VALUE = character(1), collapse = ".") |>
    escape_brackets()

  outputs <- value[nm %in% "outputs"] |>
    unlist() |>
    escape_brackets()

  c(
    "\\section{Mighty}{",
    "\\subsection{Type}{",
    value[["type"]],
    "}",
    "\\subsection{Depends}{",
    itemize(depends),
    "}",
    "\\subsection{Outputs}{",
    itemize(outputs),
    "}",
    "}"
  ) |>
    paste(collapse = "\n")
}
