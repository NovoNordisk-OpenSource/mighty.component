# predecessor

    Code
      cat(predecessor$template, sep = "\n")
    Output
      #' Predecessor
      #' @description
      #' Creates new column(s) based on a predecessor column(s).
      #'
      #' @param source `character` Name of the data set the predecessor is from
      #' @param variable `character` Name of variable(s) to use from `source`
      #' @param by `character` name(s) of variable(s) to merge by
      #' @type predecessor
      #' @depends .self USUBJID
      #' @depends pharmaverseadam::adsl USUBJID
      #' @depends pharmaverseadam::adsl ACTARM
      #' @outputs ACTARM
      
      .self <- .self |>
        dplyr::left_join(
          y = dplyr::select(pharmaverseadam::adsl, USUBJID, ACTARM),
          by = "USUBJID"
        )

# assign

    Code
      cat(assign$template, sep = "\n")
    Output
      #' Assign
      #' @description
      #' Assigns a single value to an entire column.
      #'
      #' @param variable `character` Name of variable to create or modify
      #' @param value Value to assign to the variable
      #' @type assigned
      #' @outputs y
      
      .self <- .self |>
        dplyr::mutate(
          y = 1
        )

# astdt

    Code
      cat(astdt$template, sep = "\n")
    Output
      #' Analysis start date
      #' @description
      #' Derives analysis start date based on (incomplete) dates given as
      #' character
      #'
      #' @param dtc `character` Name of date variable
      #' @type derivation
      #' @depends .self AESTDTC
      #' @outputs ASTDT
      #' @outputs ASTDTF
      
      .self <- .self |>
        dplyr::mutate(
          ASTDT = admiral::convert_dtc_to_dt(
            dtc = AESTDTC,
            highest_imputation = "M",
            date_imputation = "first"
          ),
          ASTDTF = admiral::compute_dtf(
            dtc = AESTDTC,
            dt = ASTDT
          )
        )

# aendt

    Code
      cat(astdt$template, sep = "\n")
    Output
      #' Analysis end date
      #' @description
      #' Derives analysis end date based on (incomplete) dates given as
      #' character
      #'
      #' @param dtc `character` Name of date variable
      #' @type derivation
      #' @depends .self AEENDTC
      #' @outputs AENDT
      #' @outputs AENDTF
      
      .self <- .self |>
        dplyr::mutate(
          AENDT = admiral::convert_dtc_to_dt(
            dtc = AEENDTC,
            highest_imputation = "M",
            date_imputation = "last"
          ),
          AENDTF = admiral::compute_dtf(
            dtc = AEENDTC,
            dt = AENDT
          )
        )

# ady

    Code
      cat(ady$template, sep = "\n")
    Output
      #' Analysis relative day
      #' @description
      #' Derives the relative day compared to the treatment start date.
      #'
      #' @param variable `character` Name of new variable to create
      #' @param date `character` Name of date variable to use
      #' @type derivation
      #' @depends .self ASTDT
      #' @depends .self TRTSDT
      #' @outputs ASTDY
      
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

# trtemfl

    Code
      cat(trtemfl$template, sep = "\n")
    Output
      #' Treatment-emergent flag
      #' @description
      #' Derives treatment emergent analysis flag.
      #'
      #' @param end_window Passed along to `admiral::end_window()`
      #' @type derivation
      #' @depends .self ASTDT
      #' @depends .self AENDT
      #' @depends .self TRTSDT
      #' @depends .self TRTEDT
      #' @outputs TRTEMFL
      
      .self <- .self |>
        admiral::derive_var_trtemfl(
          start_date = ASTDT,
          end_date = AENDT,
          trt_start_date = TRTSDT,
          trt_end_date = TRTEDT,
          end_window = 30
        )

