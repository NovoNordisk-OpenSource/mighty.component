test_that("list_standards works", {
  actual <- list_standards(library = "mighty.standards") 

  # ASSERT -------------------------------------------------------------------
  expect_type(actual, "character")
  expect_contains(actual, "ady")

})
