#' Mighty standard component
#'@export
mighty_standard <- R6::R6Class(
  classname = "mighty_standard", 
  public = list(
    #' @description
    #' Create standard component from template
    #' @param template moustache template
    initialize = function(template) {
      ms_initialize(template, self, private)
    },
    #' @description
    #' Render component
    #' @param ... params used to render the template
    render = function(...) {
      data <- rlang::list2(...)
      template <- whisker::whisker.render(template = private$.template, data = data)
      mighty_standard_rendered$new(template = template)
    },
    #' @description
    #' Create standard documentation
    document = function() {
      "documentation" # TODO: roxygen like documentation
    }
  ), 
  active = list(
    #' @field code code
    code = \() private$.template[-grepl("^#", private$.template)],
    #' @field template template
    template = \() private$.template,
    #' @field type type
    type = \() private$.type,
    #' @field depends depends
    depends = \() private$.depends,
    #' @field outputs outputs
    outputs = \() private$.outputs
  ),
  private = list(
    .version = as.character(packageVersion("mighty.standards")),
    .type = character(1),
    .depends = list(),
    .outputs = character(),
    .template = character()
  )
)

#' @noRd
ms_initialize <- function(template, self, private) {

  private$.template <- template

  invisible(self)
}
