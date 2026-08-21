test_that("search_url finds component at a direct file URL", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  url <- paste0(
    "https://raw.githubusercontent.com/NovoNordisk-OpenSource/",
    "mighty.standards/refs/heads/main/components/dummy/dummy.mustache"
  )

  result <- search_url(url)

  expect_type(result, "list")
  expect_equal(result$name, "dummy.mustache")
  expect_equal(result$type, "mustache")
  expect_equal(result$path, url)
  expect_true(any(grepl("@title Dummy", result$content)))
})

test_that("search_url finds component under a base URL", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  result <- search_url(
    "dummy",
    source = paste0(
      "https://raw.githubusercontent.com/NovoNordisk-OpenSource/",
      "mighty.standards/refs/heads/main/components/dummy"
    )
  )

  expect_equal(result$name, "dummy.mustache")
  expect_equal(result$type, "mustache")
})

test_that("search_url returns NULL when component is not found", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  result <- search_url(
    "nonexistent",
    source = paste0(
      "https://raw.githubusercontent.com/NovoNordisk-OpenSource/",
      "mighty.standards/refs/heads/main/components/dummy"
    )
  )

  expect_null(result)
})

test_that("find_component accepts a URL as component", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  result <- find_component(
    paste0(
      "https://raw.githubusercontent.com/NovoNordisk-OpenSource/",
      "mighty.standards/refs/heads/main/components/dummy/dummy.mustache"
    )
  )

  expect_equal(result$name, "dummy.mustache")
})

test_that("find_component accepts a URL as repos entry", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  result <- find_component(
    "dummy",
    repos = paste0(
      "https://raw.githubusercontent.com/NovoNordisk-OpenSource/",
      "mighty.standards/refs/heads/main/components/dummy"
    )
  )

  expect_equal(result$name, "dummy.mustache")
})

test_that("get_component builds a component from a URL", {
  skip_if_offline()
  skip_if_not_installed("httr2")

  result <- get_component(
    paste0(
      "https://raw.githubusercontent.com/NovoNordisk-OpenSource/",
      "mighty.standards/refs/heads/main/components/dummy/dummy.mustache"
    )
  )

  expect_s3_class(result, "mighty_component")
  expect_equal(result$id, "dummy.mustache")
})
