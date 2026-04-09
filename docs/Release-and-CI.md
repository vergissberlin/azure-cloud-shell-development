# Release and CI

## Versioning

- Release Please manages versioning.
- Tags follow SemVer without `v` prefix.
- `SCRIPT_VERSION` in `cshell` must match `.release-please-manifest.json`.

## Existing Workflows

- `version-sync-check`: verifies script/manifest version consistency
- `release-build-assets`: on release publish, builds standalone `dist/cshell`,
  ships `cshell-<version>.tar.gz`, a matching `.sha256` file, plus
  `install-<version>.sh` and its checksum
- `standalone-build-check`: builds standalone scripts, runs `bash -n`,
  `shellcheck`, `shfmt -d`, and Bats smoke tests

## Update Path

`cshell update` attempts:

1. download the release tarball + checksum and verify with `sha256sum` when
   `python3`, release assets, and tooling are available
2. latest release tag metadata from the GitHub API
3. fallback raw download from `main` when release metadata cannot be resolved

Install target selection favors writable locations.

## Documentation Sync Workflow

A dedicated wiki-sync workflow can:

- validate docs on pull requests
- publish `docs/` content to GitHub native wiki on `main` and manual dispatch
