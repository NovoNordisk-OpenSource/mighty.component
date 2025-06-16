test_that("trtemfl", {
  pharmaverseadam::adae |>
    dplyr::select(ASTDT, AENDT, TRTSDT, TRTEDT, OLD = TRTEMFL) |>
    trtemfl() |>
    with(
      expect_equal(object = TRTEMFL, expected = OLD, ignore_attr = TRUE)
    )
})
