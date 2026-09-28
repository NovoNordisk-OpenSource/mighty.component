test_that("list_components returns character vector of component IDs", {
  path <- test_path("_components")

  result <- list_components(path)

  expect_type(result, "character")
  expect_true("ady_local" %in% result)
  expect_true("test_component" %in% result)
})

test_that("list_components accepts multiple paths", {
  path <- c(
    test_path("_components"),
    system.file("examples", package = "mighty.component")
  )

  result <- list_components(path)

  expect_type(result, "character")
  expect_true("ady_local" %in% result)
  expect_true("ady" %in% result)
})

test_that("list_components as list returns component metadata", {
  path <- system.file("examples", package = "mighty.component")

  result <- list_components(path, as = "list")

  expect_type(result, "list")
  expect_length(result, 1)
  expect_equal(result[[1]]$id, "ady.mustache")
  expect_true(all(
    c("title", "type", "origin", "method") %in% names(result[[1]])
  ))
})

test_that("list_components as tibble returns tibble", {
  path <- system.file("examples", package = "mighty.component")

  result <- list_components(path, as = "tibble")

  expect_s3_class(result, "tbl_df")
  expect_true(all(
    c("id", "title", "description", "params", "depends", "outputs", "code") %in%
      names(result)
  ))
  expect_equal(nrow(result), 1)
})

test_that("list_components errors on non-existent path", {
  expect_error(
    list_components("/fake/nonexistent/path"),
    "does not exist"
  )
})

test_that("list_components returns empty character for empty directory", {
  empty_dir <- withr::local_tempdir()

  result <- list_components(empty_dir)

  expect_type(result, "character")
  expect_length(result, 0)
})

test_that("list_components accepts list of repos and specs", {
  p1 <- local_component_repo(files = "ady.R")
  p2 <- local_component_repo(files = "adt.mustache")

  list_components(repos = list(mighty_repo_local(path = p1), p2)) |>
    expect_setequal(c("ady", "adt"))
})

test_that("list_components returns duplicates across repos once", {
  p1 <- local_component_repo(files = c("ady.R", "adt.R"))
  p2 <- local_component_repo(files = c("ady.mustache", "adx.mustache"))

  list_components(repos = c(p1, p2)) |>
    expect_setequal(c("ady", "adt", "adx"))
})

test_that("list_components accepts single local:: spec", {
  path <- local_component_repo(files = "ady.R")

  list_components(repos = paste0("local::", path)) |>
    expect_equal("ady")
})

test_that("list_components as list takes first match across repos", {
  p1 <- local_component_repo(files = "ady.R")
  p2 <- local_component_repo(files = "ady.mustache")

  result <- list_components(repos = c(p1, p2), as = "list")

  expect_length(result, 1)
  expect_equal(result[[1]]$id, "ady.R")
})

test_that("list_components as list accepts mighty_repos", {
  repos <- mighty_repos(
    repos = c(
      local_component_repo(files = "ady.R"),
      local_component_repo(files = "adt/adt.mustache")
    )
  )

  result <- list_components(repos = repos, as = "list")

  vapply(X = result, FUN = \(x) x$id, FUN.VALUE = character(1)) |>
    expect_equal(c("ady.R", "adt.mustache"))
})

test_that("list_components returns empty list and tibble for empty repo", {
  empty_dir <- withr::local_tempdir()

  list_components(repos = empty_dir, as = "list") |>
    expect_equal(list())

  result <- list_components(repos = empty_dir, as = "tibble")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_named(
    result,
    c(
      "id",
      "title",
      "description",
      "type",
      "origin",
      "method",
      "params",
      "depends",
      "outputs",
      "code"
    )
  )
})

test_that("list_components as list resolves GitHub specs once", {
  calls <- local_mock_gh_tarball(
    tarball = local_github_tarball(files = c("ady/ady.mustache", "adt.R"))
  )

  result <- list_components(repos = "github::owner/repo", as = "list")

  expect_length(result, 2)
  expect_equal(calls$resolve, 1L)
  expect_equal(calls$download, 1L)
})

test_that("list_components errors on invalid as", {
  list_components(repos = withr::local_tempdir(), as = "data.frame") |>
    expect_error("must be one of")
})
