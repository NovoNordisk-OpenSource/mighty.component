# Helper function to return if a process is alive
process_is_alive <- function(pid) {
  cmd <- sprintf("ps -p %s", as.character(pid))

  res <- suppressWarnings(
    expr = {
      system(command = cmd, intern = TRUE)
    }
  )

  is.null(attr(res, "status"))
}
