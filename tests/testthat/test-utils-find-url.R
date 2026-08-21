url_base <- paste0(
  "https://raw.githubusercontent.com/NovoNordisk-OpenSource/",
  "mighty.standards/refs/heads/main/components/dummy"
)

test_that("search_url finds component at a direct file URL", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  result <- search_url(paste0(url_base, "/dummy.mustache"))

  expect_type(result, "list")
  expect_equal(result$name, "dummy.mustache")
  expect_equal(result$type, "mustache")
  expect_equal(result$path, paste0(url_base, "/dummy.mustache"))
  expect_true(any(grepl("@title Dummy", result$content)))
})

test_that("search_url finds component under a base URL", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  result <- search_url("dummy", source = url_base)

  expect_equal(result$name, "dummy.mustache")
  expect_equal(result$type, "mustache")
  expect_equal(result$path, paste0(url_base, "/dummy.mustache"))
})

test_that("search_url returns NULL when component is not found", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  result <- search_url("nonexistent", source = url_base)

  expect_null(result)
})
