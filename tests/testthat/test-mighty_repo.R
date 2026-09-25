test_that("mighty_repo treats spec without prefix as local", {
  path <- local_component_repo(files = "ady.R")

  repo <- mighty_repo(spec = path)

  expect_s7_class(repo, mighty_repo_local)
  expect_equal(repo@path, path)
})

test_that("mighty_repo strips local:: prefix", {
  path <- local_component_repo(files = "ady.R")

  repo <- mighty_repo(spec = paste0("local::", path))

  expect_s7_class(repo, mighty_repo_local)
  expect_equal(repo@path, path)
})

test_that("mighty_repo creates github repo from github:: prefix", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = "ady.R"))

  repo <- mighty_repo(spec = "github::owner/repo")

  expect_s7_class(repo, mighty_repo_github)
  expect_equal(repo@owner, "owner")
  expect_equal(repo@repo, "repo")
})

test_that("mighty_repo errors on unknown repo type", {
  mighty_repo(spec = "foo::bar") |>
    expect_error("Unknown repo type")
})

test_that("mighty_repo errors on empty repo type", {
  mighty_repo(spec = "::x") |>
    expect_error("Unknown repo type")
})

test_that("mighty_repo_class is abstract", {
  mighty_repo_class(path = tempdir()) |>
    expect_error("abstract")
})

test_that("mighty_repo_class requires path of length 1", {
  paths <- c(
    local_component_repo(files = "ady.R"),
    local_component_repo(files = "ady.R")
  )

  mighty_repo_local(path = paths) |>
    expect_error("length 1")

  mighty_repo_local(path = character(0)) |>
    expect_error("length 1")
})

test_that("format returns repo path", {
  path <- local_component_repo(files = "ady.R")

  mighty_repo_local(path = path) |>
    format() |>
    expect_equal(path)
})
