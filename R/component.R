#' Retrieve a component
#' @description
#' * `get_component()`: Find a component. Raises an error if it is not found.
#' * `get_rendered_component()`: Find a component and render it with
#'   `params`.
#'
#' @details
#' Components are `.mustache` or `.R` files. Both use the tags described in
#' [mighty_component].
#'
#' * `.mustache` files are Mustache templates.
#' * `.R` files are plain R components. They cannot have `@param` tags or
#'   Mustache placeholders.
#'
#' @inheritParams find_component
#' @param params named `list` of parameters passed to `$render()`. See the
#' component's `@param` tags (`component$params`).
#' @returns
#' * `get_component()`: A [mighty_component] object.
#' * `get_rendered_component()`: A [mighty_component_rendered] object.
#' @seealso [find_component()], [mighty_component],
#'   [mighty_component_rendered]
#' @examples
#' path <- system.file("examples", "ady.mustache", package = "mighty.component")
#' get_component(path)
#'
#' get_rendered_component(
#'   component = path,
#'   params = list(domain = "ADAE", variable = "ASTDY", date = "ASTDT")
#' )
#'
#' # Find by name in a repo
#' repo <- system.file("examples", package = "mighty.component")
#' get_component("ady", repos = repo)
#'
#' @rdname get_component
#' @export
get_component <- function(component, repos = NULL) {
  found <- find_component(component, repos)

  if (!is.null(found)) {
    return(found)
  }

  cli::cli_abort("Component {.code {component}} not found")
}

#' @rdname get_component
#' @export
get_rendered_component <- function(component, params = list(), repos = NULL) {
  x <- get_component(component, repos = repos)
  do.call(what = x$render, args = params)
}

#' Create a test component
#'
#' @description
#' Retrieve and render a component as a [mighty_component_test] object, for
#' unit tests with code coverage. See [mighty_component_test] for the
#' workflow.
#'
#' Requires the callr and covr packages.
#'
#' @inheritParams get_component
#' @param check_coverage `logical(1)` If `TRUE` (default), `$check_coverage()`
#' runs when `teardown_env` ends. It raises an error if any line has not run.
#' @param teardown_env Environment that controls when the coverage check
#' runs. Defaults to the calling environment, e.g. the `test_that()` block.
#'
#' @returns A [mighty_component_test] object.
#'
#' @seealso [get_rendered_component()], [mighty_component_test]
#'
#' @examplesIf rlang::is_installed(c("admiral", "callr", "covr", "dplyr"))
#' path <- system.file("examples", "ady.mustache", package = "mighty.component")
#' x <- get_test_component(
#'   component = path,
#'   params = list(domain = "adae", variable = "ASTDY", date = "ASTDT"),
#'   check_coverage = FALSE
#' )
#'
#' adae <- data.frame(
#'   TRTSDT = as.Date("2024-01-01"),
#'   ASTDT = as.Date(c("2024-01-01", "2024-01-10"))
#' )
#'
#' x$assign("adae", adae)$eval()
#' x$get("adae")
#' x$percent_coverage
#' x$close()
#'
#' @export
get_test_component <- function(
  component,
  params = list(),
  repos = NULL,
  check_coverage = TRUE,
  teardown_env = parent.frame()
) {
  x <- get_rendered_component(component, params, repos = repos)

  test_component <- mighty_component_test$new(
    template = x$template,
    id = x$id
  )

  if (check_coverage) {
    withr::defer(
      expr = test_component$check_coverage(),
      envir = teardown_env
    )
  }

  test_component
}
