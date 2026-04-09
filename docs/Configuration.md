# Configuration

`cshell` stores runtime configuration in:

- `~/.cshell.env`

## Core Variables

| Variable                    | Description                                                         |
|-----------------------------|---------------------------------------------------------------------|
| `AZURE_STORAGE_ACCOUNT`     | Target storage account for backup and blob operations.              |
| `AZURE_STORAGE_CONTAINER`   | Blob container name.                                                |
| `AZURE_STORAGE_ACCOUNT_KEY` | Optional; enables account-key auth when Azure AD login is not used. |

## Apigee Hybrid (`cshell hybrid`)

| Variable                   | Description                                                                                                                                                                                                                                              |
|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PROJECT_ID`               | GCP project ID.                                                                                                                                                                                                                                          |
| `ORG_NAME`                 | Apigee organization ID.                                                                                                                                                                                                                                  |
| `ORG_DISPLAY_NAME`         | Display name for the organization (provisioning / UI).                                                                                                                                                                                                   |
| `ORGANIZATION_DESCRIPTION` | Organization description (provisioning).                                                                                                                                                                                                                 |
| `ANALYTICS_REGION`         | Analytics data region (e.g. `europe-west3`).                                                                                                                                                                                                             |
| `RUNTIMETYPE`              | Runtime type (typically `HYBRID`).                                                                                                                                                                                                                       |
| `CLUSTER_NAME`             | Kubernetes cluster name.                                                                                                                                                                                                                                 |
| `CLUSTER_REGION`           | Same meaning as `CLUSTER_LOCATION` in the [Google Hybrid install docs](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-create-cluster): cluster region; for zonal clusters use the **region** that contains the zone, not the zone alone. |
| `AKS_RESOURCE_GROUP`       | Optional. Azure resource group that contains the AKS cluster named by `CLUSTER_NAME`. When set (and `az` is available), `cshell hybrid` fetches kubeconfig via `az aks get-credentials`.                                                                  |
| `APIGEE_NAMESPACE`         | Namespace for Apigee components (often `apigee`).                                                                                                                                                                                                        |
| `ENVIRONMENT_NAME`         | Apigee environment name; must match the environment created in the Apigee UI.                                                                                                                                                                            |
| `ENV_GROUP`                | Environment group name; Helm `--set envgroup`. Same role as `ENVIRONMENT_GROUP_NAME` in `overrides.yaml` examples.                                                                                                                                       |
| `ENV_GROUP_RELEASE_NAME`   | Helm release name for the `apigee-virtualhost` chart (unique per cluster).                                                                                                                                                                               |
| `DOMAIN`                   | Public hostname for the environment group (TLS / virtual host CN).                                                                                                                                                                                       |
| `CONTROL_PLANE_LOCATION`   | Optional; only when using data residency / `contractProvider`. Interactive `cshell hybrid` defaults to `europe-west3` when unset.                                                                                                                          |
| `APIGEE_HELM_CHARTS_HOME`  | Local directory where Hybrid Helm charts are stored (default **`~/apigee-hybrid/helm-charts`**, created by `cshell setup` with `mkdir -p`). After `setup`, `hybrid`, `init`, or `config set`, cshell regenerates **`~/.cshell-env-exports.sh`** (allowlisted `KEY=value` pairs only, safely quoted) and adds hooks so **new Bash sessions** load it: **`~/.bashrc`**, **`~/.profile`** (bash login shells), and **`~/.bash_profile`** (if that file exists). Requires **bash 4+**. Use **`. ~/.cshell-env-exports.sh`** in the current shell (the file is not `+x` on purpose).                                                                                         |
| `CHART_REPO`               | OCI repository URL for Apigee Hybrid charts.                                                                                                                                                                                                             |
| `CHART_VERSION`            | Helm chart version (e.g. `1.16.0-hotfix.1`).                                                                                                                                                                                                             |

`cshell hybrid` replaces only the marked block between `# BEGIN_CSHELL_HYBRID_ENV` and
`# END_CSHELL_HYBRID_ENV` in `~/.cshell.env`, so Azure and other keys outside that block
are kept.

## Auth Fallback Order

For Azure Blob operations:

1. Azure AD login (`--auth-mode login`)
2. Account key (`--auth-mode key`) when `AZURE_STORAGE_ACCOUNT_KEY` is set

## Manual Editing

You can manually edit `~/.cshell.env` and rerun:

- `cshell setup` for backup settings
- `cshell hybrid` for Apigee settings

Both commands are designed to be re-runnable and safe for updates.

## Security and inspection

- `cshell` only **loads** `~/.cshell.env` with an allowlisted parser (it does **not**
  `source` the file), so arbitrary shell snippets in values are not executed when
  running `cshell` commands.
- After writes, `cshell` attempts `chmod 600` on `~/.cshell.env`.
- Prefer `cshell config show` to inspect values (secrets are masked). Avoid
  `source ~/.cshell.env` unless you fully trust every line in the file.
