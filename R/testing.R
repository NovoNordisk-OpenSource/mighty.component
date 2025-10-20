#' Create test component
#' @inheritParams get_component
#' @param teardown_env Environment used
#' @export
test_component <- function(component, params, teardown_env = parent.frame()) {
  x <- get_rendered_component(component, params)
  test <- x$test()
  withr::defer(
    expr = test$check_coverage(),
    envir = teardown_env
  )
  test
}

#' Evaluate a test component
#' @param input Object to be used as `.self` when testing the component
#' @param component Test component
#' @export
test_eval <- function(input, component) {
  component$eval(input = input)
}
