# URL component repo

A component repo served as raw files under a base URL. Requires httr2
(\>= 1.2.2).

See
[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md)
for the component layout. `.mustache` is tried before `.R`, and
`<name>/` before files directly under `url`. The first found is used.
Status 404 and 410 count as not found; other errors are raised. `name`
is percent-encoded, and names containing `/` are not found. Responses
are not cached.

Listing components (see
[`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md))
requires an HTML directory index at `<url>/`, and at `<url>/<dir>/` for
nested components, e.g. Apache or nginx autoindex, or
`python -m http.server`. Listing aborts if an index is unavailable or
not HTML.

Transient errors (see
[`httr2::req_retry()`](https://httr2.r-lib.org/reference/req_retry.html))
and network failures are retried. The number of attempts is set by the
`max_tries` option, and each attempt is limited by the `timeout` option
(see
[mighty.component-options](https://novonordisk-opensource.github.io/mighty.component/reference/mighty.component-options.md)).

## Usage

``` r
mighty_repo_url(url)
```

## Arguments

- url:

  `character(1)` Base URL starting with `http://` or `https://`.

## Value

A `mighty_repo_url` object.

## Examples

``` r
if (FALSE) { # \dontrun{
repo <- mighty_repo_url(url = "https://example.com/components")
find_component(component = "ady", repos = repo)
} # }
```
