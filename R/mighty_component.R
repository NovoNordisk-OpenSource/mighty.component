#' Component class
#' @description
#' R6 class for a component.
#'
#' A component is a code template. Its code takes an input data set and
#' returns a modified version with new or changed columns or rows. Components
#' are documented with roxygen-like tags.
#'
#' Use [get_component()] to create a component from a file or repo.
#'
#' @details
#' ```{r child = "man/rmd/template-reference.Rmd"}
#' ```
#'
#' ### Validation
#'
#' When a component is rendered, the code is parsed and must be valid R.
#' Joins from dplyr, tidylog and dbplyr without a `by` argument raise an
#' error. Column existence is not checked.
#'
#' ### Example
#'
#' This template creates a new column `output` as two times the existing
#' column `input`:
#'
#' ```r
#' #' @title Double a column
#' #' @description
#' #' Creates a new column as two times an existing column.
#' #'
#' #' @param domain `character` Name of the domain
#' #' @param output `character` Name of the new column
#' #' @param input `character` Name of the existing column
#' #' @type column
#' #' @origin Derived
#' #' @method Two times the input column
#' #' @depends {{{domain}}} {{{input}}}
#' #' @outputs {{{output}}}
#' #' @code
#' {{{domain}}} <- {{{domain}}} |>
#'   dplyr::mutate(
#'     {{{output}}} = 2 * {{{input}}}
#'   )
#' ```
#'
#' Rendered with `domain = "ADSL"`, `output = "A"` and `input = "B"`, the
#' code (`$code`) is:
#'
#' ```r
#' ADSL <- ADSL |>
#'   dplyr::mutate(
#'     A = 2 * B
#'   )
#' ```
#'
#' The tags are rendered too, e.g. `$depends` has domain `ADSL` and
#' column `B`.
#'
#' @seealso [get_component()], [mighty_component_rendered],
#' `vignette("mighty-component")`
#' @export
mighty_component <- R6::R6Class(
  classname = "mighty_component",
  public = list(
    #' @description
    #' Create a component from a template.
    #' @param template `character` Template, one element per line. See
    #' Details.
    #' @param id `character(1)` Component ID.
    initialize = function(template, id) {
      ms_initialize(template, id, self, private)
    },
    #' @description
    #' Print the component.
    #' @return (`invisible`) self
    print = function() {
      ms_print(self)
    },
    #' @description
    #' Render the component with [whisker::whisker.render()].
    #' @param ... Named parameters used to render the template. Supply one
    #' for each `@param` tag and no others.
    #'
    #' For `@type row` components, `domain` can be a subset marker:
    #' `".mighty_subset(<domain>, '<subset>')"`, where `<subset>` is an R
    #' expression in a string, e.g.
    #' `domain = ".mighty_subset(ADLB, 'PARAMCD == \"ALB\"')"`. The code then
    #' only processes the rows where `<subset>` is `TRUE`. Other rows are kept
    #' unchanged. The marker is not allowed for other
    #' parameters or types.
    #' @return Object of class [mighty_component_rendered]
    render = function(...) {
      params <- rlang::list2(...)
      ms_render(params, self)
    },
    #' @description
    #' Create documentation in markdown format.
    #' Requires the knitr package.
    #' @return (`invisible`) `character(1)` Markdown documentation.
    #' Also printed to the console.
    document = function() {
      ms_document(self)
    }
  ),
  active = list(
    #' @field id `character(1)` Component name without file extension.
    id = \() private$.id,
    #' @field title `character(1)` Title of the component.
    title = \() private$.title,
    #' @field description `character(1)` Description of the component.
    description = \() private$.description,
    #' @field code `character` Lines below `@code`.
    code = \() private$.code,
    #' @field template `character` Full template.
    template = \() private$.template,
    #' @field type `character(1)` Component type. One of
    #' `r paste0("\x60", valid_types(), "\x60", collapse = ", ")`.
    type = \() private$.type,
    #' @field origin `character(1)` CDISC origin. One of
    #' `r paste0("\x60", valid_origins(), "\x60", collapse = ", ")`.
    origin = \() private$.origin,
    #' @field method `character(1)` Method description for define.xml.
    method = \() private$.method,
    #' @field depends `data.frame` with columns `domain` and `column`.
    depends = \() private$.depends,
    #' @field outputs `character` Columns created by the component.
    outputs = \() private$.outputs,
    #' @field params `data.frame` with columns `name` and `description`.
    params = \() private$.params
  ),
  private = list(
    .id = character(1),
    .title = character(1),
    .description = character(1),
    .type = character(1),
    .origin = NULL,
    .method = NULL,
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
  private$.id <- id
  private$.title <- get_tag(template, "title")
  private$.description <- get_tag(template, "description")
  private$.type <- get_tag(template, "type") |> assert_type()
  private$.origin <- get_tag(template, "origin") |> assert_origin()
  private$.method <- get_tag(template, "method")
  private$.params <- get_tags(template, "param") |>
    tags_to_params()
  private$.depends <- get_tags(template, "depends") |>
    tags_to_depends()
  private$.outputs <- get_tags(template, "outputs")
  private$.code <- utils::tail(
    x = template,
    n = -grep(pattern = "^#' @code", template)[[1]]
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
    if (!nzchar(tags)) {
      cli::cli_abort("@{tag} tag must not be empty")
    }
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
  }

  params
}

#' @noRd
tags_to_depends <- function(tags) {
  i <- regexpr(pattern = " +", text = tags)

  depends <- data.frame(
    domain = tags |>
      substr(start = 1, stop = i - 1) |>
      trimws(),
    column = tags |>
      substr(start = i + 1, stop = nchar(tags)) |>
      trimws()
  )

  mistakes <- tags[!nchar(depends$domain) | !nchar(depends$column)]
  if (length(mistakes)) {
    cli::cli_abort(
      c(
        "All {.code @depends} tags must have both a domain and column:",
        "x" = "Not valid: {.code {mistakes}}"
      )
    )
  }

  depends
}

#' @noRd
ms_print <- function(self) {
  cli::cli({
    cli::cli_text("{.cls {class(self)}}")
    cli::cli_text("{.field {self$id}}: {self$title}")
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
    !all(names(params) %in% self$params$name) ||
      !all(self$params$name %in% names(params))
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

  other_markers <- Filter(
    Negate(is.null),
    lapply(params[setdiff(names(params), "domain")], parse_subset_marker)
  )

  if (length(other_markers)) {
    cli::cli_abort(
      "{.code .mighty_subset()} is only valid on {.field domain}, not {.field {names(other_markers)}}"
    )
  }

  marker <- parse_subset_marker(params$domain)

  template <- self$template

  if (!is.null(marker)) {
    if (self$type != "row") {
      cli::cli_abort(
        "{.code .mighty_subset()} is only supported for {.code @type row} components, not {.val {self$type}}"
      )
    }
    params$domain <- marker$domain
    template <- wrap_subset_marker(template, marker)
  }

  template <- whisker::whisker.render(
    template = template,
    data = params
  )
  template <- strsplit(x = template, split = "\n")[[1]]

  mighty_component_rendered$new(
    template = template,
    id = self$id
  )
}

#' @noRd
parse_subset_marker <- function(domain) {
  if (!is.character(domain) || length(domain) != 1) {
    return(NULL)
  }

  parsed <- tryCatch(str2lang(domain), error = function(e) NULL)

  if (is.null(parsed) || !is.call(parsed)) {
    return(NULL)
  }

  if (
    !identical(parsed[[1]], as.name(".mighty_subset")) || length(parsed) != 3
  ) {
    return(NULL)
  }

  list(domain = as.character(parsed[[2]]), subset = eval(parsed[[3]]))
}

#' @noRd
wrap_subset_marker <- function(template, marker) {
  code_start <- grep(pattern = "^#' @code", x = template)[[1]] + 1
  header <- utils::head(x = template, n = code_start - 1)
  code <- utils::tail(x = template, n = -(code_start - 1))

  token_pattern <- "(\\{\\{\\{?\\s*domain\\s*\\}\\}\\}?)"
  domain <- "{{{domain}}}"
  selected <- paste0(domain, "_selected")
  code <- gsub(pattern = token_pattern, replacement = "\\1_selected", x = code)

  prologue <- glue::glue(
    ".{domain}_remainder <- {domain}[!with({domain}, {subset}), ]",
    "{selected}   <- {domain}[with({domain}, {subset}), ]",
    domain = domain,
    subset = marker$subset,
    selected = selected,
    .sep = "\n"
  )

  epilogue <- glue::glue(
    "{domain} <- rbind(.{domain}_remainder, {selected})",
    domain = domain,
    selected = selected,
    .sep = "\n"
  )

  c(
    header,
    strsplit(x = prologue, split = "\n")[[1]],
    code,
    strsplit(x = epilogue, split = "\n")[[1]]
  )
}

#' @noRd
ms_document <- function(self) {
  rlang::check_installed("knitr")
  template <- system.file(
    "ms_document.mustache",
    package = "mighty.component"
  ) |>
    readLines()

  data <- mget(names(mighty_component$active), envir = self)
  data$params <- as.character(knitr::kable(data$params))
  data$depends <- as.character(knitr::kable(data$depends))

  docs <- whisker::whisker.render(
    template = template,
    data = data
  )

  zephyr::msg(message = docs, msg_fun = cli::cli_verbatim)

  invisible(docs)
}
