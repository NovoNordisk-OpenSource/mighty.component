validate_r <- function(x, path) {
  ex_form <- "name <- function(...) { ... }"
  exprs <- tryCatch(
    parse(text = x, keep.source = TRUE),
    error = function(e) {
      cli::cli_abort(c(
        "x Failed to parse R code in {.path {path}}.",
        "i {e$message}",
        "i Expected one top-level function: {.code {ex_form}}."
      ))
    }
  )

  if (length(exprs) == 0L) {
    cli::cli_abort(c(
      "x No top-level function definition found in {.path {path}}.",
      "i Each file must contain exactly one function of the form {.code {ex_form}}."
    ))
  }
  if (length(exprs) > 1) {
    cli::cli_abort(c(
      "x Multiple top-level expressions found in {.path {path}}.",
      "i Each file must contain exactly one function definition: {.code {ex_form}}.",
      "i Remove extra statements or move helpers inside the function body."
    ))
  }
  funs <- extract_functions(exprs, path, ex_form)
  assert_only_1_return(body_expr = funs[[1]][[3]], fn_name = names(funs), path)
  assert_no_params(x, path)
}


# Extract function definitions from parsed expression
extract_functions <- function(exprs, path, ex_form) {
  stopifnot(length(exprs) == 1)
  call <- exprs[[1]]

  # Expect: <name> <-  function(...) { ... }
  is_named_function_definition <- rlang::is_call(call, c("<-", "=")) &&
    rlang::is_symbol(call[[2]]) &&
    rlang::is_call(call[[3]], "function")
  if (!is_named_function_definition) {
    # Catch actual code when not a function def
    cli::cli_abort(c(
      "x Expected a single top-level function definition in {.path {path}}.",
      "i Use {.code {ex_form}} (with {.code <-} or {.code =}).",
      "i Found top-level expression: {.code {rlang::expr_deparse(call, width = 60)}}"
    ))
  }

  name <- rlang::as_string(call[[2]])
  fun <- call[[3]]

  setNames(list(fun), name)
}


assert_only_1_return <- function(body_expr, fn_name, path) {
  count <- 0L

  walk <- function(x) {
    if (count > 1) {
      invisible(NULL)
    }

    # Skip nested function definitions altogether
    if (rlang::is_call(x, "function")) {
      return(invisible(NULL))
    }

    # If it's a call, check for return(...) and then recurse into its args
    if (rlang::is_call(x)) {
      if (rlang::is_call(x, "return")) {
        count <<- count + 1L
      }
      # Recurse into all arguments (skips the head automatically)
      args <- rlang::call_args(x)
      lapply(args, walk)
    } else if (is.pairlist(x) || is.list(x) || is.expression(x)) {
      # Also handle pairlists/lists/expression vectors
      lapply(x, walk)
    }

    invisible(NULL)
  }

  walk(body_expr)
  if (count > 1) {
    cli::cli_abort(c(
      "x Multiple {.code return()} statements found in function {.fn {fn_name}} in {.path {path}}.",
      "i Only one {.code return()} is allowed in the top-level function body.",
      "i Found {count} {.code return()} calls."
    ))
  }
}

assert_no_params <- function(code_string, path) {
  if (grepl("#'\\s*@param", code_string)) {
    cli::cli_abort(c(
      "x Parameters are not supported for custom R components.",
      "i Remove any roxygen2 {.code @param} tags and the corresponding function arguments from {.path {path}}."
    ))
  }
}
