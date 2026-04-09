# Hybrid Setup

`cshell hybrid` supports Apigee Hybrid bootstrap for chart download and environment setup.

## Run

```bash
cshell hybrid
```

## What It Does

- prompts for required Apigee environment values (including namespace, environment
  group, and hostname for non-prod TLS steps)
- updates the Apigee Hybrid block in `~/.cshell.env` without removing unrelated keys
- downloads required Helm charts into `APIGEE_HELM_CHARTS_HOME`

## Non-production environments

For a **non-prod** Apigee hybrid runtime, Google’s install guide expects an
environment-specific service account (often named `apigee-non-prod`), key file
`$PROJECT_ID-apigee-non-prod.json` under your charts/service-accounts layout, and
a Kubernetes secret such as `apigee-non-prod-svc-account`. Align `ENVIRONMENT_NAME`
with the environment you created in the Apigee UI.

For trial-style installs, self-signed TLS in
`$APIGEE_HELM_CHARTS_HOME/apigee-virtualhost/certs/` is acceptable; production
should use properly signed certificates.

## Helm Chart Set

- `apigee-operator`
- `apigee-datastore`
- `apigee-env`
- `apigee-ingress-manager`
- `apigee-org`
- `apigee-redis`
- `apigee-telemetry`
- `apigee-virtualhost`

## After Setup

Inspect saved values (recommended):

```bash
cshell config show
```

To export variables into an interactive shell session, you may still
`source ~/.cshell.env` **only if you trust every line** in that file.

## Official References

- Before you begin: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-before-begin>
- Download charts: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-download-charts>
