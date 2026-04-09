# Troubleshooting

## `cshell: command not found`

- Verify installation path:
  - `~/.local/bin/cshell`
- Ensure PATH contains `~/.local/bin`:
  - `export PATH="$HOME/.local/bin:$PATH"`
- Reload shell:
  - `source ~/.bashrc`

## Autocomplete Not Working

- Run `cshell setup` again.
- Verify completion file exists:
  - `~/.local/share/bash-completion/completions/cshell`
- Reload Bash:
  - `source ~/.bashrc`

## Azure Upload/Download Fails

- Confirm active Azure login context.
- Verify account/container values in `~/.cshell.env`.
- If RBAC is limited, set `AZURE_STORAGE_ACCOUNT_KEY` for fallback mode.

## `gcloud` Missing

- Re-run `cshell setup` to install Google Cloud SDK.
- Verify:
  - `gcloud --version`

## Hybrid / Apigee variables missing from `env`

`~/.cshell.env` is **not** executed by your shell automatically. After `cshell setup`, `cshell hybrid`, `cshell init`, or **`cshell config set`**, cshell refreshes **`~/.cshell-env-exports.sh`** and hooks **`~/.bashrc`** so **new** Bash sessions export allowlisted variables (then `env | grep PROJECT` etc. works). **Requires bash 4+** (Azure Cloud Shell is fine). In the **current** session run:

```bash
source ~/.cshell-env-exports.sh
```

Or open a new Cloud Shell / run `source ~/.bashrc`.

## Version Mismatch in CI

- Ensure `SCRIPT_VERSION` in `cshell` matches root version in `.release-please-manifest.json`.
