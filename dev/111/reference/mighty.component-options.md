# Options for mighty.component

### verbosity_level

Verbosity level for functions in mighty.component. See
[zephyr::verbosity_level](https://novonordisk-opensource.github.io/zephyr/reference/verbosity_level.html)
for details.

- Default: `NA_character_`

- Option: `mighty.component.verbosity_level`

- Environment: `R_MIGHTY.COMPONENT_VERBOSITY_LEVEL`

### max_tries

Maximum number of attempts for GitHub and URL requests. Transient errors
(HTTP 5xx and network failures) are retried; other errors are not.

- Default: `3L`

- Option: `mighty.component.max_tries`

- Environment: `R_MIGHTY.COMPONENT_MAX_TRIES`
