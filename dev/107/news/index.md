# Changelog

## mighty.component (development version)

- New optional `@method` tag on component headers, exposed as
  `component$method` (`NULL` if absent). Intended to let mighty.metadata
  populate a column’s define.xml method description directly from the
  component (mighty.metadata#23).

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
