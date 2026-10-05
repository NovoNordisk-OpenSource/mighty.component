## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Notes for reviewers

* `get_test_component()` creates a `mighty_component_test` object that runs
  component code in a separate R process started with 'callr'.
  In that process, `<-` in the component code is rewritten to `<<-`, the code
  is run as a function in the global environment, and `lockBinding()` is
  applied to that function in the global environment. This only affects the
  child process, never the user's session. The process is closed with
  `$close()` or when the object is garbage collected.
* Examples that need network access are wrapped in
  `@examplesIf interactive()`.

## mightyverse

This package is part of the mightyverse, a set of packages for generating
ADaM programs. The main package, 'mighty'
(https://github.com/NovoNordisk-OpenSource/mighty), will be submitted to CRAN
after this one.
