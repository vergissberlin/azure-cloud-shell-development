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

## Version Mismatch in CI

- Ensure `SCRIPT_VERSION` in `cshell` matches root version in `.release-please-manifest.json`.
