# Helper functions to evaluate R6 methods so it is
# picked up by code coverage calculations in covr
# (calling e.g. x$method(args) is not picked up)
eval_method <- function(x, method, args = list()) {
  do.call(x[[method]], args)
}
