test_that("subset and domain must be supplied together", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  eval_method(
    x = component,
    method = "render",
    args = list(
      label = "new",
      .subset = list(subset = "LBTEST == 'Microcytes'")
    )
  ) |>
    expect_error(regexp = "subset.*and.*domain.*must be supplied together")

  eval_method(
    x = component,
    method = "render",
    args = list(label = "new", .subset = list(domain = "ADLB"))
  ) |>
    expect_error(regexp = "subset.*and.*domain.*must be supplied together")
})

test_that("NA_character_ is treated as absent, same as NULL", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  eval_method(
    x = component,
    method = "render",
    args = list(
      label = "new",
      .subset = list(subset = NA_character_, domain = NA_character_)
    )
  ) |>
    expect_no_condition()

  eval_method(
    x = component,
    method = "render",
    args = list(
      label = "new",
      .subset = list(subset = "LBTEST == 'Microcytes'", domain = NA_character_)
    )
  ) |>
    expect_error(regexp = "subset.*and.*domain.*must be supplied together")
})

test_that("subset aborts on non-row @type components", {
  component <- test_path("_components", "test_component.mustache") |>
    get_component()

  component$type |>
    expect_equal("column")

  eval_method(
    x = component,
    method = "render",
    args = list(
      domain = "domain",
      x1 = 1,
      x2 = 2,
      .subset = list(subset = "A == 1", domain = "domain")
    )
  ) |>
    expect_error(regexp = "@type row")
})

test_that("non-subsetted render() is completely unaffected", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  rendered <- component$render(label = "new")

  rendered$code |>
    expect_equal(
      c(
        "new_rows <- ADLB |>",
        "  dplyr::filter(LBTEST == \"Microcytes\") |>",
        "  dplyr::mutate(LBTEST = \"new\")",
        "",
        "ADLB <- rbind(ADLB, new_rows)"
      )
    )
})

test_that("render() with a whisker `domain` param is unaffected when .subset is omitted", {
  component <- test_path("_components", "ady_local.mustache") |>
    get_component()

  rendered <- component$render(
    domain = "domain",
    date = "date_var",
    variable = "out_var"
  )

  rendered$depends |>
    expect_equal(
      data.frame(domain = rep("domain", 2), column = c("date_var", "TRTSDT"))
    )
})

test_that("subset: adds rows", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  rendered <- component$render(
    label = "Microcytes (new)",
    .subset = list(subset = "STUDYID == 'S1'", domain = "ADLB")
  )

  ADLB <- data.frame(
    USUBJID = c("1", "2", "3"),
    STUDYID = c("S1", "S1", "S2"),
    LBTEST = "Microcytes",
    stringsAsFactors = FALSE
  )

  rendered$eval(envir = environment())

  nrow(ADLB) |>
    expect_equal(5)

  sum(ADLB$LBTEST == "Microcytes (new)") |>
    expect_equal(2)

  sum(ADLB$STUDYID == "S2") |>
    expect_equal(1)
})

test_that("subset: modifies rows in place", {
  component <- test_path("_components", "subset_modify_rows.mustache") |>
    get_component()

  rendered <- component$render(
    .subset = list(subset = "STUDYID == 'S1'", domain = "ADLB")
  )

  ADLB <- data.frame(
    USUBJID = c("1", "2", "3"),
    STUDYID = c("S1", "S1", "S2"),
    LBTEST = "Microcytes",
    stringsAsFactors = FALSE
  )

  rendered$eval(envir = environment())

  nrow(ADLB) |>
    expect_equal(3)

  ADLB$LBTEST[ADLB$STUDYID == "S1"] |>
    expect_equal(c("Microcytes (modified)", "Microcytes (modified)"))

  ADLB$LBTEST[ADLB$STUDYID == "S2"] |>
    expect_equal("Microcytes")
})

test_that("subset: drops rows", {
  component <- test_path("_components", "subset_drop_rows.mustache") |>
    get_component()

  rendered <- component$render(
    .subset = list(subset = "STUDYID == 'S1'", domain = "ADLB")
  )

  ADLB <- data.frame(
    USUBJID = c("1", "2", "3"),
    STUDYID = c("S1", "S1", "S2"),
    LBTEST = c("Microcytes", "Macrocytes", "Microcytes"),
    stringsAsFactors = FALSE
  )

  rendered$eval(envir = environment())

  nrow(ADLB) |>
    expect_equal(2)

  sort(ADLB$USUBJID) |>
    expect_equal(c("2", "3"))
})

test_that("subset: empty subset leaves data unchanged, no error", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  rendered <- component$render(
    label = "Microcytes (new)",
    .subset = list(subset = "STUDYID == 'NOMATCH'", domain = "ADLB")
  )

  ADLB <- data.frame(
    USUBJID = c("1", "2", "3"),
    STUDYID = c("S1", "S1", "S2"),
    LBTEST = "Microcytes",
    stringsAsFactors = FALSE
  )
  original <- ADLB

  rendered$eval(envir = environment()) |>
    expect_no_condition()

  ADLB |>
    expect_equal(original)
})

test_that("subset: works on custom .R components", {
  component <- test_path("_components", "subset_add_rows.R") |>
    get_component()

  rendered <- component$render(
    .subset = list(subset = "STUDYID == 'S1'", domain = "ADLB")
  )

  ADLB <- data.frame(
    USUBJID = c("1", "2", "3"),
    STUDYID = c("S1", "S1", "S2"),
    LBTEST = "Microcytes",
    stringsAsFactors = FALSE
  )

  rendered$eval(envir = environment())

  nrow(ADLB) |>
    expect_equal(5)
})

test_that("subset: new column under subset raises the natural rbind error", {
  component <- test_path("_components", "subset_new_column.mustache") |>
    get_component()

  rendered <- component$render(
    .subset = list(subset = "STUDYID == 'S1'", domain = "ADLB")
  )

  ADLB <- data.frame(
    USUBJID = c("1", "2", "3"),
    STUDYID = c("S1", "S1", "S2"),
    stringsAsFactors = FALSE
  )

  rendered$eval(envir = environment()) |>
    expect_error(regexp = "numbers of columns")
})

test_that("subset wrapping does not affect @depends/@outputs/@type parsing", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  unsubsetted <- component$render(label = "new")
  subsetted <- component$render(
    label = "new",
    .subset = list(subset = "STUDYID == 'S1'", domain = "ADLB")
  )

  subsetted$depends |>
    expect_equal(unsubsetted$depends)

  subsetted$outputs |>
    expect_equal(unsubsetted$outputs)

  subsetted$type |>
    expect_equal(unsubsetted$type)
})

test_that("get_rendered_component() passes .subset through alongside params", {
  rendered <- get_rendered_component(
    component = test_path("_components", "subset_add_rows.mustache"),
    params = list(label = "Microcytes (new)"),
    .subset = list(subset = "STUDYID == 'S1'", domain = "ADLB")
  )

  rendered |>
    expect_s3_class("mighty_component_rendered")

  ADLB <- data.frame(
    USUBJID = c("1", "2", "3"),
    STUDYID = c("S1", "S1", "S2"),
    LBTEST = "Microcytes",
    stringsAsFactors = FALSE
  )

  rendered$eval(envir = environment())

  nrow(ADLB) |>
    expect_equal(5)
})
