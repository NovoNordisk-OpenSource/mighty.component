# Changelog

## mighty.component (development version)

- `mighty_component$render()` now recognizes a
  `.mighty_subset(domain, subset)` marker call passed as the `domain`
  parameter. This lets callers (e.g. `mighty.metadata`’s pooling
  feature) restrict a `@type row` component’s derivation to a subset of
  rows without corrupting `@depends` parsing or silently dropping added
  rows. Ordinary `domain` values are unaffected.

## mighty.component 0.1.0

- Initial GitHub release.
