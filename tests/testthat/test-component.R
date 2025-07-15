test_that("get_rendered_component, custom code component as function multiple depends", {
  # ARRANGE -------------------------------------------------------------------
  tmp_file <- withr::local_tempdir() |>
    file.path("ady.R")
  # Custom code component as function
  c(
    "
    #' Analysis relative day
#' @description
#' Derives the relative day compared to the treatment start date.
#' @type derivation
#' @depends .self A
#' @depends lb A
#' @outputs B
    hello <- function(a){
    'hello' |> 
      print()
    if(a){
    NULL
    } else{
      a <- 1
      }
      return(.self)

  }"
  ) |>
    writeLines(con = tmp_file)
  # ACT ---------------------------
  x <- get_rendered_component(tmp_file)

  # ASSERT
  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot_value(x$code, style = "json2")
  expect_equal(x$type, "derivation")
  expect_equal(
    x$depends,
    data.frame(domain = c(".self", "lb"), column = c("A", "A"))
  )
  expect_equal(x$outputs, "B")
})


test_that("get_rendered_component custom local mustache template with params", {
  # ARRANGE -------------------------------------------------------------------
  tmp_file <- withr::local_tempdir() |>
    file.path("ady_local.mustache")
  # Create a mock mustache template
  "
    #' Analysis relative day
#' Analysis relative day
#' @description
#' Derives the relative day compared to the treatment start date.
#'
#' @param variable `character` Name of new variable to create
#' @param date `character` Name of date variable to use
#' @type derivation
#' @depends .self {{ date }}
#' @depends .self TRTSDT
#' @outputs {{ variable }}

.self <- .self |>
  dplyr::mutate(
    {{ variable }} = admiral::compute_duration(
      start_date = TRTSDT,
      end_date = {{ date }},
      in_unit = '
  days
  ',
      out_unit = '
  days
  ',
      add_one = TRUE
    )
  )
" |>
    writeLines(con = tmp_file)
  # ACT ---------------------------
  x <- get_rendered_component(
    tmp_file,
    params = list(
      date = "date_var",
      variable = "out_var"
    )
  )

  # ASSERT
  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot_value(x$code, style = "json2")
  expect_equal(x$type, "derivation")
  expect_equal(
    x$depends,
    data.frame(domain = rep(".self", 2), column = c("date_var", "TRTSDT"))
  )
  expect_equal(x$outputs, "out_var")
})


test_that("get_rendered_component returns rendered STANDARD code component with valid inputs", {
  # ARRANGE -------------------------------------------------------------------
  # ACT ---------------------------
  x <- get_rendered_component(
    "ady",
    params = list(
      date = "date_var",
      variable = "out_var"
    )
  )

  # ASSERT ---------------------------
  expect_s3_class(x, "mighty_component_rendered")
  expect_snapshot_value(x$code, style = "json2")
  expect_equal(x$type, "derivation")
  expect_equal(
    x$depends,
    data.frame(domain = rep(".self", 2), column = c("date_var", "TRTSDT"))
  )
  expect_equal(x$outputs, "out_var")
})
