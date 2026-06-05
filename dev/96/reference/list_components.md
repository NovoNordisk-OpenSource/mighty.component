# List components in directories

List all available mighty components (`.R` and `.mustache` files) in the
specified directories.

## Usage

``` r
list_components(path, as = c("character", "list", "tibble"))
```

## Arguments

- path:

  `character` vector of directory paths to search for components.

- as:

  Format to list the components in. Default `character` lists component
  IDs (filenames without extension), while `list` and `tibble` show
  detailed component metadata.

## Value

Depending on `as`:

- `character`: vector of component IDs

- `list`: list of component metadata (id, title, description, params,
  depends, outputs, code)

- `tibble`: tibble with one row per component

## See also

[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md)

## Examples

``` r
path <- system.file("examples", package = "mighty.component")
list_components(path)
#> [1] "ady"

list_components(path, as = "list") |> str(max.level = 1)
#> List of 1
#>  $ :List of 7
```
