skip_if_not_installed("httr2", minimum_version = "1.2.2")

test_that("mighty_repo_url creates repo from string URL", {
  repo <- mighty_repo_url(url = paste0(url_base, "/?token=abc"))

  expect_true(S7::S7_inherits(repo, mighty_repo_url))
  expect_true(S7::S7_inherits(repo, mighty_repo_class))
  expect_s3_class(repo@request, "httr2_request")
  expect_equal(repo@path, url_base)
  expect_equal(repo@request$url, paste0(url_base, "/?token=abc"))
})

test_that("mighty_repo_url accepts an httr2_request", {
  req <- httr2::request(base_url = url_base) |>
    httr2::req_headers(`X-Token` = "abc")

  repo <- mighty_repo_url(url = req)

  expect_equal(repo@path, url_base)
  expect_equal(repo@request$headers$`X-Token`, "abc")
})

test_that("mighty_repo_url errors on invalid url", {
  mighty_repo_url(url = 1) |>
    expect_error("must be a single string or an <httr2_request>")

  mighty_repo_url(url = c("https://a.org", "https://b.org")) |>
    expect_error("must be a single string")

  mighty_repo_url(url = "") |>
    expect_error("must be a single string")

  mighty_repo_url(url = "ftp://example.com/components") |>
    expect_error("must start with")
})

test_that("mighty_repo_url adds retry policy from max_tries option", {
  repo <- mighty_repo_url(url = url_base)
  policies <- repo@request$policies

  expect_equal(policies$retry_max_tries, 3L)
  expect_true(policies$retry_on_failure)
  expect_true(policies$retry_is_transient(httr2::response(status_code = 503)))
  expect_false(policies$retry_is_transient(httr2::response(status_code = 404)))

  withr::local_options(mighty.component.max_tries = 5L)

  mighty_repo_url(url = url_base)@request$policies$retry_max_tries |>
    expect_equal(5L)
})

test_that("mighty_repo_url keeps user retry policy", {
  req <- httr2::request(base_url = url_base) |>
    httr2::req_retry(max_tries = 7)

  mighty_repo_url(url = req)@request$policies$retry_max_tries |>
    expect_equal(7)

  req <- httr2::request(base_url = url_base) |>
    httr2::req_retry(max_seconds = 10)
  policies <- mighty_repo_url(url = req)@request$policies

  expect_null(policies$retry_max_tries)
  expect_equal(policies$retry_max_wait, 10)
})

test_that("mighty_repo_url errors on invalid max_tries option", {
  withr::local_options(mighty.component.max_tries = 0)

  mighty_repo_url(url = url_base) |>
    expect_error("max_tries")
})

test_that("format returns url spec", {
  mighty_repo_url(url = paste0(url_base, "/")) |>
    format() |>
    expect_equal(paste0("url::", url_base))
})

test_that("mighty_repo creates url repo from url:: prefix", {
  repo <- mighty_repo(spec = paste0("url::", url_base))

  expect_true(S7::S7_inherits(repo, mighty_repo_url))
  expect_equal(repo@path, url_base)
})

test_that("find_component finds flat .mustache component", {
  calls <- local_mock_url(
    routes = list(ady.mustache = url_component_response(ext = "mustache"))
  )

  component <- find_component(
    component = "ady",
    repos = mighty_repo_url(url = url_base)
  )

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "ady.mustache")
  expect_equal(component$template, url_fixture(ext = "mustache"))
  expect_equal(
    calls$urls,
    paste0(url_base, c("/ady.R", "/ady.mustache"))
  )
})

test_that("find_component finds flat .R component", {
  calls <- local_mock_url(routes = list(ady.R = url_component_response("R")))

  component <- find_component(
    component = "ady",
    repos = mighty_repo_url(url = url_base)
  )

  expect_equal(component$id, "ady.R")
  expect_equal(component$template, url_fixture(ext = "R"))
  expect_equal(calls$urls, paste0(url_base, "/ady.R"))
})

test_that("find_component finds nested component", {
  calls <- local_mock_url(
    routes = list(`ady/ady.mustache` = url_component_response("mustache"))
  )

  component <- find_component(
    component = "ady",
    repos = mighty_repo_url(url = url_base)
  )

  expect_equal(component$id, "ady.mustache")
  expect_equal(
    calls$urls,
    paste0(
      url_base,
      c("/ady.R", "/ady.mustache", "/ady/ady.R", "/ady/ady.mustache")
    )
  )
})

test_that("find_component with extension only requests that file", {
  calls <- local_mock_url(
    routes = list(`ady/ady.mustache` = url_component_response("mustache"))
  )

  component <- find_component(
    component = "ady.mustache",
    repos = mighty_repo_url(url = url_base)
  )

  expect_equal(component$id, "ady.mustache")
  expect_equal(
    calls$urls,
    paste0(url_base, c("/ady.mustache", "/ady/ady.mustache"))
  )
})

test_that("find_component falls through 404 and 410", {
  calls <- local_mock_url(
    routes = list(
      ady.R = 410L,
      ady.mustache = 404L,
      `ady/ady.R` = url_component_response("R")
    )
  )

  component <- find_component(
    component = "ady",
    repos = mighty_repo_url(url = url_base)
  )

  expect_equal(component$id, "ady.R")
  expect_length(calls$urls, 3)
})

test_that("find_component returns NULL when all candidates are missing", {
  calls <- local_mock_url()

  find_component(component = "ady", repos = mighty_repo_url(url = url_base)) |>
    expect_null()

  expect_length(calls$urls, 4)
})

test_that("find_component errors on other HTTP errors", {
  for (status in c(403L, 500L)) {
    calls <- local_mock_url(routes = list(ady.R = status))

    err <- find_component(
      component = "ady",
      repos = mighty_repo_url(url = url_base)
    ) |>
      expect_error("Failed to fetch.*/components/ady\\.R")

    expect_s3_class(err$parent, paste0("httr2_http_", status))
    expect_length(calls$urls, 1)
  }
})

test_that("find_component keeps query string on candidate URLs", {
  calls <- local_mock_url(
    routes = list(ady.mustache = url_component_response("mustache"))
  )

  find_component(
    component = "ady",
    repos = mighty_repo_url(url = paste0(url_base, "?token=abc"))
  ) |>
    expect_s3_class("mighty_component")

  expect_equal(
    calls$urls,
    paste0(url_base, c("/ady.R", "/ady.mustache"), "?token=abc")
  )
})

test_that("find_component percent-encodes component names", {
  calls <- local_mock_url()

  find_component(
    component = "my comp",
    repos = mighty_repo_url(url = url_base)
  ) |>
    expect_null()

  expect_equal(
    calls$urls,
    paste0(
      url_base,
      c(
        "/my%20comp.R",
        "/my%20comp.mustache",
        "/my%20comp/my%20comp.R",
        "/my%20comp/my%20comp.mustache"
      )
    )
  )

  calls <- local_mock_url()

  find_component(
    component = "100%.R",
    repos = mighty_repo_url(url = paste0(url_base, "?t=1"))
  ) |>
    expect_null()

  expect_equal(
    calls$urls,
    paste0(url_base, c("/100%25.R", "/100%25/100%25.R"), "?t=1")
  )
})

test_that("find_component splits CRLF line endings", {
  body <- paste(url_fixture(ext = "mustache"), collapse = "\r\n")
  local_mock_url(routes = list(ady.mustache = url_body_response(body = body)))

  component <- find_component(
    component = "ady",
    repos = mighty_repo_url(url = url_base)
  )

  expect_equal(component$template, url_fixture(ext = "mustache"))
})

test_that("find_component checks custom .R components", {
  local_mock_url(routes = list(ady.R = url_body_response(body = "x <- {{a}}")))

  find_component(component = "ady", repos = mighty_repo_url(url = url_base)) |>
    expect_error("mustache patterns")
})

test_that("mighty_repos falls through url repo to local repo", {
  calls <- local_mock_url()
  path <- local_component_repo(files = "ady.R")

  component <- find_component(
    component = "ady",
    repos = list(mighty_repo_url(url = url_base), path)
  )

  expect_equal(component$id, "ady.R")
  expect_length(calls$urls, 4)
})

test_that("find_component accepts url:: spec", {
  local_mock_url(routes = list(ady.R = url_component_response("R")))

  component <- find_component(
    component = "ady",
    repos = paste0("url::", url_base)
  )

  expect_equal(component$id, "ady.R")
})

test_that("fetch_url returns response or NULL when missing", {
  local_mock_url(routes = list(a = url_body_response(body = "x"), b = 410L))
  req <- httr2::request(base_url = url_base)

  req |>
    httr2::req_url_path_append("a") |>
    fetch_url() |>
    httr2::resp_body_string() |>
    expect_equal("x")

  req |>
    httr2::req_url_path_append("b") |>
    fetch_url() |>
    expect_null()
})

test_that("fetch_url errors on missing with allow_missing = FALSE", {
  local_mock_url()

  err <- httr2::request(base_url = url_base) |>
    fetch_url(message = "Nope {.url {url}}.", allow_missing = FALSE) |>
    expect_error("Nope.*/components")

  expect_s3_class(err$parent, "httr2_http_404")
})

test_that("component_ids lists Apache-style directory index", {
  calls <- local_mock_url(
    routes = list(
      `/` = url_html_response(body = url_index_apache),
      `nested/` = url_html_response(body = url_index_nested)
    )
  )

  component_ids(repos = mighty_repo_url(url = url_base)) |>
    expect_equal(c("ady", "my comp", "nested"))

  expect_equal(calls$urls, paste0(url_base, c("/", "/nested/")))
})

test_that("component_ids lists python http.server-style directory index", {
  calls <- local_mock_url(
    routes = list(
      `/` = url_html_response(body = url_index_python),
      `nested/` = url_html_response(body = url_index_nested)
    )
  )

  component_ids(repos = mighty_repo_url(url = url_base)) |>
    expect_equal(c("ady", "nested"))

  expect_equal(calls$urls, paste0(url_base, c("/", "/nested/")))
})

test_that("component_ids requests one trailing slash and keeps query", {
  index <- '<a href="ady.R">ady.R</a><a href="my%20dir/">my dir/</a>'
  calls <- local_mock_url(
    routes = list(
      `/` = url_html_response(body = index),
      `my%20dir/` = url_html_response(body = "<p>empty</p>")
    )
  )

  component_ids(repos = mighty_repo_url(url = paste0(url_base, "//?t=1"))) |>
    expect_equal("ady")

  expect_equal(
    calls$urls,
    paste0(url_base, c("/?t=1", "/my%20dir/?t=1"))
  )
})

test_that("component_ids returns empty for index without components", {
  local_mock_url(routes = list(`/` = url_html_response(body = "<p>none</p>")))

  component_ids(repos = mighty_repo_url(url = url_base)) |>
    expect_equal(character(0))

  local_mock_url(routes = list(`/` = url_html_response(body = "")))

  component_ids(repos = mighty_repo_url(url = url_base)) |>
    expect_equal(character(0))
})

test_that("component_ids errors when base index is unavailable", {
  for (status in c(404L, 403L)) {
    local_mock_url(routes = list(`/` = status))

    err <- component_ids(repos = mighty_repo_url(url = url_base)) |>
      expect_error("Failed to list components at.*/components/")

    expect_match(conditionMessage(err), "may not provide a directory index")
    expect_s3_class(err$parent, paste0("httr2_http_", status))
  }
})

test_that("component_ids errors on non-HTML index", {
  local_mock_url(
    routes = list(`/` = url_html_response(body = "[]", type = "text/plain"))
  )

  err <- component_ids(repos = mighty_repo_url(url = url_base)) |>
    expect_error("Failed to list components at.*/components/")

  expect_match(conditionMessage(err), "may not provide a directory index")
  expect_null(err$parent)

  local_mock_url(routes = list(`/` = url_body_response(body = "<p></p>")))

  component_ids(repos = mighty_repo_url(url = url_base)) |>
    expect_error("Failed to list components at")
})

test_that("component_ids errors when subdirectory index is unavailable", {
  local_mock_url(
    routes = list(`/` = url_html_response(body = url_index_apache))
  )

  err <- component_ids(repos = mighty_repo_url(url = url_base)) |>
    expect_error("Failed to list components at.*/components/nested/")

  expect_s3_class(err$parent, "httr2_http_404")
})

test_that("list_components lists url repo components", {
  index <- '<a href="ady.mustache">ady</a><a href="nested/">nested/</a>'
  local_mock_url(
    routes = list(
      `/` = url_html_response(body = index),
      `nested/` = url_html_response(body = url_index_nested),
      ady.mustache = url_component_response(ext = "mustache"),
      `nested/nested.mustache` = url_component_response(ext = "mustache")
    )
  )
  repo <- mighty_repo_url(url = url_base)

  list_components(repos = repo) |>
    expect_equal(c("ady", "nested"))

  components <- list_components(repos = repo, as = "list")

  expect_length(components, 2)
  expect_equal(components[[1]]$id, "ady.mustache")
  expect_equal(components[[2]]$id, "nested.mustache")
})

test_that("list_components round-trips percent-encoded names", {
  index <- '<a href="my%20comp.R">my comp.R</a>
  <a href="100%25.mustache">100%.mustache</a>
  <a href="my%20dir/">my dir/</a>'
  calls <- local_mock_url(
    routes = list(
      `/` = url_html_response(body = index),
      `my%20dir/` = url_html_response(
        body = '<a href="my%20dir.mustache">my dir.mustache</a>'
      ),
      `my%20comp.R` = url_component_response(ext = "R"),
      `100%25.mustache` = url_component_response(ext = "mustache"),
      `my%20dir/my%20dir.mustache` = url_component_response(ext = "mustache")
    )
  )

  components <- list_components(
    repos = mighty_repo_url(url = url_base),
    as = "list"
  )

  expect_equal(
    vapply(X = components, FUN = \(x) x$id, FUN.VALUE = character(1)),
    c("my comp.R", "100%.mustache", "my dir.mustache")
  )
  expect_true(
    all(
      paste0(
        url_base,
        c("/my%20comp.R", "/100%25.mustache", "/my%20dir/my%20dir.mustache")
      ) %in%
        calls$urls
    )
  )
})

test_that("list_components combines url and local repos", {
  path <- local_component_repo(files = c("ady.R", "local.R"))
  local_mock_url(
    routes = list(
      `/` = url_html_response(body = url_index_python),
      `nested/` = url_html_response(body = url_index_nested)
    )
  )

  list_components(repos = list(mighty_repo_url(url = url_base), path)) |>
    expect_equal(c("ady", "nested", "local"))
})

test_that("find_component finds a live URL component", {
  skip_on_cran()
  skip_if_offline(host = "raw.githubusercontent.com")

  component <- find_component(
    component = "dummy",
    repos = paste0(
      "url::https://raw.githubusercontent.com/",
      "NovoNordisk-OpenSource/mighty.standards/main/components"
    )
  )

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "dummy.mustache")
})
