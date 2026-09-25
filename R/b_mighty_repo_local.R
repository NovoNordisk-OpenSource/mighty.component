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
match_files <- function(component, path) {
  candidates <- c(component, paste0(component, c(".R", ".mustache")))
  intersect(x = candidates, y = component_files(path = path))
}

#' @noRd
S7::method(list_components, mighty_repo_local) <- function(repos) {
  flat <- component_files(path = repos@path) |>
    tools::file_path_sans_ext()

  dirs <- list.dirs(path = repos@path, full.names = FALSE, recursive = FALSE)
  nested <- dirs[vapply(
    X = dirs,
    FUN = \(dir) length(match_files(dir, file.path(repos@path, dir))) > 0,
    FUN.VALUE = logical(1)
  )]

  ids <- c(flat, nested)
  unique(ids[!startsWith(x = ids, prefix = "test-")])
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, mighty_repo_local)
) <- function(component, repos) {
  name <- tools::file_path_sans_ext(component)

  file <- c(
    match_files(component = component, path = repos@path),
    file.path(
      name,
      match_files(component = component, path = file.path(repos@path, name))
    )
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
    id = basename(file)
  )
}
