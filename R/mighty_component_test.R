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
      invisible(
        mst_run(assign, list(x, value), self, private)
      )
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
      mst_eval(self, private)
    },
    #' @description
    #' Check that code coverage is 100%
    check_coverage = function() {
      mst_check_coverage(self, private)
    }
  ),
  private = list(
    .session = NULL,
    .coverage = NULL
  ),
  active = list(
    #' @field percent_coverage description
    percent_coverage = \() mean(private$.coverage$value > 0) * 100,
    #' @field line_coverage description
    line_coverage = \() private$.coverage
  )
)

#' @noRd
mst_initialize <- function(template, id, self, private, super) {
  rlang::check_installed("callr")
  rlang::check_installed("covr")

  super$initialize(template, id)

  # TODO: Can it be done less hacky?????
  # covr::function_coverage seems to be buggy for this use
  test_fn <- paste(
    c(
      ".f <- function() {",
      gsub(
        pattern = "<-",
        replacement = "<<-",
        x = self$code,
        fixed = TRUE
      ),
      "}"
    ),
    collapse = "\n"
  )

  private$.session <- callr::r_session$new()

  # TODO: binding
  self$assign(x = ".f", value = test_fn)

  init_coverage <- mst_run(
    func = \() covr::code_coverage(source_code = .f, test_code = ""),
    args = list(),
    self = self,
    private = private
  ) |>
    covr::tally_coverage()

  init_coverage$line <- init_coverage$line - 1

  private$.coverage <- init_coverage[, c("line", "value")]
}

#' @noRd
mst_print <- function(self) {
  # TODO
  invisible(self)
}

#' @noRd
mst_run <- function(func, args, self, private) {
  private$.session$run(
    func = func,
    args = args
  )
}

#' @noRd
mst_eval <- function(self, private) {
  coverage <- mst_run(
    func = \() covr::code_coverage(source_code = .f, test_code = ".f()"),
    args = list(),
    self = self,
    private = private
  ) |>
    covr::tally_coverage(by = "line")

  private$.coverage$value <- private$.coverage$value + coverage$value

  invisible()
}

#' @noRd
mst_check_coverage <- function(self, private) {
  missing_lines <- self$line_coverage$line[
    self$line_coverage$value == 0
  ]

  if (length(missing_lines)) {
    cli::cli_abort(
      c(
        "All lines in component must be covered by unit tests",
        "i" = "Lines not covered: {missing_lines}"
      )
    )
  }

  invisible(self)
}
