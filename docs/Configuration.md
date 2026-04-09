# Configuration

`cshell` stores runtime configuration in:

- `~/.cshell.env`

## Core Variables

- `AZURE_STORAGE_ACCOUNT`
- `AZURE_STORAGE_CONTAINER`
- `AZURE_STORAGE_ACCOUNT_KEY` (optional fallback)

Apigee Hybrid variables created by `cshell hybrid` include:

- `PROJECT_ID`
- `ORG_NAME`
- `ORG_DISPLAY_NAME`
- `ORGANIZATION_DESCRIPTION`
- `ANALYTICS_REGION`
- `RUNTIMETYPE`
- `CLUSTER_NAME`
- `CLUSTER_REGION` (same meaning as `CLUSTER_LOCATION` in the
  [Google Hybrid install docs](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-create-cluster);
  use the cluster region, or for zonal clusters the **region** that contains the zone)
- `APIGEE_NAMESPACE`
- `ENVIRONMENT_NAME` (must match the Apigee environment created in the UI)
- `ENV_GROUP` (environment group name; used as Helm `envgroup`, same role as
  `ENVIRONMENT_GROUP_NAME` in `overrides.yaml` examples)
- `ENV_GROUP_RELEASE_NAME` (distinct Helm release name for the `apigee-virtualhost` chart)
- `DOMAIN` (hostname for the environment group / TLS CN)
- `CONTROL_PLANE_LOCATION` (optional; only when using data residency / `contractProvider`)
- `APIGEE_HELM_CHARTS_HOME`
- `CHART_REPO`
- `CHART_VERSION`

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
