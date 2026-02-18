#' Strip all label attributes etc.
strip_attributes <- function(x) {
  for (i in seq_along(x)) {
    attr(x = x[[i]], which = "label") <- NULL
  }
  x
}
