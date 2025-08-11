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
    #' @param id `character` ID of the component. Either name of standard or path to local.
    initialize = function(template, id) {
      ms_initialize(template, id, self, private)
    },
    #' @description
    #' Print method displaying the component information.
    #' @return (`invisible`) self
    print = function() {
      ms_print(self)
    },
    #' @description
    #' Render component with supplied values.
    #' Supports mustache templates and uses `whisker::whisker.render()`.
    #' @param ... Parameters used to render the template.
    #' Must be named, and depends on the template.
    #' @return Object of class [mighty_component_rendered]
    render = function(...) {
      params <- rlang::list2(...)
      ms_render(params, self)
    },
    #' @description
    #' Create standard documentation.
    #' **TODO: Implement in #18**
    document = function() {
      "documentation" # TODO: roxygen like documentation
    }
  ),
  active = list(
    #' @field id Component ID
    id = \() private$.id,
    #' @field title Title for the component.
    title = \() private$.title,
    #' @field description Description of the component.
    description = \() private$.description,
    #' @field code The code block of the component.
    code = \() private$.code,
    #' @field template The complete template.
    template = \() private$.template,
    #' @field type The type of the component. Can be one of `r paste0(valid_types(), collapse = ", ")`.
    type = \() private$.type,
    #' @field depends Data.frame listing all the components dependencies.
    depends = \() private$.depends,
    #' @field outputs List of the new columns created by the component.
    outputs = \() private$.outputs,
    #' @field params Data.frame listing parameters that need to be supplied when rendering the component.
    params = \() private$.params
  ),
  private = list(
    .id = character(1),
    .title = character(1),
    .description = character(1),
    .type = character(1),
    .params = data.frame(
      name = character(),
      description = character()
    ),
    .depends = character(),
    .outputs = character(),
    .code = character(),
    .template = character()
  )
)

#' @noRd
ms_initialize <- function(template, id, self, private) {
  # TODO: Input validation of template
  private$.id <- id
  private$.title <- get_tag(template, "title")
  private$.description <- get_tag(template, "description")
  private$.type <- get_tag(template, "type")
  private$.params <- get_tags(template, "param") |>
    tags_to_params()
  private$.depends <- get_tags(template, "depends") |>
    tags_to_depends()
  private$.outputs <- get_tags(template, "outputs")
  private$.code <- grep(
    pattern = "^#'",
    x = template,
    value = TRUE,
    invert = TRUE
  )
  private$.template <- template
  invisible(self)
}

#' @noRd
get_tags <- function(template, tag) {
  pattern <- paste0("^@", tag)
  tags <- grep(pattern = "^#'", x = template, value = TRUE)
  tags <- gsub(pattern = "^#' *", replacement = "", x = tags)
  tags <- split(
    x = tags,
    f = cumsum(substr(tags, 1, 1) == "@")
  ) |>
    vapply(FUN = paste, collapse = " ", FUN.VALUE = character(1)) |>
    unname()
  tags <- grep(pattern = pattern, x = tags, value = TRUE)
  tags <- gsub(pattern = pattern, replacement = "", x = tags)
  gsub(pattern = "^ +| +$", replacement = "", x = tags)
}

#' @noRd
get_tag <- function(template, tag) {
  tags <- get_tags(template, tag)

  if (length(tags) == 1L) {
    return(tags)
  }

  cli::cli_abort("Multiple or no matches found for tag: {tag}")
}

#' @noRd
tags_to_params <- function(tags) {
  i <- regexpr(pattern = " ", text = tags)

  params <- data.frame(
    name = substr(x = tags, start = 1, stop = i - 1),
    description = gsub(
      pattern = "^ +| +$",
      replacement = "",
      x = substr(x = tags, start = i + 1, stop = nchar(tags))
    )
  )

  mistakes <- params$description[!nchar(params$name)]
  if (length(mistakes)) {
    cli::cli_abort(
      c(
        "All {.code @params} tags must have both a name and description:",
        "x" = "Missing description for {.code {mistakes}}"
      )
    )

  params
  }

#' @noRd
tags_to_depends <- function(tags) {
  i <- regexpr(pattern = " +", text = tags)

  data.frame(
    domain = tags |>
      substr(start = 1, stop = i - 1) |>
      trimws(),
    column = tags |>
      substr(start = i + 1, stop = nchar(tags)) |>
      trimws()
  )
}

#' @noRd
ms_print <- function(self) {
  cli::cli({
    cli::cli_text("{.cls {class(self)}}")
    cli::cli_text("{.field {self$id}}: {self$description}")
    cli::cli_text("{.emph Type:} {self$type}")

    create_bullets(
      header = "Parameters:",
      bullets = paste(self$params$name, self$params$description, sep = ": ")
    )
    create_bullets(
      header = "Depends:",
      bullets = apply(X = self$depends, MARGIN = 1, FUN = paste, collapse = ".")
    )
    create_bullets(
      header = "Outputs:",
      bullets = self$outputs
    )
  })

  invisible(self)
}

#' @noRd
create_bullets <- function(header, bullets) {
  if (!length(bullets)) {
    return(invisible())
  }

  cli::cli({
    cli::cli_text("{.emph {header}}")
    for (i in seq_along(bullets)) {
      cli::cli_li("{bullets[[i]]}")
    }
  })
}

#' @noRd
ms_render <- function(params, self) {
  if (!rlang::is_named2(params)) {
    cli::cli_abort(
      c(
        "All parameters must be named",
        "i" = "Expected parameters: {.field {self$params$name}}"
      )
    )
  }

  if (
    any(!names(params) %in% self$params$name) ||
      any(!self$params$name %in% names(params))
  ) {
    missing_params <- setdiff(self$params$name, names(params))
    unknown_params <- setdiff(names(params), self$params$name)

    cli::cli_abort(
      c(
        "Parameter names not matching component requirements:",
        glue::glue(
          "{.code {{missing_params}}} not specified",
          .open = "{{",
          .close = "}}"
        ) |>
          rlang::set_names("x"),
        glue::glue(
          "{.code {{unknown_params}}} is unknown",
          .open = "{{",
          .close = "}}"
        ) |>
          rlang::set_names("x")
      )
    )
  }

  template <- whisker::whisker.render(
    template = self$template,
    data = params
  )
  mighty_component_rendered$new(
    template = strsplit(x = template, split = "\n")[[1]],
    id = self$id
  )
}
