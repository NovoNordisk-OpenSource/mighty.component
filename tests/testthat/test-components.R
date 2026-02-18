test_that("predecessor", {
  predecessor <- get_test_component(
    component = "predecessor",
    params = list(
      domain = "advs",
      source = "pharmaverseadam::adsl",
      by = "USUBJID",
      variable = "ACTARM"
    )
  )

  advs <- pharmaverseadam::advs |>
    dplyr::select(USUBJID, PARAMCD, AVAL, ACTARM)

  predecessor$assign(
    x = "advs",
    value = dplyr::select(advs, -ACTARM)
  )

  predecessor$eval()$get("advs") |>
    expect_equal(advs)
})

test_that("assign", {
  assign <- get_test_component(
    component = "assign",
    params = list(
      domain = "df",
      variable = "y",
      value = 1
    )
  )

  df <- data.frame(x = "a", y = 1)

  assign$assign(
    x = "df",
    value = dplyr::select(df, -y)
  )

  assign$eval()$get("df") |>
    expect_equal(df)
})

test_that("astdt", {
  astdt <- get_test_component(
    component = "astdt",
    params = list(
      domain = "adae",
      dtc = "AESTDTC"
    )
  )

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, AESTDTC, ASTDT, ASTDTF) |>
    strip_attributes()

  astdt$assign(
    x = "adae",
    value = dplyr::select(adae, -ASTDT, -ASTDTF)
  )

  astdt$eval()$get("adae") |>
    expect_equal(adae)
})

test_that("aendt", {
  aendt <- get_test_component(
    component = "aendt",
    params = list(
      domain = "adae",
      dtc = "AEENDTC"
    )
  )

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, AEENDTC, AENDT, AENDTF) |>
    strip_attributes()

  aendt$assign(
    x = "adae",
    value = dplyr::select(adae, -AENDT, -AENDTF)
  )

  aendt$eval()$get("adae") |>
    expect_equal(adae)
})

test_that("ady", {
  ady <- get_test_component(
    component = "ady",
    params = list(
      domain = "adae",
      variable = "ASTDY",
      date = "ASTDT"
    )
  )

  adae <- pharmaverseadam::adae |>
    dplyr::select(USUBJID, ASTDT, TRTSDT, ASTDY) |>
    strip_attributes()

  ady$assign(
    x = "adae",
    value = dplyr::select(adae, -ASTDY)
  )

  ady$eval()$get("adae") |>
    expect_equal(adae)
})

test_that("trtemfl", {
  trtemfl <- get_test_component(
    component = "trtemfl",
    params = list(
      domain = "adae",
      end_window = 30
    )
  )

  adae <- pharmaverseadam::adae |>
    dplyr::select(ASTDT, AENDT, TRTSDT, TRTEDT, TRTEMFL) |>
    strip_attributes()

  trtemfl$assign(
    x = "adae",
    value = dplyr::select(adae, -TRTEMFL)
  )

  trtemfl$eval()$get("adae") |>
    expect_equal(adae)
})

test_that("supp_sdtm", {
  supp_sdtm <- get_test_component(
    component = "supp_sdtm",
    params = list(
      domain = "adae",
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

  supp_sdtm$assign(
    x = "adae",
    value = dplyr::select(adae, -AETRTEM)
  )

  supp_sdtm$eval()$get("adae") |>
    expect_equal(adae)
})
