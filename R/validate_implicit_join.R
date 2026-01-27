#' Validator for implicit join detection
#'
#' Detects dplyr join operations that lack an explicit `by` argument.
#' Implicit joins can lead to unexpected behavior when column names change,
#' so requiring explicit joins makes component code more robust.
#'
#' Checks join functions from the dplyr, tidylog, and dbplyr namespaces.
#'
#' @param xml XML serialization of the abstract syntax tree (AST) to validate
#'
#' @return Either `NULL` (no violations) or a `validation_violation` object
#'
#' @noRd
validate_implicit_join <- function(xml) {
  namespaces <- c("dplyr", "tidylog", "dbplyr")
  join_functions <- c(
    "left_join",
    "right_join",
    "inner_join",
    "full_join",
    "semi_join",
    "anti_join",
    "nest_join",
    "cross_join",
    "sql_join",
    "sql_semi_join"
  )

  xpath_query <- build_join_xpath_query(join_functions, namespaces)
  join_calls <- xml2::xml_find_all(xml, xpath_query)

  violations <-
    Filter(
      Negate(is.null),
      join_calls |>
        lapply(
          check_join_node_validate,
          namespaces = namespaces
        )
    )

  if (length(violations) == 0) {
    return(NULL)
  }

  new_validation_violation(
    message = "Implicit {.pkg dplyr} join(s) detected in rendered component:",
    details = "Join operations must explicitly specify the {.arg by} argument",
    violations = violations
  )
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
build_join_xpath_query <- function(join_functions, namespaces) {
  bare_fns <- sprintf("text()='%s'", join_functions)
  namespaced_fns <- namespaces |>
    lapply(function(ns) {
      sprintf("text()='%s::%s'", ns, join_functions)
    }) |>
    unlist()
  conditions <- c(bare_fns, namespaced_fns)
  sprintf("//SYMBOL_FUNCTION_CALL[%s]", paste(conditions, collapse = " or "))
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
check_join_node_validate <- function(call_node, namespaces) {
  expr_node <- xml2::xml_parent(call_node)
  call_parent <- xml2::xml_parent(expr_node)

  call_namespace <- get_call_namespace(expr_node)
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
  function_name <- extract_function_name(call_node)

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
get_call_namespace <- function(expr_node) {
  # NS_GET is the AST node type that R's parser creates for the :: operator.
  # Only use NS_GET and not NS_GET_INT (:::) because accessing internal
  # functions is not allowed in a component and validated separately
  ns_get <- xml2::xml_find_first(expr_node, "./NS_GET")
  is_bare_call <- is.na(xml2::xml_name(ns_get))
  if (is_bare_call) {
    return(NULL)
  }

  # pkg name assumed to always be present when NS_GET present
  pkg_node <- xml2::xml_find_first(expr_node, "./SYMBOL_PACKAGE")
  xml2::xml_text(pkg_node)
}


#' Extract function name including namespace if present
#'
#' Navigates the AST to determine if a function call includes a namespace
#' prefix (e.g., dplyr::) and returns the complete function name.
#'
#' @param call_node XML node representing the function call
#' @return Character string like "left_join" or "dplyr::left_join"
#' @noRd
extract_function_name <- function(call_node) {
  function_name <- xml2::xml_text(call_node)

  parent_expr <- xml2::xml_parent(call_node)
  ns_get <- xml2::xml_find_first(parent_expr, "./NS_GET")
  is_bare_call <- is.na(xml2::xml_name(ns_get))
  if (is_bare_call) {
    return(function_name)
  }

  # pkg name assumed to always exist when NS_GET present
  pkg_node <- xml2::xml_find_first(parent_expr, "./SYMBOL_PACKAGE")
  paste0(xml2::xml_text(pkg_node), "::", function_name)
}
