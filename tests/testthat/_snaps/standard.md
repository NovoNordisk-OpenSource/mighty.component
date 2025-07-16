# get_standard

    Code
      print(expect_s3_class(expect_no_condition(get_standard("ady")),
      "mighty_component"))
    Message
      <mighty_component/R6>
      Type: derivation
      Parameters:
      * variable: `character` Name of new variable to create
      * date: `character` Name of date variable to use
      Depends:
      * .self.{{ date }}
      * .self.TRTSDT
      Outputs:
      * {{ variable }}

# get_rendered_standard

    Code
      print(expect_s3_class(expect_no_condition(get_rendered_standard("ady", list(
        variable = "ASTDY", date = "ASTDT"))), "mighty_component_rendered"))
    Message
      <mighty_component_rendered/mighty_component/R6>
      Type: derivation
      Depends:
      * .self.ASTDT
      * .self.TRTSDT
      Outputs:
      * ASTDY
      Code:
      .self <- .self |>
        dplyr::mutate(
          ASTDY = admiral::compute_duration(
            start_date = TRTSDT,
            end_date = ASTDT,
            in_unit = "days",
            out_unit = "days",
            add_one = TRUE
          )
        )

