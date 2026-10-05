# Create a testable component for unit testing

Creates a `mighty_component_test` object from a rendered component,
enabling structured unit testing with optional coverage checking.

See
[mighty_component_test](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_test.md)
for a description of the testing workflow.

## Usage

``` r
get_test_component(
  component,
  params = list(),
  repos = NULL,
  check_coverage = TRUE,
  teardown_env = parent.frame()
)
```

## Arguments

- component:

  `character` component name, or path to a component file (`.R` or
  `.mustache`) when `repos` is `NULL`. The directory of the path must
  exist.

- params:

  named `list` of input parameters. Passed along to
  `mighty_component$render()`.

- repos:

  Where to look. One of:

  - `NULL` (default): `component` is a file path.

  - `character` vector of repo specs, in priority order. See
    [`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md).

  - A `mighty_repo_class` object.

  - A `list` of repo specs or `mighty_repo_class` objects, in priority
    order.

  - A
    [`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md)
    collection.

  Character vectors and lists are converted once with
  [`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md).

- check_coverage:

  `logical(1)` Whether to automatically check test coverage when the
  test completes. If `TRUE` (default), coverage is verified via
  `test_component$check_coverage()` in a deferred call.

- teardown_env:

  The environment in which to register the deferred coverage check.
  Defaults to the caller's environment
  ([`parent.frame()`](https://rdrr.io/r/base/sys.parent.html)). This
  controls when `check_coverage()` executes during test teardown.

## Value

A `mighty_component_test` object.

## See also

[`get_rendered_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
[mighty_component_test](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_test.md)
