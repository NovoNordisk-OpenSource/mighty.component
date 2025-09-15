test_that("predecessor", {
  predecessor <- test_component(
    "predecessor",
    list(source = "pharmaverseadam::adsl", by = "USUBJID", variable = "ACTARM")
  )

  advs <- pharmaverseadam::advs |>
    dplyr::select(USUBJID, PARAMCD, AVAL, ACTARM)

  advs |>
    dplyr::select(-ACTARM) |>
    test_eval(predecessor) |>
    expect_equal(advs)
})

test_that("assign", {
  assign <- test_component("assign", list(variable = "y", value = 1))

  df <- data.frame(x = "a", y = 1)

  df |>
    dplyr::select(-y) |>
    test_eval(assign) |>
    expect_equal(df)
})

test_that("astdt", {
  astdt <- test_component("astdt", list(dtc = "AESTDTC"))

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, AESTDTC, ASTDT, ASTDTF) |>
    strip_attributes()

  adae |>
    dplyr::select(-ASTDT, -ASTDTF) |>
    test_eval(astdt) |>
    expect_equal(adae)
})

test_that("aendt", {
  aendt <- test_component("aendt", list(dtc = "AEENDTC"))

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, AEENDTC, AENDT, AENDTF) |>
    strip_attributes()

  adae |>
    dplyr::select(-AENDT, -AENDTF) |>
    test_eval(aendt) |>
    expect_equal(adae)
})

test_that("ady", {
  ady <- test_component("ady", list(variable = "ASTDY", date = "ASTDT"))

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, ASTDT, TRTSDT, ASTDY) |>
    strip_attributes()

  adae |>
    dplyr::select(-ASTDY) |>
    test_eval(ady) |>
    expect_equal(adae)
})

test_that("trtemfl", {
  trtemfl <- test_component("trtemfl", list(end_window = 30))

  adae <- pharmaverseadam::adae |>
    dplyr::select(ASTDT, AENDT, TRTSDT, TRTEDT, TRTEMFL) |>
    strip_attributes()

  adae |>
    dplyr::select(-TRTEMFL) |>
    test_eval(trtemfl) |>
    expect_equal(adae)
})

test_that("supp_sdtm", {
  supp_sdtm <- test_component(
    component = "supp_sdtm",
    params = list(
      source = "pharmaversesdtm::suppae",
      qnam = "AETRTEM"
    )
  )

  suppae <- pharmaversesdtm::suppae |>
    dplyr::mutate(
      AESEQ = as.numeric(IDVARVAL),
      AETRTEM = QVAL
    ) |>
    dplyr::select(USUBJID, AESEQ, AETRTEM)

  adae <- pharmaversesdtm::ae |>
    dplyr::select(USUBJID, AESEQ, AETERM) |>
    dplyr::left_join(suppae, by = c("USUBJID", "AESEQ"))

  adae |>
    dplyr::select(-AETRTEM) |>
    test_eval(supp_sdtm) |>
    expect_equal(adae)
})
