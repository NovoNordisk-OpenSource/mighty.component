# Changelog

## mighty.component (development version)

- Component repos are S7 classes:
  [`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md),
  [`mighty_repo_local()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_local.md),
  [`mighty_repo_github()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_github.md)
  and
  [`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md).
  GitHub repos use the `github::` prefix
  ([\#108](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/108)).

- [`find_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/find_component.md)
  is exported, and
  [`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md)
  works with all repo types
  ([\#103](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/103)).

- GitHub repos are cached per commit, and transient API errors are
  retried
  ([\#93](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/93),
  [\#95](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/95)).

- `@origin` is now a required tag on every component header, not
  optional.

- New required `@method` tag on component headers, exposed as
  `component$method`. Intended to let mighty.metadata populate a
  column’s define.xml method description directly from the component.

- `mighty_component$render()` now recognizes a
  `.mighty_subset(domain, subset)` marker call passed as the value of
  the `domain` parameter. This lets callers (e.g. `mighty.metadata`’s
  pooling feature) restrict a `@type row` component’s derivation to a
  subset of rows without corrupting `@depends`/`@outputs`/`@type`
  parsing or silently dropping added rows. Parameter values that aren’t
  an exact `.mighty_subset(...)` call are unaffected. A marker on any
  parameter other than `domain` raises an error.

## mighty.component 0.1.0

- Initial GitHub release.
