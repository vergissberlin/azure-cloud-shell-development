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

## `gcloud`: `can't open file '.../.local/lib/gcloud.py'`

Older **`cshell setup`** versions copied only the small `bin/gcloud` launcher into **`~/.local/bin`**. That launcher must stay next to the full SDK tree (under **`~/google-cloud-sdk`**). A lone copy makes it treat **`~/.local`** as the SDK root and look for **`~/.local/lib/gcloud.py`**, which does not exist.

**Fix (pick one):**

1. **Preferred:** Update **`cshell`**, then run **`cshell setup`** again. The setup logic installs the SDK under **`~/google-cloud-sdk`** and puts a **symlink** at **`~/.local/bin/gcloud`** (or repairs a broken install when `gcloud --version` fails).
2. **Quick manual repair:** Ensure the real binary is used, then open a new shell:
   - `ln -sf "${HOME}/google-cloud-sdk/bin/gcloud" "${HOME}/.local/bin/gcloud"`
   - or put **`${HOME}/google-cloud-sdk/bin`** on `PATH` ahead of **`~/.local/bin`** (Google’s `install.sh --path-update` usually adds this via **`path.bash.inc`** in **`~/.bashrc`**).

## `Permission denied` when running `~/.cshell-env-exports.sh`

That file is **not** an executable script. It is **`source`d** (dot-sourced) by your shell so exports apply to the **current** session:

```bash
. ~/.cshell-env-exports.sh
```

After **`cshell setup`**, **`cshell init`**, or **`cshell config set`**, new Bash sessions
usually load the snippet automatically: those commands install hooks in **`~/.bashrc`**,
**`~/.profile`**, and **`~/.bash_profile`** (if present). **`cshell hybrid`** and
**`cshell hybrid --export`** refresh **`~/.cshell-env-exports.sh`** only — use **`source`**
or **`eval "$(cshell hybrid --export --print)"`** in the current shell, or run **`setup`**
/**`config set`** once if you want hooks for new terminals.

## Hybrid / Apigee variables missing from `env`

`~/.cshell.env` is **not** executed by your shell automatically. After **`cshell hybrid`**
or **`cshell hybrid --export`**, cshell refreshes **`~/.cshell-env-exports.sh`** only (no
**`~/.bashrc`** changes). After **`cshell setup`**, **`cshell init`**, or **`cshell config set`**,
cshell refreshes the snippet **and** installs hooks so **new** Bash sessions export
allowlisted variables (then `env | grep PROJECT` etc. works). **Requires bash 4+** (Azure
Cloud Shell is fine). In the **current** session run:

```bash
source ~/.cshell-env-exports.sh
```

Or:

```bash
eval "$(cshell hybrid --export --print)"
```

Or open a new Cloud Shell if hooks were installed earlier, or run `source ~/.bashrc` once
after **`setup`** / **`config set`**.

## Version Mismatch in CI

- Ensure `SCRIPT_VERSION` in `cshell` matches root version in `.release-please-manifest.json`.
