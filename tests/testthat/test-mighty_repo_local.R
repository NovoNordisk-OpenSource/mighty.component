test_that("mighty_repo_local errors when path does not exist", {
  path <- file.path(withr::local_tempdir(), "missing")

  mighty_repo_local(path = path) |>
    expect_error("does not exist")
})

test_that("list_components lists top-level files without extension", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = c("ady.R", "adt.mustache"))
  )

  list_components(repos = repo) |>
    expect_setequal(c("ady", "adt"))
})

test_that("list_components lists nested components by directory name", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "foo/foo.R")
  )

  list_components(repos = repo) |>
    expect_equal("foo")
})

test_that("list_components hides test- files", {
  repo <- mighty_repo_local(
    path = local_component_repo(
      files = c("ady.R", "test-ady.R", "foo/test-foo.R")
    )
  )

  list_components(repos = repo) |>
    expect_equal("ady")
})

test_that("list_components ignores deeper nesting and mismatched names", {
  repo <- mighty_repo_local(
    path = local_component_repo(
      files = c("ady.R", "bar/baz/baz.mustache", "qux/other.R")
    )
  )

  list_components(repos = repo) |>
    expect_equal("ady")
})

test_that("list_components returns character(0) for empty repo", {
  repo <- mighty_repo_local(path = withr::local_tempdir())

  list_components(repos = repo) |>
    expect_equal(character(0))
})

test_that("list_components lists same name with both extensions once", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = c("ady.R", "ady.mustache"))
  )

  list_components(repos = repo) |>
    expect_equal("ady")
})

test_that("find_component finds top-level component by name", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "ady.mustache")
  )

  component <- find_component(component = "ady", repos = repo)

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "ady.mustache")
})

test_that("find_component finds top-level component by name with extension", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "ady.mustache")
  )

  component <- find_component(component = "ady.mustache", repos = repo)

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "ady.mustache")
})

test_that("find_component finds nested component", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "foo/foo.R")
  )

  find_component(component = "foo", repos = repo)$id |>
    expect_equal("foo.R")

  find_component(component = "foo.R", repos = repo)$id |>
    expect_equal("foo.R")
})

test_that("find_component errors on same name with both extensions", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = c("ady.R", "ady.mustache"))
  )

  find_component(component = "ady", repos = repo) |>
    expect_error("Multiple matches")
})

test_that("find_component errors on top-level and nested duplicate", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = c("dup.R", "dup/dup.R"))
  )

  find_component(component = "dup", repos = repo) |>
    expect_error("Multiple matches")
})

test_that("find_component returns NULL when not found", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "ady.R")
  )

  find_component(component = "missing", repos = repo) |>
    expect_null()
})

test_that("find_component matches names literally", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "ady.mustache")
  )

  find_component(component = "a.y", repos = repo) |>
    expect_null()

  repo <- mighty_repo_local(
    path = local_component_repo(files = "a+b.R")
  )

  find_component(component = "a+b", repos = repo)$id |>
    expect_equal("a+b.R")
})

test_that("find_component finds test- files by explicit name", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "test-ady.R")
  )

  find_component(component = "test-ady", repos = repo)$id |>
    expect_equal("test-ady.R")
})

test_that("find_component validates custom R components", {
  path <- withr::local_tempdir()
  file.copy(
    from = test_path("_components", "illegal_param.R"),
    to = file.path(path, "illegal_param.R")
  )

  find_component(
    component = "illegal_param",
    repos = mighty_repo_local(path = path)
  ) |>
    expect_error("not allowed")
})
