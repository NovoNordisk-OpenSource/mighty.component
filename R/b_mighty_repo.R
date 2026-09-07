#' Common generator function
#' @export
mighty_repo <- function(spec) {
  type <- ifelse(
    test = grepl(pattern = "::", x = spec, fixed = TRUE),
    yes = sub(pattern = "::.*", replacement = "", x = spec),
    no = "local"
  )

  path <- sub(pattern = "^[^:]*::", replacement = "", x = spec)

  switch(
    EXPR = type,
    local = mighty_repo_local(path = path),
    github = mighty_repo_github(spec = path),
    cli::cli_abort("Unknown repo type {.val {type}} in {.val {spec}}.")
  )
}

#' Component repo
#' @rdname mighty_repo
#' @export
mighty_repo_class <- S7::new_class(
  name = "mighty_repo_class",
  properties = list(
    path = S7::new_property(
      class = S7::class_character,
      validator = \(value) {
        validate_string(value)
      }
    )
  ),
  abstract = TRUE
)

#' @noRd
S7::method(format, mighty_repo_class) <- function(x, ...) {
  x@path
}

#' @noRd
validate_string <- function(value) {
  if (length(value) != 1) {
    "has to be of length 1"
  }
}
