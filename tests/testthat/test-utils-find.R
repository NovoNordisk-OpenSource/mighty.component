test_that("assert_single_match passes for length 0", {
  assert_single_match(character(0)) |>
    expect_no_error() |>
    expect_invisible()
})

test_that("assert_single_match passes for length 1", {
  assert_single_match("one") |>
    expect_no_error() |>
    expect_invisible()
})

test_that("assert_single_match errors for length > 1", {
  assert_single_match(c("a", "b")) |>
    expect_error("Multiple matches")
})

test_that("search_folder finds file by exact path", {
  result <- search_folder(test_path("_components", "ady_local.R"))
  expect_type(result, "list")
  expect_equal(result$name, "ady_local.R")
  expect_equal(result$type, "r")
  expect_true(file.exists(result$path))
  expect_type(result$content, "character")
})

test_that("search_folder finds file by name in folder", {
  result <- search_folder("ady_local.R", folder = test_path("_components"))
  expect_type(result, "list")
  expect_equal(result$name, "ady_local.R")
})

test_that("search_folder errors on ambiguous name without extension", {
  search_folder("ady_local", folder = test_path("_components")) |>
    expect_error("Multiple matches")
})

test_that("search_folder returns NULL for nonexistent folder", {
  result <- search_folder("anything", folder = "/nonexistent/path")
  expect_null(result)
})

test_that("search_folder returns NULL for nonexistent component", {
  result <- search_folder("nonexistent", folder = test_path("_components"))
  expect_null(result)
})

test_that("find_component finds component in folder", {
  result <- find_component("ady_local.R", repos = test_path("_components"))
  expect_type(result, "list")
  expect_equal(result$name, "ady_local.R")
})

test_that("find_component errors when not found", {
  find_component("nonexistent", repos = test_path("_components")) |>
    expect_error("not found")
})

test_that("find_component uses first matching repo", {
  result <- find_component(
    "ady_local.R",
    repos = c(test_path("_components"), "/nonexistent/path")
  )
  expect_equal(result$name, "ady_local.R")
})

test_that("parse_github_source parses owner/repo", {
  skip_if_not_installed("remotes")
  result <- parse_github_source("owner/repo")
  expect_equal(result$username, "owner")
  expect_equal(result$repo, "repo")
})

test_that("parse_github_source parses subdir", {
  skip_if_not_installed("remotes")
  result <- parse_github_source("owner/repo/subdir")
  expect_equal(result$subdir, "subdir")
})

test_that("parse_github_source parses ref", {
  skip_if_not_installed("remotes")
  result <- parse_github_source("owner/repo@ref")
  expect_equal(result$ref, "ref")
})

test_that("parse_github_source returns NULL for invalid source", {
  skip_if_not_installed("remotes")
  result <- parse_github_source("notarepo")
  expect_null(result)
})
