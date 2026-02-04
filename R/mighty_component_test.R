#' Test mighty component
#' @description
#' Class for a testing a mighty component.
#'
#' @export
mighty_component_test <- R6::R6Class(
  classname = "mighty_component_test",
  inherit = mighty_component_rendered,
  public = list(
    #' @description
    #' Create test component from rendered template.
    #' @param template `character` Rendered template such as output from `mighty_component$render()`.
    #' @param id `character` ID of the component. Either name of standard or path to local.
    initialize = function(template, id) {
      mst_initialize(template, id, self, private, super)
    },
    #' @description
    #' Print method showing component and test coverage
    print = function() {
      mst_print(self)
    },
    #' @description
    #' Assign
    assign = function(x, value) {
      mst_run(assign, list(x, value), self, private)
    },
    get = function(x) {
      mst_run(get, list(x), self, private)
    },
    ls = function() {
      mst_run(ls, list(), self, private)
    },
    #' @description
    #' Test component against expected output.
    eval = function() {
      mst_run(\() .f(), list(), self, private)
    },
    #' @description
    #' Check that code coverage is 100%
    check_coverage = function() {
      mst_check_coverage(self, private)
    }
  ),
  private = list(
    .session = NULL,
    .coverage = 0
  ),
  active = list(
    #' @field coverage description
    coverage = \() private$.coverage
  )
)

#' @noRd
mst_initialize <- function(template, id, self, private, super) {
  rlang::check_installed("callr")
  rlang::check_installed("covr")

  super$initialize(template, id)

  private$.session <- callr::r_session$new()

  # TODO: Can it be done less hacky?????
  test_fn <- function() {}
  body(test_fn) <- parse(
    text = gsub(
      pattern = "<-",
      replacement = "<<-",
      x = self$code,
      fixed = TRUE
    )
  )

  self$assign(x = ".f", value = test_fn)

  # TODO assign function

  # TODO: Retrieve init coverage

  # private$.coverage <- zero_coverage[["coverage"]] |>
  #   covr::tally_coverage(by = "line") |>
  #   format_coverage()
}

#' @noRd
mst_print <- function(self) {
  # TODO
  invisible(self)
}

#' @noRd
mst_run <- function(func, args, self, private) {
  invisible(
    private$.session$run(
      func = func,
      args = args
    )
  )
}

#' @noRd
mst_eval <- function(self, private) {
  # result <- callr::r(
  #   func = eval_coverage,
  #   args = list(
  #     input = input,
  #     test_fn = private$.test_fn,
  #     test_code = "output <<- test_fn(.self = input)"
  #   ),
  #   package = TRUE
  # )
  # coverage <- result$coverage |>
  #   covr::tally_coverage(by = "line") |>
  #   format_coverage()
  # private$.coverage$covered <- private$.coverage$covered |
  #   as.logical(coverage$covered)
  # result$output
}

#' @noRd
eval_coverage <- function(input = data.frame(), test_fn, test_code = "") {
  # output <- NULL
  # coverage <- covr::code_coverage(
  #   source_code = paste(test_fn, collapse = "\n"),
  #   test_code = test_code,
  #   parent_env = rlang::current_env()
  # )
  # list(
  #   output = output,
  #   coverage = coverage
  # )
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
    cli::cli_abort(
      c(
        "All lines in component must be covered by unit tests",
        "i" = "Lines not covered: {self$missing_lines}"
      )
    )
  }

  invisible(self)
}
