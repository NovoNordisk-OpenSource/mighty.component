#' Mighty standard component
#' @description
#' Class for a generic mighty standard component.
#' Contains all metadata and code, and has methods
#' to document and render the component.
#'
#' @details
#' How to specify a standard!!!
#' ```r
#' #' Title for my component
#' #' @description
#' #' A more in depth desciption of what is being done
#' #'
#' #' @param variable dynamic output if applicable
#' #' @param x some other input to the component
#' #' @type derivation
#' #' @depends .self {{ x }}
#' #' @outputs {{ variable }}
#' .self <- .self |>
#'   dplyr::mutate(
#'     {{ variable }} = 2 * {{ x }}
#'   )
#' ```
#' @seealso [get_standard()], [mighty_standard_rendered]
#' @export
mighty_standard <- R6::R6Class(
  classname = "mighty_standard",
  public = list(
    #' @description
    #' Create standard component from template.
    #' @param template `character` template code. See details for how to format.
    initialize = function(template) {
      ms_initialize(template, self, private)
    },
    #' @description
    #' Render component with supplied values.
    #' Supports mustache templates and uses `whisker::whisker.render()`.
    #' @param ... Parameters used to render the template.
    #' Must be named, and depends on the template.
    #' @return Object of class [mighty_standard_rendered]
    render = function(...) {
      # TODO: Check that ... are all named and contains all relevant parameters
      template <- whisker::whisker.render(
        template = self$template,
        data = rlang::list2(...)
      )
      mighty_standard_rendered$new(
        template = strsplit(x = template, split = "\n")[[1]]
      )
    },
    #' @description
    #' Create standard documentation.
    #' **TODO: Implement in #18**
    document = function() {
      "documentation" # TODO: roxygen like documentation
    }
  ),
  active = list(
    #' @field code The code block of the component.
    code = \() private$.code,
    #' @field template The complete template.
    template = \() private$.template,
    #' @field type The type of the component. Can be one of `r paste0(valid_types(), collapse = ", ")`.
    type = \() private$.type,
    #' @field depends List of the components dependencies.
    depends = \() private$.depends,
    #' @field outputs List of the new columns created by the component.
    outputs = \() private$.outputs
  ),
  private = list(
    .type = character(1),
    .depends = list(),
    .outputs = character(),
    .code = character(),
    .template = character()
  )
)

#' @noRd
ms_initialize <- function(template, self, private) {
  # TODO: Input valdiation of template
  private$.type <- get_tag(template, "type")
  private$.depends <- get_tags(template, "depends")
  private$.outputs <- get_tags(template, "outputs")
  private$.code <- grep(
    pattern = "^#",
    x = template,
    value = TRUE,
    invert = TRUE
  )
  private$.template <- template
  invisible(self)
}

#' @noRd
get_tags <- function(template, tag) {
  pattern <- paste0("^#' @", tag)
  tags <- grep(pattern = pattern, x = template, value = TRUE)
  gsub(pattern = pattern, replacement = "", x = tags)
}

#' @noRd
get_tag <- function(template, tag) {
  tags <- get_tags(template, tag)

  if (length(tags) == 1L) {
    return(tags)
  }

  cli::cli_abort("Multiple or no matches found for tag: {tag}")
}
