#' Local component repo
#' @export
mighty_repo_local <- S7::new_class(
  name = "mighty_repo_local",
  parent = mighty_repo_class,
  validator = \(self) {
    validate_local(self)
  }
)

#' @noRd
validate_local <- function(self) {
  if (!dir.exists(self@path)) {
    paste("@path", self@path, "does not exist")
  }
}

#' @noRd
component_files <- function(path) {
  list.files(path = path, pattern = "\\.(R|mustache)$")
}

#' @noRd
S7::method(list_components, mighty_repo_local) <- function(repos) {
  files <- component_files(path = repos@path)
  files <- files[!startsWith(x = files, prefix = "test-")]

  tools::file_path_sans_ext(files)
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, mighty_repo_local)
) <- function(component, repos) {
  candidates <- c(component, paste0(component, c(".R", ".mustache")))

  file <- intersect(
    x = candidates,
    y = component_files(path = repos@path)
  ) |>
    assert_single_match()

  if (!length(file)) {
    return(NULL)
  }

  template <- readLines(con = file.path(repos@path, file))

  if (tools::file_ext(file) == "R") {
    check_custom_r(code = template)
  }

  mighty_component$new(
    template = template,
    id = file
  )
}
