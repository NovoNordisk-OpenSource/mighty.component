# Changelog

## mighty.component (development version)

- Breaking: `component$id` and the `id` from
  [`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md)
  are now the component name without file extension, e.g. `"ady"`
  instead of `"ady.mustache"`.
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
- Components can be retrieved from URLs with
  [`mighty_repo_url()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_url.md)
  (`url::` prefix), with a time limit per request (`timeout` option)
  ([\#104](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/104)).
- GitHub repos are cached per commit, and transient API errors are
  retried (`max_tries` option)
  ([\#93](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/93),
  [\#95](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/95)).
- `@origin` is now a required tag on component headers
  ([\#107](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/107)).
- New required `@method` tag on component headers, exposed as
  `component$method`
  ([\#107](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/107)).
- `@type row` components accept `".mighty_subset(<domain>, '<subset>')"`
  as `domain` to process only matching rows; other rows are unchanged
  ([\#101](https://github.com/NovoNordisk-OpenSource/mighty.component/issues/101)).

## mighty.component 0.1.0

- Initial GitHub release.
