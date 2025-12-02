# Standard components

This vignette serves as a temporary repository of the currently
available standard components inside {mighty.component}.

## ady: Analysis relative day

*type: derivation*

Derives the relative day compared to the treatment start date.

### Parameters

| name     | description                                  |
|:---------|:---------------------------------------------|
| domain   | `character` Name of new domain beind created |
| variable | `character` Name of new variable to create   |
| date     | `character` Name of date variable to use     |

### Depends

| domain     | column   |
|:-----------|:---------|
| {{domain}} | {{date}} |
| {{domain}} | TRTSDT   |

### Outputs

- {{variable}}

### Code

``` r
{{domain}} <- {{domain}} |>
  dplyr::mutate(
    {{variable}} = admiral::compute_duration(
      start_date = TRTSDT,
      end_date = {{date}},
      in_unit = "days",
      out_unit = "days",
      add_one = TRUE
    )
  )
```

## aendt: Analysis end date

*type: derivation*

Derives analysis end date based on (incomplete) dates given as character

### Parameters

| name   | description                                  |
|:-------|:---------------------------------------------|
| domain | `character` Name of new domain beind created |
| dtc    | `character` Name of date variable            |

### Depends

| domain     | column  |
|:-----------|:--------|
| {{domain}} | {{dtc}} |

### Outputs

- AENDT
- AENDTF

### Code

``` r
{{domain}} <- {{domain}} |>
  dplyr::mutate(
    AENDT = admiral::convert_dtc_to_dt(
      dtc = {{dtc}},
      highest_imputation = "M",
      date_imputation = "last"
    ),
    AENDTF = admiral::compute_dtf(
      dtc = {{dtc}},
      dt = AENDT
    )
  )
```

## assign: Assign

*type: assigned*

Assigns a single value to an entire column.

### Parameters

| name     | description                                      |
|:---------|:-------------------------------------------------|
| domain   | `character` Name of new domain beind created     |
| variable | `character` Name of variable to create or modify |
| value    | Value to assign to the variable                  |

### Depends

| domain | column |
|--------|--------|

### Outputs

- {{variable}}

### Code

``` r
{{domain}} <- {{domain}} |>
  dplyr::mutate(
    {{variable}} = {{{value}}}
  )
```

## astdt: Analysis start date

*type: derivation*

Derives analysis start date based on (incomplete) dates given as
character

### Parameters

| name   | description                                  |
|:-------|:---------------------------------------------|
| domain | `character` Name of new domain beind created |
| dtc    | `character` Name of date variable            |

### Depends

| domain     | column  |
|:-----------|:--------|
| {{domain}} | {{dtc}} |

### Outputs

- ASTDT
- ASTDTF

### Code

``` r
{{domain}} <- {{domain}} |>
  dplyr::mutate(
    ASTDT = admiral::convert_dtc_to_dt(
      dtc = {{dtc}},
      highest_imputation = "M",
      date_imputation = "first"
    ),
    ASTDTF = admiral::compute_dtf(
      dtc = {{dtc}},
      dt = ASTDT
    )
  )
```

## predecessor: Predecessor

*type: predecessor*

Creates new column(s) based on a predecessor column(s).

### Parameters

| name     | description                                              |
|:---------|:---------------------------------------------------------|
| domain   | `character` Name of new domain beind created             |
| source   | `character` Name of the data set the predecessor is from |
| variable | `character` Name of variable(s) to use from `source`     |
| by       | `character` name(s) of variable(s) to merge by           |

### Depends

| domain     | column |
|:-----------|:-------|
| {{domain}} | {{.}}  |
| {{source}} | {{.}}  |
| {{source}} | {{.}}  |

### Outputs

- {{.}}

### Code

``` r
{{domain}} <- {{domain}} |>
  dplyr::left_join(
    y = dplyr::select({{source}}, {{by}}, {{variable}}),
    by = dplyr::join_by({{by}})
  )
```

## supp_sdtm: Add Supplementary Variable from SDTM

*type: predecessor*

Add a variable from a supplementary SDTM domain.

### Parameters

| name   | description                                           |
|:-------|:------------------------------------------------------|
| domain | `character` Name of new domain beind created          |
| source | `character` Name of the supplementary data set to use |
| qnam   | `character` Name of qualifier(s) to add from `source` |

### Depends

| domain     | column   |
|:-----------|:---------|
| {{domain}} | USUBJID  |
| {{source}} | USUBJID  |
| {{source}} | IDVAR    |
| {{source}} | IDVARVAL |
| {{source}} | QNAM     |
| {{source}} | QVAL     |

### Outputs

- {{.}}

### Code

``` r
idvar <- unique({{source}}[["IDVAR"]])
idclass <- class({{domain}}[[idvar]])
idfunc <- get(paste0("as.", idclass))

supp_data <- {{source}} |>
  dplyr::select(USUBJID, IDVAR, IDVARVAL, QNAM, QVAL) |>
  tidyr::pivot_wider(names_from = QNAM, values_from = QVAL) |>
  dplyr::mutate(IDVARVAL = idfunc(IDVARVAL)) |>
  dplyr::select(USUBJID, IDVARVAL, {{qnam}})

{{domain}} <- {{domain}} |>
  dplyr::left_join(
    y = supp_data,
    by = dplyr::join_by(USUBJID, !!idvar == IDVARVAL)
  )
```

## trtemfl: Treatment-emergent flag

*type: derivation*

Derives treatment emergent analysis flag.

### Parameters

| name       | description                                  |
|:-----------|:---------------------------------------------|
| domain     | `character` Name of new domain beind created |
| end_window | Passed along to `admiral::end_window()`      |

### Depends

| domain     | column |
|:-----------|:-------|
| {{domain}} | ASTDT  |
| {{domain}} | AENDT  |
| {{domain}} | TRTSDT |
| {{domain}} | TRTEDT |

### Outputs

- TRTEMFL

### Code

``` r
{{domain}} <- {{domain}} |>
  admiral::derive_var_trtemfl(
    start_date = ASTDT,
    end_date = AENDT,
    trt_start_date = TRTSDT,
    trt_end_date = TRTEDT,
    end_window = {{end_window}}
  )
```
