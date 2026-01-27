test_that("predecessor", {
  skip("Awaiting new testing framework in #48")

  predecessor <- get_rendered_standard(
    "predecessor",
    list(source = "pharmaverseadam::adsl", by = "USUBJID", variable = "ACTARM")
  )

  expect_snapshot(predecessor)

  advs <- pharmaverseadam::advs |>
    dplyr::select(USUBJID, PARAMCD, AVAL, ACTARM)

  predecessor$test(
    input = advs |> dplyr::select(-ACTARM),
    expected = advs
  )
})

test_that("assign", {
  skip("Awaiting new testing framework in #48")

  assign <- get_rendered_standard("assign", list(variable = "y", value = 1))

  expect_snapshot(assign)

  df <- data.frame(x = "a", y = 1)

  assign$test(
    input = df |> dplyr::select(-y),
    expected = df
  )
})

test_that("astdt", {
  skip("Awaiting new testing framework in #48")

  astdt <- get_rendered_standard("astdt", list(dtc = "AESTDTC"))

  expect_snapshot(astdt)

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, AESTDTC, ASTDT, ASTDTF)

  astdt$test(
    input = adae |> dplyr::select(-ASTDT, -ASTDTF),
    expected = adae
  )
})

test_that("aendt", {
  skip("Awaiting new testing framework in #48")

  aendt <- get_rendered_standard("aendt", list(dtc = "AEENDTC"))
  expect_snapshot(aendt)

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, AEENDTC, AENDT, AENDTF)

  aendt$test(
    input = adae |> dplyr::select(-AENDT, -AENDTF),
    expected = adae
  )
})

test_that("ady", {
  browser()
  ady <- get_rendered_standard("ady", list(variable = "ASTDY", date = "ASTDT"))

  expect_snapshot(ady)

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
  skip("Awaiting new testing framework in #48")

  trtemfl <- get_rendered_standard("trtemfl", list(end_window = 30))

  expect_snapshot(trtemfl)

  adae <- pharmaverseadam::adae |>
    dplyr::select(ASTDT, AENDT, TRTSDT, TRTEDT, TRTEMFL)

  trtemfl$test(
    input = adae |> dplyr::select(-TRTEMFL),
    expected = adae
  )
})

test_that("supp_sdtm", {
  skip("Awaiting new testing framework in #48")

  supp_sdtm <- get_rendered_standard(
    standard = "supp_sdtm",
    params = list(
      source = "pharmaversesdtm::suppae",
      qnam = "AETRTEM"
    )
  )

  expect_snapshot(supp_sdtm)

  suppae <- pharmaversesdtm::suppae |>
    dplyr::mutate(
      AESEQ = as.numeric(IDVARVAL),
      AETRTEM = QVAL
    ) |>
    dplyr::select(USUBJID, AESEQ, AETRTEM)

  adae <- pharmaversesdtm::ae |>
    dplyr::select(USUBJID, AESEQ, AETERM) |>
    dplyr::left_join(suppae, by = c("USUBJID", "AESEQ"))

  supp_sdtm$test(
    input = adae |> dplyr::select(-AETRTEM),
    expected = adae
  )
})
