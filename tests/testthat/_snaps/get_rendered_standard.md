# get_rendered_component returns rendered custom code component with valid inputs

    {
      "type": "character",
      "attributes": {},
      "value": ["    print(\"hello\")", "    if (a) {", "        return(NULL)", "    }", "    else {", "        return(1)", "    }"]
    }

# get_rendered_component returns rendered STANDARD code component with valid inputs

    {
      "type": "character",
      "attributes": {},
      "value": ["", ".self <- .self |>", "  dplyr::mutate(", "    out_var = admiral::compute_duration(", "      start_date = TRTSDT,", "      end_date = date_var,", "      in_unit = \"days\",", "      out_unit = \"days\",", "      add_one = TRUE", "    )", "  )"]
    }

