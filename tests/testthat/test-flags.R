test_that("trtemfl", {
  skip(
    "TODO: Fix trtemfl so that the below will evaluate to true. 
    Make the cutoff a parameter"
  )
  pharmaverseadam::adae |>
    dplyr::select(ASTDT, AENDT, TRTSDT, TRTEDT, OLD = TRTEMFL) |>
    trtemfl() |>
    with(
      expect_equal(object = TRTEMFL, expected = OLD, ignore_attr = TRUE)
    )
})
