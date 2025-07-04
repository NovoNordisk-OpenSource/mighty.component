test_that("predecessor", {
  predecessor <- get_rendered_standard(
    "predecessor",
    list(source = "pharmaverseadam::adsl", by = "USUBJID", variable = "ACTARM")
  )

  cat(predecessor$template, sep = "\n") |>
    expect_snapshot()

  advs <- pharmaverseadam::advs |>
    dplyr::select(USUBJID, PARAMCD, AVAL, ACTARM)

  predecessor$test(
    input = advs |> dplyr::select(-ACTARM),
    expected = advs
  )
})

test_that("assign", {
  assign <- get_rendered_standard("assign", list(variable = "y", value = 1))

  cat(assign$template, sep = "\n") |>
    expect_snapshot()

  df <- data.frame(x = "a", y = 1)

  assign$test(
    input = df |> dplyr::select(-y),
    expected = df
  )
})

test_that("astdt", {
  astdt <- get_rendered_standard("astdt", list(dtc = "AESTDTC"))

  cat(astdt$template, sep = "\n") |>
    expect_snapshot()

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, AESTDTC, ASTDT, ASTDTF)

  astdt$test(
    input = adae |> dplyr::select(-ASTDT, -ASTDTF),
    expected = adae
  )
})

test_that("aendt", {
  astdt <- get_rendered_standard("aendt", list(dtc = "AEENDTC"))

  cat(astdt$template, sep = "\n") |>
    expect_snapshot()

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, AEENDTC, AENDT, AENDTF)

  astdt$test(
    input = adae |> dplyr::select(-AENDT, -AENDTF),
    expected = adae
  )
})

test_that("ady", {
  ady <- get_rendered_standard("ady", list(variable = "ASTDY", date = "ASTDT"))

  cat(ady$template, sep = "\n") |>
    expect_snapshot()

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, ASTDT, TRTSDT, ASTDY)

  ady$test(
    input = adae |> dplyr::select(-ASTDY),
    expected = adae
  )

  ady$test(
    input = adae |> dplyr::select(-ASTDY),
    expected = adae |> dplyr::mutate(ASTDY = ASTDY + 1)
  ) |>
    expect_error()
})

test_that("trtemfl", {
  trtemfl <- get_rendered_standard("trtemfl", list(end_window = 30))

  cat(trtemfl$template, sep = "\n") |>
    expect_snapshot()

  adae <- pharmaverseadam::adae |>
    dplyr::select(ASTDT, AENDT, TRTSDT, TRTEDT, TRTEMFL)

  trtemfl$test(
    input = adae |> dplyr::select(-TRTEMFL),
    expected = adae
  )
})
