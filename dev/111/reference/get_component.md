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
  `.mustache`) when `repos` is `NULL`.

- repos:

  prioritized `character` vector of locations to look for component in.
  See details.

- params:

  named `list` of input parameters. Passed along to
  `mighty_component$render()`.

## Details

Processes different component types based on file extension:

- `.R`: Extracts and renders custom functions.

- `.mustache`: Creates components from the template files.

The `repos` parameter accepts a character vector of repo specs, in
priority order. See
[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md).

When `repos` is `NULL`, `component` is a path to a component file.
Otherwise `component` is a component name, with or without extension,
looked up in `repos`.

## See also

[mighty_component](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md),
[mighty_component_rendered](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)

## Examples

``` r
path <- system.file("examples", "ady.mustache", package = "mighty.component")
get_component(path)
#> → Found "ady.mustache" in "local::/home/runner/work/_temp/Library/mighty.component/examples"
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
```
