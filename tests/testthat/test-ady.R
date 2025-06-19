test_that("ady", {
  ady <- get_rendered_standard("ady", list(variable = "ASTDY", date = "ASTDT"))

  cat(ady$code, sep = "\n")

  adae <- pharmaverseadam::adae |> 
    dplyr::select(USUBJID, ASTDT, TRTSDT, ASTDY)

  ady$test(
    input = adae |> dplyr::select(-ASTDY),
    expected = adae
  )
})
