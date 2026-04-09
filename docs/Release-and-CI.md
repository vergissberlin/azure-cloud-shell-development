# Release and CI

## Versioning

- Release Please manages versioning.
- Tags follow SemVer without `v` prefix.
- `SCRIPT_VERSION` in `cshell` must match `.release-please-manifest.json`.

## Existing Workflows

- `version-sync-check`: verifies script/manifest version consistency
- `release-build-assets`: builds and uploads `cshell-<version>.tar.gz` on release publish

## Update Path

`cshell update` attempts:

1. latest release tag
2. fallback to `main` when release metadata cannot be resolved

Install target selection favors writable locations.

## Documentation Sync Workflow

A dedicated wiki-sync workflow can:

- validate docs on pull requests
- publish `docs/` content to GitHub native wiki on `main` and manual dispatch
