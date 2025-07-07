#' Mighty standard component
#' @description
#' Class for a generic mighty standard component.
#'
#' In the mighty framework, a "component" is a code template that processes
#' input data and returns a modified version with new columns or rows.
#' Standard components share a common structure and roxygen-like documentation pattern,
#' facilitating their use inside mighty.
#'
#' @details
#' Templates are `character` vectors of R code that are interpreted.
#' Dynamic use of variables etc. are supported using the [mustache](https://mustache.github.io)
#' framework. Dynamic parameters are specified using `{{ variable_name }}`.
#'
#' ### Documentation
#'
#' A template is required to be documented with the following tags similar to when
#' documenting functions using roxygen2:
#'
#' | Tag            | Description                                          | Example                  |
#' |----------------|------------------------------------------------------|--------------------------|
#' | `@title`       | Title of the component                               | `@title My component`    |
#' | `@description` | Description of the component                         | `@description text text` |
#' | `@param`       | Specifies input used to render the component         | `@param variable new var`|
#' | `@type`        | Specifies type: `r mighty.standards:::valid_types()` | `@type derivation`       |
#' | `@depends`     | Required input variable (repeat if several)          | `@depends .self USUBJID` |
#' | `@outputs`     | Variables created (repeat if several)                | `@outputs NEWVAR`        |
#'
#' ### Conventions
#'
#' A template for a standard components follow these conventions:
#'
#' 1. The input data set is always called `.self`.
#' 1. Additional parameters used to render the template into R code are documented with the `@param` tag.
#' 1. The template ends with creating a modified version of `.self`.
#' 1. Template documented with the roxygen-like tags above
#'
#' ### Example
#'
#' Below is an example of a mighty component template that
#' creates a new dynamic variable `variable` as twice the value
#' of the dynamic input `x`, that should already by in the input data set `.self`.
#'
#' ```r
#' #' Title for my component
#' #' @description
#' #' A more in depth description of what is being done
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
#'
#' When rendered with parameters `variable = "A"` and `x = "B"`
#' the rendered code used in mighty becomes:
#'
#' ```r
#' .self <- .self |>
#'   dplyr::mutate(
#'     A = 2 * B
#'   )
#' ```
#'
#' @seealso [get_standard()], [mighty_component_rendered]
#' @export
mighty_component <- R6::R6Class(
  classname = "mighty_component",
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
    #' @return Object of class [mighty_component_rendered]
    render = function(...) {
      # TODO: Check that ... are all named and contains all relevant parameters
      template <- whisker::whisker.render(
        template = self$template,
        data = rlang::list2(...)
      )
      mighty_component_rendered$new(
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
  # TODO: Input validation of template
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
