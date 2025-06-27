test_that("list_all_R_functions_in_file extracts function names from valid R file", {
  # ARRANGE -------------------------------------------------------------------
  # Create a temporary R file with multiple function definitions
  temp_file <- withr::local_tempfile(fileext = ".R")
  r_code <- '
# Sample function 1
hello_world <- function() {
  return("Hello, World!")
}

# Sample function 2  
add_numbers <- function(a, b) {
  return(a + b)
}
'
  writeLines(r_code, temp_file)

  # ACT -----------------------------------------------------------------------
  result <- list_all_R_functions_in_file(temp_file)

  # ASSERT --------------------------------------------------------------------
  # Should return a character vector of function names
  expect_type(result, "character")

  # Should contain exactly 3 functions as defined in the test file
  expect_length(result, 2)

  # Should contain all expected function names (order may vary)
  expected_functions <- c("hello_world", "add_numbers")
  expect_setequal(result, expected_functions)
})

test_that("list_all_R_functions_in_dir extracts functions from multiple R files in directory", {
  # ARRANGE -------------------------------------------------------------------
  # Create a temporary directory with multiple R files
  temp_dir <- withr::local_tempdir()
  
  # Create first R file with 2 functions
  file1_content <- '
add_numbers <- function(a, b) {
  return(a + b)
}

hi <- function() {
  print("hi")
}
'
  writeLines(file1_content, file.path(temp_dir, "math_functions.R"))
  
  # Create second R file with 1 function
  file2_content <- '
hi2 <- function() {
  print("hi2")
}
'
  writeLines(file2_content, file.path(temp_dir, "utils.R"))
  
  # ACT -----------------------------------------------------------------------
  result <- list_all_R_functions_in_dir(temp_dir)
  
  # ASSERT --------------------------------------------------------------------
  # Should return a character vector containing all function names
  expect_type(result, "character")
  
  # Should contain exactly 3 functions total (2 from first file + 1 from second)
  expect_length(result, 3)
  
  # Should contain all expected function names from both files
  expected_functions <- c("add_numbers", "hi", "hi2")
  expect_setequal(as.character(result), expected_functions)
  
  # Should have names attribute (file paths) for each function
  expect_true(!is.null(names(result)))
  
  # All names should end with .R extension (indicating source file)
  expect_true(all(grepl("\\.R$", names(result))))
  
  # Should not contain any empty or NA values
  expect_false(any(is.na(result)))
  expect_false(any(result == ""))
})
