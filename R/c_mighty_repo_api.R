#' API component repo
#' @description
#' A component repo served by a JSON API under a base URL, e.g.
#' `https://host/api/components`. The API has two endpoints:
#'
#' * `GET <url>` lists the components as a JSON array of component names,
#'   e.g. `["ady", "adsl"]`. Names are listed as returned, without removing
#'   names starting with `test-`.
#' * `GET <url>/<name>` returns a component as a JSON object with the file
#'   name `id` and the file content `content` as strings, e.g.
#'   `{"id": "ady.mustache", "content": "..."}`. The extension of `id` must be
#'   `.R` or `.mustache`.
#'
#' Responses must have a JSON content type, e.g. `application/json`.
#'
#' When looking up a component, a `.R` or `.mustache` extension in `name` is
#' ignored, and `name` is percent-encoded in the requested URL. A response
#' with status 404 or 410 means the component is not found; other errors are
#' raised. Any query string in `url` is kept on all requests. Responses are
#' not cached.
#'
#' Requests are created, and transient errors retried, as in
#' [mighty_repo_url()].
#'
#' Requires httr2 >= 1.2.2 and jsonlite.
#' @inheritParams mighty_repo_url
#' @seealso [mighty_repo()], [mighty_repo_url()]
#' @export
mighty_repo_api <- S7::new_class(
  name = "mighty_repo_api",
  parent = mighty_repo_url,
  constructor = function(url) {
    rlang::check_installed(c("httr2", "jsonlite"))
    props <- url_repo_properties(url = url)

    S7::new_object(
      S7::S7_object(),
      path = props$path,
      request = props$request
    )
  }
)

#' @noRd
S7::method(format, mighty_repo_api) <- function(x, ...) {
  paste0("api::", x@path)
}

#' Parse a JSON response body
#'
#' Aborts with `message`, a cli message interpolated with `url` (the request
#' URL) in scope, if the body is not valid JSON or the response does not have
#' a JSON content type.
#' @noRd
json_body <- function(
  resp,
  request,
  message,
  simplify = FALSE,
  call = rlang::caller_env()
) {
  tryCatch(
    expr = httr2::resp_body_json(resp = resp, simplifyVector = simplify),
    error = \(e) {
      cli::cli_abort(
        message = message,
        parent = e,
        call = call,
        .envir = rlang::env(url = request$url)
      )
    }
  )
}

#' @noRd
S7::method(component_ids, mighty_repo_api) <- function(repos) {
  message <- c(
    "Invalid component list from {.url {url}}.",
    i = "Expected a JSON array of component names."
  )

  resp <- fetch_url(
    request = repos@request,
    message = "Failed to list components at {.url {url}}.",
    allow_missing = FALSE
  )

  ids <- json_body(
    resp = resp,
    request = repos@request,
    message = message,
    simplify = TRUE
  )

  # An empty JSON array is parsed as an empty unnamed list
  if (is.list(ids) && !length(ids) && is.null(names(ids))) {
    return(character(0))
  }

  valid <- is.character(ids) &&
    is.null(dim(ids)) &&
    !anyNA(ids) &&
    all(nzchar(ids))

  if (!valid) {
    cli::cli_abort(
      message = message,
      .envir = rlang::env(url = repos@request$url)
    )
  }

  unique(ids)
}

#' @noRd
S7::method(repo_find_component, mighty_repo_api) <- function(
  repos,
  component
) {
  request <- httr2::req_url_path_append(
    req = repos@request,
    sub(pattern = "\\.(R|mustache)$", replacement = "", x = component) |>
      encode_path()
  )

  resp <- fetch_url(request = request)

  if (is.null(resp)) {
    return(NULL)
  }

  message <- c(
    "Invalid component response from {.url {url}}.",
    i = "Expected a JSON object with string {.field id} and
    {.field content}, and {.field id} ending in {.file .R} or
    {.file .mustache}."
  )

  body <- json_body(resp = resp, request = request, message = message)

  valid <- is.list(body) &&
    !is.null(names(body)) &&
    rlang::is_string(body[["id"]]) &&
    rlang::is_string(body[["content"]]) &&
    tools::file_ext(body[["id"]]) %in% c("R", "mustache")

  if (!valid) {
    cli::cli_abort(
      message = message,
      .envir = rlang::env(url = request$url)
    )
  }

  template <- strsplit(x = body[["content"]], split = "\r?\n")[[1]]

  if (tools::file_ext(body[["id"]]) == "R") {
    check_custom_r(code = template)
  }

  mighty_component$new(template = template, id = body[["id"]])
}
