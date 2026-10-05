# Collection of component repos

An ordered collection of component repos. Lookups search the repos in
order, and the first match wins.

Each element of `repos` is either a repo spec, passed to
[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md),
or an object inheriting from `mighty_repo_class`. Repos are created once
when the collection is created.

## Usage

``` r
mighty_repos(repos = character(0))
```

## Arguments

- repos:

  `character` vector of repo specs, a single `mighty_repo_class` object,
  or a `list` of repo specs and `mighty_repo_class` objects.

## Value

A `mighty_repos` object: a `list` of repos.

## See also

[`find_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/find_component.md),
[`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md)

## Examples

``` r
path <- system.file("examples", package = "mighty.component")
repos <- mighty_repos(repos = c(path, paste0("local::", path)))
repos
#> <mighty_repos> 2 repos
#>   1. local::/home/runner/work/_temp/Library/mighty.component/examples
#>   2. local::/home/runner/work/_temp/Library/mighty.component/examples

find_component(component = "ady", repos = repos)
#> → Found "ady" in "local::/home/runner/work/_temp/Library/mighty.component/examples"
#> <mighty_component/R6>
#> ady: Analysis relative day
#> Type: column
#> Parameters:
#> • domain: `character` Name of new domain being created
#> • variable: `character` Name of new variable to create
#> • date: `character` Name of date variable to use
#> Depends:
#> • {{{domain}}}.{{{date}}}
#> • {{{domain}}}.TRTSDT
#> Outputs:
#> • {{{variable}}}
```
