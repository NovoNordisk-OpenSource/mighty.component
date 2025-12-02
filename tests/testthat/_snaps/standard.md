# get_standard

    Code
      print(expect_s3_class(expect_no_condition(get_standard("ady")),
      "mighty_component"))
    Message
      <mighty_component/R6>
      ady: Derives the relative day compared to the treatment start date.
      Type: derivation
      Parameters:
      * domain: `character` Name of new domain beind created
      * variable: `character` Name of new variable to create
      * date: `character` Name of date variable to use
      Depends:
      * {{domain}}.{{date}}
      * {{domain}}.TRTSDT
      Outputs:
      * {{variable}}

# get_rendered_standard

    Code
      print(expect_s3_class(expect_no_condition(get_rendered_standard(standard = "ady",
        params = list(domain = "adsl", variable = "ASTDY", date = "ASTDT"))),
      "mighty_component_rendered"))
    Message
      <mighty_component_rendered/mighty_component/R6>
      ady: Derives the relative day compared to the treatment start date.
      Type: derivation
      Depends:
      * adsl.ASTDT
      * adsl.TRTSDT
      Outputs:
      * ASTDY
      Code:
      adsl <- adsl |>
        dplyr::mutate(
          ASTDY = admiral::compute_duration(
            start_date = TRTSDT,
            end_date = ASTDT,
            in_unit = "days",
            out_unit = "days",
            add_one = TRUE
          )
        )

