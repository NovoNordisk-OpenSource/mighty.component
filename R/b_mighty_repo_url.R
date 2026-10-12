#' URL component repo
#' @description
#' A component repo served as raw files under a base URL. Requires httr2
#' (>= 1.2.2).
#'
#' See [mighty_repo()] for the component layout. `.mustache` is tried before
#' `.R`, and `<name>/` before files directly under `url`. The first found is
#' used. Status 404 and 410 count as not found; other errors are raised.
#' `name` is percent-encoded, and names containing `/` are not found.
#' Responses are not cached.
#'
#' Listing components (see [list_components()]) requires an HTML directory
#' index at `<url>/`, and at `<url>/<dir>/` for nested components, e.g. Apache
#' or nginx autoindex, or `python -m http.server`. Listing aborts if an index
#' is unavailable or not HTML.
#'
#' Transient errors (see [httr2::req_retry()]) and network failures are
#' retried. The number of attempts is set by the `max_tries` option, and
#' each attempt is limited by the `timeout` option (see
#' [mighty.component-options]).
#' @param url `character(1)` Base URL starting with `http://` or `https://`.
#' @returns A `mighty_repo_url` object.
#' @examplesIf rlang::is_installed("httr2", version = "1.2.2")
#' repo <- mighty_repo_url(
#'   url = paste0(
#'     "https://raw.githubusercontent.com/",
#'     "NovoNordisk-OpenSource/mighty.standards/main/components"
#'   )
#' )
#' format(repo)
#' @examplesIf interactive() && rlang::is_installed("httr2", version = "1.2.2")
#' find_component(component = "dummy", repos = repo)
#' @export
mighty_repo_url <- S7::new_class(
  name = "mighty_repo_url",
  parent = mighty_repo_class,
  properties = list(
    url = S7::new_property(
      class = S7::class_character,
      validator = \(value) validate_url(value)
    ),
    request = S7::new_property(
      class = S7::new_S3_class("httr2_request"),
      getter = \(self) url_request(url = self@url)
    )
  ),
  constructor = function(url) {
    # httr2 < 1.2.2 encodes already encoded URL paths again
    rlang::check_installed("httr2", version = "1.2.2")

    S7::new_object(S7::S7_object(), url = url)
  }
)

#' @noRd
validate_url <- function(value) {
  msg <- validate_string(value)
  if (!is.null(msg)) {
    return(msg)
  }

  if (!grepl(pattern = "^https?://", x = value)) {
    "must start with http:// or https://" # DevSkim: ignore DS137138
  }
}

#' @noRd
url_request <- function(url) {
  httr2::request(base_url = url) |>
    httr2::req_retry(
      max_tries = get_max_tries(),
      retry_on_failure = TRUE
    ) |>
    httr2::req_timeout(seconds = get_timeout())
}

#' @noRd
S7::method(format, mighty_repo_url) <- function(x, ...) {
  paste0("url::", x@url)
}

#' Returns the response, or `NULL` for status 404 and 410 when
#' `allow_missing` is `TRUE`. Other errors abort with `abort_url()`.
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

  abort_url(message = message, request = request, parent = resp, call = call)
}

#' @noRd
abort_url <- function(message, request, parent = NULL, call) {
  cli::cli_abort(
    message = message,
    parent = parent,
    call = call,
    .envir = rlang::env(url = request$url)
  )
}

#' @noRd
S7::method(repo_find_component, mighty_repo_url) <- function(
  repos,
  component
) {
  if (grepl(pattern = "/", x = component, fixed = TRUE)) {
    return(NULL)
  }

  # Already encoded input is encoded again, as names are decoded
  files <- utils::URLencode(component, reserved = TRUE, repeated = TRUE) |>
    component_candidates()

  for (path in files) {
    resp <- repos@request |>
      httr2::req_url_path_append(path) |>
      fetch_url()

    if (!is.null(resp)) {
      template <- strsplit(
        x = httr2::resp_body_string(resp = resp),
        split = "\r?\n"
      )[[1]]

      return(
        new_component(template = template, file = utils::URLdecode(path))
      )
    }
  }
}

#' @noRd
S7::method(component_ids, mighty_repo_url) <- function(repos) {
  request <- dir_request(request = repos@request)
  links <- index_links(request = request)

  nested <- lapply(
    X = links[endsWith(x = links, suffix = "/")],
    FUN = \(dir) {
      files <- request |>
        httr2::req_url_path_append(dir) |>
        index_links()

      paste0(dir, files)
    }
  )

  c(links, unlist(nested)) |>
    utils::URLdecode() |>
    ids_from_files()
}

#' @noRd
dir_request <- function(request) {
  path <- httr2::url_parse(url = request$url)$path |>
    sub(pattern = "/+$", replacement = "")

  httr2::req_url_path(req = request, paste0(path, "/"))
}

#' @noRd
index_links <- function(request, call = rlang::caller_env()) {
  message <- c(
    "Failed to list components at {.url {url}}.",
    i = "The server may not provide a directory index."
  )

  resp <- fetch_url(
    request = request,
    message = message,
    allow_missing = FALSE,
    call = call
  )

  if (!identical(httr2::resp_content_type(resp = resp), "text/html")) {
    abort_url(message = message, request = request, call = call)
  }

  if (!length(resp$body)) {
    return(character(0))
  }

  links <- httr2::resp_body_html(resp = resp, check_type = FALSE) |>
    xml2::xml_find_all(xpath = "//a[@href]") |>
    xml2::xml_attr(attr = "href")

  keep <- grepl(pattern = "^[^/?#]+/?$", x = links) &
    !grepl(pattern = "^[A-Za-z][A-Za-z0-9+.-]*:", x = links) &
    !links %in% c("./", "../")

  links[keep]
}
