test_that("lint_implicit_join detects implicit joins (without namespace)", {
  # Bad: basic implicit join without namespace prefix
  # This test verifies the linter works without dplyr:: prefix
  bad_code1 <- "left_join(df1, df2)"

  lints <- lintr::lint(text = bad_code1, linters = lint_implicit_join())

  expect_length(lints, 1)
  expect_match(lints[[1]]$message, "should explicitly specify join keys")
  expect_equal(lints[[1]]$type, "warning")
})

test_that("lint_implicit_join accepts explicit joins with 'by' argument", {
  # Good: explicit join with by argument
  good_code1 <- 'dplyr::left_join(df1, df2, by = "id")'

  lints <- lintr::lint(text = good_code1, linters = lint_implicit_join())

  expect_length(lints, 0)
})

test_that("lint_implicit_join works with multiple join keys", {
  # Good: explicit join with multiple keys
  good_code <- 'dplyr::left_join(df1, df2, by = c("id", "name"))'

  lints <- lintr::lint(text = good_code, linters = lint_implicit_join())

  expect_length(lints, 0)
})

test_that("lint_implicit_join detects namespaced implicit joins", {
  # Bad: namespaced implicit join
  bad_code <- "dplyr::left_join(df1, df2)"

  lints <- lintr::lint(text = bad_code, linters = lint_implicit_join())

  expect_length(lints, 1)
  expect_match(lints[[1]]$message, "dplyr::left_join")
})

test_that("lint_implicit_join works with all join types", {
  join_types <- c(
    "left_join",
    "right_join",
    "inner_join",
    "full_join",
    "semi_join",
    "anti_join",
    "nest_join"
  )

  for (join_type in join_types) {
    bad_code <- sprintf("dplyr::%s(df1, df2)", join_type)

    lints <- lintr::lint(text = bad_code, linters = lint_implicit_join())

    expect_equal(
      length(lints),
      1,
      label = sprintf("Failed to detect implicit dplyr::%s", join_type)
    )
    expect_match(
      lints[[1]]$message,
      join_type,
      label = sprintf("Message should mention %s", join_type)
    )
  }
})

test_that("lint_implicit_join works with piped syntax (both |> and %>%)", {
  # With native pipe
  bad_code <- "df1 |> dplyr::left_join(df2) |> dplyr::inner_join(df3)"
  good_code <- 'df1 |> dplyr::left_join(df2, by = "id")'

  lints_bad <- lintr::lint(text = bad_code, linters = lint_implicit_join())
  lints_good <- lintr::lint(text = good_code, linters = lint_implicit_join())

  expect_length(lints_bad, 2)
  expect_length(lints_good, 0)

  # # With magrittr  pipe
  lints_magrittr <- lintr::lint(
    text = "df1 %>% dplyr::left_join(df2)",
    linters = lint_implicit_join()
  )
  expect_length(lints_magrittr, 1)
})

test_that("lint_implicit_join accepts named vector in 'by'", {
  # Good: join with named vector (different column names)
  good_code <- 'dplyr::left_join(df1, df2, by = c("id" = "user_id"))'

  lints <- lintr::lint(text = good_code, linters = lint_implicit_join())

  expect_length(lints, 0)
})

test_that("lint_implicit_join handles multiline joins", {
  # Bad: multiline implicit join
  bad_code <- "
    dplyr::left_join(
      df1,
      df2
    )
  "

  lints <- lintr::lint(text = bad_code, linters = lint_implicit_join())

  expect_length(lints, 1)

  # Good: multiline explicit join
  good_code <- '
    dplyr::left_join(
      df1,
      df2,
      by = "id"
    )
  '

  lints <- lintr::lint(text = good_code, linters = lint_implicit_join())

  expect_length(lints, 0)
})

test_that("lint_implicit_join handles joins with other arguments", {
  # Bad: has suffix argument but no 'by'
  bad_code <- 'dplyr::left_join(df1, df2, suffix = c(".x", ".y"))'

  lints <- lintr::lint(text = bad_code, linters = lint_implicit_join())

  expect_length(lints, 1)

  # Good: has both 'by' and other arguments
  good_code <- 'dplyr::left_join(df1, df2, by = "id", suffix = c(".x", ".y"))'

  lints <- lintr::lint(text = good_code, linters = lint_implicit_join())

  expect_length(lints, 0)
})

test_that("lint_implicit_join handles complex piped workflows", {
  complex_code <- '
    result <- df1 |>
      dplyr::left_join(df2, by = "id") |>
      dplyr::inner_join(df3) |>
      dplyr::anti_join(df4)
  '

  lints <- lintr::lint(text = complex_code, linters = lint_implicit_join())

  # Should detect 2 implicit joins
  expect_length(lints, 2)
})

test_that("lint_implicit_join doesn't flag non-join functions", {
  # Code with other functions that shouldn't be flagged
  code <- "
    result <- df1 |>
      dplyr::mutate(new_col = old_col * 2) |>
      dplyr::filter(value > 0) |>
      dplyr::select(id, name)
  "

  lints <- lintr::lint(text = code, linters = lint_implicit_join())

  expect_length(lints, 0)
})

test_that("lint_implicit_join handles 'by' with variable", {
  # Using a variable for 'by' should still be considered explicit
  good_code <- '
    join_cols <- c("id", "name")
    dplyr::left_join(df1, df2, by = join_cols)
  '

  lints <- lintr::lint(text = good_code, linters = lint_implicit_join())

  expect_length(lints, 0)
})

test_that("lint_implicit_join handles join_by() syntax (dplyr 1.1.0+)", {
  # dplyr 1.1.0 introduced join_by() helper
  good_code <- "dplyr::left_join(df1, df2, by = dplyr::join_by(id))"

  lints <- lintr::lint(text = good_code, linters = lint_implicit_join())

  expect_length(lints, 0)
})

test_that("lint_implicit_join reports correct line numbers", {
  multiline_code <- "
library(dplyr)

result1 <- dplyr::left_join(df1, df2)

result2 <- dplyr::left_join(df1, df2, by = 'id')

result3 <- dplyr::inner_join(df1, df2)
  "

  lints <- lintr::lint(text = multiline_code, linters = lint_implicit_join())

  expect_length(lints, 2)
  expect_equal(lints[[1]]$line_number, 4)
  expect_equal(lints[[2]]$line_number, 8)
})

test_that("lint_implicit_join works in real file context", {
  # Create a temporary file
  temp_file <- tempfile(fileext = ".R")

  code <- '
library(dplyr)

bad_join <- dplyr::left_join(cars, mtcars)
good_join <- dplyr::left_join(cars, mtcars, by = "speed")
  '

  writeLines(code, temp_file)

  # Lint the file
  lints <- lintr::lint(temp_file, linters = lint_implicit_join())

  expect_length(lints, 1)
  expect_equal(lints[[1]]$line_number, 4)

  # Clean up
  unlink(temp_file)
})

test_that("lint_implicit_join handles by = NULL explicitly", {
  # Bad: explicitly setting by = NULL (edge case)
  bad_code <- "dplyr::left_join(df1, df2, by = NULL)"

  lints <- lintr::lint(text = bad_code, linters = lint_implicit_join())

  # This should NOT flag it because 'by' argument is present
  # (even though by = NULL has same behavior as omitting it)
  # We're only checking for presence of the argument, not its value
  expect_length(lints, 0)
})

test_that("lint_implicit_join handles realistic component", {
  component <- '
# Merge multiple datasets
demographics <- read.csv("demographics.csv")
lab_results <- read.csv("labs.csv")
vitals <- read.csv("vitals.csv")

analysis <- demographics |>
  dplyr::left_join(lab_results) |>
  dplyr::inner_join(vitals, by = "patient_id") |>
  dplyr::filter(!is.na(result))
  '
  lints <- lintr::lint(text = component, linters = lint_implicit_join())

  # Should detect 1 implicit join
  expect_length(lints, 1)
})

test_that("lint_implicit_join handles nested and complex expressions", {
  complex_code <- '
result <- base_data |>
  dplyr::left_join(
    supplemental_data |> dplyr::select(id, value),
    by = "id"
  ) |>
  dplyr::inner_join(reference_data) |>
  dplyr::semi_join(active_records |> dplyr::filter(status == "active"))
  '

  lints <- lintr::lint(text = complex_code, linters = lint_implicit_join())

  expect_length(lints, 2)
})

test_that("lint_implicit_join handles function definitions with joins", {
  function_code <- '
merge_datasets <- function(primary, secondary, reference) {
  primary |>
    dplyr::left_join(secondary) |>
    dplyr::inner_join(reference, by = "id") |>
    dplyr::semi_join(priority_records)
}
  '

  lints <- lintr::lint(text = function_code, linters = lint_implicit_join())

  expect_length(lints, 2)
})

test_that("lint_implicit_join handles mixed dplyr and base R code", {
  mixed_code <- '
# Base R merge (should not be flagged)
result1 <- merge(df1, df2, by = "id")

# dplyr implicit join (should be flagged)
result2 <- dplyr::left_join(df1, df2)

# dplyr explicit join (should not be flagged)
result3 <- dplyr::inner_join(df1, df2, by = "id")
  '

  lints <- lintr::lint(text = mixed_code, linters = lint_implicit_join())

  # Should detect only the dplyr implicit join, not the base R merge
  expect_length(lints, 1)
})

test_that("lint_implicit_join works with custom namespaces parameter", {
  # Test with tidylog namespace
  tidylog_code <- "tidylog::left_join(df1, df2)"

  # Should NOT detect when tidylog is not in namespaces
  lints_default <- lintr::lint(
    text = tidylog_code,
    linters = lint_implicit_join(namespaces = "dplyr")
  )
  expect_length(lints_default, 0)

  # Should detect when tidylog is in namespaces
  lints_tidylog <- lintr::lint(
    text = tidylog_code,
    linters = lint_implicit_join(namespaces = c("dplyr", "tidylog"))
  )
  expect_length(lints_tidylog, 1)
  expect_match(lints_tidylog[[1]]$message, "tidylog::left_join")
})

test_that("lint_implicit_join handles multiple namespaces simultaneously", {
  mixed_namespace_code <- '
result1 <- dplyr::left_join(df1, df2)
result2 <- tidylog::inner_join(df1, df2)
result3 <- dplyr::left_join(df1, df2, by = "id")
  '

  lints <- lintr::lint(
    text = mixed_namespace_code,
    linters = lint_implicit_join(namespaces = c("dplyr", "tidylog"))
  )

  # Should detect both dplyr and tidylog implicit joins
  expect_length(lints, 2)
})
