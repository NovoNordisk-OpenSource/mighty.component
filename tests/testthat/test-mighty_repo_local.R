test_that("mighty_repo_local errors when path does not exist", {
  path <- file.path(withr::local_tempdir(), "missing")

  mighty_repo_local(path = path) |>
    expect_error("Directory .* does not exist")
})

test_that("mighty_repo_local requires path to be a single non-empty string", {
  paths <- c(
    local_component_repo(files = "ady.R"),
    local_component_repo(files = "ady.R")
  )

  mighty_repo_local(path = paths) |>
    expect_error("must be a single non-empty string")

  mighty_repo_local(path = character(0)) |>
    expect_error("must be a single non-empty string")

  mighty_repo_local(path = NA_character_) |>
    expect_error("must be a single non-empty string")

  mighty_repo_local(path = "") |>
    expect_error("must be a single non-empty string")
})

test_that("component_candidates lists nested before top-level paths", {
  component_candidates(component = "ady") |>
    expect_equal(c("ady/ady.mustache", "ady.mustache", "ady/ady.R", "ady.R"))

  component_candidates(component = "ady.R") |>
    expect_equal(c("ady/ady.R", "ady.R"))

  component_candidates(component = "foo.bar") |>
    expect_equal(
      c(
        "foo.bar/foo.bar.mustache",
        "foo.bar.mustache",
        "foo.bar/foo.bar.R",
        "foo.bar.R"
      )
    )
})

test_that("ids_from_files returns flat files without extension", {
  ids_from_files(files = c("ady.R", "adt.mustache", "notes.txt")) |>
    expect_equal(c("ady", "adt"))
})

test_that("ids_from_files returns nested components by directory name", {
  ids_from_files(files = c("foo/foo.R", "bar/bar.mustache")) |>
    expect_equal(c("foo", "bar"))
})

test_that("ids_from_files ignores non-matching nested files", {
  ids_from_files(
    files = c("x/other.R", "y/y.txt", "z/z.R.bak", "a/b/b.R")
  ) |>
    expect_equal(character(0))
})

test_that("ids_from_files lists flat before nested", {
  ids_from_files(files = c("foo/foo.R", "ady.mustache")) |>
    expect_equal(c("ady", "foo"))
})

test_that("ids_from_files drops test- files", {
  ids_from_files(
    files = c("ady.R", "test-ady.R", "foo/test-foo.R", "test-y/test-y.R")
  ) |>
    expect_equal("ady")
})

test_that("ids_from_files removes duplicates", {
  ids_from_files(
    files = c(
      "ady.R",
      "ady.mustache",
      "ady/ady.R",
      "foo/foo.R",
      "foo/foo.mustache"
    )
  ) |>
    expect_equal(c("ady", "foo"))
})

test_that("ids_from_files returns character(0) for empty input", {
  ids_from_files(files = character(0)) |>
    expect_equal(character(0))
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
      files = c("ady.R", "test-ady.R", "test-foo/test-foo.R")
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

test_that("list_components ignores directories with component extension", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = c("x.R/other.R", "foo/foo.R"))
  )

  list_components(repos = repo) |>
    expect_equal("foo")
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
  expect_equal(component$id, "ady")
})

test_that("find_component finds top-level component by name with extension", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "ady.mustache")
  )

  component <- find_component(component = "ady.mustache", repos = repo)

  expect_s3_class(component, "mighty_component")
  expect_equal(component$id, "ady")
})

test_that("find_component finds nested component", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "foo/foo.R")
  )

  find_component(component = "foo", repos = repo)$id |>
    expect_equal("foo")

  find_component(component = "foo.R", repos = repo)$id |>
    expect_equal("foo")
})

test_that("find_component finds nested component with a dotted name", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "foo.bar/foo.bar.R")
  )

  find_component(component = "foo.bar", repos = repo)$id |>
    expect_equal("foo.bar")

  find_component(component = "foo.bar.R", repos = repo)$id |>
    expect_equal("foo.bar")
})

test_that("find_component matches names case-sensitively", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = c("ady.R", "foo/foo.R"))
  )

  find_component(component = "ADY", repos = repo) |>
    expect_null()

  find_component(component = "FOO", repos = repo) |>
    expect_null()
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

test_that("find_component ignores directories with component extension", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = c("x.R/other.R", "foo/foo.R"))
  )

  find_component(component = "x", repos = repo) |>
    expect_null()

  find_component(component = "x.R", repos = repo) |>
    expect_null()

  find_component(component = "foo", repos = repo)$id |>
    expect_equal("foo")
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
    expect_equal("a+b")
})

test_that("find_component finds test- files by explicit name", {
  repo <- mighty_repo_local(
    path = local_component_repo(files = "test-ady.R")
  )

  find_component(component = "test-ady", repos = repo)$id |>
    expect_equal("test-ady")
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
