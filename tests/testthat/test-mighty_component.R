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
  
})