test_that("find_component with NULL repos finds component from file path", {
  path <- local_component_repo(files = "ady.mustache")

  component <- find_component(
    component = file.path(path, "ady.mustache"),
    repos = NULL
  )

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "ady")
})

test_that("find_component with NULL repos returns NULL for missing file", {
  path <- local_component_repo(files = "ady.mustache")

  find_component(component = file.path(path, "missing.R"), repos = NULL) |>
    expect_null()
})

test_that("find_component with missing repos uses component as path", {
  withr::local_dir(new = local_component_repo(files = "ady.R"))

  find_component("ady")$id |>
    expect_equal("ady")

  find_component(component = "ady")$id |>
    expect_equal("ady")
})

test_that("find_component accepts single repo spec", {
  path <- local_component_repo(files = "ady.R")

  find_component(component = "ady", repos = path)$id |>
    expect_equal("ady")

  find_component(component = "ady", repos = paste0("local::", path))$id |>
    expect_equal("ady")
})

test_that("find_component returns NULL when not found in any repo", {
  path1 <- local_component_repo(files = "adt.R")
  path2 <- local_component_repo(files = "ady.mustache")

  find_component(component = "missing", repos = c(path1, path2)) |>
    expect_null()
})

test_that("find_component accepts list of repo objects and specs", {
  path1 <- local_component_repo(files = "adt.R")
  path2 <- local_component_repo(files = "ady.mustache")

  find_component(
    component = "ady",
    repos = list(mighty_repo_local(path = path1), path2)
  )$id |>
    expect_equal("ady")
})

test_that("find_component finds component in github spec in list", {
  local_mock_gh_tarball(
    tarball = local_github_tarball(files = "ady/ady.mustache")
  )
  path <- local_component_repo(files = "adt.R")

  find_component(
    component = "ady",
    repos = list(path, "github::owner/repo")
  )$id |>
    expect_equal("ady")
})

test_that("find_component resolves github spec once across calls", {
  calls <- local_mock_gh_tarball(
    tarball = local_github_tarball(files = "ady/ady.mustache")
  )

  find_component(component = "ady", repos = "github::owner/repo")
  find_component(component = "ady", repos = "github::owner/repo")

  expect_equal(calls$resolve, 1L)
  expect_equal(calls$download, 1L)
})

test_that("find_component errors on missing directory in repos", {
  missing <- file.path(withr::local_tempdir(), "missing")
  path <- local_component_repo(files = "ady.R")

  find_component(component = "ady", repos = c(missing, path)) |>
    expect_error("does not exist")
})

test_that("find_component errors when component is not a single string", {
  path <- local_component_repo(files = "ady.R")

  find_component(component = c("a", "b"), repos = path) |>
    expect_error("must be a single string")

  get_component(component = c("a", "b"), repos = path) |>
    expect_error("must be a single string")
})

test_that("find_component errors on invalid repos", {
  find_component(component = "ady", repos = 1) |>
    expect_error("must be a string")
})

test_that("get_component errors when component is not found", {
  path <- local_component_repo(files = "ady.R")

  get_component(component = "missing", repos = path) |>
    expect_error("not found")
})

test_that("get_component returns found component", {
  path <- local_component_repo(files = "ady.R")

  get_component(component = "ady", repos = path) |>
    expect_s3_class("mighty_component")
})
