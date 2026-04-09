# azure-cloud-shell-development

A bash helper script (`cshell`) for Azure Cloud Shell that covers Apigee Hybrid
development workflows, backup/restore of the home directory, and first-time
setup of common tooling.

CLI output styling is standardized through shared helpers in
`scripts/misc-cli-utils.sh` to keep command feedback consistent across scripts.

---

## Installation

### Quick install via curl (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh | bash
```

This bootstrap installer resolves the latest release tag and installs `cshell`
from that tag by default. When GitHub release assets include
`cshell-<version>.tar.gz` plus matching `.sha256` files (published by CI),
`install.sh` verifies the checksum before extracting the standalone `cshell`
binary. If verification is not possible, it falls back to downloading the raw
`cshell` script from the tag (no integrity check — prefer official releases).

#### Verify a release tarball manually (optional)

```bash
VERSION="1.4.0"
curl -fsSL -O "https://github.com/vergissberlin/azure-cloud-shell-development/releases/download/${VERSION}/cshell-${VERSION}.tar.gz"
curl -fsSL -O "https://github.com/vergissberlin/azure-cloud-shell-development/releases/download/${VERSION}/cshell-${VERSION}.tar.gz.sha256"
sha256sum -c "cshell-${VERSION}.tar.gz.sha256"
tar -xzf "cshell-${VERSION}.tar.gz"
chmod +x cshell
```

#### Manual download and install (raw script)

Requires a writable install directory (`/usr/local/bin` when permitted, otherwise
`$HOME/.local/bin`):

```bash
# Download a specific release tag (tags use plain SemVer, e.g. 1.0.0)
TAG="1.0.0"
INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "${INSTALL_DIR}"
curl -fsSL "https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/${TAG}/cshell" \
  -o "${INSTALL_DIR}/cshell"
chmod +x "${INSTALL_DIR}/cshell"
```

#### Download install script first, then run

```bash
curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh \
  -o install.sh
chmod +x install.sh
./install.sh
```

### Versioning and releases

- Releases are created with Release Please.
- Git tags use plain SemVer (`1.2.3`) without a `v` prefix.
- `cshell --version` matches the released tag version.
- On each published release, GitHub Actions uploads `cshell-<version>.tar.gz`,
  its `sha256` checksum, and checksum-matched `install-<version>.sh` assets.

### Build model (source vs generated assets)

- Source scripts in the repository stay readable and modular (`lib/*.sh` modules
  are vendored into the generated standalone `dist/cshell` during CI).
- CI generates standalone release scripts in `dist/` by embedding shared CLI
  helpers from `scripts/misc-cli-utils.sh`.
- Generated artifacts are not committed; they are produced during workflows.
- The public install entrypoint remains unchanged:
  `curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh | bash`
  and `install.sh` in the default branch remains self-contained for this flow.

### From a local clone

```bash
bash cshell setup
```

- Running **as root**: installs to `/usr/bin/cshell`.
- Running **without root** (typical in Azure Cloud Shell): installs to
  `~/.local/bin/cshell` and warns if that directory is not on `PATH`.

Use `cshell --no-update-check …` (or `export CSHELL_NO_UPDATE_CHECK=1`) to skip
the GitHub release hint. The hint is cached for 24 hours by default
(`CSHELL_UPDATE_CHECK_TTL_SECONDS` overrides the TTL).

---

## Commands

Most task commands (`init`, `setup`, `hybrid`, `backup`, `restore`, `update`)
may print a cached GitHub release hint when a newer `cshell` version exists.

### `cshell init`

Creates the Azure infrastructure required for backups:

1. Optionally sets the active Azure subscription
2. Creates the **Resource Group** (if it does not exist)
3. Creates the **Storage Account** (if it does not exist)
4. Creates the **Blob container** (if it does not exist)
5. Tries to resolve and save `AZURE_STORAGE_ACCOUNT_KEY` for auth fallback
6. Saves all configuration to `~/.cshell.env`

```bash
cshell init
```

**Interactive prompts:**

| Prompt | Default |
|---|---|
| Azure Subscription ID or name | current subscription |
| Resource group name | `rg-cshell` |
| Azure region | `germanywestcentral` |
| Storage Account name | – |
| Blob container name | `backups` |
| Storage SKU | `Standard_LRS` |

---

### `cshell setup`

Performs first-time setup:

1. Installs `cshell` to `/usr/bin` when root, otherwise `~/.local/bin`
2. Automatically installs shell autocomplete for `cshell` (Bash)
3. Installs the **Google Cloud SDK** (`gcloud`) for Apigee Hybrid development
4. Interactively configures the **Azure Blob Storage** account used for backups

Autocomplete is installed to user-space paths and setup is idempotent. Re-running
`cshell setup` updates completion files safely.
   (optional `AZURE_STORAGE_ACCOUNT_KEY` supported for key-based fallback)

Backup upload command that is configured:

```bash
az storage blob upload \
  --account-name <storage-account-name> \
  --container-name <container-name> \
  --name archive.zip \
  --file ~/archive.zip
```

---

### `cshell hybrid`

Sets up an [Apigee Hybrid v1.16](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-before-begin) environment:

1. Interactively prompts for all required environment variables and writes them
   to `~/.cshell.env`
2. Downloads the Apigee Hybrid Helm charts as described in the
   [official documentation](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-download-charts)

**Environment variables configured:**

| Variable | Description | Default |
|---|---|---|
| `PROJECT_ID` | GCP Project ID | – |
| `ORG_NAME` | Apigee Organization name | `$PROJECT_ID` |
| `ORG_DISPLAY_NAME` | Apigee Organization display name | `$ORG_NAME` |
| `ORGANIZATION_DESCRIPTION` | Organization description | – |
| `ANALYTICS_REGION` | Analytics region (e.g. `europe-west3`) | `europe-west3` |
| `RUNTIMETYPE` | Runtime type | `HYBRID` |
| `CLUSTER_NAME` | Kubernetes cluster name | `aks-hybrid` |
| `CLUSTER_REGION` | Kubernetes cluster region | `$ANALYTICS_REGION` |
| `APIGEE_HELM_CHARTS_HOME` | Local path to Helm charts directory | `~/apigee-hybrid/helm-charts` |

**Helm charts downloaded:**

```
apigee-operator · apigee-datastore · apigee-env · apigee-ingress-manager
apigee-org · apigee-redis · apigee-telemetry · apigee-virtualhost
```

Inspect values with `cshell config show` instead of `source ~/.cshell.env`
(`source` executes the file as shell code — only if every line is trusted).

**Documentation links:**

- [Before you begin](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-before-begin)
- [Download Helm charts](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-download-charts)
- [Install Apigee Hybrid (community guide)](https://github.com/vergissberlin/apigee-hybride-development/blob/main/docs/install-apigee-hybrid.md)

---

### `cshell backup`

Creates a ZIP archive of the home directory (`~/archive.zip`) and uploads it
to the configured Azure Blob Storage container:

```bash
cshell backup
cshell backup --dry-run   # plan only
cshell backup --verbose   # extra context before zip
```

- Excludes `.cache/` and other non-essential directories
- Skips the upload if no Azure storage account is configured (run
  `cshell setup` first)

---

### `cshell restore`

Restores the home directory from `~/archive.zip`:

```bash
cshell restore
cshell restore --dry-run
```

- If `archive.zip` is not found locally, it is downloaded automatically from
  the configured Azure Blob Storage container
- Requires `cshell setup` to have been run first when downloading from Azure

---

### `cshell update`

Updates the `cshell` executable itself from the latest GitHub release and prints
the installed version at the end.

```bash
cshell update
```

- Prefers a verified `cshell-<version>.tar.gz` + `.sha256` asset when `python3`
  and `sha256sum` are available
- Uses latest release tag when available
- Falls back to `main` if release metadata cannot be resolved
- Chooses a writable install target automatically (`$PATH` binary, then
  `/usr/local/bin/cshell`, then `~/.local/bin/cshell`)

---

### `cshell docs`

Prints all relevant project and Apigee documentation links in one place:

```bash
cshell docs
```

- Includes links to README, releases, issues, and contributing guide
- Includes links to Apigee Hybrid setup references

---

### `cshell config`

- `cshell config show` — print allowlisted keys (secrets masked)
- `cshell config set KEY VALUE …` — update an allowlisted key (empty value removes the line)
- `cshell config validate` — basic Azure CLI / storage sanity checks

---

## Environment file

All configuration is stored in `~/.cshell.env`. The file is written with
`chmod 600` whenever `cshell` updates it. **Do not `source` this file from an
untrusted editor session** — treat it like credentials on disk and prefer
`cshell config show` for inspection.

You can edit it manually when needed. Re-running `cshell setup` or `cshell hybrid`
updates managed blocks without duplicating previous `setup` storage entries.

Storage auth fallback order:

1. Azure AD login (`--auth-mode login`)
2. Account key (`--auth-mode key`) when `AZURE_STORAGE_ACCOUNT_KEY` is set

---

## Prerequisites

| Tool | Required for |
|---|---|
| `bash` ≥ 4 | All commands |
| `az` (Azure CLI) | `init`, `setup`, `backup`, `restore` |
| `gcloud` | `hybrid` |
| `helm` ≥ 3.14 | `hybrid` |
| `zip` / `unzip` | `backup`, `restore` |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to
this project.

## Documentation

- Comprehensive project docs live in [docs/](docs/).
- The GitHub Wiki is synchronized from `docs/` by the `wiki-sync` workflow:
  - Pull requests validate links and structure.
  - Pushes to `main` and manual runs publish updates to the native wiki repository.
