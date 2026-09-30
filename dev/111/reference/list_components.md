# List components in repos

List all available mighty components in the given repos. See
[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md)
for the component layout. Files starting with `test-` are not listed.

## Usage

``` r
list_components(repos, as = c("character", "list", "tibble"))
```

## Arguments

- repos:

  Where to look. One of:

  - `character` vector of repo specs. See
    [`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md).

  - A `mighty_repo_class` object.

  - A `list` of repo specs or `mighty_repo_class` objects.

  - A
    [`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md)
    collection.

  Character vectors and lists are converted once with
  [`mighty_repos()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repos.md).

- as:

  Format to list the components in:

  - `"character"`: component names (filenames without extension).

  - `"list"`: metadata for each component.

  - `"tibble"`: metadata for each component as a tibble. Requires the
    `tibble` and `tidyr` packages.

  When a component exists in several repos, the metadata is taken from
  the first repo, as in
  [`find_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/find_component.md).

## Value

Depending on `as`:

- `"character"`: `character` vector of unique component names.

- `"list"`: `list` with one element per component, each a named `list`
  with `id`, `title`, `description`, `type`, `origin`, `method`,
  `params`, `depends`, `outputs` and `code`.

- `"tibble"`: tibble with one row per component and the same columns.

## See also

[`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
[`find_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/find_component.md)

## Examples

``` r
path <- system.file("examples", package = "mighty.component")
list_components(path)
#> [1] "ady"

list_components(path, as = "list") |>
  str(max.level = 2)
#> List of 1
#>  $ :List of 10
#>   ..$ id         : chr "ady.mustache"
#>   ..$ title      : chr "Analysis relative day"
#>   ..$ description: chr "Derives the relative day compared to the treatment start date."
#>   ..$ type       : chr "column"
#>   ..$ origin     : chr "Derived"
#>   ..$ method     : chr "Relative day computed from treatment start date"
#>   ..$ params     :'data.frame':  3 obs. of  2 variables:
#>   ..$ depends    :'data.frame':  2 obs. of  2 variables:
#>   ..$ outputs    : chr "{{{variable}}}"
#>   ..$ code       : chr [1:10] "{{{domain}}} <- {{{domain}}} |>" "  dplyr::mutate(" "    {{{variable}}} = admiral::compute_duration(" "      start_date = TRTSDT," ...
```
