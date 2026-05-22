# get_rendered_component, custom code component from R script

    Code
      x
    Message
      <mighty_component_rendered/mighty_component/R6>
      _components/ady_local.R: Derives the relative day compared to the treatment
      start date.
      Type: column
      Depends:
      * domain.date_var
      * domain.TRTSDT
      Outputs:
      * out_var
      Code:
      domain <- domain |>
        dplyr::mutate(
          out_var = admiral::compute_duration(
            start_date = TRTSDT,
            end_date = date_var,
            in_unit = "days",
            out_unit = "days",
            add_one = TRUE
          )
        )

# get_rendered_component custom local mustache template with params

    Code
      x
    Message
      <mighty_component_rendered/mighty_component/R6>
      _components/ady_local.mustache: Derives the relative day compared to the
      treatment start date.
      Type: column
      Depends:
      * domain.date_var
      * domain.TRTSDT
      Outputs:
      * out_var
      Code:
      domain <- domain |>
        dplyr::mutate(
          out_var = admiral::compute_duration(
            start_date = TRTSDT,
            end_date = date_var,
            in_unit = 'days',
            out_unit = 'days',
            add_one = TRUE
          )
        )

