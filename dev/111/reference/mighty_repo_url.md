# URL component repo

A component repo served as raw files under a base URL, e.g.
`https://example.com/components`. Authentication is only possible
through the query string, e.g. a token or signed URL. The query string
is kept on all requests, but left out when the repo is printed. Custom
headers are not supported.

Components follow the layout in
[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md).
A component `name` is looked up by requesting, in order:

1.  `<url>/<name>.R`

2.  `<url>/<name>.mustache`

3.  `<url>/<name>/<name>.R`

4.  `<url>/<name>/<name>.mustache`

The first successful response is used. Responses with status 404 or 410
are treated as not found; other errors are raised. `name` is
percent-encoded in the requested URLs, and names containing `/` are not
found. Responses are not cached.

Listing components (see
[`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md))
requires an HTML directory index at `<url>/`, and at `<url>/<dir>/` for
nested components, e.g. Apache or nginx autoindex, or
`python -m http.server`. Listing aborts if an index is unavailable or
not HTML.

Transient errors (see
[`httr2::req_retry()`](https://httr2.r-lib.org/reference/req_retry.html))
and network failures are retried. The number of attempts is set by the
`max_tries` option. See
[mighty.component-options](https://novonordisk-opensource.github.io/mighty.component/reference/mighty.component-options.md).

## Usage

``` r
mighty_repo_url(url)
```

## Arguments

- url:

  `character(1)` base URL starting with `http://` or `https://`.

## See also

[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md)
