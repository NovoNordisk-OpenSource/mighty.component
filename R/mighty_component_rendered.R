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
mighty_component_rendered <- R6::R6Class(
  classname = "mighty_component_rendered",
  inherit = mighty_component,
  public = list(
    #' @description
    #' Create standard component from rendered template.
    #' @param template `character` Rendered template such as output from `mighty_component$render()`.
    #' @param id `character` ID of the component. Either name of standard or path to local.
    initialize = function(template, id) {
      super$initialize(template, id)
      private$.params <- data.frame(
        name = character(),
        description = character()
      )
    },
    #' @description
    #' Print rendered component
    #' @return (`invisible`) self
    print = function() {
      msr_print(self, super)
    },
    #' @description
    #' Stream rendered code into a script (appended)
    #' @param path `character(1)` path to the R script to stream code into.
    stream = function(path) {
      msr_stream(path, self)
    },
    #' @description
    #' Evaluate code in a specified environment.
    #' @param envir Environment to evaluate in. Parsed to `eval()`.
    #' Defaults to using the current environment with `parent.frame()`.
    eval = function(envir = parent.frame()) {
      eval(
        expr = parse(text = self$code),
        envir = envir
      )
    },
    #' @description
    #' Test component against expected output.
    #' @param expected The expected output in `value` after evaluation
    #' @param value Name of the object used to compare against after evaluating
    #' the component. Defaults to `"domain"`.
    #' @param envir Parent environment to use for evaluation of test code.
    #' Defaults to using the current environment with `parent.frame()`.
    test = function(expected, value = "domain", envir = parent.frame()) {
      msr_test(expected, value, envir, self, private)
    },
    #' @description
    #' Calculate test coverage for already run tests
    test_coverage = function() {
      msr_test_coverage(self)
    }
  )
)

#' @noRd
msr_print <- function(self, super) {
  cli::cli({
    super$print()
    cli::cli_text("{.emph Code:}")
    cli::cli_code(self$code)
  })

  invisible(self)
}

#' @noRd
msr_stream <- function(path, self) {
  f <- file(description = path, open = "a")
  writeLines(text = self$code, con = f)
  close(f)
  invisible(self)
}

#' @noRd
msr_test <- function(expected, value, envir, self, private) {
  env <- new.env(parent = envir)
  self$eval(envir = env)
  testthat::expect_equal(
    object = env[[value]],
    expected = expected,
    ignore_attr = TRUE
  )
  return(invisible(self))
}

#' @noRd
msr_test_coverage <- function(self) {
  return(numeric(1))
}
