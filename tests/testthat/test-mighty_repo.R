test_that("mighty_repo treats spec without prefix as local", {
  path <- local_component_repo(files = "ady.R")

  repo <- mighty_repo(spec = path)

  expect_true(S7::S7_inherits(repo, mighty_repo_local))
  expect_equal(repo@path, path)
})

test_that("mighty_repo strips local:: prefix", {
  path <- local_component_repo(files = "ady.R")

  repo <- mighty_repo(spec = paste0("local::", path))

  expect_true(S7::S7_inherits(repo, mighty_repo_local))
  expect_equal(repo@path, path)
})

test_that("mighty_repo creates github repo from github:: prefix", {
  local_mock_gh_tarball(tarball = local_github_tarball(files = "ady.R"))

  repo <- mighty_repo(spec = "github::owner/repo")

  expect_true(S7::S7_inherits(repo, mighty_repo_github))
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

test_that("mighty_repo errors when spec is not a single string", {
  mighty_repo(spec = c("a", "b")) |>
    expect_error("must be a single string")
})

test_that("mighty_repo_class is abstract", {
  mighty_repo_class() |>
    expect_error("abstract")
})

test_that("format returns local spec", {
  path <- local_component_repo(files = "ady.R")

  mighty_repo_local(path = path) |>
    format() |>
    expect_equal(paste0("local::", path))
})
