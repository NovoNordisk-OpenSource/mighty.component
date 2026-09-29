# URL component repo

A component repo served as raw files under a base URL, e.g.
`https://host/components`. Only public URLs are supported. To add
headers, pass an `httr2_request` created with
[`httr2::request()`](https://httr2.r-lib.org/reference/request.html)
instead of a string.

A component `name` is looked up by requesting, in order:

1.  `<url>/<name>.R`

2.  `<url>/<name>.mustache`

3.  `<url>/<name>/<name>.R`

4.  `<url>/<name>/<name>.mustache`

If `name` has a `.R` or `.mustache` extension, only that file is
requested, flat and nested. The first successful response is used.
Responses with status 404 or 410 are treated as not found; other errors
are raised. `name` is percent-encoded in the requested URLs. Any query
string in `url` is kept on all requests. Responses are not cached.

Listing components (see
[`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md))
requires the server to provide an HTML directory index, e.g. Apache or
nginx autoindex, or `python -m http.server`. The index at `<url>/` is
parsed for relative links to entries directly in the directory. Links to
files (`<file>`) are flat components. Links to directories (`<dir>/`)
are listed through their own index at `<url>/<dir>/`, and hold nested
components. Absolute links, links with a query or fragment, and `../`
are ignored. Listing aborts if an index is unavailable or not HTML.

Unless the request already has a retry policy (see
[`httr2::req_retry()`](https://httr2.r-lib.org/reference/req_retry.html)),
transient errors (HTTP 5xx and network failures) are retried. The number
of attempts is set by the `max_tries` option. See
[mighty.component-options](https://novonordisk-opensource.github.io/mighty.component/reference/mighty.component-options.md).

Requires httr2 \>= 1.2.2.

## Usage

``` r
mighty_repo_url(url)
```

## Arguments

- url:

  `character(1)` base URL starting with `http://` or `https://`, or an
  `httr2_request` for the base URL.

## See also

[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md)
