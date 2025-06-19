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
      eval(expr = parse(text = private$.template), envir = envir)
    },
    #' @description
    #' Test component
    test = function() {
      TRUE # TODO: Testthat like functionality
    },
    #' @description
    #' Test coverage
    coverage = function() {
      0.2 # TODO: Calculate coverage based on tests
    }
  )
)
