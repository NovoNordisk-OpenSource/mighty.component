
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mighty.component <a href="https://novonordisk-opensource.github.io/mighty.component"><img src="man/figures/logo.png" align="right" height="139" alt="mighty.component website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/NovoNordisk-OpenSource/mighty.component/actions/workflows/check_and_co.yaml/badge.svg)](https://github.com/NovoNordisk-OpenSource/mighty.component/actions/workflows/check_and_co.yaml)
<!-- badges: end -->

mighty.component provides reusable code templates, called components,
for the {mighty} framework, used to generate ADaM programs. Components
are Mustache templates documented with roxygen-like tags. Retrieve them
from local directories, GitHub or URLs, then render, validate, evaluate
and test them.

## Installation

You can install the development version of `mighty.component` from
GitHub with:

``` r
pak::pak("NovoNordisk-OpenSource/mighty.component")
```

## Usage

Get a component by name from a repo. Repos can be local directories,
`github::owner/repo/subdir@ref` or `url::https://...`. With several
repos, they are searched in order and the first match is used.

``` r
library(mighty.component)

repo <- system.file("examples", package = "mighty.component")
ady <- get_component("ady", repos = repo)
ady
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

Render it with study-specific parameters:

``` r
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

Rendered components can be evaluated with `$eval()`, written to a script
with `$stream()`, and unit tested with `get_test_component()`. See
`vignette("mighty-component")` for details.
