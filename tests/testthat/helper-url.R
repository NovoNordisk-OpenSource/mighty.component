url_base <- "https://example.com/components"

url_fixture <- function(ext) {
  readLines(con = test_path("_components", paste0("ady_local.", ext)))
}

url_body_response <- function(body) {
  httr2::response(status_code = 200, body = charToRaw(body))
}

url_component_response <- function(ext) {
  url_body_response(body = paste(url_fixture(ext = ext), collapse = "\n"))
}

#' Mock HTTP responses for URLs under `url_base`
#'
#' `routes` maps paths relative to `url_base` (query string removed) to an
#' `httr2_response` or an HTTP status code. Unknown paths return 404.
#' Returns an environment recording the requested URLs in `urls`.
local_mock_url <- function(routes = list(), env = parent.frame()) {
  skip_if_not_installed("httr2")

  calls <- new.env(parent = emptyenv())
  calls$urls <- character(0)

  httr2::local_mocked_responses(
    mock = function(req) {
      calls$urls <- c(calls$urls, req$url)
      path <- sub(pattern = "\\?.*$", replacement = "", x = req$url) |>
        substring(first = nchar(url_base) + 2)
      route <- routes[[path]] %||% 404L

      if (is.numeric(route)) {
        return(httr2::response(status_code = route))
      }
      route
    },
    env = env
  )

  calls
}
