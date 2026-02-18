withr::local_options(
  .new = list(mighty.component.verbosity_level = "quiet"),
  .local_envir = teardown_env()
)
