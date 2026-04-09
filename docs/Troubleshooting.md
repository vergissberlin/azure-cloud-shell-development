# Troubleshooting

## `cshell: command not found`

- Verify installation path:
  - `~/.local/bin/cshell`
- Ensure PATH contains `~/.local/bin`:
  - `export PATH="$HOME/.local/bin:$PATH"`
- Reload shell:
  - `source ~/.bashrc`

## `bash: …/.local/bin/cshell: No such file or directory`

This appears after **`rm -rf ~/.local`** (or similar): the binary is gone, but Bash may still use a **remembered path** from `command hashing`.

1. Clear the hash table, then confirm the file is missing:
   - `hash -r`
   - `command -v cshell` (often prints nothing / next command fails until you reinstall)
2. **Reinstall** `cshell` (pick one):
   - From the project checkout (developer path):
     - `mkdir -p ~/.local/bin`
     - `cp /path/to/azure-cloud-shell-development/cshell ~/.local/bin/cshell && chmod +x ~/.local/bin/cshell`
     - Also copy **`lib/*.sh`** next to that `cshell` if you are **not** using the release tarball (see [Installation](Installation.md)).
   - Official one-liner (installs to `~/.local/bin` when `/usr/local/bin` is not writable):
     - `curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh | bash`
3. Ensure **`~/.bashrc`** still adds `~/.local/bin` to `PATH` (the installer and `cshell setup` usually add this).
4. Run `hash -r` again (or open a new shell), then `cshell --version`.

**Note:** Removing `~/.local` also deletes other user tools under `~/.local`. Your **`~/.cshell.env`** in `$HOME` is **outside** `~/.local`, so Hybrid/Azure settings there are usually **unchanged** unless you removed the whole home directory tree.

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

`~/.cshell.env` is **not** executed by your shell automatically. After `cshell setup`, `cshell hybrid`, `cshell init`, **`cshell config set`**, or **`cshell hybrid --export`**, cshell refreshes **`~/.cshell-env-exports.sh`** and hooks **`~/.bashrc`** so **new** Bash sessions export allowlisted variables (then `env | grep PROJECT` etc. works). **Requires bash 4+** (Azure Cloud Shell is fine). In the **current** session run:

```bash
source ~/.cshell-env-exports.sh
```

Or:

```bash
eval "$(cshell hybrid --export --print)"
```

Or open a new Cloud Shell / run `source ~/.bashrc`.

## Version Mismatch in CI

- Ensure `SCRIPT_VERSION` in `cshell` matches root version in `.release-please-manifest.json`.
