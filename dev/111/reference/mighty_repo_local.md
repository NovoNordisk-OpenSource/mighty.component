# Local component repo

A component repo in a local directory. See
[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md)
for the component layout. An error is raised if more than one file
matches a component.

## Usage

``` r
mighty_repo_local(path)
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
