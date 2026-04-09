# Agent Rules

## Execution Environment

- Environment is an Azure Linux Cloud Shell sandbox.
- No root privileges are available.
- Azure CLI (`az`) is already authenticated.
- Only tools available inside the sandbox may be used.

## Operational Constraints

- Never use `sudo` or assume elevated permissions.
- Prefer user-space paths and non-root workflows.
- Avoid installation steps that require system package managers or root access.
- Adapt commands and scripts for Cloud Shell limitations by default.

## Wiki documentation

- GitHub Wiki content is **synced from** [`docs/`](docs/) on `main` only; do not
  tell users to edit the wiki in the browser.
- When changing CLI or installer behavior, update the matching files under
  `docs/` and keep [`docs/Wiki-Guidelines.md`](docs/Wiki-Guidelines.md) in
  mind (English, valid relative links, Home + `_Sidebar` for new pages).

## Style and tooling

- Respect [.editorconfig](.editorconfig): UTF-8, LF, final newline, trim trailing whitespace; **4 spaces** in the Dockerfile, **2 spaces** in YAML and typical text files.

## Tests

- When changing `cshell`, `lib/*.sh`, `install.sh`, installer/update flows, or
  any behavior covered by this repo, **add or extend automated tests** (Bats
  under [`tests/`](tests/) by default).
- Aim for coverage of the new or modified paths; keep **`just check`** (build,
  `shellcheck`, `shfmt`, Bats) passing before merging.

## Commit messages

- Use **[Conventional Commits](https://www.conventionalcommits.org/)** in **English** for every commit message (for example `feat:`, `fix:`, `docs:`, `ci:`, `chore:`).
- Align types with [Release Please](.github/workflows/release-please.yml) sections in [`.release-please-config.json`](.release-please-config.json) so changelog generation stays consistent.
