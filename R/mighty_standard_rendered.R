#' Rendered mighty standard component
#' @description
#' Class for a rendered mighty standard component.
#'
#' Once rendered a component can be used to:
#'
#' * Stream into an R script
#' * Evaluate the generated code in an environment
#' * Test code against expected output
#' * Calculate test coverage
#'
#' @seealso [get_rendered_standard()]
#' @export
mighty_standard_rendered <- R6::R6Class(
  classname = "mighty_standard_rendered",
  inherit = mighty_standard,
  public = list(
    #' @description
    #' Create standard component from rendered template.
    #' @param template  `character` Rendered template such as output from `mighty_standard$render()`.
    initialize = function(template) {
      super$initialize(template)
    },
    #' @description
    #' Stream rendered code into a script (appended)
    #' @param path `character(1)` path to the R script to stream code into.
    stream = function(path) {
      msr_stream(path, self)
    },
    #' @description
    #' Evaluate code in a specified environment.
    #' @param envir Environment to evaluate in. Parsed to `eval()`. Defaults to using the current environment with `parent.frame()`.
    eval = function(envir = parent.frame()) {
      eval(
        expr = parse(text = self$code),
        envir = envir
      )
    },
    #' @description
    #' Test component against expected output.
    #' **TODO: Implement in #17**
    #' @param input The input to use as `.self` for the code chunk
    #' @param expected The expected output in `.self` after evaluation
    test = function(input, expected) {
      msr_test(input, expected, self, private)
    },
    #' @description
    #' Calculate test coverage for already run tests
    #' **TODO: Implement in #17**
    test_coverage = function() {
      msr_test_coverage(self)
    }
  )
)

#' @noRd
msr_stream <- function(path, self) {
  f <- file(description = path, open = "a")
  writeLines(text = self$code, con = f)
  close(f)
  invisible(self)
}

#' @noRd
msr_test <- function(input, expected, self, private) {
  env <- new.env(parent = baseenv())
  env$.self <- input
  self$eval(envir = env)
  testthat::expect_equal(
    object = env$.self,
    expected = expected,
    ignore_attr = TRUE
  )
  # TODO: Implement coverage calculation and return inside self/private
  return(invisible(self))
}

#' @noRd
msr_test_coverage <- function(self) {
  # TODO: Implement calculation to measure test coverage based on previous ran tests
  return(numeric(1))
}
