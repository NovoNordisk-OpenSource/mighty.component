#' @noRd
ms_tool <- function(method, self) {
  rlang::check_installed("ellmer")

  args <- self$params$description |>
    lapply(ellmer::type_string, required = TRUE) |>
    rlang::set_names(self$params$name)

  tool_fn <- switch(
    EXPR = method,
    params = tool_params(self),
    render = tool_render(self),
    eval = tool_eval(self)
  )

  ellmer::tool(
    fun = tool_fn,
    description = self$description,
    arguments = args,
    name = gsub(
      # For custom component use only filename due to ellmer restrictions
      pattern = "\\..*$",
      replacement = "",
      x = basename(self$id)
    ),
    annotations = ellmer::tool_annotations(
      title = self$title,
      dynamic_output = any(grepl(pattern = "\\{\\{", x = self$outputs)),
      outputs = self$outputs,
      code = self$code
    )
  )
}

#' @noRd
tool_args <- function(standard) {
  args <- paste(standard$params$name, "=", collapse = ",")
  paste0("rlang::pairlist2(", args, ")") |>
    rlang::parse_expr() |>
    rlang::eval_tidy()
}

#' @noRd
tool_params <- function(standard) {
  args <- tool_args(standard)

  rlang::new_function(
    args = args,
    body = quote({
      env <- rlang::current_env()
      params <- lapply(X = names(args), FUN = get, envir = env)
      names(params) <- names(args)

      list(
        id = standard$id,
        params = params
      )
    })
  )
}

#' @noRd
tool_render <- function(standard) {
  rlang::new_function(
    args = tool_args(standard),
    body = quote({
      args <- rlang::fn_fmls_syms()
      x <- do.call(what = standard$render, args = args)
      x$template
    })
  )
}

#' @noRd
tool_eval <- function(standard) {
  rlang::new_function(
    args = tool_args(standard),
    body = quote({
      args <- rlang::fn_fmls_syms()
      rendered <- do.call(what = standard$render, args = args)
      rendered$eval()
    })
  )
}
