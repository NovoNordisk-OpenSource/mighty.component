# Critical Code Review: PR \#91 — perf: cache GitHub repo tarball to reduce API calls

## Summary

The motivation is solid (real rate-limit pain) and the architectural
shift — download tarball once, then reuse `search_folder` — is the right
move. Several critical issues from the initial review have been fixed (R
compat, disk leak, malformed tarball crash, error chaining). The
remaining issues are around API contract correctness and test quality.

### Critical

### 6. `R/utils-find.R:106` — `ref = ""` is sent to GitHub when ref is `NULL`

The path template `/repos/{owner}/{repo}/tarball/{ref}` interpolates the
empty string, producing `/repos/o/r/tarball/` with a trailing slash. The
old behavior passed `NULL` which `gh` omitted entirely, letting GitHub
resolve the default branch. These are not equivalent. Pass `ref` through
directly (or omit the path param when `NULL`) rather than substituting
`""`.

### 7. `R/utils-find.R:168-177` — Semantics regression: “is not a directory” guardrail removed

Old code raised an error when a component-stem path resolved to a file
rather than a directory. The new code silently passes file paths through
to `search_folder`, which returns `NULL`. A user with `id: foo` against
a repo where `foo` is a file (not a directory) used to get a clear
error; now they get “Component not found.” No test covers this case.

### Required Changes

### 10. `R/utils-find.R:82` — Cache staleness semantics undocumented

`repo_cache` is session-global mutable state cached forever.
`ref = "main"` is cached even if upstream changes. Document this:
“cached for the lifetime of the R session, not refreshed on branch
updates.”

### 13. `R/utils-find.R:140` — Trivial conditional is dead weight

``` r

if (!is.null(subdir)) file.path(path, subdir) else path
```

`file.path(path, NULL)` returns `path` in R, so the `if` is unnecessary.
Verify and simplify.

### 14. `tests/testthat/test-utils-find-github.R` — Boilerplate duplication

Every test repeats `skip_if_not_installed`, `clear_repo_cache`,
`withr::defer(clear_repo_cache())`, and the same mock factory. Extract a
`local_fake_repo()` helper. ~250 lines that could be ~100.

### 15. `tests/testthat/test-utils-find-github.R:224-249` — Cache-by-ref test doesn’t prove correctness

Same tarball is returned for both refs, so
`expect_false(identical(path1, path3))` passes even if `ref` were
ignored entirely in the download. Use distinct fixture tarballs to
verify content differs.

## Suggestions

### 18. Consider hashing the cache key into the directory name

`tempfile("mighty_repo_")` produces a random name. Debugging which
directory belongs to which source is guesswork. Sanitize the key into
the dir name.

### 19. Consider memoizing failures

A 404 for `owner/repo@ref` won’t change in a session. Currently every
lookup against a missing repo re-downloads and re-fails.

## Verdict

**Request Changes.**

The blocking issues are **\#6** (incorrect API call when `ref` is
`NULL`) and **\#7** (silent UX regression for file-as-directory). Both
are straightforward fixes. The remaining items are cleanup/quality
improvements that should be addressed but aren’t blockers.
