# Retrieve mighty standard component

Retrieve either the generalized standard component (template) or the
rendered standard component with code that is ready to use.

- `get_standard()`: Returns an object of class `mighty_component`

- `get_rendered_standard()`: Returns an object of class
  `mighty_component_rendered`

When rendering the standard the required list of parameters depends on
the standard. Check the documentation of the specific standard for
details.

## Usage

``` r
get_standard(standard)

get_rendered_standard(standard, params = list())
```

## Arguments

- standard:

  `character` name of the standard component to retrieve.

- params:

  named `list` of input parameters. Passed along to
  `mighty_component$render()`.

## See also

[`list_standards()`](https://nn-opensource.github.io/mighty.component/reference/list_standards.md),
[mighty_component](https://nn-opensource.github.io/mighty.component/reference/mighty_component.md),
[mighty_component_rendered](https://nn-opensource.github.io/mighty.component/reference/mighty_component_rendered.md)

## Examples

``` r
get_standard("ady")
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

get_rendered_standard("ady", list(domain = "advs", variable = "ASTDY", date = "ASTDT"))
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
