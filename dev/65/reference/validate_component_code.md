# Validate component code

Validate component code

## Usage

``` r
validate_component_code(code, validators = .default_validators())
```

## Arguments

- code:

  Character string of R code to validate

- validators:

  List of validator functions to run

## Value

Invisible NULL on success, throws error if validation fails
