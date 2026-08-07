test_that("marker in domain expands to bare identifier in @depends/@outputs/@type", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  rendered <- component$render(
    domain = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")",
    label = "new"
  )

  rendered$depends |>
    expect_equal(data.frame(domain = "ADLB", column = "LBTEST"))

  rendered$outputs |>
    expect_equal("LBTEST")

  rendered$type |>
    expect_equal("row")
})

test_that("marker in domain wraps rendered code with prologue/epilogue", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  rendered <- component$render(
    domain = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")",
    label = "new"
  )

  rendered$code |>
    expect_equal(
      c(
        ".mighty_subset_keep <- ADLB[!with(ADLB, STUDYID == 'S1'), ]",
        "ADLB             <- ADLB[with(ADLB, STUDYID == 'S1'), ]",
        "new_rows <- ADLB |>",
        "  dplyr::filter(LBTEST == \"Microcytes\") |>",
        "  dplyr::mutate(LBTEST = \"new\")",
        "",
        "ADLB <- rbind(ADLB, new_rows)",
        "ADLB <- rbind(.mighty_subset_keep, ADLB)"
      )
    )
})

test_that("subset marker: adds rows only within the subset, preserves rows outside it", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  rendered <- component$render(
    domain = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")",
    label = "Microcytes (new)"
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

test_that("subset marker: modifies matching rows in place, leaves others untouched", {
  component <- test_path("_components", "subset_modify_rows.mustache") |>
    get_component()

  rendered <- component$render(
    domain = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")"
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

test_that("subset marker: drops matching rows, leaves others untouched", {
  component <- test_path("_components", "subset_drop_rows.mustache") |>
    get_component()

  rendered <- component$render(
    domain = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")"
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

test_that("subset marker: new column under subset raises the natural rbind error", {
  component <- test_path("_components", "subset_new_column.mustache") |>
    get_component()

  rendered <- component$render(
    domain = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")"
  )

  ADLB <- data.frame(
    USUBJID = c("1", "2", "3"),
    STUDYID = c("S1", "S1", "S2"),
    stringsAsFactors = FALSE
  )

  rendered$eval(envir = environment()) |>
    expect_error(regexp = "numbers of columns")
})

test_that("ordinary (non-marker) domain value renders unchanged", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  rendered <- component$render(domain = "ADLB", label = "new")

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

  rendered$depends |>
    expect_equal(data.frame(domain = "ADLB", column = "LBTEST"))
})

test_that("marker-shaped domain on a non-row @type component errors clearly", {
  component <- test_path("_components", "test_component.mustache") |>
    get_component()

  component$type |>
    expect_equal("column")

  eval_method(
    x = component,
    method = "render",
    args = list(
      domain = ".mighty_subset(domain, \"A == 1\")",
      x1 = 1,
      x2 = 2
    )
  ) |>
    expect_error(regexp = "@type row")
})

test_that("a call-shaped but non-marker domain value falls through unaffected", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  rendered <- component$render(
    domain = "some_fn(ADLB,1)",
    label = "new"
  )

  rendered$depends |>
    expect_equal(data.frame(domain = "some_fn(ADLB,1)", column = "LBTEST"))

  grepl(pattern = "mighty_subset_keep", x = rendered$code) |>
    any() |>
    expect_false()
})

test_that("marker is detected regardless of which parameter carries it", {
  component <- test_path("_components", "subset_named_dataset.mustache") |>
    get_component()

  rendered <- component$render(
    dataset = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")",
    label = "Microcytes (new)"
  )

  rendered$depends |>
    expect_equal(data.frame(domain = "ADLB", column = "LBTEST"))

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
})

test_that("more than one parameter looking like a marker errors clearly", {
  component <- test_path("_components", "subset_add_rows.mustache") |>
    get_component()

  eval_method(
    x = component,
    method = "render",
    args = list(
      domain = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")",
      label = ".mighty_subset(ADAE, \"STUDYID == 'S1'\")"
    )
  ) |>
    expect_error(regexp = "Multiple parameters")
})

test_that("get_rendered_component() passes marker domain through", {
  rendered <- get_rendered_component(
    component = test_path("_components", "subset_add_rows.mustache"),
    params = list(
      domain = ".mighty_subset(ADLB, \"STUDYID == 'S1'\")",
      label = "Microcytes (new)"
    )
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
