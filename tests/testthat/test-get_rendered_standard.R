test_that("get_rendered_standard returns rendered standard with valid inputs", {
  # ARRANGE -------------------------------------------------------------------
 tmp_file <- withr::local_tempdir() |> 
  file.path("ady.R")
  # Create a mock mustache template
  c(
    "hello <- function(a){
    print('hello')
    if(a){
    return(NULL)
    } else{
      return(1)
      }

  }"
  ) |> writeLines(con = tmp_file)
browser()   
  mighty_standard$new(template = readLines(tmp_file))
  
})
