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

  expect_s7_class(repo, mighty_repo_github)
  expect_s7_class(repo, mighty_repo_local)
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

test_that("mighty_repo_github errors on missing subdir", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))

  mighty_repo_github(spec = "owner/repo/nope") |>
    expect_error("Subdirectory")
})

test_that("list_components lists components in github repo", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))

  repo <- mighty_repo_github(spec = "owner/repo")

  list_components(repos = repo) |>
    expect_setequal(c("ady", "flat_comp"))
})

test_that("find_component finds nested and top-level components", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))

  repo <- mighty_repo_github(spec = "owner/repo")

  component <- find_component(component = "ady", repos = repo)

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "ady.mustache")

  find_component(component = "flat_comp", repos = repo)$id |>
    expect_equal("flat_comp.R")
})

test_that("find_component returns NULL when not found in github repo", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = repo_files))

  repo <- mighty_repo_github(spec = "owner/repo")

  find_component(component = "nonexistent", repos = repo) |>
    expect_null()
})

test_that("mighty_repo_github caches download per sha", {
  calls <- local_mock_gh_tarball(
    tarball = local_github_tarball(files = repo_files)
  )

  repo1 <- mighty_repo_github(spec = "owner/repo@v1")
  repo2 <- mighty_repo_github(spec = "owner/repo@v1")

  expect_equal(calls$download, 1L)
  expect_equal(calls$resolve, 2L)
  expect_identical(repo1@path, repo2@path)
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

test_that("mighty_repo_github errors when sha cannot be resolved", {
  local_mock_gh(
    fun = function(endpoint, ..., .destfile = NULL) {
      stop("Not Found", call. = FALSE)
    }
  )

  mighty_repo_github(spec = "owner/repo") |>
    expect_error("Failed to resolve")
})

test_that("mighty_repo_github errors when tarball query fails", {
  local_mock_gh(
    fun = gh_resolve_or(download = \(destfile) stop("Not Found", call. = FALSE))
  )

  mighty_repo_github(spec = "owner/repo") |>
    expect_error("Failed to query")
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
    expect_error("empty directory")
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

test_that("parse_github_source parses owner/repo", {
  skip_if_not_installed("remotes")

  result <- parse_github_source(spec = "owner/repo")

  expect_equal(result$username, "owner")
  expect_equal(result$repo, "repo")
  expect_null(result$subdir)
  expect_null(result$ref)
})

test_that("parse_github_source parses subdir", {
  skip_if_not_installed("remotes")

  parse_github_source(spec = "owner/repo/subdir")$subdir |>
    expect_equal("subdir")
})

test_that("parse_github_source parses ref", {
  skip_if_not_installed("remotes")

  parse_github_source(spec = "owner/repo@ref")$ref |>
    expect_equal("ref")
})

test_that("parse_github_source returns NULL for invalid source", {
  skip_if_not_installed("remotes")

  parse_github_source(spec = "notarepo") |>
    expect_null()
})

test_that("mighty_repo_github downloads a live GitHub repo", {
  skip_on_cran()
  skip_if_offline(host = "api.github.com")
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")
  clear_repo_cache()
  withr::defer(clear_repo_cache())

  repo <- mighty_repo(
    spec = "github::NovoNordisk-OpenSource/mighty.standards/components@main"
  )

  expect_s7_class(repo, mighty_repo_github)
  expect_match(repo@sha, "^[0-9a-f]{40}$")
  expect_true(dir.exists(repo@path))

  components <- list_components(repos = repo)

  expect_gt(length(components), 0)
  expect_false(any(startsWith(x = components, prefix = "test-")))
})
