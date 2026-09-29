#' URL component repo
#' @description
#' A component repo served as raw files under a base URL, e.g.
#' `https://host/components`. Only public URLs are supported. To add headers,
#' pass an `httr2_request` created with [httr2::request()] instead of a
#' string.
#'
#' A component `name` is looked up by requesting, in order:
#' 1. `<url>/<name>.R`
#' 1. `<url>/<name>.mustache`
#' 1. `<url>/<name>/<name>.R`
#' 1. `<url>/<name>/<name>.mustache`
#'
#' If `name` has a `.R` or `.mustache` extension, only that file is requested,
#' flat and nested. The first successful response is used. Responses with
#' status 404 or 410 are treated as not found; other errors are raised.
#' Any query string in `url` is kept on all requests. Responses are not
#' cached.
#'
#' Unless the request already has a retry policy (see [httr2::req_retry()]),
#' transient errors (HTTP 5xx and network failures) are retried. The number of
#' attempts is set by the `max_tries` option. See [mighty.component-options].
#' @param url `character(1)` base URL starting with `http://` or `https://`,
#' or an `httr2_request` for the base URL.
#' @seealso [mighty_repo()]
#' @export
mighty_repo_url <- S7::new_class(
  name = "mighty_repo_url",
  parent = mighty_repo_class,
  properties = list(
    request = S7::new_S3_class("httr2_request")
  ),
  constructor = function(url) {
    props <- url_repo_properties(url = url)

    S7::new_object(
      S7::S7_object(),
      path = props$path,
      request = props$request
    )
  }
)

#' Validate `url`, build the request and derive `@path`
#' @noRd
url_repo_properties <- function(url, call = rlang::caller_env()) {
  rlang::check_installed("httr2", call = call)

  request <- if (inherits(url, "httr2_request")) {
    url
  } else if (is.character(url)) {
    check_string(x = url, call = call)

    if (!grepl(pattern = "^https?://", x = url)) {
      cli::cli_abort(
        "{.arg url} must start with {.val http://} or {.val https://},
        not {.val {url}}.",
        call = call
      )
    }

    httr2::request(base_url = url)
  } else {
    cli::cli_abort(
      "{.arg url} must be a single string or an {.cls httr2_request},
      not {.obj_type_friendly {url}}.",
      call = call
    )
  }

  # httr2 has no getter for policies, so check the internal fields
  has_retry <- !is.null(request$policies$retry_max_tries) ||
    !is.null(request$policies$retry_max_wait)

  if (!has_retry) {
    request <- httr2::req_retry(
      req = request,
      max_tries = get_max_tries(),
      retry_on_failure = TRUE,
      is_transient = \(resp) httr2::resp_status(resp = resp) >= 500
    )
  }

  path <- httr2::url_modify(url = request$url, query = NULL) |>
    sub(pattern = "/+$", replacement = "")

  list(path = path, request = request)
}

#' @noRd
S7::method(format, mighty_repo_url) <- function(x, ...) {
  paste0("url::", x@path)
}

#' Perform a request
#'
#' Returns the response, or `NULL` for status 404 and 410 when
#' `allow_missing` is `TRUE`. Other errors abort with `message`, a cli message
#' interpolated with `url` (the request URL) in scope.
#' @noRd
fetch_url <- function(
  request,
  message = "Failed to fetch {.url {url}}.",
  allow_missing = TRUE,
  call = rlang::caller_env()
) {
  resp <- tryCatch(
    expr = httr2::req_perform(req = request),
    error = identity
  )

  if (!inherits(resp, "error")) {
    return(resp)
  }

  if (allow_missing && inherits(resp, c("httr2_http_404", "httr2_http_410"))) {
    return(NULL)
  }

  cli::cli_abort(
    message = message,
    parent = resp,
    call = call,
    .envir = rlang::env(url = request$url)
  )
}

#' @noRd
S7::method(repo_find_component, mighty_repo_url) <- function(
  repos,
  component
) {
  files <- if (grepl(pattern = "\\.(R|mustache)$", x = component)) {
    component
  } else {
    paste0(component, c(".R", ".mustache"))
  }
  name <- tools::file_path_sans_ext(component)

  for (file in c(files, file.path(name, files))) {
    resp <- repos@request |>
      httr2::req_url_path_append(file) |>
      fetch_url()

    if (!is.null(resp)) {
      template <- strsplit(
        x = httr2::resp_body_string(resp = resp),
        split = "\r?\n"
      )[[1]]

      if (tools::file_ext(file) == "R") {
        check_custom_r(code = template)
      }

      return(
        mighty_component$new(template = template, id = basename(file))
      )
    }
  }
}
