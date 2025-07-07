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
      template <- whisker::whisker.render(
        template = self$template,
        data = rlang::list2(...)
      )
      mighty_standard_rendered$new(
        template = strsplit(x = template, split = "\n")[[1]]
      )
    },
    #' @description
    #' Create standard documentation
    document = function() {
      "documentation" # TODO: roxygen like documentation
    }
  ),
  active = list(
    #' @field code code
    code = \() private$.code,
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
    .type = character(1),
    .depends = list(),
    .outputs = character(),
    .code = character(),
    .template = character()
  )
)

#' @noRd
ms_initialize <- function(template, self, private) {

  private$.type <- get_tag(template, "type")
  private$.depends <- get_tags(template, "depends") |> format_depends()
  private$.outputs <- get_tags(template, "outputs")
  private$.code <- grep(pattern = "^#", x = template, value = TRUE, invert = TRUE)
  private$.template <- template
  invisible(self)
}

#' @noRd
get_tags <- function(template, tag) {
  pattern <- paste0("^#' @", tag)
  tags <- grep(pattern = pattern, x = template, value = TRUE)
  gsub(pattern = pattern, replacement = "", x = tags) |> 
    trimws()
}

#' @noRd
get_tag <- function(template, tag) {
  tags <- get_tags(template, tag)

  if (length(tags) == 1L) {
    return(trimws(tags))
  }

  cli::cli_abort("Multiple or no matches found for tag: {tag}")
}

format_depends <- function(x){
# The .self nomenclature is used by mighty.standards to force the user
  # to be explicit about the provenance and make automating on top easier,
  # however, this is not use by mighty, so needs to be removed
 
  x <- gsub("\\.self\\s*", "", x)
  gsub(" ", ".", x)
  
}