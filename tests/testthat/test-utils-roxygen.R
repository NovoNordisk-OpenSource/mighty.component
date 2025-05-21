test_that("Documentation is created with custom tags", {
  blocks <- test_path("cases", "good.R") |> 
    roxygen2::parse_file() |> 
    expect_no_condition()

  results <- roxygen2::roclet_process(
    x = roxygen2::rd_roclet(),
    blocks = blocks
  ) |> 
    expect_no_condition()

  tmp <- withr::local_tempdir()
  dir.create(file.path(tmp, "man")) |> 
    expect_true()

  rd_file <- roxygen2::roclet_output(
    x = roxygen2::rd_roclet(), 
    results = results, 
    base_path = tmp
  ) |> 
    expect_no_error()

  expect_snapshot_file(rd_file)
})
