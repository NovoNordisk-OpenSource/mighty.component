test_that("mighty_repos creates repos from character vector", {
  path1 <- local_component_repo(files = "ady.R")
  path2 <- local_component_repo(files = "adt.R")

  repos <- mighty_repos(repos = c(path1, paste0("local::", path2)))

  expect_true(S7::S7_inherits(repos, mighty_repos))
  expect_length(repos, 2)
  expect_true(S7::S7_inherits(repos[[1]], mighty_repo_local))
  expect_equal(repos[[2]]@path, path2)
})

test_that("mighty_repos accepts list of specs and repo objects", {
  path1 <- local_component_repo(files = "ady.R")
  path2 <- local_component_repo(files = "adt.R")
  repo1 <- mighty_repo_local(path = path1)

  repos <- mighty_repos(repos = list(repo1, path2))

  expect_identical(repos[[1]], repo1)
  expect_equal(repos[[2]]@path, path2)
})

test_that("mighty_repos accepts a single repo object", {
  repo <- mighty_repo_local(path = local_component_repo(files = "ady.R"))

  repos <- mighty_repos(repos = repo)

  expect_length(repos, 1)
  expect_identical(repos[[1]], repo)
})

test_that("mighty_repos allows empty collection", {
  repos <- mighty_repos()

  expect_length(repos, 0)

  find_component(component = "ady", repos = repos) |>
    expect_null()

  list_components(repos = repos) |>
    expect_equal(character(0))
})

test_that("mighty_repos errors on invalid element", {
  mighty_repos(repos = list(1)) |>
    expect_error("must be a string")
})

test_that("mighty_repos validator rejects non-repo elements", {
  repos <- mighty_repos(repos = local_component_repo(files = "ady.R"))
  repos[[1]] <- "not a repo"

  S7::validate(repos) |>
    expect_error("mighty_repo_class")
})

test_that("mighty_repos resolves GitHub specs once", {
  calls <- local_mock_gh_tarball(
    tarball = local_github_tarball(files = "ady/ady.mustache")
  )

  repos <- mighty_repos(repos = "github::owner/repo")
  find_component(component = "ady", repos = repos)
  find_component(component = "ady", repos = repos)
  list_components(repos = repos)

  expect_equal(calls$resolve, 1L)
  expect_equal(calls$download, 1L)
})

test_that("find_component searches mighty_repos in order", {
  withr::local_options(mighty.component.verbosity_level = "verbose")
  path1 <- local_component_repo(files = "adt.R")
  path2 <- local_component_repo(files = c("ady.mustache", "adt.mustache"))
  repos <- mighty_repos(repos = c(path1, path2))

  find_component(component = "adt", repos = repos)$id |>
    expect_equal("adt.R") |>
    expect_message(basename(path1), fixed = TRUE)

  find_component(component = "ady", repos = repos)$id |>
    expect_equal("ady.mustache") |>
    expect_message(basename(path2), fixed = TRUE)
})

test_that("list_components lists unique components across mighty_repos", {
  repos <- mighty_repos(
    repos = c(
      local_component_repo(files = c("ady.R", "adt.R")),
      local_component_repo(files = c("ady.mustache", "adx.R"))
    )
  )

  list_components(repos = repos) |>
    expect_equal(c("adt", "ady", "adx"))
})

test_that("format and print show repo specs", {
  withr::local_dir(new = local_component_repo(files = "ady.R"))
  dir.create("sub")

  repos <- mighty_repos(repos = c(".", "local::sub"))

  format(repos) |>
    expect_equal(c("local::.", "local::sub"))

  expect_snapshot(print(repos))
  expect_snapshot(print(mighty_repos()))
})
