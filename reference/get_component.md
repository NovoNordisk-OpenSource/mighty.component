# Retrieve mighty code component

Retrieve a mighty code component, supporting both built-in standards and
custom components from local files.

- `get_component()`: Returns an object of class `mighty_component`
  containing the standard or custom component.

- `get_rendered_component()`: Returns an object of class
  `mighty_component_rendered` containing the rendered code component

When rendering a component the required list of parameters depends on
the individual component. Check the documentation of the specific
standard, or the local component, for details.

## Usage

``` r
get_component(component)

get_rendered_component(component, params = list())
```

## Arguments

- component:

  `character` specifying either a standard component name or path to a
  custom component file (R or Mustache template).

- params:

  named `list` of input parameters. Passed along to
  `mighty_component$render()`.

## Details

Processes different component types based on file extension or component
name:

- *No extension*: Looks for built-in standard components with that name.

- `.R`: Extracts and renders custom functions.

- `.mustache`: Creates components from the template files.

## See also

[`get_standard()`](https://NovoNordisk-OpenSource.github.io/mighty.component/reference/get_standard.md),
[`get_rendered_standard()`](https://NovoNordisk-OpenSource.github.io/mighty.component/reference/get_standard.md),
[mighty_component](https://NovoNordisk-OpenSource.github.io/mighty.component/reference/mighty_component.md),
[mighty_component_rendered](https://NovoNordisk-OpenSource.github.io/mighty.component/reference/mighty_component_rendered.md)

## Examples

``` r
get_component("ady")
#> <mighty_component/R6>
#> ady: Derives the relative day compared to the treatment start date.
#> Type: derivation
#> Parameters:
#> • domain: `character` Name of new domain being created
#> • variable: `character` Name of new variable to create
#> • date: `character` Name of date variable to use
#> Depends:
#> • {{domain}}.{{date}}
#> • {{domain}}.TRTSDT
#> Outputs:
#> • {{variable}}

get_rendered_component("ady", list(domain = "advs", variable = "ASTDY", date = "ASTDT"))
#> <mighty_component_rendered/mighty_component/R6>
#> ady: Derives the relative day compared to the treatment start date.
#> Type: derivation
#> Depends:
#> • advs.ASTDT
#> • advs.TRTSDT
#> Outputs:
#> • ASTDY
#> Code:
#> advs <- advs |>
#>   dplyr::mutate(
#>     ASTDY = admiral::compute_duration(
#>       start_date = TRTSDT,
#>       end_date = ASTDT,
#>       in_unit = "days",
#>       out_unit = "days",
#>       add_one = TRUE
#>     )
#>   )
```
