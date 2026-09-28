#' Local component repo
#' @description
#' A component repo in a local directory. Components are `.R` or `.mustache`
#' files directly in `path`, or in a directory named after the component
#' (`<path>/<name>/<name>.R`).
#' @param path `character(1)` path to an existing directory.
#' @examples
#' path <- system.file("examples", package = "mighty.component")
#' mighty_repo_local(path = path)
#' @seealso [mighty_repo()]
#' @export
mighty_repo_local <- S7::new_class(
  name = "mighty_repo_local",
  parent = mighty_repo_class,
  constructor = function(path) {
    S7::new_object(S7::S7_object(), path = path)
  },
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
S7::method(format, mighty_repo_local) <- function(x, ...) {
  paste0("local::", x@path)
}

#' @noRd
component_files <- function(path) {
  files <- list.files(path = path, pattern = "\\.(R|mustache)$")
  files[!dir.exists(file.path(path, files))]
}

#' @noRd
match_files <- function(component, path) {
  candidates <- c(component, paste0(component, c(".R", ".mustache")))
  intersect(x = candidates, y = component_files(path = path))
}

#' @noRd
S7::method(component_ids, mighty_repo_local) <- function(repos) {
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
S7::method(repo_find_component, mighty_repo_local) <- function(
  repos,
  component
) {
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
