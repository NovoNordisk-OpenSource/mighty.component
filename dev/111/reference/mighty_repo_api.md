# API component repo

A component repo served by a JSON API under a base URL, e.g.
`https://host/api/components`. The API has two endpoints:

- `GET <url>` lists the components as a JSON array of component names,
  e.g. `["ady", "adsl"]`. Names are listed as returned, without removing
  names starting with `test-`.

- `GET <url>/<name>` returns a component as a JSON object with the file
  name `id` and the file content `content` as strings, e.g.
  `{"id": "ady.mustache", "content": "..."}`. The extension of `id` must
  be `.R` or `.mustache`.

Responses must have a JSON content type, e.g. `application/json`.

When looking up a component, a `.R` or `.mustache` extension in `name`
is ignored, and `name` is percent-encoded in the requested URL. A
response with status 404 or 410 means the component is not found; other
errors are raised. Any query string in `url` is kept on all requests.
Responses are not cached.

Requests are created, and transient errors retried, as in
[`mighty_repo_url()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_url.md).

## Usage

``` r
mighty_repo_api(url)
```

## Arguments

- url:

  `character(1)` base URL starting with `http://` or `https://`, or an
  `httr2_request` for the base URL.

## See also

[`mighty_repo()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo.md),
[`mighty_repo_url()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_url.md)
