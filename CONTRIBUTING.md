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

3. Make your changes to `cshell` (or other files) and test them locally (see
   [Testing](#testing) below).

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
  `usage()`.

---

## Testing

There are no automated tests yet. Before submitting a pull request, please
verify your changes manually:

```bash
# Run syntax check
bash -n cshell

# Run shellcheck (if installed)
shellcheck cshell

# Smoke-test locally (setup step requires and a real Azure subscription)
bash cshell --help 2>/dev/null || bash cshell invalid_command
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
