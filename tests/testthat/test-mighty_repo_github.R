repo_files <- c("ady/ady.mustache", "flat_comp.R")

local_mock_gh <- function(fun, env = parent.frame()) {
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")
  clear_repo_cache()
  withr::defer(clear_repo_cache(), envir = env)

  local_mocked_bindings(gh = fun, .package = "gh", .env = env)
}

gh_resolve_or <- function(download) {
  function(endpoint, ..., .destfile = NULL) {
    if (is.null(.destfile)) {
      return(list(message = "sha"))
    }
    download(.destfile)
  }
}

test_that("mighty_repo_github creates repo from owner/repo", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))

  repo <- mighty_repo_github(spec = "owner/repo")

  expect_true(S7::S7_inherits(repo, mighty_repo_github))
  expect_true(S7::S7_inherits(repo, mighty_repo_local))
  expect_equal(repo@owner, "owner")
  expect_equal(repo@repo, "repo")
  expect_equal(repo@subdir, character(0))
  expect_equal(repo@ref, character(0))
  expect_equal(repo@sha, "sha-HEAD")
  expect_true(dir.exists(repo@path))
  expect_true(dir.exists(file.path(repo@path, "ady")))
})

test_that("mighty_repo_github scopes to subdir and resolves ref", {
  local_mock_gh_tarball(
    tarball = local_github_tarball(files = file.path("components", repo_files))
  )

  repo <- mighty_repo_github(spec = "owner/repo/components@v1")

  expect_equal(repo@subdir, "components")
  expect_equal(repo@ref, "v1")
  expect_equal(repo@sha, "sha-v1")
  expect_equal(basename(repo@path), "components")

  list_components(repos = repo) |>
    expect_setequal(c("ady", "flat_comp"))
})

test_that("format returns github spec pinned to sha", {
  local_mock_gh_tarball(
    tarball = local_github_tarball(files = file.path("components", repo_files))
  )

  mighty_repo_github(spec = "owner/repo/components@v1") |>
    format() |>
    expect_equal("github::owner/repo/components@sha-v1")

  mighty_repo_github(spec = "owner/repo") |>
    format() |>
    expect_equal("github::owner/repo@sha-HEAD")
})

test_that("mighty_repo_github errors on invalid spec", {
  skip_if_not_installed("remotes")

  mighty_repo_github(spec = "notarepo") |>
    expect_error("not a valid GitHub source")
})

test_that("mighty_repo_github errors on pull request and release specs", {
  calls <- local_mock_gh_tarball(
    tarball = local_github_tarball(files = repo_files)
  )

  mighty_repo_github(spec = "owner/repo#12") |>
    expect_error("not supported")

  mighty_repo_github(spec = "owner/repo@*release") |>
    expect_error("not supported")

  expect_equal(calls$resolve, 0L)
  expect_equal(calls$download, 0L)
})

test_that("mighty_repo_github errors on missing subdir", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))

  mighty_repo_github(spec = "owner/repo/nope") |>
    expect_error("Subdirectory")
})

test_that("mighty_repo_github resolves each ref once", {
  calls <- local_mock_gh_tarball(
    tarball = local_github_tarball(files = repo_files)
  )

  mighty_repo_github(spec = "owner/repo")
  mighty_repo_github(spec = "owner/repo@v1")
  mighty_repo_github(spec = "owner/repo")
  mighty_repo_github(spec = "owner/repo@v1")

  expect_equal(calls$resolve, 2L)
})

test_that("mighty_repo_github downloads again for different sha", {
  calls <- local_mock_gh_tarball(
    tarball = local_github_tarball(files = repo_files)
  )

  repo1 <- mighty_repo_github(spec = "owner/repo@v1")
  repo2 <- mighty_repo_github(spec = "owner/repo@v2")

  expect_equal(calls$download, 2L)
  expect_false(identical(repo1@path, repo2@path))
})

test_that("mighty_repo_github reuses cache for refs with same sha", {
  calls <- local_mock_gh_tarball(
    tarball = local_github_tarball(files = repo_files),
    sha = \(ref) "same"
  )

  repo1 <- mighty_repo_github(spec = "owner/repo@v1")
  repo2 <- mighty_repo_github(spec = "owner/repo@main")

  expect_equal(calls$download, 1L)
  expect_identical(repo1@path, repo2@path)
})

test_that("mighty_repo_github reports download and cache use", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))
  withr::local_options(mighty.component.verbosity_level = "verbose")

  mighty_repo_github(spec = "owner/repo") |>
    expect_message("Downloading repo")

  mighty_repo_github(spec = "owner/repo") |>
    expect_message("Using cached repo")
})

local_mock_untar_warning <- function(env = parent.frame()) {
  real_untar <- utils::untar
  local_mocked_bindings(
    untar = function(tarfile, exdir, ...) {
      warning("tar warning {x}")
      real_untar(tarfile = tarfile, exdir = exdir, ...)
    },
    .package = "utils",
    .env = env
  )
}

test_that("mighty_repo_github reports untar warnings when verbose", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))
  local_mock_untar_warning()
  withr::local_options(mighty.component.verbosity_level = "verbose")

  expect_no_warning(
    mighty_repo_github(spec = "owner/repo") |>
      expect_message("tar warning {x}", fixed = TRUE) |>
      expect_message("Downloading repo")
  )
})

test_that("mighty_repo_github silences untar warnings when quiet", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))
  local_mock_untar_warning()

  expect_no_warning(
    expect_no_message(mighty_repo_github(spec = "owner/repo"))
  )
})

test_that("mighty_repo_github errors when tarball is an HTML page", {
  local_mock_gh(
    fun = gh_resolve_or(
      download = \(destfile) {
        writeLines(text = "<html><body>404</body></html>", con = destfile)
      }
    )
  )

  mighty_repo_github(spec = "owner/repo") |>
    expect_error("Failed to extract")
})

test_that("mighty_repo_github errors when tarball is empty", {
  local_mock_gh(
    fun = gh_resolve_or(download = \(destfile) file.create(destfile))
  )

  mighty_repo_github(spec = "owner/repo") |>
    expect_error("Failed to extract")
})

test_that("mighty_repo_github errors when tarball has no top-level dir", {
  tarball <- local_github_tarball(files = "ady.R", top_dir = ".")
  local_mock_gh(
    fun = gh_resolve_or(
      download = \(destfile) file.copy(from = tarball, to = destfile)
    )
  )

  mighty_repo_github(spec = "owner/repo") |>
    expect_error("empty directory")
})

temp_repo_files <- function() {
  list.files(path = tempdir(), pattern = "^mighty_(repo|extract)_|\\.tar\\.gz$")
}

test_that("mighty_repo_github leaves only the cached repo on disk", {
  tarball <- local_github_tarball(files = repo_files)
  local_mock_gh_tarball(tarball = tarball)
  before <- temp_repo_files()

  repo <- mighty_repo_github(spec = "owner/repo")

  expect_equal(setdiff(temp_repo_files(), before), basename(repo@path))
  expect_equal(normalizePath(dirname(repo@path)), normalizePath(tempdir()))
  expect_true(file.exists(file.path(repo@path, "flat_comp.R")))

  clear_repo_cache()
  expect_setequal(temp_repo_files(), before)
})

gh_http_error <- function(status) {
  rlang::abort(
    message = paste0("GitHub API error (", status, ")"),
    class = c("github_error", paste0("http_error_", status))
  )
}

gh_network_error <- function() {
  rlang::abort(
    message = "Failed to perform HTTP request.",
    class = c("httr2_failure", "httr2_error")
  )
}

local_mock_gh_errors <- function(
  errors,
  success = \(...) "result",
  env = parent.frame()
) {
  calls <- new.env(parent = emptyenv())
  calls$n <- 0L
  calls$waits <- numeric(0)

  local_mock_gh(
    fun = function(...) {
      calls$n <- calls$n + 1L
      if (calls$n <= length(errors)) {
        errors[[calls$n]]()
      }
      success(...)
    },
    env = env
  )
  local_mocked_bindings(
    retry_wait = \(seconds) {
      calls$waits <- c(calls$waits, seconds)
    },
    .env = env
  )

  calls
}

test_that("gh_with_retry backs off exponentially", {
  calls <- local_mock_gh_errors(
    errors = list(gh_network_error, \() gh_http_error(503))
  )

  gh_with_retry("GET /x") |>
    expect_equal("result")

  expect_equal(calls$n, 3L)
  expect_equal(calls$waits, c(1, 2))
})

test_that("gh_with_retry does not retry client errors", {
  calls <- local_mock_gh_errors(errors = list(\() gh_http_error(404)))

  gh_with_retry("GET /x") |>
    expect_error(class = "http_error_404")

  expect_equal(calls$n, 1L)
  expect_length(calls$waits, 0)
})

test_that("gh_with_retry gives up after max tries", {
  calls <- local_mock_gh_errors(errors = rep(list(gh_network_error), 5))

  gh_with_retry("GET /x") |>
    expect_error(class = "httr2_failure")

  expect_equal(calls$n, 3L)
  expect_equal(calls$waits, c(1, 2))
})

test_that("gh_with_retry respects max_tries option", {
  calls <- local_mock_gh_errors(errors = list(\() gh_http_error(500)))
  withr::local_options(mighty.component.max_tries = 1)

  gh_with_retry("GET /x") |>
    expect_error(class = "http_error_500")

  expect_equal(calls$n, 1L)
  expect_length(calls$waits, 0)
})

test_that("gh_with_retry errors on invalid max_tries option", {
  calls <- local_mock_gh_errors(errors = list())

  withr::with_options(
    new = list(mighty.component.max_tries = 0),
    code = gh_with_retry("GET /x")
  ) |>
    expect_error("max_tries")

  withr::with_options(
    new = list(mighty.component.max_tries = "a"),
    code = gh_with_retry("GET /x")
  ) |>
    expect_error("max_tries")

  expect_equal(calls$n, 0L)
})

test_that("gh_with_retry reports retries when verbose", {
  local_mock_gh_errors(errors = list(\() gh_http_error(502)))
  withr::local_options(mighty.component.verbosity_level = "verbose")

  gh_with_retry("GET /x") |>
    expect_message("Retrying in 1s \\(attempt 2/3\\)")
})

test_that("gh_with_retry is silent on retries when quiet", {
  local_mock_gh_errors(errors = list(\() gh_http_error(502)))

  gh_with_retry("GET /x") |>
    expect_no_message()
})

test_that("retry_wait sleeps", {
  retry_wait(seconds = 0) |>
    expect_null()
})

test_that("mighty_repo_github retries transient errors", {
  tarball <- local_github_tarball(files = repo_files)
  calls <- local_mock_gh_errors(
    errors = list(\() gh_http_error(502)),
    success = gh_resolve_or(
      download = \(destfile) file.copy(from = tarball, to = destfile)
    )
  )

  repo <- mighty_repo_github(spec = "owner/repo")

  expect_equal(repo@sha, "sha")
  expect_true(dir.exists(file.path(repo@path, "ady")))
  expect_equal(calls$n, 3L)
  expect_equal(calls$waits, 1)
})

test_that("mighty_repo_github does not retry or cache failed resolves", {
  calls <- local_mock_gh_errors(errors = list(\() gh_http_error(404)))

  mighty_repo_github(spec = "owner/repo") |>
    expect_error("Failed to resolve")

  expect_equal(calls$n, 1L)
  expect_length(calls$waits, 0)
  expect_length(ls(sha_cache), 0)
})

test_that("mighty_repo_github does not retry client errors on download", {
  calls <- local_mock_gh_errors(
    errors = list(),
    success = gh_resolve_or(download = \(destfile) gh_http_error(404))
  )

  mighty_repo_github(spec = "owner/repo") |>
    expect_error("Failed to query")

  expect_equal(calls$n, 2L)
  expect_length(calls$waits, 0)
})

test_that("mighty_repo_github downloads a live GitHub repo", {
  skip_on_cran()
  skip_if_offline(host = "api.github.com")
  # gh < 1.6.0 rejects GitHub App tokens (ghs_ prefix) used on CI
  skip_if_not_installed("gh", minimum_version = "1.6.0")
  skip_if_not_installed("remotes")
  clear_repo_cache()
  withr::defer(clear_repo_cache())

  repo <- mighty_repo(
    spec = "github::NovoNordisk-OpenSource/mighty.standards/components@main"
  )

  expect_true(S7::S7_inherits(repo, mighty_repo_github))
  expect_match(repo@sha, "^[0-9a-f]{40}$")
  expect_true(dir.exists(repo@path))

  components <- list_components(repos = repo)

  expect_gt(length(components), 0)
  expect_false(any(startsWith(x = components, prefix = "test-")))
})
