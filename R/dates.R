#' Analysis start date
#' @export
astdt <- function(.self, variable) {
  .self <- .self |> 
    admiral::derive_vars_dt(
      new_vars_prefix = "AST", 
      dtc = variable, 
      highest_imputation = "D", 
      date_imputation = "first", 
      flag_imputation = "date"
    )
  
  return(.self)
}
