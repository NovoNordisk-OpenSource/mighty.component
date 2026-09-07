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
S7::method(list_components, mighty_repo_local) <- function(
  repos,
  remove_ext = TRUE
) {
  files <- repos@path |>
    list.files(
      pattern = "\\.(R|mustache)$"
    )

  if (remove_ext) {
    files <- tools::file_path_sans_ext(files)
  }

  files
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, mighty_repo_local)
) <- function(component, repos) {
  file <- grep(
    pattern = paste0("^", component, "(|\\.R|\\.mustache)$"),
    x = list_components(repos = repos, remove_ext = FALSE),
    value = TRUE
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
    id = component
  )
}
