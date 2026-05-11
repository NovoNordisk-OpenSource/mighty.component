#' Retrieve mighty code component
#' @description
#' Retrieve a mighty code component from a local file.
#'
#' * `get_component()`: Returns an object of class `mighty_component`.
#' * `get_rendered_component()`: Returns an object of class `mighty_component_rendered`.
#'
#' When rendering a component the required list of parameters depends on the individual component.
#' Check the documentation of the local component for details.
#'
#' @details Processes different component types based on file extension:
#'
#' * `.R`: Extracts and renders custom functions.
#' * `.mustache`: Creates components from the template files.
#'
#' @param component `character` path to a component file (`.R` or `.mustache`).
#' @param params named `list` of input parameters. Passed along to `mighty_component$render()`.
#' @seealso [mighty_component], [mighty_component_rendered]
#' @examples
#' path <- system.file("templates", "example.mustache", package = "mighty.component")
#' if (nzchar(path)) get_component(path)
#'
#' @rdname get_component
#' @export
get_component <- function(component) {
  file_type <- tolower(tools::file_ext(component))

  if (file_type != "" && !file.exists(component)) {
    cli::cli_abort("Component {.file {component}} not found")
  }

  switch(
    file_type,
    "r" = get_custom_r(component),
    "mustache" = get_mustache(component),
    cli::cli_abort(
      "Component {.file {component}} not found. Provide a {.file .R} or {.file .mustache} file path."
    )
  )
}

#' @noRd
get_mustache <- function(component) {
  mighty_component$new(
    template = readLines(component),
    id = component
  )
}

#' @rdname get_component
#' @export
get_rendered_component <- function(component, params = list()) {
  x <- get_component(component)
  do.call(what = x$render, args = params)
}

#' Create a testable component for unit testing
#'
#' @description
#' Creates a `mighty_component_test` object from a rendered component,
#' enabling structured unit testing with optional coverage checking.
#'
#' See [mighty_component_test] for a description of the testing workflow.
#'
#' @inheritParams get_component
#' @param check_coverage `logical(1)` Whether to automatically check test
#' coverage when the test completes. If `TRUE` (default), coverage is
#' verified via `test_component$check_coverage()` in a deferred call.
#' @param teardown_env The environment in which to register the deferred
#' coverage check. Defaults to the caller's environment (`parent.frame()`).
#' This controls when `check_coverage()` executes during test teardown.
#'
#' @return A `mighty_component_test` object.
#'
#' @seealso [get_rendered_component()], [mighty_component_test]
#'
#' @export
get_test_component <- function(
  component,
  params = list(),
  check_coverage = TRUE,
  teardown_env = parent.frame()
) {
  x <- get_rendered_component(component, params)

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
