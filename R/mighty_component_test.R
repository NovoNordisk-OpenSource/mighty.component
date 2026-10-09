#' Test mighty component class
#' @description
#' R6 class for unit testing a component with code coverage tracking.
#' The code runs in a separate R session, and the lines executed are counted.
#'
#' @details
#' Use [get_test_component()] to create a test component. The workflow is:
#'
#' 1. Create the test component with `get_test_component()`.
#' 1. Assign input data with `$assign()`.
#' 1. Run the code and update coverage with `$eval()`.
#' 1. Retrieve results with `$get()`.
#' 1. Test the results with testthat `expect_*()` functions.
#' 1. Close the session with `$close()`.
#'
#' By default, `get_test_component()` checks coverage with
#' `$check_coverage()` when the test ends. Coverage is kept in the current
#' R session, so it can still be checked after `$close()`.
#'
#' The code runs inside a function, with `<-` replaced by `<<-`, so
#' assignments are made in the session's global environment.
#'
#' @examplesIf rlang::is_installed(c("admiral", "callr", "covr", "dplyr"))
#' path <- system.file("examples", "ady.mustache", package = "mighty.component")
#' x <- get_test_component(
#'   component = path,
#'   params = list(domain = "adae", variable = "ADY", date = "ADT"),
#'   check_coverage = FALSE
#' )
#' x$percent_coverage
#'
#' x$assign(
#'   "adae",
#'   data.frame(TRTSDT = as.Date("2024-01-01"), ADT = as.Date("2024-01-05"))
#' )
#' x$eval()
#' x$ls()
#' x$get("adae")$ADY
#' x$percent_coverage
#' x$check_coverage()
#' x$close()
#'
#' @seealso [get_test_component()]
#' @export
mighty_component_test <- R6::R6Class(
  classname = "mighty_component_test",
  inherit = mighty_component_rendered,
  public = list(
    #' @description
    #' Create a test component from a rendered template. Starts a new R
    #' session. Requires the callr and covr packages.
    #' @param template `character` Rendered template, one element per line.
    #' @param id `character(1)` Component ID.
    initialize = function(template, id) {
      mst_initialize(template, id, self, private, super)
    },
    #' @description
    #' Print the test component with its code coverage.
    #' @return (`invisible`) self
    print = function() {
      mst_print(self, private)
    },
    #' @description
    #' Assign a variable in the test session.
    #' @param x `character(1)` Variable name.
    #' @param value Value to assign.
    #' @return (`invisible`) self
    assign = function(x, value) {
      mst_run(assign, list(x, value), self, private)
      invisible(self)
    },
    #' @description
    #' Get a variable from the test session.
    #' @param x `character(1)` Variable name.
    #' @return Value of the variable.
    get = function(x) {
      mst_run(get, list(x), self, private)
    },
    #' @description
    #' List the variables in the test session.
    #' @return `character` Variable names.
    ls = function() {
      mst_run(ls, list(), self, private)
    },
    #' @description
    #' Run the code in the test session and update the coverage.
    #' @return (`invisible`) self
    eval = function() {
      mst_eval(self, private)
    },
    #' @description
    #' Check that every line of the code has run at least once. Raises an
    #' error otherwise.
    #' @return (`invisible`) self
    check_coverage = function() {
      mst_check_coverage(self, private)
    },
    #' @description
    #' Close the test session. Called automatically when the object is
    #' garbage collected.
    #' @return (`invisible`) self
    close = function() {
      mst_close(self, private)
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
    #' @field percent_coverage `numeric(1)` Percentage of lines covered
    #' (0-100).
    percent_coverage = \() mean(private$.coverage$value > 0) * 100,
    #' @field line_coverage `data.frame` with columns `line` and `value`
    #' (number of times the line has run).
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

  init_coverage$line <- init_coverage$line - 1

  private$.coverage <- init_coverage[, c("line", "value")]
}

#' @noRd
mst_finalize <- function(self, private) {
  mst_close(self, private)
}

#' @noRd
mst_close <- function(self, private) {
  if (!mst_is_closed(private)) {
    private$.session$close()
  }
  invisible(self)
}

#' @noRd
mst_is_closed <- function(private) {
  is.null(private$.session) || private$.session$get_state() == "finished"
}

#' @noRd
mst_print <- function(self, private) {
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
    if (mst_is_closed(private)) {
      cli::cli_text("{.emph Session closed.}")
    }
  })

  invisible(self)
}

#' @noRd
mst_run <- function(func, args = list(), self, private) {
  if (mst_is_closed(private)) {
    cli::cli_abort(
      c(
        "The test session is closed.",
        "i" = "Create a new test component with {.fn get_test_component}."
      ),
      call = NULL
    )
  }
  # Drop the enclosing env so the session does not keep `self` alive
  environment(func) <- globalenv()
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
