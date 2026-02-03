# Create test component

Create test component

## Usage

``` r
test_component(
  component,
  params,
  check_coverage = TRUE,
  teardown_env = parent.frame()
)
```

## Arguments

- component:

  `character` specifying either a standard component name or path to a
  custom component file (R or Mustache template).

- params:

  named `list` of input parameters. Passed along to
  `mighty_component$render()`.

- check_coverage:

  `logical(1)`

- teardown_env:

  Environment used
