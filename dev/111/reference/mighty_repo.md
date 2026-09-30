# Component repos

- `mighty_repo()`: Create a component repo from a spec.

- `mighty_repo_class`: Abstract parent class of all component repos. It
  has no properties and cannot be created directly.

Specs have the form `type::path`. Supported types:

- `local`: A local directory, e.g. `local::inst/examples`. A spec
  without a prefix is treated as local.

- `github`: A GitHub repository, e.g. `github::owner/repo/subdir@ref`.
  See
  [`mighty_repo_github()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_github.md).

- `url`: Raw files under a base URL, e.g.
  `url::https://example.com/components`. See
  [`mighty_repo_url()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_url.md).

All repo types share one layout. A component `name` is the file
`<name>.R` or `<name>.mustache`, either directly in the repo or in a
directory named after the component (`<name>/<name>.R`). A name with an
extension only matches that file.

## Usage

``` r
mighty_repo(spec)
```

## Arguments

- spec:

  `character(1)` repo spec. See description.

## Value

`mighty_repo()`: An object inheriting from `mighty_repo_class`.

## See also

[`mighty_repo_local()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_local.md),
[`mighty_repo_github()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_github.md),
[`mighty_repo_url()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_url.md)

## Examples

``` r
path <- system.file("examples", package = "mighty.component")
mighty_repo(path)
#> <mighty.component::mighty_repo_local>
#>  @ path: chr "/home/runner/work/_temp/Library/mighty.component/examples"
mighty_repo(paste0("local::", path))
#> <mighty.component::mighty_repo_local>
#>  @ path: chr "/home/runner/work/_temp/Library/mighty.component/examples"
```
