# Retrieve mighty code component

Retrieve a mighty code component.

- `get_component()`: Returns an object of class `mighty_component`.

- `get_rendered_component()`: Returns an object of class
  `mighty_component_rendered`.

When rendering a component the required list of parameters depends on
the individual component. Check the documentation of the local component
for details.

## Usage

``` r
get_component(component, repos = NULL)

get_rendered_component(component, params = list(), repos = NULL)
```

## Arguments

- component:

  `character` component name, or path to a component file (`.R` or
  `.mustache`) when `repos` is `NULL`. The directory of the path must
  exist.

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

- params:

  named `list` of input parameters. Passed along to
  `mighty_component$render()`.

## Details

Processes different component types based on file extension:

- `.R`: Extracts and renders custom functions.

- `.mustache`: Creates components from the template files.

## See also

[mighty_component](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md),
[mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)

## Examples

``` r
path <- system.file("examples", "ady.mustache", package = "mighty.component")
get_component(path)
#> → Found "ady.mustache" in "local::/home/runner/work/_temp/Library/mighty.component/examples"
#> <mighty_component/R6>
#> ady: Analysis relative day
#> Type: column
#> Parameters:
#> • domain: `character` Name of new domain being created
#> • variable: `character` Name of new variable to create
#> • date: `character` Name of date variable to use
#> Depends:
#> • {{{domain}}}.{{{date}}}
#> • {{{domain}}}.TRTSDT
#> Outputs:
#> • {{{variable}}}
```
