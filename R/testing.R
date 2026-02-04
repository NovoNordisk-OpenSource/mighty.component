#' Create test component
#' @inheritParams get_component
#' @param check_coverage `logical(1)`
#' @param teardown_env Environment used
#' @export
get_test_component <- function(
  component,
  params,
  check_coverage = TRUE,
  teardown_env = parent.frame()
) {
  x <- get_rendered_component(component, params)
  test <- x$test()
  if (check_coverage) {
    withr::defer(
      expr = test$check_coverage(),
      envir = teardown_env
    )
  }
  test
}
