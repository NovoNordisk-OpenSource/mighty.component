
#' Retrieve mighty standard component
#' @export
get_standard <- function(standard) {
  mighty_standard$new(standard)
}

#' Mighty standard component
#'@export
mighty_standard <- R6::R6Class(
  classname = "mighty_standard", 
  public = list(
    initialize = function(standard) {
      ms_initialize(standard, self, private)
    },
    render = function(...) {
      data <- rlang::list2(...)
      whisker::whisker.render(template = private$.template, data = data)
    },
    eval = function(..., envir = parent.frame()) {
      code <- self$render(...)
      eval(expr = parse(text = code), envir = envir)
    },
    test = function() {

    },
    coverage = function() {

    }
  ), 
  active = list(
    type = \() private$.type,
    depends = \() private$.depends,
    outputs = \() private$.outputs
  ),
  private = list(
    .version = as.character(packageVersion("mighty.standards")),
    .component = character(1),
    .type = character(1),
    .depends = list(),
    .outputs = character(),
    .template = character()
  )
)

#' @noRd
ms_initialize <- function(standard, self, private) {
  private$.component <- standard

  private$.template <- file.path("inst", "components", standard) |> # TODO: Use system.file() and add check
    paste0(".mustache") |> 
    readLines() 

  invisible(standard)
}


x <- get_standard("astdt")

x

.self <- pharmaverseadam::adcm |> 
  dplyr::select(CMSTDTC) |> 
  print()

x$render(dtc = "CMSTDTC") |> 
  cat()

.self
x

x$eval(dtc = "CMSTDTC")


.self

x$outputs

x$render(dtc = "AENDTC") |> 
  cat()

f <- c(
  "dummy <- function(.self) {",
  x$render(dtc = "CMSTDTC"),
  "return(.self)",
  "}"
) |> 
  paste(collapse = "\n")

t <- "dummy(dplyr::select(pharmaverseadam::adcm, CMSTDTC))"

covr::code_coverage(f, t)


