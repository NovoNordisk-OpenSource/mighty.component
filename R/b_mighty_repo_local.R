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
  properties = list(
    path = S7::new_property(
      class = S7::class_character,
      validator = \(value) {
        validate_string(value)
      }
    )
  ),
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
    paste("Directory", self@path, "does not exist")
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

#' Component ids from relative file paths
#'
#' Flat components are `<name>.R|.mustache`. Nested components are
#' `<name>/<name>.R|.mustache`. Files starting with `test-` are dropped.
#' @noRd
ids_from_files <- function(files) {
  is_flat <- !grepl(pattern = "/", x = files, fixed = TRUE) &
    grepl(pattern = "\\.(R|mustache)$", x = files)
  flat <- tools::file_path_sans_ext(files[is_flat])

  paths <- files[grepl(pattern = "^[^/]+/[^/]+$", x = files)]
  dirs <- dirname(paths)
  is_nested <- basename(paths) == paste0(dirs, ".R") |
    basename(paths) == paste0(dirs, ".mustache")
  nested <- dirs[is_nested]

  ids <- c(flat, nested)
  unique(ids[!startsWith(x = ids, prefix = "test-")])
}

#' @noRd
S7::method(component_ids, mighty_repo_local) <- function(repos) {
  dirs <- list.dirs(path = repos@path, full.names = FALSE, recursive = FALSE)
  nested <- lapply(
    X = dirs,
    FUN = \(dir) {
      file.path(dir, component_files(path = file.path(repos@path, dir)))
    }
  )

  ids_from_files(files = c(component_files(path = repos@path), unlist(nested)))
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
