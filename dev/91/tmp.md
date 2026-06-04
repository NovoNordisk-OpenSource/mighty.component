# Design: Tarball Download with Local Delegation

## Problem

`search_github()` in `R/utils-find.R` makes 2 HTTP requests per
component lookup with no caching. A typical study run triggers 200-800
API calls, exhausting unauthenticated rate limits (60/hr) in a single
test run.

## Solution

Replace per-component API calls with a single tarball download per
GitHub source. After extraction, delegate all lookups to the existing
`search_folder()` function.

## Architecture

    find_component(component, repos)
      -> repo is a local directory? -> search_folder() (unchanged)
      -> repo is a GitHub source?
          -> ensure_repo_local(owner, repo, subdir, ref)
              -> already downloaded this session? -> return cached path
              -> not yet? -> GET /repos/{owner}/{repo}/tarball/{ref}
                            -> extract to tempdir
                            -> cache extracted path
                            -> return path (subdir-scoped if applicable)
          -> try subdirectory convention: search_folder(component, local_path/component_name)
          -> if NULL and subdir was set: fall back to flat: search_folder(component, local_path)

## Key changes

### New function: `ensure_repo_local()`

Lives in `utils-find.R` alongside `search_github()` and
`search_folder()`.

``` r

# Package-level cache: maps "owner/repo@ref" -> local extracted path
# Cache assumes ref does not change meaning within a session.
repo_cache <- new.env(parent = emptyenv())

ensure_repo_local <- function(owner, repo, subdir = NULL, ref = NULL) {
  key <- paste0(owner, "/", repo, "@", ref %||% "HEAD")

  if (exists(key, envir = repo_cache)) {
    path <- repo_cache[[key]]
  } else {
    tarfile <- tempfile(fileext = ".tar.gz")
    on.exit(unlink(tarfile), add = TRUE)

    gh::gh(
      "GET /repos/{owner}/{repo}/tarball/{ref}",
      owner = owner,
      repo = repo,
      ref = ref %||% "",
      .destfile = tarfile
    )

    exdir <- tempfile("mighty_repo_")
    utils::untar(tarfile, exdir = exdir)

    # Discover the top-level directory (don't assume naming)
    top_dir <- list.dirs(exdir, recursive = FALSE)
    path <- top_dir[[1]]

    repo_cache[[key]] <- path
  }

  if (!is.null(subdir)) file.path(path, subdir) else path
}
```

### Unexported `clear_repo_cache()`

For use in tests only. Clears the package-level cache between test
blocks.

``` r

clear_repo_cache <- function() {
  rm(list = ls(repo_cache), envir = repo_cache)
}
```

### Simplified `search_github()`

Error handling lives here (not in `ensure_repo_local()`). The
`check_installed("gh")` guard stays here. Replicates the existing lookup
semantics: try `subdir/component_name/` first (subdirectory convention),
fall back to flat listing only when `subdir` was specified.

``` r

search_github <- function(component, source) {
  rlang::check_installed("gh")

  parsed <- parse_github_source(source)
  if (is.null(parsed)) return(NULL)

  local_path <- tryCatch(
    ensure_repo_local(
      owner = parsed$username,
      repo = parsed$repo,
      subdir = parsed$subdir,
      ref = parsed$ref
    ),
    http_error_404 = \(e) NULL,
    error = \(e) {
      cli::cli_abort("Failed to query {.val {source}}: {conditionMessage(e)}")
    }
  )

  if (is.null(local_path)) return(NULL)

  # Try subdirectory convention: component lives in subdir/component_name/
  result <- search_folder(
    component,
    folder = file.path(local_path, tools::file_path_sans_ext(component))
  )

  # Fall back to flat listing (only when subdir was specified, matching prior behavior)
  if (is.null(result) && !is.null(parsed$subdir)) {
    result <- search_folder(component, folder = local_path)
  }

  result
}
```

The existing `search_folder()` handles extension matching, ambiguity
errors, etc. – no changes needed there.

## API calls

| Scenario                    | Before | After |
|-----------------------------|--------|-------|
| 100 components, 1 repo      | 200    | **1** |
| 100 components, 3 repos     | 600    | **3** |
| 5 components, 1 repo        | 10     | **1** |
| Same component requested 5x | 10     | **1** |

## Dependencies

- `gh` (stays in Suggests) – for authenticated/unauthenticated download;
  guarded by `check_installed()`
- `remotes` (stays in Suggests) – for `parse_repo_spec()`; guarded by
  `check_installed()`
- [`utils::untar()`](https://rdrr.io/r/utils/untar.html) – base R, no
  new dependency
- `jsonlite` – **remove from Suggests and WORDLIST** (no longer used
  anywhere in the package)

## Edge cases

1.  **`ref` is NULL** – tarball API defaults to the repo’s default
    branch. Cache key uses `"HEAD"` as placeholder. Known limitation: if
    the default branch changes mid-session, the cache is stale.
    Acceptable because runs are single-shot.
2.  **Source has subdir** (e.g., `owner/repo/components`) – download
    whole repo, scope the local path to the subdir. Subdir validity
    checked by `search_folder()` returning NULL if it doesn’t exist.
3.  **Component in nested directory** (e.g.,
    `components/ady/ady.mustache`) – handled by trying
    `subdir/component_name/` before flat fallback.
4.  **Private repos** – work if `GITHUB_TOKEN` is set (same as current
    behavior via `gh`).
5.  **Unauthenticated, public repos** – tarball endpoint works without
    auth.
6.  **Network failure** –
    [`gh::gh()`](https://gh.r-lib.org/reference/gh.html) will error,
    caught by `tryCatch` in `search_github()`.
7.  **Repo doesn’t exist** – 404 from tarball endpoint, caught by error
    handler, returns NULL so `find_component()` tries next repo.

## Cache lifecycle

- Session-scoped: lives in a package-level environment, dies when R
  process exits.
- Temp files: extracted to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html), cleaned up
  automatically by R on session end.
- No explicit invalidation needed – within a single
  `generate_adam_code()` run, the ref doesn’t change.
- Cache assumes ref does not change meaning within a session (known
  limitation, acceptable for single-shot runs).

## `path` field change (internal only)

The current `search_github()` returns `matched$download_url` (a GitHub
URL) as the `path` field. After this change, `search_folder()` returns a
local temp file path instead.

Verified non-breaking: the `path` field is never accessed outside
`utils-find.R`. Neither mighty.component’s public API nor the mighty
package exposes it.

## What stays the same

- `find_component()` signature and behavior – unchanged
- `search_folder()` – unchanged
- `parse_github_source()` – unchanged (still uses `remotes`, guard stays
  inside)
- Return value structure – same `list(name, type, path, content)` shape
- Public API
  ([`get_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md),
  [`get_rendered_component()`](https://novonordisk-opensource.github.io/mighty.component/reference/get_component.md))
  – unchanged
- [`list_components()`](https://novonordisk-opensource.github.io/mighty.component/reference/list_components.md)
  – not affected (local paths only)

## Testing

- Mock [`gh::gh()`](https://gh.r-lib.org/reference/gh.html) tarball
  response with a pre-built `.tar.gz` fixture containing test
  components, using `local_mocked_bindings()`
- Use unexported `clear_repo_cache()` in test setup/teardown to isolate
  tests
- Verify cache hit on second call (no second download)
- Test subdirectory convention lookup (component in
  `subdir/component_name/`)
- Test flat fallback when subdir is set
- Test subdir scoping
- Test error propagation on network failure (404 returns NULL, other
  errors abort)
