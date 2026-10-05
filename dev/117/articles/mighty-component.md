# Getting Started with mighty.component

``` r

library(mighty.component)
```

## What is a component?

A component is a reusable code template for one data transformation
step. Its code takes an input data set and returns it with new or
changed columns or rows. Mustache placeholders, such as `{{{domain}}}`,
are filled in when the component is rendered, so the same template works
across studies. Roxygen-like tags, such as `@title`, `@param` and
`@depends`, document what the component does, needs and creates.

Components are commonly used to build ADaM (Analysis Data Model)
programs. Each component handles one derivation, and several components
make up a program. In the mighty ecosystem, mighty.metadata provides
study configuration (via
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.html)
and `_study.yml`) that controls which components are rendered and with
which parameters.

## Anatomy of a component template

Below is a minimal component that creates a column as two times an
existing column:

``` r
#' @title Double a column
#' @description
#' Creates a new column as two times an existing column.
#'
#' @param domain `character` Name of the domain
#' @param output `character` Name of the new column
#' @param input `character` Name of the existing column
#' @type column
#' @origin Derived
#' @method Two times the input column
#' @depends {{{domain}}} {{{input}}}
#' @outputs {{{output}}}
#' @code
{{{domain}}} <- {{{domain}}} |>
  dplyr::mutate(
    {{{output}}} = 2 * {{{input}}}
  )
```

The template syntax is described below.

### Templates

A template starts with tags in roxygen comments (`#'`). All lines below
the `@code` tag are the R code.

Templates use [Mustache](https://mustache.github.io/mustache.5.html)
placeholders. `$render()` fills them in with
[`whisker::whisker.render()`](https://rdrr.io/pkg/whisker/man/whisker.render.html).

- `{{{name}}}` inserts the value of parameter `name`. Always use triple
  braces. Double braces (`{{name}}`) HTML-escape the value, e.g. `a<b`
  becomes `a&lt;b`.
- `{{#name}}...{{/name}}` repeats the enclosed text for each element of
  the vector `name`. Use `{{{.}}}` to insert the current element.

### Tags

A tag continues until the next tag. Required tags must appear exactly
once.

| Tag | Required | Description | Example |
|----|----|----|----|
| `@title` | Yes | Title of the component. | `@title Double a column` |
| `@description` | Yes | Description of the component. | `@description Creates a new column.` |
| `@param` | No | Name, then description. One per placeholder. | `` @param domain `character` Name of the domain `` |
| `@type` | Yes | Component type. See *Types* below. | `@type column` |
| `@origin` | Yes | CDISC origin. See allowed values below. | `@origin Derived` |
| `@method` | Yes | Free-text method description for define.xml. | `@method Two times the input column` |
| `@depends` | No | Input domain, then column. Repeat for each. | `@depends {{{domain}}} USUBJID` |
| `@outputs` | No | Column created. Repeat for each. | `@outputs {{{output}}}` |
| `@code` | Yes | Last tag. All lines below are the code. | `@code` |

`@origin` must be one of `Assigned`, `Collected`, `Derived`,
`Not Available`, `Other`, `Predecessor`, `Protocol`.

`@depends` is split at the first space into domain and column. Do not
use spaces inside its placeholders, e.g. use `{{{domain}}}`, not
`{{{ domain }}}`.

### Types

- `column`: Adds or modifies columns. The row count is unchanged.
- `row`: Adds, removes or modifies rows.
- `parameter`: Derives a new `PARAMCD` (BDS parameter).
- `internal`: Helper step with no define.xml output.

### Conventions

1.  The input data set is `{{{domain}}}`.
2.  The code assigns the result back to `{{{domain}}}`.
3.  Every placeholder is declared with `@param`.
4.  Functions are called with explicit namespaces,
    e.g. [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html).
5.  Joins specify `by`. This is enforced when rendering.

See
[`?mighty_component`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component.md)
for validation rules and a rendered example.

## Retrieve and inspect a component

List the example components shipped with the package:

``` r

path <- system.file("examples", package = "mighty.component")
list_components(path)
#> [1] "ady"
```

Retrieve one by file path:

``` r

ady <- get_component(
  system.file("examples", "ady.mustache", package = "mighty.component")
)
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

Access individual fields:

``` r

ady$id
#> [1] "ady"
ady$title
#> [1] "Analysis relative day"
ady$type
#> [1] "column"
ady$params
#>       name                                  description
#> 1   domain `character` Name of new domain being created
#> 2 variable   `character` Name of new variable to create
#> 3     date     `character` Name of date variable to use
ady$depends
#>         domain     column
#> 1 {{{domain}}} {{{date}}}
#> 2 {{{domain}}}     TRTSDT
ady$outputs
#> [1] "{{{variable}}}"
ady$origin
#> [1] "Derived"
ady$method
#> [1] "Relative day computed from treatment start date"
```

## Render a component

Rendering fills in the placeholders with values. `$render()` takes one
named argument per `@param` tag and returns a
`mighty_component_rendered` object. Every placeholder is now a name:

``` r

ady_rendered <- ady$render(domain = "ADAE", variable = "ASTDY", date = "ASTDT")
ady_rendered
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

The rendered code is validated: it must be valid R, and joins must
specify `by` (see [Automatic code
validation](#automatic-code-validation)). Columns are not checked. Use
[`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md)
(see [Testing components](#testing-components)) to run a component on
real data.

[`get_rendered_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md)
retrieves and renders in one step. It takes the parameters as a named
`list`:

``` r

get_rendered_component(
  system.file("examples", "ady.mustache", package = "mighty.component"),
  list(domain = "ADAE", variable = "ASTDY", date = "ASTDT")
)
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

A missing parameter raises an error:

``` r

ady$render(domain = "ADAE")
#> Error in `ms_render()`:
#> ! Parameter names not matching component requirements:
#> ✖ `variable` not specified
#> ✖ `date` not specified
```

## Evaluate rendered code

`$eval()` runs the code. By default it runs in the calling environment.
Use the `envir` argument to choose another environment. The code assigns
the result back to the domain (e.g., `ADAE <- ADAE |> ...`), so `ADAE`
is updated without assigning the return value.

``` r

ADAE <- pharmaverseadam::adae |>
  dplyr::select(USUBJID, ASTDT, TRTSDT)

names(ADAE)
#> [1] "USUBJID" "ASTDT"   "TRTSDT"
```

`ASTDY` does not exist yet. Run the rendered component:

``` r

ady_rendered$eval()
names(ADAE)
#> [1] "USUBJID" "ASTDT"   "TRTSDT"  "ASTDY"
head(ADAE)
#> # A tibble: 6 × 4
#>   USUBJID     ASTDT      TRTSDT     ASTDY
#>   <chr>       <date>     <date>     <dbl>
#> 1 01-701-1015 2014-01-03 2014-01-02     2
#> 2 01-701-1015 2014-01-03 2014-01-02     2
#> 3 01-701-1015 2014-01-09 2014-01-02     8
#> 4 01-701-1023 2012-08-07 2012-08-05     3
#> 5 01-701-1023 2012-08-07 2012-08-05     3
#> 6 01-701-1023 2012-08-07 2012-08-05     3
```

`$stream()` appends the code to an R script instead:

``` r

script_file <- tempfile(fileext = ".R")
ady_rendered$stream(script_file)
readLines(script_file)
#>  [1] "ADAE <- ADAE |>"                       
#>  [2] "  dplyr::mutate("                      
#>  [3] "    ASTDY = admiral::compute_duration("
#>  [4] "      start_date = TRTSDT,"            
#>  [5] "      end_date = ASTDT,"               
#>  [6] "      in_unit = 'days',"               
#>  [7] "      out_unit = 'days',"              
#>  [8] "      add_one = TRUE"                  
#>  [9] "    )"                                 
#> [10] "  )"
```

## Writing a custom component

Write your own components as `.mustache` files. This component derives
the ratio of the analysis value to baseline:

``` r
#' @title Ratio to baseline
#' @description
#' Derives the ratio of the analysis value to the baseline value.
#'
#' @param domain `character` Name of the domain
#' @param variable `character` Name of the new ratio variable
#' @type column
#' @origin Derived
#' @method Ratio of AVAL to BASE
#' @depends {{{domain}}} AVAL
#' @depends {{{domain}}} BASE
#' @outputs {{{variable}}}
#' @code
{{{domain}}} <- {{{domain}}} |>
  dplyr::mutate(
    {{{variable}}} = dplyr::if_else(BASE != 0, AVAL / BASE, NA_real_)
  )
```

Save the template as `r2base.mustache`. Then load, render and run it:

``` r

r2base <- get_component(r2base_file)
r2base
#> <mighty_component/R6>
#> r2base: Ratio to baseline
#> Type: column
#> Parameters:
#> • domain: `character` Name of the domain
#> • variable: `character` Name of the new ratio variable
#> Depends:
#> • {{{domain}}}.AVAL
#> • {{{domain}}}.BASE
#> Outputs:
#> • {{{variable}}}
```

``` r

r2base_rendered <- r2base$render(
  domain = "ADLB",
  variable = "R2BASE"
)
r2base_rendered$code
#> [1] "ADLB <- ADLB |>"                                              
#> [2] "  dplyr::mutate("                                             
#> [3] "    R2BASE = dplyr::if_else(BASE != 0, AVAL / BASE, NA_real_)"
#> [4] "  )"
```

``` r

ADLB <- pharmaverseadam::adlb |>
  dplyr::filter(PARAMCD == "ALB") |>
  dplyr::select(USUBJID, PARAMCD, AVISIT, AVAL, BASE)

head(ADLB)
#> # A tibble: 6 × 5
#>   USUBJID     PARAMCD AVISIT                 AVAL  BASE
#>   <chr>       <chr>   <chr>                 <dbl> <dbl>
#> 1 01-701-1015 ALB     Baseline                 38    38
#> 2 01-701-1015 ALB     Week 2                   39    38
#> 3 01-701-1015 ALB     POST-BASELINE MAXIMUM    39    38
#> 4 01-701-1015 ALB     Week 4                   38    38
#> 5 01-701-1015 ALB     Week 6                   37    38
#> 6 01-701-1015 ALB     POST-BASELINE MINIMUM    37    38

r2base_rendered$eval()

ADLB |>
  dplyr::select(USUBJID, PARAMCD, AVISIT, AVAL, BASE, R2BASE) |>
  head()
#> # A tibble: 6 × 6
#>   USUBJID     PARAMCD AVISIT                 AVAL  BASE R2BASE
#>   <chr>       <chr>   <chr>                 <dbl> <dbl>  <dbl>
#> 1 01-701-1015 ALB     Baseline                 38    38  1    
#> 2 01-701-1015 ALB     Week 2                   39    38  1.03 
#> 3 01-701-1015 ALB     POST-BASELINE MAXIMUM    39    38  1.03 
#> 4 01-701-1015 ALB     Week 4                   38    38  1    
#> 5 01-701-1015 ALB     Week 6                   37    38  0.974
#> 6 01-701-1015 ALB     POST-BASELINE MINIMUM    37    38  0.974
```

## Component repos

A component repo is a collection of components.
[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
[`find_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/find_component.md)
and
[`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md)
take a `repos` argument with one or more repo specs:

- A local directory, e.g. `"inst/components"` or
  `"local::inst/components"`.
- A GitHub repository, e.g. `"github::owner/repo/subdir@ref"`. Requires
  the gh and remotes packages.
- Raw files under a URL, e.g. `"url::https://example.com/components"`.
  Requires httr2 (\>= 1.2.2).

A component `name` is the file `<name>.mustache` or `<name>.R`, either
directly in the repo or in a directory `<name>/`. See
[`?mighty_repo`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md)
for details.

Put the `r2base` component from above in a team repo, together with a
modified copy of `ady`:

``` r

examples <- system.file("examples", package = "mighty.component")
team_repo <- tempfile("team")
dir.create(team_repo)
invisible(file.copy(r2base_file, team_repo))

ady_template <- readLines(file.path(examples, "ady.mustache"))
ady_template[[1]] <- "#' @title Analysis relative day (team version)"
writeLines(ady_template, file.path(team_repo, "ady.mustache"))
```

Several repos are searched in order, and the first match wins. Here
`ady` is found in the team repo:

``` r

repos <- c(team_repo, examples)
list_components(repos)
#> [1] "ady"    "r2base"
get_component("ady", repos = repos)$title
#> [1] "Analysis relative day (team version)"
```

Reverse the order to use `ady` from the examples:

``` r

get_component("ady", repos = rev(repos))$title
#> [1] "Analysis relative day"
```

[`find_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/find_component.md)
returns `NULL` if no repo contains the component.
[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md)
raises an error:

``` r

is.null(find_component("adt", repos = repos))
#> [1] TRUE
get_component("adt", repos = repos)
#> Error in `get_component()`:
#> ! Component `adt` not found
```

`list_components(as = "tibble")` returns the metadata of each component.
It requires the tibble and tidyr packages:

``` r

list_components(repos, as = "tibble") |>
  dplyr::select(id, title, type, origin)
#> # A tibble: 2 × 4
#>   id     title                                type   origin 
#>   <chr>  <chr>                                <chr>  <chr>  
#> 1 ady    Analysis relative day (team version) column Derived
#> 2 r2base Ratio to baseline                    column Derived
```

A character vector is converted to repos on each call. Use
[`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md)
to create the repos once and reuse them. GitHub and URL repos need
network access:

``` r

repos <- mighty_repos(c(
  "github::owner/repo/components@main",
  "url::https://example.com/components",
  examples
))
get_component("ady", repos = repos)
```

See
[`?mighty_repo_github`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_github.md)
and
[`?mighty_repo_url`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_url.md)
for authentication and retries.

## Automatic code validation

Rendered code is validated. It must be valid R, and joins from dplyr,
tidylog and dbplyr must specify `by`. Implicit joins are a common source
of bugs when key columns differ between studies.

This component fails validation:

``` r

#' @title Bad join example
#' @description Implicit join that will fail validation.
#'
#' @param domain `character` Name of the domain
#' @type row
#' @origin Derived
#' @method Implicit join on other_data
#' @depends {{{domain}}} USUBJID
#' @outputs NEWCOL
#' @code
{{{domain}}} <- {{{domain}}} |>
  dplyr::left_join(other_data)
```

``` r

get_rendered_component(bad_file, list(domain = "ADAE"))
#> Error in `abort_validation_errors()`:
#> ! Component validation failed:
#> 
#> ! Implicit dplyr join(s) detected in rendered component:
#> ✖ Join operations must explicitly specify the `by` argument
#> ℹ Line 2: dplyr::left_join
```

Specify the join key with `by` to fix it:

``` r

#' @title Good join example
#' @description Explicit join that passes validation.
#'
#' @param domain `character` Name of the domain
#' @type row
#' @origin Derived
#' @method Explicit join on other_data by USUBJID
#' @depends {{{domain}}} USUBJID
#' @outputs NEWCOL
#' @code
{{{domain}}} <- {{{domain}}} |>
  dplyr::left_join(other_data, by = dplyr::join_by(USUBJID))
```

``` r

get_rendered_component(good_file, list(domain = "ADAE"))$code
#> [1] "ADAE <- ADAE |>"                                             
#> [2] "  dplyr::left_join(other_data, by = dplyr::join_by(USUBJID))"
```

## Testing components

[`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md)
creates a component that runs in a separate R session and tracks code
coverage. Use it for interactive checks and for unit tests with
testthat.

By default (`check_coverage = TRUE`), coverage is checked when the
calling environment ends, e.g. the `test_that()` block. An error is
raised if any line has not run. This vignette is not a test, so it sets
`check_coverage = FALSE`.

``` r

ady_path <- system.file(
  "examples", "ady.mustache",
  package = "mighty.component"
)
ady_test <- get_test_component(
  component = ady_path,
  params = list(domain = "ADAE", variable = "ASTDY", date = "ASTDT"),
  check_coverage = FALSE # keep the default TRUE in tests
)
ady_test
#> <mighty_component_test/mighty_component_rendered/mighty_component/R6>
#> ady: Derives the relative day compared to the treatment start date.
#> Test Coverage: 0.00%
#> Code: (✔ Covered, ✖ Uncovered)
#> ✖ ADAE <- ADAE |>
#> ✖   dplyr::mutate(
#> ✖     ASTDY = admiral::compute_duration(
#> ✖       start_date = TRTSDT,
#> ✖       end_date = ASTDT,
#> ✖       in_unit = 'days',
#> ✖       out_unit = 'days',
#> ✖       add_one = TRUE
#> ✖     )
#> ✖   )
```

Assign input data in the test session:

``` r

adae_input <- pharmaverseadam::adae |>
  dplyr::select(USUBJID, ASTDT, TRTSDT)

ady_test$assign("ADAE", adae_input)
ady_test$ls()
#> [1] "ADAE"
```

Run the component and get the result:

``` r

ady_test$eval()
ady_test$get("ADAE") |> head()
#> # A tibble: 6 × 4
#>   USUBJID     ASTDT      TRTSDT     ASTDY
#>   <chr>       <date>     <date>     <dbl>
#> 1 01-701-1015 2014-01-03 2014-01-02     2
#> 2 01-701-1015 2014-01-03 2014-01-02     2
#> 3 01-701-1015 2014-01-09 2014-01-02     8
#> 4 01-701-1023 2012-08-07 2012-08-05     3
#> 5 01-701-1023 2012-08-07 2012-08-05     3
#> 6 01-701-1023 2012-08-07 2012-08-05     3
```

Every line of the code has now run:

``` r

# Print method
ady_test
#> <mighty_component_test/mighty_component_rendered/mighty_component/R6>
#> ady: Derives the relative day compared to the treatment start date.
#> Test Coverage: 100.00%
#> Code: (✔ Covered, ✖ Uncovered)
#> ✔ ADAE <- ADAE |>
#> ✔   dplyr::mutate(
#> ✔     ASTDY = admiral::compute_duration(
#> ✔       start_date = TRTSDT,
#> ✔       end_date = ASTDT,
#> ✔       in_unit = 'days',
#> ✔       out_unit = 'days',
#> ✔       add_one = TRUE
#> ✔     )
#> ✔   )
# Percent coverage
ady_test$percent_coverage
#> [1] 100
# Line coverage as a data.frame
ady_test$line_coverage
#>    line value
#> 1     1     1
#> 2     2     1
#> 3     3     1
#> 4     4     1
#> 5     5     1
#> 6     6     1
#> 7     7     1
#> 8     8     1
#> 9     9     1
#> 10   10     1
```

In a testthat file, create the test component inside `test_that()`,
assign data, evaluate and test the results. Coverage is checked when the
test ends. See
[`?mighty_component_test`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_component_test.md)
for the workflow.
