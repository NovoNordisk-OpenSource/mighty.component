# Retrieve mighty code component

Retrieve a mighty code component from a local file.

- `get_component()`: Returns an object of class `mighty_component`.

- `get_rendered_component()`: Returns an object of class
  `mighty_component_rendered`.

When rendering a component the required list of parameters depends on
the individual component. Check the documentation of the local component
for details.

## Usage

``` r
get_component(component)

get_rendered_component(component, params = list())
```

## Arguments

- component:

  `character` path to a component file (`.R` or `.mustache`).

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
#> <mighty_component/R6>
#> /home/runner/work/_temp/Library/mighty.component/examples/ady.mustache: Derives
#> the relative day compared to the treatment start date.
#> Type: derivation
#> Parameters:
#> • domain: `character` Name of new domain being created
#> • variable: `character` Name of new variable to create
#> • date: `character` Name of date variable to use
#> Depends:
#> • {{domain}}.{{ date }}
#> • {{domain}}.TRTSDT
#> Outputs:
#> • {{ variable }}
```
