# Create a test component

Retrieve and render a component as a
[mighty_component_test](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_test.md)
object, for unit tests with code coverage. See
[mighty_component_test](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_test.md)
for the workflow.

Requires the callr and covr packages.

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

  `character(1)` Component name. If `repos` is `NULL`, path to a
  component file, with or without extension.

- params:

  named `list` of parameters passed to `$render()`. See the component's
  `@param` tags (`component$params`).

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

  `logical(1)` If `TRUE` (default), `$check_coverage()` runs when
  `teardown_env` ends. It raises an error if any line has not run.

- teardown_env:

  Environment that controls when the coverage check runs. Defaults to
  the calling environment, e.g. the `test_that()` block.

## Value

A
[mighty_component_test](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_test.md)
object.

## See also

[`get_rendered_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
[mighty_component_test](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_test.md)

## Examples

``` r
path <- system.file("examples", "ady.mustache", package = "mighty.component")
x <- get_test_component(
  component = path,
  params = list(domain = "adae", variable = "ASTDY", date = "ASTDT"),
  check_coverage = FALSE
)
#> → Found "ady.mustache" in "local::/home/runner/work/_temp/Library/mighty.component/examples"

adae <- data.frame(
  TRTSDT = as.Date("2024-01-01"),
  ASTDT = as.Date(c("2024-01-01", "2024-01-10"))
)

x$assign("adae", adae)$eval()
x$get("adae")
#>       TRTSDT      ASTDT ASTDY
#> 1 2024-01-01 2024-01-01     1
#> 2 2024-01-01 2024-01-10    10
x$percent_coverage
#> [1] 100
x$close()
```
