#' Validate that code has no implicit dplyr joins
#'
#' This function checks R code for join operations (left_join, right_join, etc.)
#' that don't explicitly specify the join keys via the 'by' argument.
#' Throws an error if any implicit joins are detected.
#'
#' @param code Character string of R code to validate
#' @param namespaces Character vector of package namespaces to check.
#'   Default includes "dplyr", "tidylog", and "dbplyr". Can be customized
#'   to include other packages that export join functions.
#' @return Invisible NULL on success, throws error if implicit joins found
#' @keywords internal
validate_implicit_join <- function(
  code,
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

  # Parse code to XML
  parsed <- parse(text = code, keep.source = TRUE)
  xml_string <- xmlparsedata::xml_parse_data(parsed)
  xml <- xml2::read_xml(xml_string)

  # Find all join function calls
  xpath_query <- .build_join_xpath_query(join_functions, namespaces)
  join_calls <- xml2::xml_find_all(xml, xpath_query)

  # Check each join call for violations
  violations <-
    Filter(
      Negate(is.null),
      join_calls |>
        lapply(
          .check_join_node_validate,
          namespaces = namespaces
        )
    )

  # Throw error if any violations found
  has_violations <- length(violations) > 0
  if (has_violations) {
    .abort_implicit_joins(violations)
  }

  invisible(NULL)
}


#' Abort with formatted implicit join error message
#'
#' Throws a cli error with formatted information about implicit join violations.
#'
#' @param violations List of violation objects, each containing line_number and function_name
#' @noRd
.abort_implicit_joins <- function(violations) {
  cli::cli_abort(
    c(
      "Implicit {.pkg dplyr} join(s) detected in rendered component:",
      "x" = "Join operations must explicitly specify the {.arg by} argument",
      rlang::set_names(
        vapply(
          violations,
          function(v) {
            sprintf("Line %d: %s", v$line_number, v$function_name)
          },
          character(1)
        ),
        rep("i", length(violations))
      )
    )
  )
}


#' Check a single join node for implicit join (validation version)
#'
#' Examines a join function call node to determine if it lacks an explicit
#' 'by' argument. Returns a list with violation details if implicit, NULL otherwise.
#'
#' @param call_node XML node representing the join function call
#' @param namespaces Character vector of allowed package namespaces
#' @return List with line_number and function_name if implicit, NULL otherwise
#' @noRd
.check_join_node_validate <- function(call_node, namespaces) {
  expr_node <- xml2::xml_parent(call_node)
  call_parent <- xml2::xml_parent(expr_node)

  call_namespace <- .get_call_namespace(expr_node)
  is_excluded_namespace <- !is.null(call_namespace) &&
    !call_namespace %in% namespaces
  if (is_excluded_namespace) {
    return(NULL)
  }

  by_args <- xml2::xml_find_all(call_parent, ".//SYMBOL_SUB[text()='by']")
  has_by_argument <- length(by_args) > 0
  if (has_by_argument) {
    return(NULL)
  }

  line_num <- as.integer(xml2::xml_attr(call_node, "line1"))
  function_name <- .extract_function_name(call_node)

  list(
    line_number = line_num,
    function_name = function_name
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
  is_bare_call <- is.na(xml2::xml_name(ns_get))
  if (is_bare_call) {
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
  is_bare_call <- is.na(xml2::xml_name(ns_get))
  if (is_bare_call) {
    return(function_name)
  }

  # Package name always exisets when NS_GET is present
  pkg_node <- xml2::xml_find_first(parent_expr, "./SYMBOL_PACKAGE")
  paste0(xml2::xml_text(pkg_node), "::", function_name)
}
