# Internal parameters for reuse in functions

Internal parameters for reuse in functions

## Arguments

- verbosity_level:

  Verbosity level for functions in mighty.component. See
  [zephyr::verbosity_level](https://novonordisk-opensource.github.io/zephyr/reference/verbosity_level.html)
  for details.. Default: `NA_character_`.

- max_tries:

  Maximum number of attempts for GitHub and URL requests. Network
  failures, HTTP 5xx from GitHub and HTTP 429 and 503 from URLs are
  retried; other errors are not.. Default: `3L`.

## Details

See
[mighty.component-options](https://novonordisk-opensource.github.io/mighty.component/reference/mighty.component-options.md)
for more information.
