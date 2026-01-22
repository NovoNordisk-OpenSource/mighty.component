test_that("validate_implicit_join detects implicit joins (without namespace)", {
  bad_code1 <- "left_join(df1, df2)"

  expect_error(
    validate_implicit_join(bad_code1),
    "Implicit.*join.*detected"
  )
})

test_that("validate_implicit_join accepts explicit joins with 'by' argument", {
  good_code1 <- 'dplyr::left_join(df1, df2, by = "id")'

  expect_no_error(validate_implicit_join(good_code1))
})

test_that("validate_implicit_join works with multiple join keys", {
  good_code <- 'dplyr::left_join(df1, df2, by = c("id", "name"))'

  expect_no_error(validate_implicit_join(good_code))
})

test_that("validate_implicit_join detects namespaced implicit joins", {
  bad_code <- "dplyr::left_join(df1, df2)"

  expect_error(
    validate_implicit_join(bad_code),
    "dplyr::left_join"
  )
})

test_that("validate_implicit_join works with all join types", {
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

    expect_error(
      validate_implicit_join(bad_code),
      join_type,
      info = sprintf("Should detect implicit dplyr::%s", join_type)
    )
  }
})

test_that("validate_implicit_join works with piped syntax (both |> and %>%)", {
  bad_code <- "df1 |> dplyr::left_join(df2) |> dplyr::inner_join(df3)"
  expect_error(
    validate_implicit_join(bad_code),
    "Implicit.*join"
  )

  good_code <- 'df1 |> dplyr::left_join(df2, by = "id")'
  expect_no_error(validate_implicit_join(good_code))

  bad_magrittr <- "df1 %>% dplyr::left_join(df2)"
  expect_error(
    validate_implicit_join(bad_magrittr),
    "Implicit.*join"
  )
})

test_that("validate_implicit_join accepts named vector in 'by'", {
  good_code <- 'dplyr::left_join(df1, df2, by = c("id" = "user_id"))'

  expect_no_error(validate_implicit_join(good_code))
})

test_that("validate_implicit_join handles multiline joins", {
  bad_code <- "
    dplyr::left_join(
      df1,
      df2
    )
  "

  expect_error(
    validate_implicit_join(bad_code),
    "Implicit.*join"
  )

  good_code <- '
    dplyr::left_join(
      df1,
      df2,
      by = "id"
    )
  '

  expect_no_error(validate_implicit_join(good_code))
})

test_that("validate_implicit_join handles joins with other arguments", {
  bad_code <- 'dplyr::left_join(df1, df2, suffix = c(".x", ".y"))'

  expect_error(
    validate_implicit_join(bad_code),
    "Implicit.*join"
  )

  good_code <- 'dplyr::left_join(df1, df2, by = "id", suffix = c(".x", ".y"))'

  expect_no_error(validate_implicit_join(good_code))
})

test_that("validate_implicit_join handles complex piped workflows", {
  complex_code <- '
    result <- df1 |>
      dplyr::left_join(df2, by = "id") |>
      dplyr::inner_join(df3) |>
      dplyr::anti_join(df4)
  '

  expect_error(
    validate_implicit_join(complex_code),
    "Implicit.*join"
  )
})

test_that("validate_implicit_join doesn't flag non-join functions", {
  code <- "
    result <- df1 |>
      dplyr::mutate(new_col = old_col * 2) |>
      dplyr::filter(value > 0) |>
      dplyr::select(id, name)
  "

  expect_no_error(validate_implicit_join(code))
})

test_that("validate_implicit_join handles 'by' with variable", {
  good_code <- '
    join_cols <- c("id", "name")
    dplyr::left_join(df1, df2, by = join_cols)
  '

  expect_no_error(validate_implicit_join(good_code))
})

test_that("validate_implicit_join handles join_by() syntax (dplyr 1.1.0+)", {
  good_code <- "dplyr::left_join(df1, df2, by = dplyr::join_by(id))"

  expect_no_error(validate_implicit_join(good_code))
})

test_that("validate_implicit_join reports correct line numbers in error", {
  multiline_code <- "
library(dplyr)

result1 <- dplyr::left_join(df1, df2)

result2 <- dplyr::left_join(df1, df2, by = 'id')

result3 <- dplyr::inner_join(df1, df2)
  "

  error_obj <- tryCatch(
    validate_implicit_join(multiline_code),
    error = function(e) e
  )

  expect_s3_class(error_obj, "error")
  expect_match(conditionMessage(error_obj), "Line [0-9]+")
})

test_that("validate_implicit_join handles by = NULL explicitly", {
  code_with_null <- "dplyr::left_join(df1, df2, by = NULL)"

  expect_no_error(validate_implicit_join(code_with_null))
})

test_that("validate_implicit_join handles nested and complex expressions", {
  complex_code <- '
result <- base_data |>
  dplyr::left_join(
    supplemental_data |> dplyr::select(id, value),
    by = "id"
  ) |>
  dplyr::inner_join(reference_data) |>
  dplyr::semi_join(active_records |> dplyr::filter(status == "active"))
  '

  expect_error(
    validate_implicit_join(complex_code),
    "Implicit.*join"
  )
})

test_that("validate_implicit_join handles function definitions with joins", {
  function_code <- '
merge_datasets <- function(primary, secondary, reference) {
  primary |>
    dplyr::left_join(secondary) |>
    dplyr::inner_join(reference, by = "id") |>
    dplyr::semi_join(priority_records)
}
  '

  expect_error(
    validate_implicit_join(function_code),
    "Implicit.*join"
  )
})

test_that("validate_implicit_join handles mixed dplyr and base R code", {
  mixed_code <- '
result1 <- merge(df1, df2, by = "id")

result2 <- dplyr::left_join(df1, df2)

result3 <- dplyr::inner_join(df1, df2, by = "id")
  '

  expect_error(
    validate_implicit_join(mixed_code),
    "Implicit.*join"
  )
})

test_that("validate_implicit_join works with custom namespaces parameter", {
  tidylog_code <- "tidylog::left_join(df1, df2)"

  expect_no_error(
    validate_implicit_join(tidylog_code, namespaces = "dplyr")
  )

  expect_error(
    validate_implicit_join(tidylog_code, namespaces = c("dplyr", "tidylog")),
    "tidylog::left_join"
  )
})

test_that("validate_implicit_join handles multiple namespaces simultaneously", {
  mixed_namespace_code <- '
result1 <- dplyr::left_join(df1, df2)
result2 <- tidylog::inner_join(df1, df2)
result3 <- dplyr::left_join(df1, df2, by = "id")
  '

  expect_error(
    validate_implicit_join(
      mixed_namespace_code,
      namespaces = c("dplyr", "tidylog")
    ),
    "Implicit.*join"
  )
})
