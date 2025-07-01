#' Retrieve mighty standard component
#' @param standard standard
#' @export
get_standard <- function(standard, library) {
  template <- find_standard(standard, library)
  mighty_standard$new(template = readLines(template))
}

get_rendered_component <- function(standard, ...) {
  is_r_file <- grepl(pattern = standard, pattern = "\\.[Rr]$")
  if (is_r_file) {
    return(get_rendered_custom(standard))
  }

  get_rendered_standard(standard, ...)
}

#' Retrieve rendered mighty standard component
#' @param standard standard
#' @param params list of input parameters
#' @export
get_rendered_standard <- function(standard, library, params) {
  x <- get_standard(standard, library)
  do.call(what = x$render, args = params)
}

get_rendered_custom <- function(code_component, path) {
  code_string <- readLines(path) |>
    paste0(collapse = "\n")
  template |> parse(text = code_string) |>
    eval() |> 
    body() |> 
    deparse()
  mighty_standard$new(template = )
}

#' List all available standards
#' @export
list_standards <- function(library) {
  templates <- system.file(
    "components",
    package = library
  ) |>
    list.files(full.names = TRUE) |>
    get_id()
  setNames(templates, rep(library, length(templates)))
}

#' Read in tepmlate files and return code component id
get_id <- function(path_templates) {
  path_templates |>
    vapply(
      function(i) {
        x <- readLines(i, warn = FALSE)
        get_tag(x, "id") |> trimws()
      },
      FUN.VALUE = character(1L)
    )
}

#' @noRd
find_standard <- function(standard, library) {
  if (!standard %in% list_standards(library)) {
    cli::cli_abort("Component {template} not found")
  }

  system.file(
    "components",
    paste0(standard, ".mustache"),
    package = "mighty.standards"
  )
}
