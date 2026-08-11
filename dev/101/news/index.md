# Changelog

## mighty.component (development version)

- `mighty_component$render()` now recognizes a
  `.mighty_subset(domain, subset)` marker call passed as the value of
  any parameter. This lets callers (e.g. `mighty.metadata`’s pooling
  feature) restrict a `@type row` component’s derivation to a subset of
  rows without corrupting `@depends`/`@outputs`/`@type` parsing or
  silently dropping added rows. Parameter values that aren’t an exact
  `.mighty_subset(...)` call are unaffected.

## mighty.component 0.1.0

- Initial GitHub release.
