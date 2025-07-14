test_that("mighty_component", {
  component <- test_path("_input", "test_component.mustache")

  test_component <- mighty_component$new(template = readLines(component)) |>
    expect_no_condition() |>
    expect_s3_class("mighty_component")

  expect_snapshot(test_component)

  test_component$code |>
    expect_equal(
      ".self$NEWWAR <- {{ x1 }} * Y$B + .self$A - {{ x2 }}"
    )

  test_component$template |>
    expect_equal(readLines(component))

  test_component$type |>
    expect_equal("derivation")

  test_component$depends |>
    expect_s3_class("data.frame") |>
    expect_equal(
      data.frame(
        domain = c(".self", "Y"),
        column = c("A", "B")
      )
    )

  test_component$outputs |>
    expect_equal("NEWVAR")

  test_component$params |>
    expect_equal(
      c(
        x1 = "First input",
        x2 = "Second input"
      )
    )

  test_component_rendered <- test_component$render(x1 = 1, x2 = 2) |>
    expect_no_condition() |>
    expect_s3_class("mighty_component_rendered")

  expect_snapshot(test_component_rendered)

  test_component_rendered$code |>
    expect_equal(
      ".self$NEWWAR <- 1 * Y$B + .self$A - 2"
    )

  grepl(pattern = "\\{\\{|\\}\\}", x = test_component_rendered$template) |>
    any() |>
    expect_false()

  test_component_rendered$type |>
    expect_equal("derivation")

  test_component_rendered$depends |>
    expect_s3_class("data.frame") |>
    expect_equal(
      data.frame(
        domain = c(".self", "Y"),
        column = c("A", "B")
      )
    )

  test_component_rendered$outputs |>
    expect_equal("NEWVAR")

  test_component_rendered$params |>
    expect_equal(character(0))

  test_component_rendered$render() |>
    expect_equal(test_component_rendered)
})

test_that("get_tags", {
  get_tag(template = "#' @mytag content", tag = "mytag") |>
    expect_equal("content")

  get_tags(
    template = c(
      "#' @mytag content1",
      "#' @mytag content2",
      "something else",
      "#' @myothertag content",
      "#' @mytag content3"
    ),
    tag = "mytag"
  ) |>
    expect_equal(c("content1", "content2", "content3"))

  get_tags(
    template = c("#' @myothertag content", "also unrelated"),
    tag = "mytag"
  ) |>
    expect_equal(character(0))
})

test_that("get_tag", {
  get_tag(template = "#' @mytag myvalue", tag = "mytag") |>
    expect_equal("myvalue")

  get_tag(
    template = c("#' @mytag myvalue", "#' @myothertag myothervalue"),
    tag = "mytag"
  ) |>
    expect_equal("myvalue")

  get_tag(
    template = c("#' @mytag myvalue", "#' @mytag myothervalue"),
    tag = "mytag"
  ) |>
    expect_error(regexp = "Multiple or no matches found for tag")

  get_tag(
    template = c("#' @mytag myvalue", "#' @mytag myothervalue"),
    tag = "myothertag"
  ) |>
    expect_error(regexp = "Multiple or no matches found for tag")
})

test_that("tags_to_named", {
  tags_to_named("mytag myvalue") |>
    expect_equal(c(mytag = "myvalue"))

  tags_to_named(c("tag1 value1", "tag2 value2")) |>
    expect_equal(c(tag1 = "value1", tag2 = "value2"))
})

test_that("tags_to_depends", {
  tags_to_depends("mydata myvariable") |>
    expect_equal(
      data.frame(domain = "mydata", column = "myvariable")
    )

  tags_to_depends(c("data1 var1", "data2 var2")) |>
    expect_equal(
      data.frame(
        domain = c("data1", "data2"),
        column = c("var1", "var2")
      )
    )

  tags_to_depends(character(0)) |>
    expect_s3_class("data.frame") |>
    expect_named(c("domain", "column")) |>
    nrow() |>
    expect_equal(0)
})

test_that("ms_print", {
  test_path("_input", "test_component.mustache") |>
    readLines() |>
    mighty_component$new() |>
    print() |>
    expect_invisible() |>
    expect_s3_class("mighty_component") |>
    expect_snapshot()
})

test_that("create_bullets", {
  create_bullets(
    header = "nothing to list",
    bullets = character(0)
  ) |>
    expect_no_message()

  create_bullets(
    header = "mytest",
    bullets = c("first item", "second item")
  ) |>
    expect_snapshot()
})

test_that("ms_render", {
  test_component <- test_path("_input", "test_component.mustache") |>
    readLines() |>
    mighty_component$new()

  ms_render(
    params = list(x1 = 5, 2),
    self = test_component
  ) |>
    expect_error(
      regexp = "All parameters must be named"
    )

  ms_render(
    params = list(x1 = 5),
    self = test_component
  ) |>
    expect_error(
      regexp = "Parameter names not matching component requirements"
    )

  test_component_rendered <- ms_render(
    params = list(x1 = 5, x2 = 4),
    self = test_component
  ) |>
    expect_no_condition()
})
