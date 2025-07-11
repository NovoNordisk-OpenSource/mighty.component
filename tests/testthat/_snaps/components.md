# predecessor

    Code
      predecessor
    Message
      <mighty_component_rendered/mighty_component/R6>
      Type: predecessor
      Depends:
      * .self.USUBJID
      * pharmaverseadam::adsl.USUBJID
      * pharmaverseadam::adsl.ACTARM
      Outputs:
      * ACTARM
      Code:
      .self <- .self |>
        dplyr::left_join(
          y = dplyr::select(pharmaverseadam::adsl, USUBJID, ACTARM),
          by = "USUBJID"
        )

# assign

    Code
      assign
    Message
      <mighty_component_rendered/mighty_component/R6>
      Type: assigned
      Outputs:
      * y
      Code:
      .self <- .self |>
        dplyr::mutate(
          y = 1
        )

# astdt

    Code
      astdt
    Message
      <mighty_component_rendered/mighty_component/R6>
      Type: derivation
      Depends:
      * .self
      * AESTDTC
      Outputs:
      * ASTDT
      * ASTDTF
      Code:
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
      aendt
    Message
      <mighty_component_rendered/mighty_component/R6>
      Type: derivation
      Depends:
      * .self
      * AEENDTC
      Outputs:
      * AENDT
      * AENDTF
      Code:
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
      ady
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

# trtemfl

    Code
      trtemfl
    Message
      <mighty_component_rendered/mighty_component/R6>
      Type: derivation
      Depends:
      * .self.ASTDT
      * .self.AENDT
      * .self.TRTSDT
      * .self.TRTEDT
      Outputs:
      * TRTEMFL
      Code:
      .self <- .self |>
        admiral::derive_var_trtemfl(
          start_date = ASTDT,
          end_date = AENDT,
          trt_start_date = TRTSDT,
          trt_end_date = TRTEDT,
          end_window = 30
        )

