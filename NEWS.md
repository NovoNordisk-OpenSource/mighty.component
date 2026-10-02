# mighty.component (development version)

* Component repos are S7 classes: `mighty_repo()`, `mighty_repo_local()`,
  `mighty_repo_github()` and `mighty_repos()`. GitHub repos use the
  `github::` prefix (#108).
* `find_component()` is exported, and `list_components()` works with all repo
  types (#103).
* Components can be retrieved from URLs with `mighty_repo_url()` (`url::`
  prefix), with a time limit per request (`timeout` option) (#104).
* GitHub repos are cached per commit, and transient API errors are retried
  (`max_tries` option) (#93, #95).
* `@origin` is now a required tag on every component header, not optional.
* New required `@method` tag on component headers, exposed as
  `component$method`. Intended to let mighty.metadata populate a column's
  define.xml method description directly from the component.
* `mighty_component$render()` now recognizes a `.mighty_subset(domain, subset)`
  marker call passed as the value of the `domain` parameter. This lets callers
  (e.g. `mighty.metadata`'s pooling feature) restrict a `@type row`
  component's derivation to a subset of rows without corrupting
  `@depends`/`@outputs`/`@type` parsing or silently dropping added rows.
  Parameter values that aren't an exact `.mighty_subset(...)` call are
  unaffected. A marker on any parameter other than `domain` raises an error.

# mighty.component 0.1.0

* Initial GitHub release.
