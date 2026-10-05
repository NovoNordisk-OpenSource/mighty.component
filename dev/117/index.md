# mighty.component

mighty.component serves as a repository of generic compute component
classes used to produce ADaM scripts in the {mighty} framework.

## Installation

You can install the development version of `mighty.component` from
GitHub with:

``` r

pak::pak("NovoNordisk-OpenSource/mighty.component")
```

## Usage

`mighty.component` provides generic classes to work with mighty
components, and helper functions to retrieve them.

Retrieve a component from a template file and render it with its
parameters:

``` r

library(mighty.component)

ady <- get_component(
  system.file("examples", "ady.mustache", package = "mighty.component")
)
ady$render(domain = "ADAE", variable = "ASTDY", date = "ASTDT")
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
```

Components can also be retrieved by name from one or more repos: local
directories, `github::owner/repo/subdir@ref`, or `url::https://...`.
Repos are searched in order, and the first match is used.

``` r

get_component(
  "ady",
  repos = system.file("examples", package = "mighty.component")
)
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

See
[`vignette("mighty-component")`](https://novonordisk-opensource.github.io/mighty.component/articles/mighty-component.md)
on how to work with components and repos.
