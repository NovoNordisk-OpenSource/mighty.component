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

test_that("get_standard", {
  get_standard("ady") |>
    expect_no_condition() |>
    expect_s3_class("mighty_component") |>
    print() |>
    expect_snapshot()
})

test_that("get_rendered_standard", {
  get_rendered_standard("ady", list(variable = "ASTDY", date = "ASTDT")) |>
    expect_no_condition() |>
    expect_s3_class("mighty_component_rendered") |>
    print() |>
    expect_snapshot()

  get_rendered_standard("ady", list(wrong_input = 5)) |>
    expect_error()
})
