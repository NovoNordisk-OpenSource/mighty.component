test_that("search_github finds component via subdirectory convention", {
  local_mock_gh_tarball(test_path("_fixtures", "fake_repo.tar.gz"))

  result <- search_github("ady", source = "owner/repo")

  expect_type(result, "list")
  expect_equal(result$name, "ady.mustache")
  expect_true(any(grepl("compute_ady", result$content)))
})

test_that("search_github returns NULL for missing component", {
  local_mock_gh_tarball(test_path("_fixtures", "fake_repo.tar.gz"))

  result <- search_github("nonexistent", source = "owner/repo")
  expect_null(result)
})

test_that("search_github downloads tarball once for multiple components", {
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")

  clear_repo_cache()
  withr::defer(clear_repo_cache())

  tarball <- test_path("_fixtures", "fake_repo_subdir.tar.gz")
  call_count <- 0L

  local_mocked_bindings(
    gh = function(...) {
      call_count <<- call_count + 1L
      args <- list(...)
      file.copy(tarball, args$.destfile)
    },
    .package = "gh"
  )

  search_github("ady", source = "owner/repo/components")
  search_github("flat_comp.R", source = "owner/repo/components")
  search_github("ady", source = "owner/repo/components")

  expect_equal(call_count, 1L)
})

test_that("search_github with subdir scopes to subdirectory", {
  local_mock_gh_tarball(test_path("_fixtures", "fake_repo_subdir.tar.gz"))

  result <- search_github("ady", source = "owner/repo/components")

  expect_type(result, "list")
  expect_equal(result$name, "ady.mustache")
})

test_that("search_github falls back to flat listing when subdir is set", {
  local_mock_gh_tarball(test_path("_fixtures", "fake_repo_subdir.tar.gz"))

  result <- search_github("flat_comp.R", source = "owner/repo/components")

  expect_type(result, "list")
  expect_equal(result$name, "flat_comp.R")
})

test_that("search_github errors on 404 (repo does not exist)", {
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")

  clear_repo_cache()
  withr::defer(clear_repo_cache())

  local_mocked_bindings(
    gh = function(...) {
      cnd <- structure(
        class = c("http_error_404", "error", "condition"),
        list(message = "Not Found")
      )
      stop(cnd)
    },
    .package = "gh"
  )

  expect_error(
    search_github("ady", source = "owner/repo"),
    "Failed to query"
  )
})

test_that("search_github errors when gh writes HTML 404 page to destfile", {
  # gh::gh with .destfile does NOT raise http_error_404 for non-existent repos.
  # GitHub redirects to a 404 HTML page which gets saved as the .tar.gz file.
  # The code must detect this corrupt tarball and error clearly.
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")

  clear_repo_cache()
  withr::defer(clear_repo_cache())

  local_mocked_bindings(
    gh = function(...) {
      args <- list(...)
      # Simulate what actually happens, gh silently writes HTML to .destfile
      writeLines("<html><body>404 Not Found</body></html>", args$.destfile)
    },
    .package = "gh"
  )
  expect_error(
    search_github("ady", source = "owner/nonexistent-repo"),
    "Failed to query"
  )
})

test_that("search_github errors when gh writes empty file to destfile", {
  # The destfile is created but empty or truncated
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")

  clear_repo_cache()
  withr::defer(clear_repo_cache())

  local_mocked_bindings(
    gh = function(...) {
      args <- list(...)
      file.create(args$.destfile)
    },
    .package = "gh"
  )

  expect_error(
    search_github("ady", source = "owner/empty-tarball-repo"),
    "Failed to query"
  )
})

test_that("search_github returns NULL for unparsable source", {
  skip_if_not_installed("gh")
  skip_if_not_installed("remotes")

  result <- search_github("ady", source = "notarepo")
  expect_null(result)
})

test_that("ensure_repo_local caches by ref", {
  skip_if_not_installed("gh")

  clear_repo_cache()
  withr::defer(clear_repo_cache())

  tarball <- test_path("_fixtures", "fake_repo.tar.gz")
  call_count <- 0L

  local_mocked_bindings(
    gh = function(...) {
      call_count <<- call_count + 1L
      args <- list(...)
      file.copy(tarball, args$.destfile)
    },
    .package = "gh"
  )

  path1 <- ensure_repo_local("owner", "repo", ref = "v1.0")
  path2 <- ensure_repo_local("owner", "repo", ref = "v1.0")
  path3 <- ensure_repo_local("owner", "repo", ref = "v2.0")

  expect_equal(path1, path2)
  expect_false(identical(path1, path3))
  expect_equal(call_count, 2L)
})

test_that("search_github errors when component name resolves to a file, not a directory", {
  local_mock_gh_tarball(test_path(
    "_fixtures",
    "fake_repo_file_as_component.tar.gz"
  ))

  expect_error(
    search_github("ady", source = "owner/repo"),
    "is not a directory"
  )
})
