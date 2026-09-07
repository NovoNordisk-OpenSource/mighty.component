#' Find mighty code component
#' @export
find_component <- S7::new_generic(
  name = "find_component",
  dispatch_args = c("component", "repos")
)

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, S7::new_S3_class("NULL"))
) <- function(component, repos) {
  find_component(
    component = basename(component),
    repos = dirname(component)
  )
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, S7::class_list)
) <- function(component, repos) {
  for (i in seq_along(repos)) {
    res <- find_component(
      component = component,
      repos = repos[[i]]
    )

    if (!is.null(res)) {
      zephyr::msg_verbose(
        message = c(
          ">" = "Found {.val {component}} in {.val {format(repos[[i]])}}"
        )
      )
      return(res)
    }
  }
}

#' @noRd
S7::method(
  find_component,
  list(S7::class_character, S7::class_character)
) <- function(component, repos) {
  if (length(repos) > 1L) {
    return(
      find_component(
        component = component,
        repos = as.list(repos)
      )
    )
  }

  find_component(
    component = component,
    repos = mighty_repo(repos)
  )
}
