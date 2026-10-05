#' Rendered component class
#' @description
#' R6 class for a rendered component, created by
#' [mighty_component]`$render()` or [get_rendered_component()].
#'
#' A rendered component can be:
#'
#' * Streamed into an R script with `$stream()`.
#' * Evaluated in an environment with `$eval()`.
#'
#' @seealso [get_rendered_component()], [mighty_component]
#' @export
mighty_component_rendered <- R6::R6Class(
  classname = "mighty_component_rendered",
  inherit = mighty_component,
  public = list(
    #' @description
    #' Create a rendered component from a rendered template. The code is
    #' validated. See the Validation section in [mighty_component].
    #' @param template `character` Rendered template, one element per line.
    #' @param id `character(1)` Component ID.
    initialize = function(template, id) {
      msr_initialize(template, id, self, private, super)
    },
    #' @description
    #' Print the rendered component, including its code.
    #' @return (`invisible`) self
    print = function() {
      msr_print(self, super)
    },
    #' @description
    #' Write the code to an R script. The code is appended if the file
    #' exists.
    #' @param path `character(1)` Path to the R script.
    #' @return (`invisible`) self
    stream = function(path) {
      msr_stream(path, self)
    },
    #' @description
    #' Evaluate the code.
    #' @param envir Environment to evaluate the code in. Defaults to the
    #' calling environment.
    #' @return Value of the last evaluated expression of the code.
    eval = function(envir = parent.frame()) {
      msr_eval(envir, self)
    }
  )
)

#' @noRd
msr_initialize <- function(template, id, self, private, super) {
  super$initialize(template, id)

  validate_component_code(self$code)

  private$.params <- data.frame(
    name = character(),
    description = character()
  )
}

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
  withr::defer(close(f))
  writeLines(text = self$code, con = f)
  invisible(self)
}

#' @noRd
msr_eval <- function(envir, self) {
  zephyr::msg_verbose(
    message = c(
      ">" = "Evaluating component {.field {self$title}}",
      "i" = "{.emph Code:}",
      "{.code {self$code}}"
    ),
    msg_fun = cli::cli_bullets
  )

  eval(
    expr = parse(text = self$code),
    envir = envir
  )
}
