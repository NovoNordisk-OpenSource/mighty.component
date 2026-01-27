test_that("validate_component_code (implicit joins) detects implicit joins (without namespace)", {
  bad_code1 <- "left_join(df1, df2)"

  expect_error(
    validate_component_code(bad_code1),
    "Implicit.*join.*detected"
  )
})

test_that("validate_component_code (implicit joins) accepts explicit joins with 'by' argument", {
  good_code1 <- 'dplyr::left_join(df1, df2, by = "id")'

  expect_no_error(validate_component_code(good_code1))
})

test_that("validate_component_code (implicit joins) works with multiple join keys", {
  good_code <- 'dplyr::left_join(df1, df2, by = c("id", "name"))'

  expect_no_error(validate_component_code(good_code))
})

test_that("validate_component_code (implicit joins) detects namespaced implicit joins", {
  bad_code <- "dplyr::left_join(df1, df2)"

  expect_error(
    validate_component_code(bad_code),
    "dplyr::left_join"
  )
})

test_that("validate_component_code (implicit joins) works with all join types", {
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
      validate_component_code(bad_code),
      join_type,
      info = sprintf("Should detect implicit dplyr::%s", join_type)
    )
  }
})

test_that("validate_component_code (implicit joins) works with piped syntax (both |> and %>%)", {
  bad_code <- "df1 |> dplyr::left_join(df2) |> dplyr::inner_join(df3)"
  expect_error(
    validate_component_code(bad_code),
    "Implicit.*join"
  )

  good_code <- 'df1 |> dplyr::left_join(df2, by = "id")'
  expect_no_error(validate_component_code(good_code))

  bad_magrittr <- "df1 %>% dplyr::left_join(df2)"
  expect_error(
    validate_component_code(bad_magrittr),
    "Implicit.*join"
  )
})

test_that("validate_component_code (implicit joins) accepts named vector in 'by'", {
  good_code <- 'dplyr::left_join(df1, df2, by = c("id" = "user_id"))'

  expect_no_error(validate_component_code(good_code))
})

test_that("validate_component_code (implicit joins) handles multiline joins", {
  bad_code <- "
    dplyr::left_join(
      df1,
      df2
    )
  "

  expect_error(
    validate_component_code(bad_code),
    "Implicit.*join"
  )

  good_code <- '
    dplyr::left_join(
      df1,
      df2,
      by = "id"
    )
  '

  expect_no_error(validate_component_code(good_code))
})

test_that("validate_component_code (implicit joins) handles joins with other arguments", {
  bad_code <- 'dplyr::left_join(df1, df2, suffix = c(".x", ".y"))'

  expect_error(
    validate_component_code(bad_code),
    "Implicit.*join"
  )

  good_code <- 'dplyr::left_join(df1, df2, by = "id", suffix = c(".x", ".y"))'

  expect_no_error(validate_component_code(good_code))
})

test_that("validate_component_code (implicit joins) catches multiple implicit joins in simple code", {
  code_with_two_errors <- "
result1 <- dplyr::left_join(df1, df2)
result2 <- dplyr::inner_join(df3, df4)
  "

  err <- expect_error(
    validate_component_code(code_with_two_errors),
    "Implicit.*join"
  )
  expect_match(conditionMessage(err), "left_join")
  expect_match(conditionMessage(err), "inner_join")
})

test_that("validate_component_code (implicit joins) handles complex piped workflows", {
  complex_code <- '
    result <- df1 |>
      dplyr::left_join(df2, by = "id") |>
      dplyr::inner_join(df3) |>
      dplyr::anti_join(df4)
  '

  expect_error(
    validate_component_code(complex_code),
    "Implicit.*join"
  )
})

test_that("validate_component_code (implicit joins) doesn't flag non-join functions", {
  code <- "
    result <- df1 |>
      dplyr::mutate(new_col = old_col * 2) |>
      dplyr::filter(value > 0) |>
      dplyr::select(id, name)
  "

  expect_no_error(validate_component_code(code))
})

test_that("validate_component_code (implicit joins) handles 'by' with variable", {
  good_code <- '
    join_cols <- c("id", "name")
    dplyr::left_join(df1, df2, by = join_cols)
  '

  expect_no_error(validate_component_code(good_code))
})

test_that("validate_component_code (implicit joins) handles join_by() syntax (dplyr 1.1.0+)", {
  good_code <- "dplyr::left_join(df1, df2, by = dplyr::join_by(id))"

  expect_no_error(validate_component_code(good_code))
})

test_that("validate_component_code (implicit joins) reports correct line numbers in error", {
  multiline_code <- "
library(dplyr)

result1 <- dplyr::left_join(df1, df2)

result2 <- dplyr::left_join(df1, df2, by = 'id')

result3 <- dplyr::inner_join(df1, df2)
  "

  err <- expect_error(
    validate_component_code(multiline_code),
    "Implicit.*join"
  )

  error_message <- conditionMessage(err)
  expect_match(error_message, "Line 4")
  expect_match(error_message, "Line 8")
})

test_that("validate_component_code (implicit joins) handles by = NULL explicitly", {
  code_with_null <- "dplyr::left_join(df1, df2, by = NULL)"

  expect_no_error(validate_component_code(code_with_null))
})

test_that("validate_component_code (implicit joins) handles nested and complex expressions", {
  complex_code <- '
result <- base_data |>
  dplyr::left_join(
    supplemental_data |> dplyr::select(id, value),
    by = "id"
  ) |>
  dplyr::inner_join(reference_data) |>
  dplyr::semi_join(active_records |> dplyr::filter(status == "active"))
  '

  err <- expect_error(
    validate_component_code(complex_code),
    "Implicit.*join"
  )

  # Should flag both inner_join and semi_join (but not left_join which has 'by')
  expect_match(conditionMessage(err), "inner_join")
  expect_match(conditionMessage(err), "semi_join")
})

test_that("validate_component_code (implicit joins) handles function definitions with joins", {
  function_code <- '
merge_datasets <- function(primary, secondary, reference) {
  primary |>
    dplyr::left_join(secondary) |>
    dplyr::inner_join(reference, by = "id") |>
    dplyr::semi_join(priority_records)
}
  '

  expect_error(
    validate_component_code(function_code),
    "Implicit.*join"
  )
})

test_that("validate_component_code (implicit joins) handles mixed dplyr and base R code", {
  mixed_code <- '
result1 <- merge(df1, df2, by = "id")

result2 <- dplyr::left_join(df1, df2)

result3 <- dplyr::inner_join(df1, df2, by = "id")
  '

  expect_error(
    validate_component_code(mixed_code),
    "Implicit.*join"
  )
})

test_that("validate_component_code (implicit joins) handles multiple namespaces simultaneously", {
  mixed_namespace_code <- '
result1 <- dplyr::left_join(df1, df2)
result2 <- tidylog::inner_join(df1, df2)
result3 <- dplyr::left_join(df1, df2, by = "id")
  '

  expect_error(
    validate_component_code(mixed_namespace_code),
    "Implicit.*join"
  )
})
