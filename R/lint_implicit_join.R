#' Linter to detect dplyr joins without explicit 'by' argument
#'
#' This linter flags join operations (left_join, right_join, inner_join, etc.)
#' that don't explicitly specify the join keys via the 'by' argument.
#'
#' @param namespaces Character vector of package namespaces to check.
#'   Default includes "dplyr", "tidylog", and "dbplyr". Can be customized
#'   to include other packages that export join functions.
#' @return A linter function
#' @export
lint_implicit_join <- function(
  namespaces = c(
    "dplyr",
    "tidylog",
    "dbplyr"
  )
) {
  join_functions <- c(
    "left_join",
    "right_join",
    "inner_join",
    "full_join",
    "semi_join",
    "anti_join",
    "nest_join"
  )

  lintr::Linter(function(source_expression) {
    if (!lintr::is_lint_level(source_expression, "expression")) {
      return(list())
    }

    xml <- source_expression$xml_parsed_content

    xpath_query <- .build_join_xpath_query(join_functions, namespaces)
    join_calls <- xml2::xml_find_all(xml, xpath_query)

    lints <-
      Filter(
        Negate(is.null),
        join_calls |>
          lapply(
            .check_join_node,
            source_expression = source_expression,
            namespaces = namespaces
          )
      )

    lints
  })
}


#' Check a single join node for implicit join
#'
#' Examines a join function call node to determine if it lacks an explicit
#' 'by' argument. Returns a Lint object if the join is implicit, NULL otherwise.
#'
#' @param call_node XML node representing the join function call
#' @param source_expression Source expression object from lintr
#' @param namespaces Character vector of allowed package namespaces
#' @return lintr::Lint object if join is implicit, NULL otherwise
#' @noRd
.check_join_node <- function(call_node, source_expression, namespaces) {
  expr_node <- xml2::xml_parent(call_node)
  call_parent <- xml2::xml_parent(expr_node)

  call_namespace <- .get_call_namespace(expr_node)
  if (!is.null(call_namespace) && !call_namespace %in% namespaces) {
    return(NULL)
  }

  # Since this is a specific lint, hardcoding "by" is OK
  by_args <- xml2::xml_find_all(call_parent, ".//SYMBOL_SUB[text()='by']")

  if (length(by_args) > 0) {
    return(NULL)
  }
  line_num <- as.integer(xml2::xml_attr(call_node, "line1"))
  col_num <- as.integer(xml2::xml_attr(call_node, "col1"))
  line_text <- source_expression$lines[as.character(line_num)]

  call_node |>
    .extract_function_name() |>
    .create_implicit_join_lint(
      source_expression,
      location = list(
        line_num = line_num,
        col_num = col_num,
        line_text = line_text
      )
    )
}

#' Extract namespace from a function call node
#'
#' Determines the package namespace of a function call by examining the AST.
#' Returns NULL for bare function calls (no namespace), or the namespace string
#' for namespaced calls (e.g., "dplyr" from "dplyr::left_join").
#'
#' @param expr_node XML node representing the expression containing the call
#' @return Character string of namespace, or NULL if bare call or indeterminate
#' @noRd
.get_call_namespace <- function(expr_node) {
  # NS_GET is the AST node type that R's parser creates for the :: operator.
  # Only use NS_GET and not NS_GET_INT (:::) because accessing internal
  # functions is not allowed in a component and validated seprately
  ns_get <- xml2::xml_find_first(expr_node, "./NS_GET")

  if (is.na(xml2::xml_name(ns_get))) {
    return(NULL)
  }

  # Package name always exisets when NS_GET is present
  pkg_node <- xml2::xml_find_first(expr_node, "./SYMBOL_PACKAGE")
  xml2::xml_text(pkg_node)
}

#' Build XPath query for finding join function calls
#'
#' Constructs an XPath query that matches both bare function calls
#' (e.g., left_join) and namespaced calls (e.g., dplyr::left_join).
#'
#' @param join_functions Character vector of join function names
#' @param namespaces Character vector of package namespaces to check
#' @return Character string containing XPath query
#' @noRd
.build_join_xpath_query <- function(join_functions, namespaces) {
  # Match bare function names and all specified namespace::function combinations
  conditions <- c(
    sprintf("text()='%s'", join_functions),
    unlist(lapply(namespaces, function(ns) {
      sprintf("text()='%s::%s'", ns, join_functions)
    }))
  )
  sprintf("//SYMBOL_FUNCTION_CALL[%s]", paste(conditions, collapse = " or "))
}

#' Extract function name including namespace if present
#'
#' Navigates the AST to determine if a function call includes a namespace
#' prefix (e.g., dplyr::) and returns the complete function name.
#'
#' @param call_node XML node representing the function call
#' @return Character string like "left_join" or "dplyr::left_join"
#' @noRd
.extract_function_name <- function(call_node) {
  function_name <- xml2::xml_text(call_node)

  parent_expr <- xml2::xml_parent(call_node)
  ns_get <- xml2::xml_find_first(parent_expr, "./NS_GET")

  if (is.na(xml2::xml_name(ns_get))) {
    return(function_name)
  }

  # Package name always exisets when NS_GET is present
  pkg_node <- xml2::xml_find_first(parent_expr, "./SYMBOL_PACKAGE")
  paste0(xml2::xml_text(pkg_node), "::", function_name)
}

#' Create a Lint object for implicit join violation
#'
#' Constructs a lintr::Lint object with appropriate message for joins
#' that lack explicit 'by' arguments.
#'
#' @param function_name Name of the join function (e.g., "left_join")
#' @param source_expression Source expression object from lintr
#' @param location List containing line_num, col_num, and line_text
#' @return lintr::Lint object
#' @noRd
.create_implicit_join_lint <- function(
  function_name,
  source_expression,
  location
) {
  lintr::Lint(
    filename = source_expression$filename,
    line_number = location$line_num,
    column_number = location$col_num,
    type = "warning",
    message = sprintf(
      "`dplyr` join operation '%s' should explicitly specify join keys using the `by` argument.", #nolint
      function_name
    ),
    line = location$line_text
  )
}
