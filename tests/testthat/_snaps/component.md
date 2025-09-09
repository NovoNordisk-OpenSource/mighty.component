# get_rendered_component, custom code component as function multiple depends

    Code
      x
    Message
      <mighty_component_rendered/mighty_component/R6>
      _components/ady.R: Derives the relative day compared to the treatment start
      date.
      Type: derivation
      Depends:
      * .self.A
      * lb.A
      Outputs:
      * B
      Code:
        "hello" |>
          print()
        if (a) {
          NULL
        } else {
          a <- 1
        }
        

# Custom R file with multiple function definitions fails 

    Code
      actual$code
    Output
      [1] ""                            "  # code comments"          
      [3] "  ADLB <- ADLB |> "          "    dplyr::filter(AGE > 60)"
      [5] "  "                         

# get_rendered_component custom local mustache template with params

    Code
      x
    Message
      <mighty_component_rendered/mighty_component/R6>
      _components/ady_local.mustache: Derives the relative day compared to the
      treatment start date.
      Type: derivation
      Depends:
      * .self.date_var
      * .self.TRTSDT
      Outputs:
      * out_var
      Code:
      .self <- .self |>
        dplyr::mutate(
          out_var = admiral::compute_duration(
            start_date = TRTSDT,
            end_date = date_var,
            in_unit = 'days',
            out_unit = 'days',
            add_one = TRUE
          )
        )

# get_rendered_component returns rendered STANDARD code component with valid inputs

    Code
      y
    Message
      <mighty_component_rendered/mighty_component/R6>
      ady: Derives the relative day compared to the treatment start date.
      Type: derivation
      Depends:
      * .self.date_var
      * .self.TRTSDT
      Outputs:
      * out_var
      Code:
      .self <- .self |>
        dplyr::mutate(
          out_var = admiral::compute_duration(
            start_date = TRTSDT,
            end_date = date_var,
            in_unit = "days",
            out_unit = "days",
            add_one = TRUE
          )
        )

