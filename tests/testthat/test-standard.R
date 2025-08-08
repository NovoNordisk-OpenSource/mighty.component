test_that("list standards", {
  list_standards() |>
    expect_no_condition() |>
    expect_type("character")

  list_standards("list") |>
    expect_no_condition() |>
    expect_type("list")

  list_standards("tibble") |>
    expect_no_condition() |>
    expect_s3_class("tbl_df") |>
    names() |>
    expect_equal(c(
      "id",
      "title",
      "description",
      "params",
      "depends",
      "outputs",
      "code"
    ))
})

test_that("find standard", {
  find_standard("ady") |>
    expect_no_condition() |>
    expect_type("character") |>
    expect_length(1)

  find_standard("does_not_exist") |>
    expect_error("Component does_not_exist not found")
})
