# Contributing

Thank you for your interest in contributing to **azure-cloud-shell-development**!

---

## Getting started

1. **Fork** the repository and clone your fork:

   ```bash
   git clone https://github.com/<your-username>/azure-cloud-shell-development.git
   cd azure-cloud-shell-development
   ```

2. Create a feature branch:

   ```bash
   git checkout -b feat/my-improvement
   ```

3. Make your changes to `cshell`, `lib/*.sh`, `install.sh`, or other files and
   test them locally (see [Testing](#testing) below).

4. Open a **pull request** against the `main` branch.

---

## Code style

- The main script is `cshell` – a plain Bash script.
- Follow the existing patterns:
  - Use `info`, `success`, `warn`, and `error` helper functions for all output.
  - Use `ask` for interactive prompts that support a default value.
  - Keep `set -euo pipefail` in effect – avoid patterns that suppress errors
    silently.
  - Add a `require_root` guard to any function that needs elevated privileges.
- New subcommands go into their own `cmd_<name>()` function and must be wired
  up in the `case` block at the bottom of the script and documented in
  `usage()` and `docs/Command-Reference.md`.
- Shared, testable helpers should live under `lib/*.sh` (embedded into
  `dist/cshell` by `scripts/build-standalone-scripts.sh`).

---

## Testing

Pull requests run **`bash -n`**, **`shellcheck`**, **`shfmt -d`**, and **Bats**
smoke tests via GitHub Actions.

With [**just**](https://github.com/casey/just) installed (`brew install just`), from the repo root:

```bash
just doctor   # see if shellcheck, shfmt, bats are on PATH (just prepends Homebrew dirs)
just check    # same pipeline as standalone-build-check (build, syntax, shellcheck, shfmt, bats)
just --list   # all recipes (build, lint, fmt, bats-deps, …)
```

If `just check` stops at `lint` with “shellcheck not found”, install the tools (e.g. `brew install shellcheck shfmt`) — see `just doctor`.

Without `just`, run the commands below manually.

Locally:

```bash
# Syntax (repository + generated standalone)
bash -n cshell install.sh lib/*.sh scripts/build-standalone-scripts.sh
./scripts/build-standalone-scripts.sh
bash -n dist/cshell dist/install.sh

# Linters — same commands as CI (job `shell-lint` in `.github/workflows/standalone-build-check.yml`)
# Install: Ubuntu/Debian `sudo apt-get install -y shellcheck shfmt`, macOS `brew install shellcheck shfmt`,
# or Docker: `docker run --rm -v "$PWD:/mnt" -w /mnt koalaman/shellcheck:stable shellcheck -x cshell install.sh scripts/build-standalone-scripts.sh lib/*.sh`
shellcheck -x cshell install.sh scripts/build-standalone-scripts.sh lib/*.sh
shellcheck -x dist/cshell
shfmt -d -ci -bn cshell install.sh lib/*.sh scripts/build-standalone-scripts.sh

# Bats (example: install bats-core, then)
bats tests

# Manual smoke (init/setup need a real Azure subscription when exercised)
CSHELL_NO_UPDATE_CHECK=1 bash cshell help
```

---

## Commit messages

Use the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <short description>

[optional body]
```

Common types: `feat`, `fix`, `docs`, `refactor`, `chore`.

---

## Reporting issues

Please open a
[GitHub issue](https://github.com/vergissberlin/azure-cloud-shell-development/issues)
and include:

- The output of `cshell <command>` (with sensitive values redacted)
- Your OS and Azure CLI version (`az --version`)
- Steps to reproduce

---

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE) of this project.
