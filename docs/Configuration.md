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
- `CLUSTER_REGION`
- `APIGEE_HELM_CHARTS_HOME`

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
