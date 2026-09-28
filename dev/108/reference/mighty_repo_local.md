# Local component repo

A component repo in a local directory. Components are `.R` or
`.mustache` files directly in `path`, or in a directory named after the
component (`<path>/<name>/<name>.R`).

## Usage

``` r
mighty_repo_local(path = character(0))
```

## Arguments

- path:

  `character(1)` path to an existing directory.

## See also

[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md)

## Examples

``` r
path <- system.file("examples", package = "mighty.component")
mighty_repo_local(path = path)
#> <mighty.component::mighty_repo_local>
#>  @ path: chr "/home/runner/work/_temp/Library/mighty.component/examples"
```
