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

url_html_response <- function(body, type = "text/html; charset=utf-8") {
  httr2::response(
    status_code = 200,
    headers = list(`Content-Type` = type),
    body = charToRaw(body)
  )
}

url_index_apache <- '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<html>
<head><title>Index of /components</title></head>
<body>
<h1>Index of /components</h1>
<table>
<tr>
<th><a href="?C=N;O=D">Name</a></th>
<th><a href="?C=M;O=A">Last modified</a></th>
<th><a href="?C=S;O=A">Size</a></th>
</tr>
<tr><td><a href="/">Parent Directory</a></td></tr>
<tr><td><a href="ady.mustache">ady.mustache</a></td></tr>
<tr><td><a href="my%20comp.R">my comp.R</a></td></tr>
<tr><td><a href="nested/">nested/</a></td></tr>
<tr><td><a href="test-ady.R">test-ady.R</a></td></tr>
<tr><td><a href="README.md">README.md</a></td></tr>
</table>
<address>Apache at <a href="https://example.com/">example.com</a></address>
</body>
</html>'

url_index_python <- '<!DOCTYPE HTML>
<html lang="en">
<head><meta charset="utf-8"><title>Directory listing for /</title></head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href="../">../</a></li>
<li><a href="./">./</a></li>
<li><a href="#top">top</a></li>
<li><a href="ady.R">ady.R</a></li>
<li><a href="nested/">nested/</a></li>
<li><a href="deep/other.R">deep/other.R</a></li>
<li><a href="https://example.com/abs.R">abs.R</a></li>
<li><a href="//cdn.example.com/cdn.R">cdn.R</a></li>
<li><a href="mailto:a@example.com">mail.R</a></li>
<li><a href="list.R?download=1">list.R</a></li>
<li><a>no-href.R</a></li>
</ul>
<hr>
</body>
</html>'

url_index_nested <- '<html><body><pre>
<a href="../">../</a>
<a href="nested.mustache">nested.mustache</a>
<a href="other.R">other.R</a>
</pre></body></html>'

#' Mock HTTP responses for URLs under `url_base`
#'
#' `routes` maps paths relative to `url_base` (query string removed) to an
#' `httr2_response` or an HTTP status code. The base URL itself (with or
#' without trailing `/`) is `"/"`. Unknown paths return 404.
#' Returns an environment recording the requested URLs in `urls`.
local_mock_url <- function(routes = list(), env = parent.frame()) {
  calls <- new.env(parent = emptyenv())
  calls$urls <- character(0)

  httr2::local_mocked_responses(
    mock = function(req) {
      calls$urls <- c(calls$urls, req$url)
      path <- sub(pattern = "\\?.*$", replacement = "", x = req$url) |>
        substring(first = nchar(url_base) + 2)
      if (!nzchar(path)) {
        path <- "/"
      }
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
