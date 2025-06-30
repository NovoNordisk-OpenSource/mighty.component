test_that("get_rendered_standard returns rendered standard with valid inputs", {
  # ARRANGE -------------------------------------------------------------------
 tmp_file <- withr::local_tempdir() |> 
  file.path("ady.R")
  # Create a mock mustache template
  c(
    "#' Analysis relative day",
    "#' @id ady",
    "#' @type derivation",
    "#' @depends .self {{ date }}",
    "#' @depends .self TRTSDT",
    "#' @outputs {{ variable }}",
    ".self <-  .self |>",
    "  dplyr::mutate(",
    "    {{ variable }} = admiral::compute_duration(",
    "      start_date = TRTSDT,",
    "      end_date = {{ date }},",
    "      in_unit = \"days\",",
    "      out_unit = \"days\",",
    "      add_one = TRUE",
    "    )",
    "  )"
  ) |> writeLines(con = tmp_file)
   
  browser()
  get_rendered_standard(standard = "ady", library = tmp_file, params = list(
    date = "TRTSDT",
    variable = "ADY"
  ))
  # Create a mighty_standard instance with the mock template
  mock_standard <- mighty_standard$new(template = mock_template)
  
})
