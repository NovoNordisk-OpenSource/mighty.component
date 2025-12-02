# List all available standards

List all available mighty standard components.

## Usage

``` r
list_standards(as = c("character", "list", "tibble"))
```

## Arguments

- as:

  Format to list the standards in. Default `character` just lists the
  names, while `list` and `tibble` show more detailed information.

## Value

`character` vector of standard names

## Examples

``` r
# Simple character list of all standard ids:
list_standards()
#> [1] "ady"         "aendt"       "assign"      "astdt"       "predecessor"
#> [6] "supp_sdtm"   "trtemfl"    

# Tibble for an easy overview
list_standards(as = "tibble")
#> # A tibble: 7 × 7
#>   id          title                     description params depends outputs code 
#>   <chr>       <chr>                     <chr>       <list> <list>  <list>  <lis>
#> 1 ady         Analysis relative day     Derives th… <df>   <df>    <chr>   <chr>
#> 2 aendt       Analysis end date         Derives an… <df>   <df>    <chr>   <chr>
#> 3 assign      Assign                    Assigns a … <df>   <NULL>  <chr>   <chr>
#> 4 astdt       Analysis start date       Derives an… <df>   <df>    <chr>   <chr>
#> 5 predecessor Predecessor               Creates ne… <df>   <df>    <chr>   <chr>
#> 6 supp_sdtm   Add Supplementary Variab… Add a vari… <df>   <df>    <chr>   <chr>
#> 7 trtemfl     Treatment-emergent flag   Derives tr… <df>   <df>    <chr>   <chr>

# List (only showing first 2):
list_standards(as = "list") |>
  head(2) |>
  str()
#> List of 2
#>  $ :List of 7
#>   ..$ id         : chr "ady"
#>   ..$ title      : chr "Analysis relative day"
#>   ..$ description: chr "Derives the relative day compared to the treatment start date."
#>   ..$ params     :'data.frame':  3 obs. of  2 variables:
#>   .. ..$ name       : chr [1:3] "domain" "variable" "date"
#>   .. ..$ description: chr [1:3] "`character` Name of new domain being created" "`character` Name of new variable to create" "`character` Name of date variable to use"
#>   ..$ depends    :'data.frame':  2 obs. of  2 variables:
#>   .. ..$ domain: chr [1:2] "{{domain}}" "{{domain}}"
#>   .. ..$ column: chr [1:2] "{{date}}" "TRTSDT"
#>   ..$ outputs    : chr "{{variable}}"
#>   ..$ code       : chr [1:10] "{{domain}} <- {{domain}} |>" "  dplyr::mutate(" "    {{variable}} = admiral::compute_duration(" "      start_date = TRTSDT," ...
#>  $ :List of 7
#>   ..$ id         : chr "aendt"
#>   ..$ title      : chr "Analysis end date"
#>   ..$ description: chr "Derives analysis end date based on (incomplete) dates given as character"
#>   ..$ params     :'data.frame':  2 obs. of  2 variables:
#>   .. ..$ name       : chr [1:2] "domain" "dtc"
#>   .. ..$ description: chr [1:2] "`character` Name of new domain being created" "`character` Name of date variable"
#>   ..$ depends    :'data.frame':  1 obs. of  2 variables:
#>   .. ..$ domain: chr "{{domain}}"
#>   .. ..$ column: chr "{{dtc}}"
#>   ..$ outputs    : chr [1:2] "AENDT" "AENDTF"
#>   ..$ code       : chr [1:12] "{{domain}} <- {{domain}} |>" "  dplyr::mutate(" "    AENDT = admiral::convert_dtc_to_dt(" "      dtc = {{dtc}}," ...
```
