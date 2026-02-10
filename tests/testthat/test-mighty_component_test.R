test_that("general testing workflow", {
  x <- get_test_component(
    component = test_path("_components", "ady_local.mustache"),
    params = list(domain = "adlb", variable = "ADY2", date = "ADT")
  )

  x$assign("adlb", head(pharmaverseadam::adlb, 5)) |>
    expect_invisible()

  x$ls() |>
    expect_visible() |>
    expect_equal("adlb")

  x$get("adlb") |>
    names() |>
    intersect("ADY2") |>
    expect_length(0)

  x$percent_coverage |>
    expect_equal(0)

  x$eval() |>
    expect_invisible()

  x$get("adlb") |>
    expect_visible() |>
    names() |>
    expect_contains("ADY2")

  x$percent_coverage |>
    expect_equal(100)

  x$line_coverage |>
    expect_s3_class("data.frame") |>
    names() |>
    expect_equal(c("line", "value"))

  x$check_coverage() |>
    expect_no_error()

  x$line_coverage$value |>
    min() |>
    expect_equal(1)
})

test_that("printing and test percentage updates", {
  x <- get_test_component(
    component = test_path("_components", "test_coverage.mustache"),
    params = list(value = 5),
    check_coverage = FALSE
  )

  x$percent_coverage |>
    expect_equal(0)

  print(x) |>
    expect_snapshot()

  x$assign("limit", 10)$eval()$get("x") |>
    expect_equal(5)

  x$percent_coverage |>
    expect_gt(0) |>
    expect_lt(100)

  print(x) |>
    expect_snapshot()

  x$assign("limit", 3)$eval()$get("x") |>
    expect_equal(3)

  x$percent_coverage |>
    expect_equal(100)

  print(x) |>
    expect_snapshot()

  x$line_coverage |>
    expect_equal(
      data.frame(
        line = c(1, 3, 4, 5),
        value = c(2, 2, 1, 2)
      )
    )
})

test_that(".test_fn is protected", {
  x <- get_test_component(
    component = test_path("_components", "ady_local.mustache"),
    params = list(domain = "adlb", variable = "ADY2", date = "ADT"),
    check_coverage = FALSE
  )

  x$assign(".test_fn", 2) |>
    expect_error("locked binding")
})

test_that("Error with no test code coverage", {
  local({
    get_test_component(
      component = test_path("_components", "test_component.mustache"),
      params = list(domain = "a", x1 = 1, x2 = 3)
    )
  }) |>
    expect_error("All lines in component must be covered by unit tests")
})

test_that("Session closed on finalize", {
  skip_on_os(os = "windows")

  x <- get_test_component(
    component = test_path("_components", "test_component.mustache"),
    params = list(domain = "a", x1 = 1, x2 = 3),
    check_coverage = FALSE
  )

  pid <- x[[".__enclos_env__"]][["private"]][[".session"]]$get_pid()

  pid |>
    process_is_alive() |>
    expect_true()

  rm(x)
  gc() # Garbage collection enforced finalize on deleted objects

  pid |>
    process_is_alive() |>
    expect_false()
})
