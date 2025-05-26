test_that("predecessor", {
  pharmaverseadam::advs |>
    dplyr::select(USUBJID, PARAMCD, AVAL) |>
    predecessor(source = pharmaverseadam::adsl, variable = "ACTARM") |> 
    expect_no_condition() |> 
    with(any(is.na(ACTARM))) |> 
    expect_false()
})

test_that("assigned", {
  mtcars |> 
    assigned("new", 1) |> 
    with(new == 1) |> 
    all() |> 
    expect_true()
})
