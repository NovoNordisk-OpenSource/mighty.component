rendered_test_component <- function() {
  # TODO: Replace with get_rendered_component when
  # available in entire script
  test_path("_input", "test_component.mustache") |>
    readLines() |>
    whisker.render(data = list(x1 = 5, x2 = 3)) |>
    {
      \(x) strsplit(x = x, "\n")[[1]]
    }() |>
    mighty_component_rendered$new()
}

test_that("msr_print", {
  rendered_test_component() |>
    print() |>  
    expect_snapshot()
})

test_that("msr_stream", {
  x <- rendered_test_component()

  script <- withr::local_tempfile(fileext = ".R")

  msr_stream(path = script, self = x) |>
    expect_no_condition() |>
    expect_equal(x)

  readLines(script) |>
    expect_equal(x$code)
})


test_that("msr_test_coverage", {
  x <- rendered_test_component()
  msr_test_coverage(x) |>
    expect_equal(0)
})
