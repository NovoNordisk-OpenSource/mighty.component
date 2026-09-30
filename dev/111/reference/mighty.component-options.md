# Options for mighty.component

### verbosity_level

Verbosity level for functions in mighty.component. See
[zephyr::verbosity_level](https://novonordisk-opensource.github.io/zephyr/reference/verbosity_level.html)
for details.

- Default: `NA_character_`

- Option: `mighty.component.verbosity_level`

- Environment: `R_MIGHTY.COMPONENT_VERBOSITY_LEVEL`

### max_tries

Maximum number of attempts for GitHub and URL requests. See
[`mighty_repo_github()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_github.md)
and
[`mighty_repo_url()`](https://novonordisk-opensource.github.io/mighty.component/reference/mighty_repo_url.md)
for which errors are retried.

- Default: `3L`

- Option: `mighty.component.max_tries`

- Environment: `R_MIGHTY.COMPONENT_MAX_TRIES`
