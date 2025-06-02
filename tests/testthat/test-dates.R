test_that("astdt", {
  pharmaverseadam::adae |>
    dplyr::select(USUBJID, AESTDTC, OLDV = ASTDT, OLDF = ASTDTF) |>
    astdt("AESTDTC") |>
    with({
      expect_equal(object = ASTDT, expected = OLDV, ignore_attr = TRUE)
      expect_equal(object = ASTDTF, expected = OLDF, ignore_attr = TRUE)
    })
})

test_that("aendt", {
  pharmaverseadam::adae |>
    dplyr::select(USUBJID, AEENDTC, OLDV = AENDT, OLDF = AENDTF) |>
    aendt("AEENDTC") |>
    with({
      expect_equal(object = AENDT, expected = OLDV, ignore_attr = TRUE)
      expect_equal(object = AENDTF, expected = OLDF, ignore_attr = TRUE)
    })
})

test_that("ady", {
  pharmaverseadam::adae |>
    dplyr::select(USUBJID, ASTDT, TRTSDT, OLD = ASTDY) |>
    ady("ASTDT") |>
    with(
      expect_equal(object = ASTDY, expected = OLD, ignore_attr = TRUE)
    )
})
