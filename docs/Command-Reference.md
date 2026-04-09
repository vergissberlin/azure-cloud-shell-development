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
`~/.cshell.env` so Azure keys stay intact. Requires **Helm v3.14+** and GCP auth
to pull OCI charts. With `APIGEE_SETUP_NONINTERACTIVE=1`, uses defaults from the
environment / `~/.cshell.env` (no prompts). Prints the full Google Hybrid v1.16
install link list (same as `cshell docs`).

- `hybrid --check`: read-only validation that `~/.cshell.env` exists and all
  required Hybrid variables are **non-empty** (`PROJECT_ID`, `ORG_*`,
  `ANALYTICS_REGION`, `RUNTIMETYPE`, `CLUSTER_*`, `APIGEE_NAMESPACE`,
  `ENVIRONMENT_NAME`, `ENV_GROUP`, `ENV_GROUP_RELEASE_NAME`, `DOMAIN`,
  `APIGEE_HELM_CHARTS_HOME`). **DOMAIN must be set** for a successful check (stricter
  than `APIGEE_SETUP_NONINTERACTIVE`, which only warns when `DOMAIN` is empty).
  `CONTROL_PLANE_LOCATION` is optional. `CHART_REPO` / `CHART_VERSION` need not
  appear in the file when built-in defaults apply. After loading the env file it
  prints a **numbered checklist** (items 1–13) in the same order as the Google
  Apigee Hybrid v1.16 install topics (plus the community guide link): **✓** /
  **✗** when cshell can verify locally (required env block present; cluster
  reachability and namespace when `kubectl` is available and uses a working
  context; unpacked Helm chart directories under `APIGEE_HELM_CHARTS_HOME`), and
  **—** when a step is not auto-verified (documentation steps 5–12 and item 13).
  **Exit status** still reflects **only** required-variable validation (and file
  presence), not whether every checklist row is ✓. No file writes and no chart
  downloads.

- `hybrid --export`: same required-variable checks as `--check`, then regenerates
  **`~/.cshell-env-exports.sh`** and ensures the **`~/.bashrc`** hook sources it
  (same as `cshell_env_sync_exports` after setup/hybrid/config). Use this when
  you only want exports refreshed without running the full interactive hybrid
  flow. In the **current** shell, run `source ~/.cshell-env-exports.sh` (or
  `source ~/.bashrc`). **Requires bash 4+** for the snippet writer.

- `hybrid --export --print`: after the same validation, writes the snippet file and
  prints **only** `export …` lines to **stdout** (no banners). Intended for:
  `eval "$(cshell hybrid --export --print)"` to load allowlisted variables into
  the **current** shell in one step. **Requires bash 4+**.

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
Prefers verified tarball + SHA256 release assets when available. On the raw fallback,
also fetches the `lib/*.sh` files next to the installed script so sourcing succeeds.
