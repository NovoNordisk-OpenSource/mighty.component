# mighty.component (development version)

* Breaking: `component$id` and the `id` from `list_components()` are now the
  component name without file extension, e.g. `"ady"` instead of
  `"ady.mustache"` (#118).
* Component repos are S7 classes: `mighty_repo()`, `mighty_repo_local()`,
  `mighty_repo_github()` and `mighty_repos()`. GitHub repos use the
  `github::` prefix (#108).
* `find_component()` is exported, and `list_components()` works with all repo
  types (#103).
* Components can be retrieved from URLs with `mighty_repo_url()` (`url::`
  prefix), with a time limit per request (`timeout` option) (#104).
* GitHub repos are cached per commit, and transient API errors are retried
  (`max_tries` option) (#93, #95).
* GitHub repos no longer leave extraction directories in the temporary
  directory, also when extraction fails (#119).
* `@origin` is now a required tag on component headers (#107).
* New required `@method` tag on component headers, exposed as
  `component$method` (#107).
* `@type row` components accept `".mighty_subset(<domain>, '<subset>')"` as
  `domain` to process only matching rows; other rows are unchanged (#101).
* `component$document()` checks that knitr is installed, and prints with cli
  so the output can be suppressed (#119).
* `mighty_component_test` gains `$close()` to close the test session. The
  session is also closed when the object is garbage collected (#119).
* `component$stream()` closes the file connection when writing fails (#119).
* Documentation is revised, and `?mighty_component` and the vignette share one
  template reference (#117).

# mighty.component 0.1.0

* Initial GitHub release.
