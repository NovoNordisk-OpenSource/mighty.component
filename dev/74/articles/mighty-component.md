# Getting Started with mighty.component

``` r
library(mighty.component)
```

## What is a mighty component?

Components let you write a data transformation once and reuse it across
studies by swapping variable names at render time. Instead of copying
and modifying code for each new study, you maintain a single template.

A mighty component is a reusable code template for a single,
well-defined data transformation step. Components are commonly used to
generate ADaM (Analysis Dataset Model) programs, but the concept is
general: any parameterized R code snippet that reads a data set,
modifies it, and writes it back can be expressed as a component.

Components combine two ideas:

- **Mustache templating** — placeholders like `{{ domain }}` are filled
  in at render time, so the same logic works across different data sets
  and variables.
- **Roxygen-like documentation** — tags like `@title`, `@param`, and
  `@depends` describe what the component does, what it needs, and what
  it produces.

Think of components as reusable building blocks: each one handles a
single derivation or transformation, and you compose several of them to
build a complete program.

## Anatomy of a component template

Below is a minimal component that doubles a column. Every tag is visible
at a glance:

    #' @title Double a variable
    #' @description
    #' Creates a new column that is twice the value of an existing column.
    #'
    #' @param domain `character` Name of the domain (data frame)
    #' @param input `character` Name of the existing column to double
    #' @param output `character` Name of the new column to create
    #' @type derivation
    #' @depends {{domain}} {{input}}
    #' @outputs {{output}}
    #' @code
    {{domain}} <- {{domain}} |>
      dplyr::mutate(
        {{output}} = 2 * {{input}}
      )

### Tags reference

| Tag                       | Purpose                                                               |
|---------------------------|-----------------------------------------------------------------------|
| `@title`                  | One-line title (required)                                             |
| `@description`            | Multi-line description (required)                                     |
| `@param name description` | Declares a Mustache placeholder the user must supply at render time   |
| `@type`                   | Semantic type: `derivation`, `predecessor`, `assigned`, or `row`      |
| `@depends domain column`  | Declares that the code reads `column` from `domain` (repeat for each) |
| `@outputs variable`       | Declares a column the code creates (repeat for each)                  |
| `@code`                   | Everything below this tag is executable R code                        |

### Mustache syntax

Components use [Mustache](https://mustache.github.io) — a simple,
logic-less templating language. Inside `@code`, `{{ }}` are Mustache
placeholders, not R syntax. They are text-replaced with concrete values
before the code is parsed as R. Rendering is done by the
[whisker](https://github.com/edwindj/whisker) R package.

The three patterns used in components are:

- **`{{ variable }}`** — replaced with the value supplied at render
  time.
- **`{{{ variable }}}`** — unescaped replacement. Used when the value is
  literal R code (e.g., `{{{ value }}}` to insert `1`, `"text"`, or an
  expression).
- **`{{#list}}...{{/list}}`** — repeats its body once for each element
  of a vector parameter.

See the [Mustache manual](https://mustache.github.io/mustache.5.html)
for the full syntax reference.

### Conventions

1.  The input data set is always called `{{ domain }}`.
2.  The code must assign the result back to `{{ domain }}`.
3.  Use explicit package namespaces
    ([`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html),
    not `mutate()`).
4.  Joins must always specify an explicit `by` argument — this is
    enforced by automatic validation (see [Automatic code
    validation](#automatic-code-validation)).

## Retrieve and inspect a component

List the built-in standard components:

``` r
list_standards()
#> [1] "ady"         "aendt"       "assign"      "astdt"       "predecessor"
#> [6] "supp_sdtm"   "trtemfl"
```

Retrieve one by name:

``` r
ady <- get_component("ady")
ady
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
```

Access individual fields through the active bindings:

``` r
ady$title
#> [1] "Analysis relative day"
ady$type
#> [1] "derivation"
ady$params
#>       name                                  description
#> 1   domain `character` Name of new domain being created
#> 2 variable   `character` Name of new variable to create
#> 3     date     `character` Name of date variable to use
ady$depends
#>       domain   column
#> 1 {{domain}} {{date}}
#> 2 {{domain}}   TRTSDT
ady$outputs
#> [1] "{{variable}}"
```

You can also retrieve a component from a local `.mustache` or `.R` file
by passing the file path to
[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md).

[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md)
is the recommended entry point — it handles both built-in standards and
custom files. If you know you only need a built-in standard, you can
also use
[`get_standard()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_standard.md)
and
[`get_rendered_standard()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_standard.md)
directly.

## Render a component

Rendering fills in the Mustache placeholders with concrete values. The
`$render()` method takes parameters as named arguments and returns a
`mighty_component_rendered` object. Notice every `{{ }}` placeholder is
now a concrete name:

``` r
ady_rendered <- ady$render(domain = "adae", variable = "ASTDY", date = "ASTDT")
ady_rendered
#> <mighty_component_rendered/mighty_component/R6>
#> ady: Derives the relative day compared to the treatment start date.
#> Type: derivation
#> Depends:
#> • adae.ASTDT
#> • adae.TRTSDT
#> Outputs:
#> • ASTDY
#> Code:
#> adae <- adae |>
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

A convenience function combines retrieval and rendering in one step. It
returns the same rendered component as above. Note that
[`get_rendered_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md)
takes parameters as a named `list`, unlike `$render()` which takes
`...`:

``` r
get_rendered_component(
  "ady",
  list(domain = "adae", variable = "ASTDY", date = "ASTDT")
)
#> <mighty_component_rendered/mighty_component/R6>
#> ady: Derives the relative day compared to the treatment start date.
#> Type: derivation
#> Depends:
#> • adae.ASTDT
#> • adae.TRTSDT
#> Outputs:
#> • ASTDY
#> Code:
#> adae <- adae |>
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

If you omit a required parameter, you get an informative error:

``` r
ady$render(domain = "adae")
#> Error in `ms_render()`:
#> ! Parameter names not matching component requirements:
#> ✖ `variable` not specified
#> ✖ `date` not specified
```

## Evaluate rendered code

Once rendered, call `$eval()` to execute the code in your current
environment. The component code contains an assignment (e.g.,
`adae <- adae |> ...`), and `$eval()` evaluates that code in the calling
environment via `eval(envir = parent.frame())`. This means `$eval()`
modifies the domain variable in place — no assignment of the return
value is needed.

``` r
adae <- pharmaverseadam::adae |>
  dplyr::select(USUBJID, ASTDT, TRTSDT)

names(adae)
#> [1] "USUBJID" "ASTDT"   "TRTSDT"
```

The `ASTDY` column does not exist yet. Run the rendered component:

``` r
ady_rendered$eval()
#> → Evaluating component Analysis relative day
#> ℹ Code:
#> `adae <- adae |>`, ` dplyr::mutate(`, ` ASTDY = admiral::compute_duration(`, `
#> start_date = TRTSDT,`, ` end_date = ASTDT,`, ` in_unit = "days",`, ` out_unit =
#> "days",`, ` add_one = TRUE`, ` )`, and ` )`
names(adae)
#> [1] "USUBJID" "ASTDT"   "TRTSDT"  "ASTDY"
head(adae)
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

`$eval()` executes the rendered code in the calling environment by
default. You can pass a different environment via the `envir` argument
if needed.

If you want to save the rendered code to a script file instead of
evaluating it interactively, use `$stream(path)` to append the code to
an R file.

## Writing a custom component

You can author your own components as `.mustache` files. Here is a
realistic example that derives a ratio of the current value to baseline
(`R2BASE`) for a lab parameter. Save the following template to a
`.mustache` file:

    #' @title Ratio to baseline
    #' @description
    #' Derives the ratio of the analysis value to the baseline value.
    #'
    #' @param domain `character` Name of the domain
    #' @param variable `character` Name of the new ratio variable
    #' @type derivation
    #' @depends {{domain}} AVAL
    #' @depends {{domain}} BASE
    #' @outputs {{variable}}
    #' @code
    {{domain}} <- {{domain}} |>
      dplyr::mutate(
        {{variable}} = dplyr::if_else(BASE != 0, AVAL / BASE, NA_real_)
      )

After saving this template to a `.mustache` file, load, render, and run
it:

``` r
r2base <- get_component(r2base_file)
r2base
#> <mighty_component/R6>
#> /tmp/RtmpmInIzX/file1ad755841ddf.mustache: Derives the ratio of the analysis
#> value to the baseline value.
#> Type: derivation
#> Parameters:
#> • domain: `character` Name of the domain
#> • variable: `character` Name of the new ratio variable
#> Depends:
#> • {{domain}}.AVAL
#> • {{domain}}.BASE
#> Outputs:
#> • {{variable}}
```

``` r
r2base_rendered <- r2base$render(
  domain = "adlb",
  variable = "R2BASE"
)
r2base_rendered$code
#> [1] "adlb <- adlb |>"                                              
#> [2] "  dplyr::mutate("                                             
#> [3] "    R2BASE = dplyr::if_else(BASE != 0, AVAL / BASE, NA_real_)"
#> [4] "  )"
```

``` r
adlb <- pharmaverseadam::adlb |>
  dplyr::filter(PARAMCD == "ALB") |>
  dplyr::select(USUBJID, PARAMCD, AVISIT, AVAL, BASE)

head(adlb)
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
#> → Evaluating component Ratio to baseline
#> ℹ Code:
#> `adlb <- adlb |>`, ` dplyr::mutate(`, ` R2BASE = dplyr::if_else(BASE != 0, AVAL
#> / BASE, NA_real_)`, and ` )`

adlb |>
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

## Automatic code validation

When a component is rendered, the generated code is automatically
validated. The package currently checks for **implicit joins** — any
[`dplyr::left_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
[`dplyr::inner_join()`](https://dplyr.tidyverse.org/reference/mutate-joins.html),
or similar call without an explicit `by` argument triggers an error.
This prevents a common source of bugs in clinical programming where join
columns change between studies.

Here is a component that fails validation:

    #' @title Bad join example
    #' @description Implicit join that will fail validation.
    #'
    #' @param domain `character` domain name
    #' @type predecessor
    #' @depends {{domain}} USUBJID
    #' @outputs NEWCOL
    #' @code
    {{domain}} <- {{domain}} |>
      dplyr::left_join(other_data)

``` r
get_rendered_component(bad_file, list(domain = "adae"))
#> Error in `abort_validation_errors()`:
#> ! Component validation failed:
#> 
#> ! Implicit dplyr join(s) detected in rendered component:
#> ✖ Join operations must explicitly specify the `by` argument
#> ℹ Line 2: dplyr::left_join
```

The fix is to specify the join key explicitly:

    #' @title Good join example
    #' @description Explicit join that passes validation.
    #'
    #' @param domain `character` domain name
    #' @type predecessor
    #' @depends {{domain}} USUBJID
    #' @outputs NEWCOL
    #' @code
    {{domain}} <- {{domain}} |>
      dplyr::left_join(other_data, by = dplyr::join_by(USUBJID))

``` r
get_rendered_component(good_file, list(domain = "adae"))$code
#> [1] "adae <- adae |>"                                             
#> [2] "  dplyr::left_join(other_data, by = dplyr::join_by(USUBJID))"
```

## Testing components

[`get_test_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_test_component.md)
creates a component that runs in an **isolated R session** with
automatic code coverage tracking. This is useful both for interactive
exploration and for formal unit tests with `testthat`.

We set `check_coverage = FALSE` here because this code runs inside a
vignette, not inside a `test_that()` block. The default (`TRUE`) uses
[`withr::defer()`](https://withr.r-lib.org/reference/defer.html) to
automatically verify coverage when a test finishes — use that default in
your actual tests.

``` r
ady_test <- get_test_component(
  component = "ady",
  params = list(domain = "adae", variable = "ASTDY", date = "ASTDT"),
  check_coverage = FALSE
)
ady_test
#> <mighty_component_test/mighty_component_rendered/mighty_component/R6>
#> ady: Derives the relative day compared to the treatment start date.
#> Test Coverage: 0.00%
#> Code: (✔ Covered, ✖ Uncovered)
#> ✖ adae <- adae |>
#> ✖   dplyr::mutate(
#> ✖     ASTDY = admiral::compute_duration(
#> ✖       start_date = TRTSDT,
#> ✖       end_date = ASTDT,
#> ✖       in_unit = "days",
#> ✖       out_unit = "days",
#> ✖       add_one = TRUE
#> ✖     )
#> ✖   )
```

Assign input data into the isolated session:

``` r
adae_input <- pharmaverseadam::adae |>
  dplyr::select(USUBJID, ASTDT, TRTSDT)

ady_test$assign("adae", adae_input)
ady_test$ls()
#> [1] "adae"
```

Execute the component and retrieve the result:

``` r
ady_test$eval()
ady_test$get("adae") |> head()
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

Check coverage — every line of the component code should have been
executed:

``` r
# Normal print method
ady_test
#> <mighty_component_test/mighty_component_rendered/mighty_component/R6>
#> ady: Derives the relative day compared to the treatment start date.
#> Test Coverage: 100.00%
#> Code: (✔ Covered, ✖ Uncovered)
#> ✔ adae <- adae |>
#> ✔   dplyr::mutate(
#> ✔     ASTDY = admiral::compute_duration(
#> ✔       start_date = TRTSDT,
#> ✔       end_date = ASTDT,
#> ✔       in_unit = "days",
#> ✔       out_unit = "days",
#> ✔       add_one = TRUE
#> ✔     )
#> ✔   )
# Percent coverage
ady_test$percent_coverage
#> [1] 100
# Line coverage in a data.frame
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

When `check_coverage = TRUE` (the default), coverage is verified
automatically when the test object goes out of scope using
[`withr::defer()`](https://withr.r-lib.org/reference/defer.html). If any
line was not executed, an error is raised. This integrates naturally
with `testthat` test files: create the test component inside a
`test_that()` block, assign data, evaluate, and assert on the results —
coverage checking happens automatically when the test finishes.
