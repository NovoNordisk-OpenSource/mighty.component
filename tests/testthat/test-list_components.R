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
  expect_equal(result[[1]]$id, file.path(path, "ady.mustache"))
  expect_true("title" %in% names(result[[1]]))
})

test_that("list_components as tibble returns tibble", {
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
    "not found"
  )
})

test_that("list_components returns empty character for empty directory", {
  empty_dir <- withr::local_tempdir()

  result <- list_components(empty_dir)

  expect_type(result, "character")
  expect_length(result, 0)
})
