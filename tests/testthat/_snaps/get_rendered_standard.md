# get_rendered_component, custom code component multiple depends

    {
      "type": "character",
      "attributes": {},
      "value": ["", "    'hello' |> ", "      print()", "    if(a){", "    NULL", "    } else{", "      a <- 1", "      }", "      "]
    }

# get_rendered_component returns rendered STANDARD code component with valid inputs

    {
      "type": "character",
      "attributes": {},
      "value": ["", ".self <- .self |>", "  dplyr::mutate(", "    out_var = admiral::compute_duration(", "      start_date = TRTSDT,", "      end_date = date_var,", "      in_unit = \"days\",", "      out_unit = \"days\",", "      add_one = TRUE", "    )", "  )"]
    }

