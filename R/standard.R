#' Retrieve mighty standard component
#' @param standard standard
#' @export
get_standard <- function(standard, library) {
  template <- find_standard(standard, library)
  mighty_standard$new(template = readLines(template))
}

#' Retrieve rendered mighty standard component
#' @export
get_rendered_component <- function(standard, ...) {
  is_r_file <- grepl(pattern = "\\.[Rr]$", x = standard)
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

get_rendered_custom <- function(path) {

  code_string <- readLines(path) |>
    paste0(collapse = "\n")
  fn_body_string <- parse(text = code_string) |>
    eval() |>
    body() |>
    deparse()

  # Remove opening and closing brackets
  fn_body <- fn_body_string[-c(1, length(fn_body_string))]

  # metadata
  metadata <- code_string |> strsplit(split = "\\n") |> unlist()
  metadata <- grep(pattern = "^#\\'", x = trimws(metadata), value = TRUE)
  mighty_standard$new(template = c(metadata, fn_body))$render()
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
