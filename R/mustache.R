
render_component <- function(component, data = NULL, ...) {
  data <- c(data, rlang::list2(...))
  file.path("inst", "components", component) |> 
    paste0(".mustache") |> 
    readLines() |> 
    whisker::whisker.render(data = data)
}

render_component("assigned", variable = "AGE", value = 15) |> 
    parse(text = _) |> 
      eval()

.self

render_component("predecessor", source = "adsl", by = "USUBJID", variable = "AGE") |> 
  cat(sep = "\n")

render_component("predecessor", source = "adsl", by = "USUBJID", variable = "AGE") |> 
  cat(sep = "\n")

.self <- pharmaverseadam::advs |>
  dplyr::select(USUBJID, PARAMCD, AVAL) |> 
  print()

render_component("predecessor", source = "pharmaverseadam::adsl", by = "USUBJID", variable = "ACTARM", x = "Y") |> 
  parse(text = _) |> 
  eval()

.self

script <- withr::local_tempfile(tmpdir = ".", fileext = ".R")

render_component("predecessor", source = "pharmaverseadam::adsl", by = "USUBJID", variable = "ACTARM") |> 
  cat(file = script, append = TRUE)


render_component("predecessor", source = "pharmaverseadam::adsl", by = "USUBJID", variable = c("AGE", "AGEU", "AGEGRP")) |> 
  cat(file = script, append = TRUE)

readLines(script) |> 
  cat(sep = "\n")
