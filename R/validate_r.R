validate_r <- function(x, path) {
  exprs <- tryCatch(
    parse(text = x, keep.source = TRUE),
    error = function(e) {
      cli::cli_abort(
        "Failed to parse code from {path} with the following error message : {e$message}"
      )
    }
  )
  funs <- extract_functions(exprs)
  if (length(funs) == 0L) {
    cli::cli_abort("No function definitions found in {path}.")
  }
  if (length(funs) > 1) {
    cli::cli_abort(
      "Only one function definition per file allowed. There are {length(funs)} functions defined in {path}: {names(funs)}."
    )
  }
 
  assert_only_1_return(body_expr = funs[[1]][[3]], fn_name = names(funs), path)
}


# Extract function definitions from parsed expressions: returns a named list of function ASTs.
extract_functions <- function(exprs) {
  funs <- list()
  for (expr in exprs) {
    if (!is.call(expr)) {
      next
    }
    is_assignment_operator <- rlang::is_call(expr, c("<-", "="))
    is_function_definition_call <- rlang::is_call(expr, "function")
    if (is_assignment_operator) {
      lhs <- expr[[2]]
      rhs <- expr[[3]]
      if (is.symbol(lhs) && rlang::is_call(rhs, "function")) {
        funs[[as.character(lhs)]] <- rhs
        next
      }
    }

    # Also support anonymous top-level: function(...) { ... }
    if (is_function_definition_call) {
      funs[["<anonymous>"]] <- expr
    }
  }
  funs
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
    cli::cli_abort(
      "Multiple {.code return()} statments found in function `{fn_name}` defined in file {path}. Only one {.code return()} is allowed in the top-level function"
    )
  }
}
