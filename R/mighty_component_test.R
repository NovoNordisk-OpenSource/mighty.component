#' Test mighty component
#' @description
#' Class for unit testing a mighty component with code coverage tracking.
#' Runs component code in an isolated R session and tracks which lines are
#' executed during testing.
#'
#' @details
#' Always use [get_test_component()] to create instances for testing. The test
#' workflow is:
#'
#' 1. Create test component with `get_test_component()`
#' 2. Assign input data with `$assign()`
#' 3. Execute and track coverage with `$eval()`
#' 4. Retrieve results with `$get()`
#' 5. Test results with `expect_*()` functions from `{testthat}`
#'
#' Coverage is automatically checked at test teardown via `$check_coverage()`.
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
    #' Assign a variable in the isolated test session.
    #' @param x `character` Name of the variable to assign.
    #' @param value Value to assign to the variable.
    #' @return `self` invisibly, for method chaining.
    assign = function(x, value) {
      mst_run(assign, list(x, value), self, private)
      invisible(self)
    },
    #' @description
    #' Retrieve a variable from the isolated test session.
    #' @param x `character` Name of the variable to retrieve.
    #' @return The value of the variable.
    get = function(x) {
      mst_run(get, list(x), self, private)
    },
    #' @description
    #' List all objects in the isolated test session.
    #' @return `character` vector of variable names.
    ls = function() {
      mst_run(ls, list(), self, private)
    },
    #' @description
    #' Execute the component code and update coverage tracking.
    #' @return `self` invisibly, for method chaining.
    eval = function() {
      mst_eval(self, private)
    },
    #' @description
    #' Check that all lines in the component were executed at least once.
    #' Throws an error if any lines have zero coverage.
    #' @return `self` invisibly if all lines are covered.
    check_coverage = function() {
      mst_check_coverage(self, private)
    }
  ),
  private = list(
    finalize = function() {
      mst_finalize(self, private)
    },
    .session = NULL,
    .coverage = NULL
  ),
  active = list(
    #' @field percent_coverage `numeric` Percentage of lines covered (0-100).
    percent_coverage = \() mean(private$.coverage$value > 0) * 100,
    #' @field line_coverage `data.frame` with columns `line` and `value`
    #' showing execution count per line.
    line_coverage = \() private$.coverage
  )
)

#' @noRd
mst_initialize <- function(template, id, self, private, super) {
  rlang::check_installed("callr")
  rlang::check_installed("covr")

  super$initialize(template, id)

  test_fn <- paste(
    c(
      ".test_fn <- function() {",
      "  .eval_env <- new.env(parent = globalenv())",
      "  eval(expression({",
      self$code,
      "  }), envir = .eval_env)",
      "  list2env(as.list(.eval_env), envir = globalenv())",
      "  invisible(NULL)",
      "}"
    ),
    collapse = "\n"
  )

  private$.session <- callr::r_session$new()

  self$assign(x = ".test_fn", value = test_fn)

  mst_run(
    # Locks .test_fn to make sure it is not accidentally overwritten
    func = \() lockBinding(sym = ".test_fn", env = globalenv()),
    args = list(),
    self = self,
    private = private
  )

  init_coverage <- mst_run(
    func = \() {
      # nocov start
      covr::code_coverage(
        source_code = get(".test_fn"),
        test_code = ""
      )
      # nocov end
    },
    self = self,
    private = private
  ) |>
    covr::tally_coverage()

  # Filter to only component code lines (lines 4 to 3 + n_code_lines)
  # and adjust line numbers to match original component code
  code_start <- 4
  code_end <- 3 + length(self$code)
  init_coverage <- init_coverage[
    init_coverage$line >= code_start & init_coverage$line <= code_end,
  ]
  init_coverage$line <- init_coverage$line - 3

  # Exclude blank lines from coverage tracking
  non_blank_lines <- which(trimws(self$code) != "")
  init_coverage <- init_coverage[init_coverage$line %in% non_blank_lines, ]
  # Reset rownames after filtering so they're sequential (1, 2, 3, ...)
  # rather than preserving original indices (e.g., 3, 5, 6, 7)
  rownames(init_coverage) <- NULL

  private$.coverage <- init_coverage[, c("line", "value")]
}

#' @noRd
mst_finalize <- function(self, private) {
  private$.session$close()
}

#' @noRd
mst_print <- function(self) {
  coverage <- self$line_coverage
  covered <- coverage$line[coverage$value > 0]
  uncovered <- coverage$line[coverage$value == 0]

  code_status <- rep(x = " ", times = length(self$code))
  code_status[covered] <- cli::col_green(cli::symbol$tick)
  code_status[uncovered] <- cli::col_red(cli::symbol$cross)

  code_msg <- paste(code_status, cli::code_highlight(self$code))

  cli::cli({
    cli::cli_text("{.cls {class(self)}}")
    cli::cli_text("{.field {self$id}}: {self$description}")
    cli::cli_text(
      "{.emph Test Coverage:} {.strong {format(self$percent_coverage, digits = 2, nsmall = 2)}%}"
    )
    cli::cli_text(
      "{.emph Code: ({cli::col_green(cli::symbol$tick)} Covered, {cli::col_red(cli::symbol$cross)} Uncovered)}"
    )
    cli::cli_verbatim(code_msg)
  })

  invisible(self)
}

#' @noRd
mst_run <- function(func, args = list(), self, private) {
  private$.session$run(
    func = func,
    args = args
  )
}

#' @noRd
mst_eval <- function(self, private) {
  coverage <- mst_run(
    func = \() {
      # nocov start
      covr::code_coverage(
        source_code = get(x = ".test_fn"),
        test_code = ".test_fn()"
      )
      # nocov end
    },
    self = self,
    private = private
  ) |>
    covr::tally_coverage(by = "line")

  # Filter to only component code lines (lines 4 to 3 + n_code_lines)
  # and exclude blank lines
  code_start <- 4
  code_end <- 3 + length(self$code)
  coverage <- coverage[
    coverage$line >= code_start & coverage$line <= code_end,
  ]
  coverage$line <- coverage$line - 3
  non_blank_lines <- which(trimws(self$code) != "")
  coverage <- coverage[coverage$line %in% non_blank_lines, ]

  private$.coverage$value <- private$.coverage$value + coverage$value

  invisible(self)
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
