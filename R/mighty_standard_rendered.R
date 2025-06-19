#' Rendered mighty standard component
#' @export
mighty_standard_rendered <- R6::R6Class(
  classname = "mighty_standard_rendered",
  inherit = mighty_standard,
  public = list(
    #' @description
    #' Create standard component from rendered template
    #' @param template rendered template
    initialize = function(template) {
      super$initialize(template)
    },
    #' @description
    #' Evaluate code
    #' @param envir Environment to evaluate in. Parsed to `eval()`.
    eval = function(envir = parent.frame()) {
      eval(
        expr = parse(text = self$code),
        envir = envir
      )
    },
    #' @description
    #' Test component
    #' @param input The input to use as `.self` for the code chunk
    #' @param expected The expected output in `.self` after evaluation
    test = function(input, expected) {
      ms_test(input, expected, self)
    },
    #' @description
    #' Test coverage
    coverage = function() {
      0.2 # TODO: Calculate coverage based on tests
    }
  )
)

#' @noRd
ms_test <- function(input, expected, self) {
  env <- new.env(parent = baseenv())
  env$.self <- input
  self$eval(envir = env)
  testthat::expect_equal(
    object = env$.self, 
    expected = expected, 
    ignore_attr = TRUE
  )
}