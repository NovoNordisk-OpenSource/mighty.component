test_that("find_component with NULL repos finds component from file path", {
  path <- local_component_repo(files = "ady.mustache")

  component <- find_component(
    component = file.path(path, "ady.mustache"),
    repos = NULL
  )

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "ady.mustache")
})

test_that("find_component with NULL repos returns NULL for missing file", {
  path <- local_component_repo(files = "ady.mustache")

  find_component(component = file.path(path, "missing.R"), repos = NULL) |>
    expect_null()
})

test_that("find_component with missing repos uses component as path", {
  withr::local_dir(new = local_component_repo(files = "ady.R"))

  find_component("ady")$id |>
    expect_equal("ady.R")

  find_component(component = "ady")$id |>
    expect_equal("ady.R")
})

test_that("find_component accepts single repo spec", {
  path <- local_component_repo(files = "ady.R")

  find_component(component = "ady", repos = path)$id |>
    expect_equal("ady.R")

  find_component(component = "ady", repos = paste0("local::", path))$id |>
    expect_equal("ady.R")
})

test_that("find_component returns component from first repo in order", {
  path1 <- local_component_repo(files = "ady.R")
  path2 <- local_component_repo(files = "ady.mustache")

  find_component(component = "ady", repos = c(path1, path2))$id |>
    expect_equal("ady.R")

  find_component(component = "ady", repos = c(path2, path1))$id |>
    expect_equal("ady.mustache")
})

test_that("find_component falls back to later repos", {
  path1 <- local_component_repo(files = "adt.R")
  path2 <- local_component_repo(files = "ady.mustache")

  find_component(component = "ady", repos = c(path1, path2))$id |>
    expect_equal("ady.mustache")
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
    expect_equal("ady.mustache")
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
    expect_equal("ady.mustache")
})

test_that("find_component reports repo where component was found", {
  withr::local_options(mighty.component.verbosity_level = "verbose")
  path1 <- local_component_repo(files = "adt.R")
  path2 <- local_component_repo(files = "ady.mustache")

  msg <- find_component(component = "ady", repos = c(path1, path2)) |>
    expect_message("Found")

  conditionMessage(msg) |>
    expect_match(path2, fixed = TRUE)
})

test_that("find_component errors on missing directory in repos", {
  missing <- file.path(withr::local_tempdir(), "missing")
  path <- local_component_repo(files = "ady.R")

  find_component(component = "ady", repos = c(missing, path)) |>
    expect_error("does not exist")
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
