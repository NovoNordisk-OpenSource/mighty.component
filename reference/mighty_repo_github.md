# GitHub component repo

A component repo hosted on GitHub. When the object is created, `ref` is
resolved to a commit SHA and the repository tarball for that commit is
downloaded and extracted to a temporary directory. Resolved SHAs are
cached per ref and tarballs per commit for the session, so all lookups
afterwards are local. Restart the session to pick up new commits on a
branch.

`spec` is a `remotes`-style repository reference: `owner/repo`,
`owner/repo/subdir`, `owner/repo@ref` or a combination.

## Usage

``` r
mighty_repo_github(spec)
```

## Arguments

- spec:

  `character(1)` GitHub repository reference. See description.
