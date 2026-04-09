# Hybrid Setup

`cshell hybrid` supports Apigee Hybrid bootstrap for chart download and environment setup.

## Run

```bash
cshell hybrid
```

## What It Does

- prompts for required Apigee environment values
- writes values into `~/.cshell.env`
- downloads required Helm charts into `APIGEE_HELM_CHARTS_HOME`

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
