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

  mighty_standard$new(
    template = c(
      extract_function_metadata(code_string),
      extract_function_body(code_string)
    )
  )$render()
}

extract_function_body <- function(code_string) {
  # We can't just use body() to extract the fn's body, becaus for if-else blocks it produces strings that are not formatted properly as R code
  fn_nm <- code_string |> parse(text = _) |> _[[1]][[2]]

  # Get into envir
  parse(text = code_string) |>
    eval()

  fn_nm |> 
    get() |>
    attr("srcref") |> 
    paste(collapse = "\n") |>
    remove_function_header() |>
    remove_function_return()
  
  # TODO: proper validation checks of custom components - e.g. cannot have multiple return statements, must end with return(.self), etc

}

extract_function_metadata <- function(code_string) {
  metadata <- code_string |> strsplit(split = "\\n") |> unlist()
  metadata <- grep(pattern = "^#\\'", x = trimws(metadata), value = TRUE)
}

#' List all available standards
#' @export
list_standards <- function(library) {
  templates <- system.file(
    "components",
    package = library
  ) |>
    list.files()
  setNames(templates, rep(library, length(templates)))
}


#' @noRd
find_standard <- function(standard, library) {
  out <- system.file(
    "components",
    paste0(standard, ".mustache"),
    package = library
  )
  if (out == "") {
    cli::cli_abort("Component {standard} not found in {library}")
  }
  out
}

remove_function_header <- function(f_string) {
  # grep_pattern <- "function\\(\\s*\\.self\\s*(,\\s*\\w+)*\\s*\\)\\s*\\{"
  grep_pattern <- "function\\(\\s*(.*?)\\)\\s*?\\{"

  # When there are function definitions embedded in a node, we need to allow
  # those to remain
  gsub(pattern = grep_pattern,
       replacement = "",
       x = f_string)

}

remove_function_return <- function(f_string) {
  # TODO: check for when the return statement is broken up by linebreaks
  grep_pattern <- "return\\(.*?\\)(?s:.*)\\}"
  gsub(
    pattern = grep_pattern,
    replacement = "",
    x = f_string,
    perl = TRUE
  )

}
