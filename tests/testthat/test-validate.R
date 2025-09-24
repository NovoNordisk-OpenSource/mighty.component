test_that("validate_template accepts valid templates", {
  valid_template <- c(
    "#' @title Test Component",
    "#' @description",
    "#' Test description for component",
    "#'",
    "#' @param variable Name of variable to create",
    "#' @type derivation",
    "#' @depends .self USUBJID",
    "#' @outputs {{variable}}",
    "#' @code",
    ".self <- .self |>",
    "  dplyr::mutate(",
    "    {{variable}} = 'test'",
    "  )"
  )

  expect_no_error(validate_template(valid_template))
})

test_that("validate_template rejects non-character input", {
  expect_error(
    validate_template(123),
    "must be a character vector"
  )

  expect_error(
    validate_template(list("test")),
    "must be a character vector"
  )
})

test_that("validate_template rejects empty templates", {
  expect_error(
    validate_template(character(0)),
    "must not be empty"
  )
})

test_that("validate_template requires @title tag", {
  template_no_title <- c(
    "#' @description Test description",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_error(
    validate_template(template_no_title, id = "template_no_title"),
    "Missing required tag.*@title"
  )
})

test_that("validate_template requires @description tag", {
  template_no_desc <- c(
    "#' @title Test Component",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_error(
    validate_template(template_no_desc),
    "Missing required tag.*@description"
  )
})

test_that("validate_template requires @type tag", {
  template_no_type <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @code",
    ".self"
  )

  expect_error(
    validate_template(template_no_type),
    "Missing required tag.*@type"
  )
})

test_that("validate_template requires @code tag", {
  template_no_code <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @type derivation"
  )

  expect_error(
    validate_template(template_no_code),
    "Missing required tag.*@code"
  )
})

test_that("validate_template rejects empty @title", {
  template_empty_title <- c(
    "#' @title",
    "#' @description Test description",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_error(
    validate_template(template_empty_title),
    "@title.*cannot be empty"
  )
})

test_that("validate_template rejects empty @description", {
  template_empty_desc <- c(
    "#' @title Test Component",
    "#' @description",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_error(
    validate_template(template_empty_desc),
    "@description.*cannot be empty"
  )
})

test_that("validate_template validates @type against valid types", {
  template_invalid_type <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @type invalid_type",
    "#' @code",
    ".self"
  )

  expect_error(
    validate_template(template_invalid_type),
    "@type must be one of"
  )
})

test_that("validate_template accepts valid @type values", {
  valid_types <- c("predecessor", "derivation", "row")

  for (type in valid_types) {
    template <- c(
      "#' @title Test Component",
      "#' @description Test description",
      paste("#' @type", type),
      "#' @code",
      ".self"
    )

    expect_no_error(validate_template(template))
  }
})

test_that("validate_template requires non-empty @code section", {
  template_empty_code <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @type derivation",
    "#' @code"
  )

  expect_error(
    validate_template(template_empty_code),
    "@code.*section cannot be empty"
  )

  template_whitespace_code <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @type derivation",
    "#' @code",
    "   ",
    "  "
  )

  expect_error(
    validate_template(template_whitespace_code),
    "@code.*section cannot be empty"
  )
})

test_that("@param missing description", {
  # Missing description
  template_bad_param <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @param variable",
    "#' @type derivation",
    "#' @code",
    ".self"
  )
  expect_error(
    mighty_component$new(template_bad_param, "A"),
    "Invalid.*@param.*Must have both name and description"
  )
})

test_that("multi-line @param description works", {
  # Missing description
  template_bad_param <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @param variable long multi line description that
    #' goes",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_no_error(
    mighty_component$new(template_bad_param, "A")
  )
})

test_that("@depends tags needs both domain and column", {
  # Missing column
  template_bad_depends <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @depends .self",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_error(
    validate_template(template_bad_depends),
    "Invalid.*@depends.*Must have both domain and column"
  )

  # Valid depends format
  template_valid_depends <- c(
    "#' @title Test Component",
    "#' @description Test description",
    "#' @depends .self USUBJID",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_no_error(validate_template(template_valid_depends))
})

test_that("validate_template validates @outputs tags", {
  template_valid_output <- c(
    "#' @title Test Component",
    "#' @description Test multiple",
    "#' description",
    "#' @outputs NEWVAR",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_no_error(validate_template(template_valid_output))
})

test_that("duplicate tags", {
  template_valid_output <- c(
    "#' @title Test Component",
    "#' @title Test Component",
    "#' @description Test desc",
    "#' @outputs NEWVAR",
    "#' @type derivation",
    "#' @code",
    ".self"
  )

  expect_error(
    validate_template(template_valid_output),
    "Multiple or no matches found for tag: '@title'"
  )
})

test_that("validate_template handles complex valid template", {
  complex_template <- c(
    "#' @title Complex Component",
    "#' @description",
    "#' This is a complex component that does multiple things",
    "#' across multiple lines of description.",
    "#'",
    "#' @param variable Name of output variable",
    "#' @param input_var Name of input variable",
    "#' @type derivation",
    "#' @depends .self {{input_var}}",
    "#' @depends .self USUBJID",
    "#' @outputs {{variable}}",
    "#' @outputs var_B",
    "#' @code",
    ".self <- .self |>",
    "  dplyr::mutate(",
    "    {{variable}} = case_when(",
    "      {{input_var}} > 0 ~ 'positive',",
    "      {{input_var}} < 0 ~ 'negative',",
    "      TRUE ~ 'zero'",
    "    )",
    "  )"
  )

  expect_no_error(validate_template(complex_template))
})

test_that("validate_template rejects empty outputs tag", {
  empty_outputs <- c(
    "#' @title empty code",
    "#' @description",
    "#' description",
    "#'",
    "#' @type derivation",
    "#' @depends .self USUBJID",
    "#' @outputs ",
    "#' @code",
    ".self <- .self |>",
    "  dplyr::mutate(",
    "    {{variable}} = case_when(",
    "      {{input_var}} > 0 ~ 'positive',",
    "      {{input_var}} < 0 ~ 'negative',",
    "      TRUE ~ 'zero'",
    "    )",
    "  )"
  )

  expect_error(validate_template(empty_outputs), "outputs` tag cannot be empty")
})

test_that("validate_template gives specific error for duplicate @description tags", {
  # This test demonstrates the error handling consistency issue
  template_duplicate_description <- c(
    "#' @title Test Component",
    "#' @description First description",
    "#' @description Second description", # Duplicate description
    "#' @type derivation",
    "#' @depends .self USUBJID",
    "#' @outputs NEWVAR",
    "#' @code",
    ".self"
  )

  # Should get specific error about duplicate tags, not generic "cannot be empty" error
  expect_error(
    validate_template(template_duplicate_description),
    "Multiple or no matches found for tag: '@description'"
  )
})

test_that("Error when parameters required by @code, @depends, or @outputs is not supplied by @param tags", {
  template <- c(
    "#' @title Mistake in parameters",
    "#' @description This is a test component with missing parameters.",
    "#' @param variable name",
    "#' @type derivation",
    "#' @depends .self {{ date }}",
    "#' @depends .self TRTSDT",
    "#' @outputs {{ variable }}",
    "#' @code",
    "print('hello')"
  )

  path <- withr::local_tempfile(fileext = ".mustache")
  writeLines(template, path)
  
  expect_error(get_rendered_component(component = path, params = list(variable = "out_var")), "")
})
