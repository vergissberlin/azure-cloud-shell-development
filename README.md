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
from that tag by default.

#### Manual download and install

```bash
# Download a specific release tag (no `v` prefix)
TAG="1.0.0"
curl -fsSL "https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/${TAG}/cshell" \
  -o /usr/local/bin/cshell
chmod +x /usr/local/bin/cshell
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
- On each published release, GitHub Actions uploads
  `cshell-<version>.tar.gz` as a release asset.

### From a local clone

```bash
bash cshell setup
```

This installs `cshell` to `/usr/bin/cshell` so it is available system-wide.

---

## Commands

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
| Azure region | `westeurope` |
| Storage Account name | – |
| Blob container name | `backups` |
| Storage SKU | `Standard_LRS` |

---

### `cshell setup`

Performs first-time setup:

1. Installs `cshell` to `/usr/bin`
2. Installs the **Google Cloud SDK** (`gcloud`) for Apigee Hybrid development
3. Installs **oh-my-zsh**
4. Interactively configures the **Azure Blob Storage** account used for backups
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
| `ANALYTICS_REGION` | Analytics region (e.g. `europe-west1`) | `us-central1` |
| `RUNTIMETYPE` | Runtime type | `HYBRID` |
| `CLUSTER_NAME` | Kubernetes cluster name | `apigee-hybrid` |
| `CLUSTER_REGION` | Kubernetes cluster region | `$ANALYTICS_REGION` |
| `APIGEE_HELM_CHARTS_HOME` | Local path to Helm charts directory | `~/apigee-hybrid/helm-charts` |

**Helm charts downloaded:**

```
apigee-operator · apigee-datastore · apigee-env · apigee-ingress-manager
apigee-org · apigee-redis · apigee-telemetry · apigee-virtualhost
```

Source the generated file before running further Apigee steps:

```bash
source ~/.cshell.env
```

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
```

- Excludes `.cache/` and other non-essential directories
- Skips the upload if no Azure storage account is configured (run
  `cshell setup` first)

---

### `cshell restore`

Restores the home directory from `~/archive.zip`:

```bash
cshell restore
```

- If `archive.zip` is not found locally, it is downloaded automatically from
  the configured Azure Blob Storage container
- Requires `cshell setup` to have been run first when downloading from Azure

---

## Environment file

All configuration is stored in `~/.cshell.env`. You can edit it manually at
any time. Re-running `cshell setup` or `cshell hybrid` will regenerate or
extend this file.

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
| `zsh` | `setup` (oh-my-zsh) |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to
this project.
