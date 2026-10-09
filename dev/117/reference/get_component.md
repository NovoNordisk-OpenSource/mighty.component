# Retrieve a component

- `get_component()`: Find a component. Raises an error if it is not
  found.

- `get_rendered_component()`: Find a component and render it with
  `params`.

## Usage

``` r
get_component(component, repos = NULL)

get_rendered_component(component, params = list(), repos = NULL)
```

## Arguments

- component:

  `character(1)` Component name. If `repos` is `NULL`, path to a
  component file, with or without extension.

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

  named `list` of parameters passed to `$render()`. See the component's
  `@param` tags (`component$params`).

## Value

- `get_component()`: A
  [mighty_component](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)
  object.

- `get_rendered_component()`: A
  [mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)
  object.

## Details

Components are `.mustache` or `.R` files. Both use the tags described in
[mighty_component](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md).

- `.mustache` files are Mustache templates.

- `.R` files are plain R components. They cannot have `@param` tags or
  Mustache placeholders.

## See also

[`find_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/find_component.md),
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

get_rendered_component(
  component = path,
  params = list(domain = "ADAE", variable = "ASTDY", date = "ASTDT")
)
#> → Found "ady.mustache" in "local::/home/runner/work/_temp/Library/mighty.component/examples"
#> <mighty_component_rendered/mighty_component/R6>
#> ady: Analysis relative day
#> Type: column
#> Depends:
#> • ADAE.ASTDT
#> • ADAE.TRTSDT
#> Outputs:
#> • ASTDY
#> Code:
#> ADAE <- ADAE |>
#>   dplyr::mutate(
#>     ASTDY = admiral::compute_duration(
#>       start_date = TRTSDT,
#>       end_date = ASTDT,
#>       in_unit = 'days',
#>       out_unit = 'days',
#>       add_one = TRUE
#>     )
#>   )

# Find by name in a repo
repo <- system.file("examples", package = "mighty.component")
get_component("ady", repos = repo)
#> → Found "ady" in "local::/home/runner/work/_temp/Library/mighty.component/examples"
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
