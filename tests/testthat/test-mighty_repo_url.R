skip_if_not_installed("httr2")

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
