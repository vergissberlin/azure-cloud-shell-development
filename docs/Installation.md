# Installation

## Recommended Install

```bash
curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh | bash
```

This installer resolves the latest release and installs `cshell` into a writable
location. When release assets include `cshell-<version>.tar.gz` and the matching
`.sha256` file, the installer verifies the checksum before extracting the
standalone binary; otherwise it falls back to downloading the raw `cshell` script
and the matching `lib/*.sh` helpers into the same directory (for example
`~/.local/bin/lib/`) so the CLI keeps working (verify manually when you need
supply-chain guarantees — see the repository README).

## Install From Local Clone

```bash
bash cshell setup
```

`setup` installs:

- `cshell` binary (user-space by default)
- Bash completion for `cshell`
- Google Cloud SDK (`gcloud`) if missing; after a **fresh** install, `cshell` runs **`gcloud auth login`** when stdin is a TTY and neither **`APIGEE_SETUP_NONINTERACTIVE=1`** nor **`CI`** is set (otherwise it prints the command to run manually). If `gcloud` already has an active account, login is skipped.
- Azure Blob backup configuration prompts (if you leave the storage account key empty and `az` is logged in, `cshell` resolves `AZURE_STORAGE_ACCOUNT_KEY` via Azure Resource Manager — `curl` to `listKeys`, with `az storage account keys list` as fallback)

## Validate Installation

```bash
cshell --version
cshell help
```

## Path and Completion

If needed, ensure `~/.local/bin` is in `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Reload your shell:

```bash
source ~/.bashrc
```
