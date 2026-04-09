# Command Reference

## Global

- `cshell --version`: print current script version
- `cshell help`: print usage, command list, and documentation links
- `cshell docs`: print project and Apigee documentation links
- `cshell --no-update-check` (or `CSHELL_NO_UPDATE_CHECK=1`): skip the optional
  “newer release available” hint (cached by default for 24 hours)

## `cshell config`

- `config show`: print allowlisted variables from `~/.cshell.env` (secrets masked)
- `config set KEY VALUE`: update an allowlisted key (empty `VALUE` removes it)
- `config validate`: lightweight checks for Azure CLI and storage settings

## `cshell init`

Creates or reuses Azure backup resources:

- resource group
- storage account
- blob container

Writes resulting config values to `~/.cshell.env`.

## `cshell setup`

Performs first-time setup:

- installs `cshell`
- configures Bash completion
- installs `gcloud` if missing
- prompts for Azure Blob backup parameters

## `cshell hybrid`

Prepares Apigee Hybrid environment variables (including namespace, environment
name, environment group, hostname, and optional control-plane location for data
residency) and pulls required Helm charts. Replaces only the Hybrid block in
`~/.cshell.env` so Azure keys stay intact.

## `cshell backup`

- creates `~/archive.zip`
- uploads archive to configured Azure Blob container
- uses login auth first, then account-key fallback if available
- `--dry-run` / `-n`: print the plan without creating `archive.zip` or uploading
- `--verbose` / `-v`: print extra context before archiving

## `cshell restore`

- restores from local `~/archive.zip`
- or downloads from Azure Blob if local archive is missing
- `--dry-run` / `-n`: show what would happen without changing files
- `--verbose` / `-v`: print extra context before `unzip`

## `cshell update`

Downloads and installs latest released `cshell` version to an appropriate writable path.
Prefers verified tarball + SHA256 release assets when available.
