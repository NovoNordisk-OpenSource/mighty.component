#' URL component repo
#' @description
#' A component repo served as raw files under a base URL, e.g.
#' `https://example.com/components`. Only public URLs are supported.
#'
#' A component `name` is looked up by requesting, in order:
#' 1. `<url>/<name>.R`
#' 1. `<url>/<name>.mustache`
#' 1. `<url>/<name>/<name>.R`
#' 1. `<url>/<name>/<name>.mustache`
#'
#' Names containing `/` are not found.
#'
#' If `name` has a `.R` or `.mustache` extension, only that file is requested,
#' flat and nested. The first successful response is used. Responses with
#' status 404 or 410 are treated as not found; other errors are raised.
#' `name` is percent-encoded in the requested URLs. Any query string in `url`
#' is kept on all requests, but left out when the repo is printed. Responses are
#' not cached.
#'
#' Listing components (see [list_components()]) requires the server to
#' provide an HTML directory index, e.g. Apache or nginx autoindex, or
#' `python -m http.server`. The index at `<url>/` is parsed for relative links
#' to entries directly in the directory. Links to files (`<file>`) are
#' flat components. Links to directories (`<dir>/`) are listed through their
#' own index at `<url>/<dir>/`, and hold nested components. Absolute links,
#' links with a query or fragment, and `../` are ignored. Listing aborts if
#' an index is unavailable or not HTML.
#'
#' Transient errors (HTTP 5xx and network failures) are retried. The number of
#' attempts is set by the `max_tries` option. See [mighty.component-options].
#' The option is read on every request.
#'
#' Requires httr2 >= 1.2.2.
#' @param url `character(1)` base URL starting with `http://` or `https://`.
#' @seealso [mighty_repo()]
#' @export
mighty_repo_url <- S7::new_class(
  name = "mighty_repo_url",
  parent = mighty_repo_class,
  properties = list(
    url = S7::new_property(
      class = S7::class_character,
      validator = \(value) {
        validate_url(value)
      }
    ),
    request = S7::new_property(
      class = S7::new_S3_class("httr2_request"),
      getter = \(self) url_request(url = self@url)
    )
  ),
  constructor = function(url) {
    # httr2 < 1.2.2 encodes already encoded URL paths again
    rlang::check_installed("httr2", version = "1.2.2")
    check_string(x = url)

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

#' Request for `url` with retry policy
#' @noRd
url_request <- function(url) {
  httr2::request(base_url = url) |>
    httr2::req_retry(
      max_tries = get_max_tries(),
      retry_on_failure = TRUE,
      is_transient = \(resp) httr2::resp_status(resp = resp) >= 500
    )
}

#' Query and fragment are dropped, as they may hold credentials
#' @noRd
S7::method(format, mighty_repo_url) <- function(x, ...) {
  url <- httr2::url_modify(url = x@url, query = NULL, fragment = NULL)
  paste0("url::", url)
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

#' Percent-encode the segments of `<name>/<file>`
#'
#' Already encoded input is encoded again, as names are decoded.
#' @noRd
encode_path <- function(path) {
  strsplit(x = path, split = "/", fixed = TRUE)[[1]] |>
    vapply(
      FUN = utils::URLencode,
      FUN.VALUE = character(1),
      reserved = TRUE,
      repeated = TRUE,
      USE.NAMES = FALSE
    ) |>
    paste(collapse = "/")
}

#' Request with exactly one trailing `/` on the URL path
#' @noRd
dir_request <- function(request) {
  path <- httr2::url_parse(url = request$url)$path |>
    sub(pattern = "/+$", replacement = "")

  httr2::req_url_path(req = request, paste0(path, "/"))
}

#' Links to entries in an HTML directory index
#'
#' Returns the `href` of links to entries directly in the directory. Links
#' with a scheme, query or fragment, links starting with `/`, links with a `/`
#' other than one trailing, and `./` and `../` are dropped. Aborts if the
#' request fails or the response is not HTML.
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
    cli::cli_abort(
      message = message,
      call = call,
      .envir = rlang::env(url = request$url)
    )
  }

  # Not httr2::resp_has_body(), which is missing in httr2 < 1.0.0
  if (!length(resp$body)) {
    return(character(0))
  }

  # Raw input, as xml2 reads a string without markup as a file path
  links <- httr2::resp_body_string(resp = resp) |>
    charToRaw() |>
    xml2::read_html(encoding = "UTF-8") |>
    xml2::xml_find_all(xpath = "//a[@href]") |>
    xml2::xml_attr(attr = "href")

  keep <- grepl(pattern = "^[^/?#]+/?$", x = links) &
    !grepl(pattern = "^[A-Za-z][A-Za-z0-9+.-]*:", x = links) &
    !links %in% c("./", "../")

  links[keep]
}

#' Decode percent-encoded links
#' @noRd
decode_links <- function(links) {
  vapply(
    X = links,
    FUN = utils::URLdecode,
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )
}

#' @noRd
S7::method(component_ids, mighty_repo_url) <- function(repos) {
  request <- dir_request(request = repos@request)
  links <- index_links(request = request)
  is_dir <- endsWith(x = links, suffix = "/")

  nested <- lapply(
    X = links[is_dir],
    FUN = \(dir) {
      files <- request |>
        httr2::req_url_path_append(dir) |>
        index_links()

      file.path(
        decode_links(links = sub(pattern = "/$", replacement = "", x = dir)),
        decode_links(links = files[!endsWith(x = files, suffix = "/")])
      )
    }
  )

  ids_from_files(
    files = c(decode_links(links = links[!is_dir]), unlist(nested))
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

  files <- if (grepl(pattern = "\\.(R|mustache)$", x = component)) {
    component
  } else {
    paste0(component, c(".R", ".mustache"))
  }
  name <- tools::file_path_sans_ext(component)

  for (file in c(files, file.path(name, files))) {
    resp <- repos@request |>
      httr2::req_url_path_append(encode_path(path = file)) |>
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
