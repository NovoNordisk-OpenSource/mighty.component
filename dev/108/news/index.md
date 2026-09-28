# Changelog

## mighty.component (development version)

### Breaking changes

- GitHub component repos now need a `github::` prefix, e.g.
  `"github::NovoNordisk-OpenSource/mighty.standards/components@main"`.
  Specs without a prefix are treated as local paths, and a missing local
  directory now aborts instead of being skipped
  ([\#108](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/108)).
- [`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md)
  takes `repos` instead of `path`, accepting the same inputs as
  [`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md).
- A component’s `id` is always the matched filename including extension
  (e.g. `"ady.mustache"`), however the component was looked up.
- Component names are matched exactly, not as regular expressions.
- Pull request (`owner/repo#12`) and release (`owner/repo@*release`)
  specs are not supported and raise an error.

### New features

- Component lookup is built on S7 repo classes:
  [`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md)
  creates a repo from a `type::path` spec, with
  [`mighty_repo_local()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_local.md)
  and
  [`mighty_repo_github()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_github.md)
  as the supported types
  ([\#108](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/108)).
- [`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md)
  holds an ordered collection of repos. Create it once and reuse it to
  resolve GitHub refs only once for many lookups.
- [`find_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/find_component.md)
  is exported. Unlike
  [`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md)
  it returns `NULL` when the component is not found.
- [`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md)
  supports GitHub repos
  ([\#103](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/103))
  and again supports `as = "list"` and `as = "tibble"`, now including
  `type`, `origin` and `method`.
- Components can live in a directory named after them
  (`<repo>/<name>/<name>.R`), in local and GitHub repos. Files starting
  with `test-` are not listed.
- GitHub repos are resolved to a commit SHA and downloaded once per
  commit per session, so a moving branch is always current
  ([\#93](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/93)).
- Transient GitHub API errors (HTTP 5xx, network failures) are retried.
  Set the number of attempts with the
  `mighty.component.github_max_tries` option (default 3)
  ([\#95](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/95)).
- Warnings from extracting GitHub tarballs are shown with verbose output
  instead of being dropped
  ([\#92](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/92)).

### Other changes

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
