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
  skip("as = is not yet supported for S7 repos")
  path <- system.file("examples", package = "mighty.component")

  result <- list_components(path, as = "list")

  expect_type(result, "list")
  expect_length(result, 1)
  expect_equal(result[[1]]$id, "ady.mustache")
  expect_true("title" %in% names(result[[1]]))
})

test_that("list_components as tibble returns tibble", {
  skip("as = is not yet supported for S7 repos")
  path <- system.file("examples", package = "mighty.component")

  result <- list_components(path, as = "tibble")

  expect_s3_class(result, "tbl_df")
  expect_true(all(
    c("id", "title", "description", "params", "depends", "outputs", "code") %in%
      names(result)
  ))
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
