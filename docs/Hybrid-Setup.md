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

## Requirements

- **Helm** v3.14 or newer (Apigee Hybrid v1.16 expectation). Older versions are rejected.
- **GCP auth** for the OCI registry `oci://us-docker.pkg.dev/apigee-release/...`
  (for example `gcloud auth login` or `gcloud auth application-default login`).
  See the official *Download the Apigee Helm charts* page linked below.

## Non-interactive use

With `APIGEE_SETUP_NONINTERACTIVE=1`, `cshell hybrid` does not read from the TTY:
it uses the default shown in each prompt, typically from existing environment
variables or from `~/.cshell.env` (load a complete Hybrid block first).
`PROJECT_ID` must be non-empty; if `DOMAIN` is empty, a warning is printed.

## All official install steps (v1.16)

Run `cshell docs` for the same link list printed by `cshell hybrid`, or open the
[Hybrid v1.16 documentation hub](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-before-begin)
and follow the numbered install topics (cluster, charts, namespace, service
accounts, TLS, overrides, control plane access, cert-manager, CRDs, Helm install).

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

To get allowlisted variables into **`env`** in Bash, prefer the generated snippet
(after `cshell hybrid` / `setup` / `init` / `config set`):

```bash
source ~/.cshell-env-exports.sh
```

New Bash sessions load it via `~/.bashrc` (bash 4+). Avoid `source ~/.cshell.env`
unless you trust every line in that file.

## Official References

- Before you begin: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-before-begin>
- Create cluster: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-create-cluster>
- Download charts: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-download-charts>
- Create namespace: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-create-namespace>
- Service accounts: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-service-accounts>
- Service account authentication: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-sa-authentication>
- TLS certificates: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-create-tls-certificates>
- Overrides: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-create-overrides>
- Control plane access: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-enable-control-plane-access>
- cert-manager: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-cert-manager>
- CRDs: <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-crds>
- Helm charts (install): <https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-helm-charts>
- Helm install (upstream): <https://helm.sh/docs/intro/install/>
