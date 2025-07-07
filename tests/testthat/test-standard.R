test_that("list standards", {
  list_standards() |>
    expect_no_condition() |>
    expect_type("character")
})

test_that("find standard", {
  find_standard("ady") |>
    expect_no_condition() |>
    expect_type("character") |>
    expect_length(1)

  find_standard("does_not_exist") |>
    expect_error("Component does_not_exist not found")
})
