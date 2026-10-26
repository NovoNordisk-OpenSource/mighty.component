## Resubmission

This is a resubmission. In this version I have:

* Removed the single quotes around 'components' in the Description field.
  Only package, software and API names are now quoted.
* Writing to the user's filespace: no function writes by default. The only
  function that writes files, `mighty_component_rendered$stream(path)`, has
  no default `path`, so the user must always supply the file. Examples, the
  vignette and tests only write to `tempdir()`. R CMD check with
  `_R_CHECK_THINGS_IN_CHECK_DIR_` and `_R_CHECK_THINGS_IN_TEMP_DIR_` set
  reports no leftover files.
* Removed all use of `<<-` and `lockBinding()`. `get_test_component()` no
  longer rewrites the component code. The user's global environment is never
  modified; see the notes for reviewers below.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Notes for reviewers

* `get_test_component()` creates a `mighty_component_test` object that runs
  component code in a separate R process (the test session) started with
  'callr'. This process is an isolated sandbox for unit testing: input data,
  the component code and its results live in the global environment of the
  test session only. The user's R session and its global environment are never
  modified. The test session is closed with `$close()` or when the object is
  garbage collected. This is documented in the "Test session" section of
  `?mighty_component_test`.
* Examples that need network access are wrapped in
  `@examplesIf interactive()`.

## mightyverse

This package is part of the mightyverse, a set of packages for generating
ADaM programs. The main package, 'mighty'
(https://github.com/NovoNordisk-OpenSource/mighty), will be submitted to CRAN
after this one.
