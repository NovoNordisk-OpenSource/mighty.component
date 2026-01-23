# Validate that code has no implicit dplyr joins

This function checks R code for join operations (left_join, right_join,
etc.) that don't explicitly specify the join keys via the 'by' argument.
Throws an error if any implicit joins are detected.

## Usage

``` r
validate_implicit_join(code, namespaces = c("dplyr", "tidylog", "dbplyr"))
```

## Arguments

- code:

  Character string of R code to validate

- namespaces:

  Character vector of package namespaces to check. Default includes
  "dplyr", "tidylog", and "dbplyr". Can be customized to include other
  packages that export join functions.

## Value

Invisible NULL on success, throws error if implicit joins found
