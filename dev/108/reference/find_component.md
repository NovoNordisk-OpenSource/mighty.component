# Find mighty code component

Look up a component in one or more repos. Unlike
[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
returns `NULL` instead of raising an error when the component is not
found.

## Usage

``` r
find_component(component, repos)
```

## Arguments

- component:

  `character` component name, or path to a component file (`.R` or
  `.mustache`) when `repos` is `NULL` or missing.

- repos:

  Where to look. One of:

  - `NULL` or missing: `component` is a file path.

  - `character` vector of repo specs, in priority order. See
    [`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md).

  - A `mighty_repo_class` object.

  - A `list` of repo specs or `mighty_repo_class` objects, in priority
    order.

  - A
    [`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md)
    collection.

  Character vectors and lists are converted with
  [`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md).
  GitHub refs are resolved once per session. See
  [`mighty_repo_github()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_github.md).

## Value

A
[mighty_component](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)
object, or `NULL` if not found.

## See also

[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
[`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md)

## Examples

``` r
path <- system.file("examples", package = "mighty.component")
find_component("ady", repos = path)
#> → Found "ady" in "local::/home/runner/work/_temp/Library/mighty.component/examples"
#> <mighty_component/R6>
#> ady.mustache: Analysis relative day
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

find_component("does_not_exist", repos = path)
```
