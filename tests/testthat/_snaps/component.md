# get_rendered_component, custom code component as function multiple depends

    Code
      x
    Message
      <mighty_component_rendered/mighty_component/R6>
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
        

# get_rendered_component custom local mustache template with params

    Code
      x
    Message
      <mighty_component_rendered/mighty_component/R6>
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

