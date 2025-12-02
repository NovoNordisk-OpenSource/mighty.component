# predecessor

    Code
      predecessor
    Message
      <mighty_component_rendered/mighty_component/R6>
      predecessor: Creates new column(s) based on a predecessor column(s).
      Type: predecessor
      Depends:
      * advs.USUBJID
      * pharmaverseadam::adsl.USUBJID
      * pharmaverseadam::adsl.ACTARM
      Outputs:
      * ACTARM
      Code:
      advs <- advs |>
        dplyr::left_join(
          y = dplyr::select(pharmaverseadam::adsl, USUBJID, ACTARM),
          by = dplyr::join_by(USUBJID)
        )

