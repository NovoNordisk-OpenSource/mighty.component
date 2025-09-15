#' Rendered mighty standard component
#' @description
#' Class for a rendered mighty standard component.
#'
#' Once rendered a component can be used to:
#'
#' * Test code against expected output
#' * Calculate test coverage
#'
#' @seealso [get_rendered_standard()]
#' @export
mighty_component_test <- R6::R6Class(
  classname = "mighty_component_test",
  public = list(
    #' @description
    #' Create standard component from rendered template.
    #' @param component `character` Rendered template such as output from `mighty_component$render()`.
    initialize = function(component) {
      mst_initialize(component, self, private)
    },
    #' @description
    #' Print method showing test coverage
    print = \() mst_print(self),
    #' @description
    #' Test component against expected output.
    #' @param input The input to use as `.self` for the code chunk
    eval = function(input) {
      mst_eval(input, self, private)
    },
    #' @description
    #' Check that code coverage is 100%
    check_coverage = function() {
      mst_check_coverage(self, private)
    }
  ),
  private = list(
    .component = NULL,
    .test_fn = NULL,
    .coverage = NULL
  ),
  active = list(
    #' @field component The [mighty_component_rendered] object being tested.
    component = \() private$.component,
    #' @field test_coverage Test coverage percentage
    test_coverage = \() mean(private$.coverage$covered) * 100,
    #' @field missing_lines Index of lines uncovered by unit tests
    missing_lines = \() private$.coverage$line[!private$.coverage$covered],
    #' @field covered_lines Index of lines covered by unit tests
    covered_lines = \() private$.coverage$line[private$.coverage$covered]
  )
)

#' @noRd
mst_initialize <- function(component, self, private) {
  rlang::check_installed("callr")
  rlang::check_installed("covr")

  private$.component <- component

  private$.test_fn <- c(
    "test_fn <- function(.self) {",
    component$code,
    "return(.self)",
    "}"
  )

  private$.coverage <- callr::r(
    func = \(test_fn) {
      covr::code_coverage(
        source_code = paste(test_fn, collapse = "\n"),
        test_code = "",
        parent_env = rlang::current_env()
      )
    },
    args = list(
      test_fn = private$.test_fn
    )
  ) |>
    covr::tally_coverage(by = "line") |>
    format_coverage()
}

#' @noRd
mst_print <- function(self) {
  cli::cli({
    cli::cli_text("{.emph Code:}")
    cli::cli_code(self$component$code)
  })

  invisible(self)
}

#' @noRd
mst_eval <- function(input, self, private) {
  result <- callr::r(
    func = \(input, test_fn) {
      output <- NULL

      coverage <- covr::code_coverage(
        source_code = paste(test_fn, collapse = "\n"),
        test_code = "output <<- test_fn(.self = input)",
        parent_env = rlang::current_env()
      )

      list(
        output = output,
        coverage = coverage
      )
    },
    args = list(
      input = input,
      test_fn = private$.test_fn
    )
  )

  coverage <- result$coverage |>
    covr::tally_coverage(by = "line") |>
    format_coverage()

  private$.coverage$covered <- private$.coverage$covered |
    as.logical(coverage$covered)

  result$output
}

#' @noRd
format_coverage <- function(tally) {
  data.frame(
    line = tally$line - 1,
    covered = as.logical(tally$value)
  )
}

#' @noRd
mst_check_coverage <- function(self, private) {
  if (length(self$missing_lines)) {
    cli::cli_abort("ALL LINES MUST BE COVERED")
  }

  invisible(self)
}
