skip_if_not_installed("httr2", minimum_version = "1.2.2")
skip_if_not_installed("jsonlite")

test_that("mighty_repo_api creates repo inheriting from mighty_repo_url", {
  repo <- mighty_repo_api(url = paste0(url_base, "/?token=abc"))

  expect_true(S7::S7_inherits(repo, mighty_repo_api))
  expect_true(S7::S7_inherits(repo, mighty_repo_url))
  expect_true(S7::S7_inherits(repo, mighty_repo_class))
  expect_equal(repo@path, url_base)
  expect_equal(repo@request$url, paste0(url_base, "/?token=abc"))
  expect_equal(repo@request$policies$retry_max_tries, 3L)
})

test_that("mighty_repo_api accepts an httr2_request", {
  req <- httr2::request(base_url = url_base) |>
    httr2::req_headers(`X-Token` = "abc")

  mighty_repo_api(url = req)@request$headers$`X-Token` |>
    expect_equal("abc")
})

test_that("mighty_repo_api errors on invalid url", {
  mighty_repo_api(url = 1) |>
    expect_error("must be a single string or an <httr2_request>")

  mighty_repo_api(url = "ftp://example.com/components") |>
    expect_error("must start with")
})

test_that("format returns api spec", {
  mighty_repo_api(url = paste0(url_base, "/")) |>
    format() |>
    expect_equal(paste0("api::", url_base))
})

test_that("mighty_repo creates api repo from api:: prefix", {
  repo <- mighty_repo(spec = paste0("api::", url_base))

  expect_true(S7::S7_inherits(repo, mighty_repo_api))
  expect_equal(repo@path, url_base)
})

test_that("component_ids lists ids from base URL", {
  calls <- local_mock_url(
    routes = list(
      `/` = url_json_response(body = '["ady", "test-ady", "b", "ady"]')
    )
  )

  component_ids(repos = mighty_repo_api(url = url_base)) |>
    expect_equal(c("ady", "test-ady", "b"))

  expect_equal(calls$urls, url_base)
})

test_that("component_ids keeps query string on list request", {
  calls <- local_mock_url(routes = list(`/` = url_json_response(body = "[]")))

  component_ids(repos = mighty_repo_api(url = paste0(url_base, "?t=1"))) |>
    expect_equal(character(0))

  expect_equal(calls$urls, paste0(url_base, "?t=1"))
})

test_that("component_ids errors on invalid component list", {
  bodies <- c(
    '{"ids": ["ady"]}',
    "{}",
    "[1, 2]",
    '["ady", null]',
    '[["ady"]]',
    '[""]',
    "true"
  )

  for (body in bodies) {
    local_mock_url(routes = list(`/` = url_json_response(body = body)))

    err <- component_ids(repos = mighty_repo_api(url = url_base)) |>
      expect_error("Invalid component list from.*/components")

    expect_match(conditionMessage(err), "JSON array of component names")
  }
})

test_that("component_ids errors on unparsable component list", {
  responses <- list(
    url_json_response(body = "[]", type = "text/plain"),
    url_json_response(body = "[ady"),
    httr2::response(status_code = 200)
  )

  for (resp in responses) {
    local_mock_url(routes = list(`/` = resp))

    err <- component_ids(repos = mighty_repo_api(url = url_base)) |>
      expect_error("Invalid component list from.*/components")

    expect_s3_class(err$parent, "error")
  }
})

test_that("component_ids errors when list request fails", {
  for (status in c(404L, 500L)) {
    local_mock_url(routes = list(`/` = status))

    err <- component_ids(repos = mighty_repo_api(url = url_base)) |>
      expect_error("Failed to list components at.*/components")

    expect_s3_class(err$parent, paste0("httr2_http_", status))
  }
})

test_that("find_component finds .mustache component", {
  calls <- local_mock_url(
    routes = list(ady = url_api_component_response(ext = "mustache"))
  )

  component <- find_component(
    component = "ady",
    repos = mighty_repo_api(url = url_base)
  )

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "ady.mustache")
  expect_equal(component$template, url_fixture(ext = "mustache"))
  expect_equal(calls$urls, paste0(url_base, "/ady"))
})

test_that("find_component finds .R component", {
  local_mock_url(routes = list(ady = url_api_component_response(ext = "R")))

  component <- find_component(
    component = "ady",
    repos = mighty_repo_api(url = url_base)
  )

  expect_equal(component$id, "ady.R")
  expect_equal(component$template, url_fixture(ext = "R"))
})

test_that("find_component ignores extension in name", {
  calls <- local_mock_url(
    routes = list(ady = url_api_component_response(ext = "R"))
  )
  repo <- mighty_repo_api(url = paste0(url_base, "?t=1"))

  for (name in c("ady.R", "ady.mustache")) {
    find_component(component = name, repos = repo)$id |>
      expect_equal("ady.R")
  }

  expect_equal(calls$urls, rep(paste0(url_base, "/ady?t=1"), 2))
})

test_that("find_component percent-encodes component name", {
  calls <- local_mock_url(
    routes = list(
      `my%20comp` = url_api_component_response(ext = "R", id = "my comp.R")
    )
  )
  repo <- mighty_repo_api(url = url_base)

  find_component(component = "my comp", repos = repo)$id |>
    expect_equal("my comp.R")

  find_component(component = "100%/x.R", repos = repo) |>
    expect_null()

  expect_equal(
    calls$urls,
    paste0(url_base, c("/my%20comp", "/100%25/x"))
  )
})

test_that("find_component returns NULL on 404 and 410", {
  for (status in c(404L, 410L)) {
    local_mock_url(routes = list(ady = status))

    find_component(
      component = "ady",
      repos = mighty_repo_api(url = url_base)
    ) |>
      expect_null()
  }
})

test_that("find_component errors on other HTTP errors", {
  local_mock_url(routes = list(ady = 500L))

  err <- find_component(
    component = "ady",
    repos = mighty_repo_api(url = url_base)
  ) |>
    expect_error("Failed to fetch.*/components/ady")

  expect_s3_class(err$parent, "httr2_http_500")
})

test_that("find_component errors on invalid component response", {
  bodies <- c(
    '{"id": "ady.R"}',
    '{"content": "x"}',
    '{"id": "ady.R", "content": 1}',
    '{"id": "ady.R", "content": ["a", "b"]}',
    '{"id": 1, "content": "x"}',
    '{"id": "ady.txt", "content": "x"}',
    '{"id": "", "content": "x"}',
    '["ady.R", "x"]',
    '"x"'
  )

  for (body in bodies) {
    local_mock_url(routes = list(ady = url_json_response(body = body)))

    err <- find_component(
      component = "ady",
      repos = mighty_repo_api(url = url_base)
    ) |>
      expect_error("Invalid component response from.*/components/ady")

    expect_match(conditionMessage(err), "JSON object with string")
  }
})

test_that("find_component errors on unparsable component response", {
  local_mock_url(
    routes = list(
      ady = url_json_response(body = '{"id": "ady.R"}', type = "text/html")
    )
  )

  err <- find_component(
    component = "ady",
    repos = mighty_repo_api(url = url_base)
  ) |>
    expect_error("Invalid component response from.*/components/ady")

  expect_s3_class(err$parent, "error")
})

test_that("find_component splits CRLF line endings", {
  body <- list(
    id = "ady.mustache",
    content = paste(url_fixture(ext = "mustache"), collapse = "\r\n")
  ) |>
    jsonlite::toJSON(auto_unbox = TRUE)
  local_mock_url(routes = list(ady = url_json_response(body = body)))

  component <- find_component(
    component = "ady",
    repos = mighty_repo_api(url = url_base)
  )

  expect_equal(component$template, url_fixture(ext = "mustache"))
})

test_that("find_component checks custom .R components", {
  body <- '{"id": "ady.R", "content": "x <- {{a}}"}'
  local_mock_url(routes = list(ady = url_json_response(body = body)))

  find_component(component = "ady", repos = mighty_repo_api(url = url_base)) |>
    expect_error("mustache patterns")
})

test_that("find_component accepts api:: spec", {
  local_mock_url(routes = list(ady = url_api_component_response(ext = "R")))

  find_component(component = "ady", repos = paste0("api::", url_base))$id |>
    expect_equal("ady.R")
})

test_that("mighty_repos falls through api repo to local repo", {
  calls <- local_mock_url()
  path <- local_component_repo(files = "ady.R")

  component <- find_component(
    component = "ady",
    repos = list(mighty_repo_api(url = url_base), path)
  )

  expect_equal(component$id, "ady.R")
  expect_equal(calls$urls, paste0(url_base, "/ady"))
})

test_that("list_components lists api repo components", {
  local_mock_url(
    routes = list(
      `/` = url_json_response(body = '["ady", "nested"]'),
      ady = url_api_component_response(ext = "mustache"),
      nested = url_api_component_response(ext = "R", id = "nested.R")
    )
  )
  repo <- mighty_repo_api(url = url_base)

  list_components(repos = repo) |>
    expect_equal(c("ady", "nested"))

  components <- list_components(repos = repo, as = "list")

  expect_length(components, 2)
  expect_equal(components[[1]]$id, "ady.mustache")
  expect_equal(components[[2]]$id, "nested.R")
})

test_that("list_components combines api and local repos", {
  path <- local_component_repo(files = c("ady.R", "local.R"))
  local_mock_url(routes = list(`/` = url_json_response(body = '["ady", "b"]')))

  list_components(repos = list(mighty_repo_api(url = url_base), path)) |>
    expect_equal(c("ady", "b", "local"))
})
