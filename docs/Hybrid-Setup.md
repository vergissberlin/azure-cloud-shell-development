# Hybrid Setup

`cshell hybrid` supports Apigee Hybrid bootstrap for chart download and environment setup.

## Run

```bash
cshell hybrid
```

`cshell hybrid --check` runs read-only validation and prints **session checks** (GCP
`gcloud` auth and AKS / `kubectl` reachability, plus optional `az aks show` when
`AKS_RESOURCE_GROUP` is set) before the documented install checklist.

## What It Does

- prompts for required Apigee environment values (including namespace, environment
  group, and hostname for TLS steps)
- prompts for an **`overrides` profile**: **`nonprod`** (single shared service-account
  secret) or **`prod`** (seven distinct `apigee-*-svc-account` secrets per Google’s
  production flow), stored as **`APIGEE_OVERRIDES_PROFILE`**
- prompts for shared **`overrides.yaml`** fields that are not already in the Hybrid
  block (for example **`instanceID`**, ingress gateway name, TLS paths relative to the
  `apigee-virtualhost` chart, optional ingress service annotations, runtime image tag,
  and optional large-payload runtime tuning). For **nonprod** only, also prompts for the
  non-prod Kubernetes secret name (`APIGEE_NONPROD_SA_SECRET`).
- updates the Apigee Hybrid block in `~/.cshell.env` without removing unrelated keys
  (including optional overrides-related keys when set; see **Configuration**)
- downloads required Helm charts into `APIGEE_HELM_CHARTS_HOME` (default
  `~/apigee-hybrid/helm-charts`, created by `cshell setup` with `mkdir -p` when needed)
- writes a starter [`overrides.yaml`](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-create-overrides)
  under **`APIGEE_HELM_CHARTS_HOME`** using the **Kubernetes Secrets** pattern
  (`serviceAccountSecretRefs` / `serviceAccountRef`): **nonprod** uses one secret for
  multiple components; **prod** maps each component to the matching **`apigee-<role>-svc-account`** secret name. The file has a single valid top-level
  `runtime:` block (Google’s docs show two `runtime:` keys in some examples; the
  generator merges image and large-payload tuning into one block). In interactive mode,
  cshell **prints the full file** and asks for confirmation before writing (default **no**).
  If **`overrides.yaml`** already exists, you are asked whether to replace it first; in
  non-interactive mode it is left unchanged unless **`APIGEE_OVERRIDES_OVERWRITE=1`**
- when **`AKS_RESOURCE_GROUP`** is non-empty and **`CLUSTER_NAME`** matches your AKS
  cluster, runs **`az aks get-credentials --resource-group … --name …
  --overwrite-existing`** so `kubectl` can use that cluster (requires Azure CLI on
  `PATH` and a logged-in `az` session; failures are warned, not fatal)

## Requirements

- **Helm** v3.14 or newer (Apigee Hybrid v1.16 expectation). Older versions are rejected.
- **GCP auth** for the OCI registry `oci://us-docker.pkg.dev/apigee-release/...`
  (for example `gcloud auth login` or `gcloud auth application-default login`).
  `cshell setup` starts **`gcloud auth login`** after installing the SDK when the session is interactive; for OCI chart pulls you typically still need **`gcloud auth application-default login`** as in Google’s Hybrid docs.
  See the official *Download the Apigee Helm charts* page linked below.

## Non-interactive use

With `APIGEE_SETUP_NONINTERACTIVE=1`, `cshell hybrid` does not read from the TTY:
it uses the default shown in each prompt, typically from existing environment
variables or from `~/.cshell.env` (load a complete Hybrid block first).
`PROJECT_ID` must be non-empty; if `DOMAIN` is empty, a warning is printed.
Set **`APIGEE_OVERRIDES_PROFILE=prod`** (or **`nonprod`**) before running so the correct
**`overrides.yaml`** generator runs.
**`overrides.yaml`** is written **without** a terminal preview or extra write confirmation.
Existing **`overrides.yaml`** files are not overwritten unless **`APIGEE_OVERRIDES_OVERWRITE=1`**.
Use **`APIGEE_OVERRIDE_LARGE_PAYLOAD=1`** to enable large-payload runtime tuning without
a confirmation prompt.

## All official install steps (v1.16)

Run `cshell docs` for the same link list printed by `cshell hybrid`, or open the
[Hybrid v1.16 documentation hub](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-before-begin)
and follow the numbered install topics (cluster, charts, namespace, service
accounts, TLS, overrides, control plane access, cert-manager, CRDs, Helm install).

`cshell hybrid --check` prints that order as a **checklist** (with ✓ / ✗ / ○) after
loading `~/.cshell.env`. Each step is **multi-line**: status glyph and step title on the
first line (no square brackets around the symbol), then a dimmed **`Doc:`** line with the URL
and, when needed, a **`↳`** hint — both indented to align with the **first character of the step title**.
The checklist includes automated hints for every step
(Helm chart layout, service-account keys or `gcloud`, Kubernetes secrets, TLS
material, `overrides.yaml`, Apigee control-plane access, cert-manager, CRDs, Helm
releases, and reachability of the official install hub URL). **Exit status** still depends only on required
Hybrid variables unless you pass **`--strict`**, in which case any **✗** row fails the
command (rows marked **○** do not).

Set **`NO_COLOR`** (or pipe stdout) for plain text without ANSI colors. Use
**`cshell hybrid --check --json`** for a single machine-readable JSON document on
stdout (same exit rules as `--check`); see **Command Reference**.

## One step at a time (`hybrid --step`)

Use **`cshell hybrid --step N`** (with **N** from **1** to **13**) to print only checklist
item **N** (same status heuristics as `hybrid --check`) and run the small slice of
automation cshell supports for that item — for example **`--step 3`** to pull Helm
charts only, **`--step 5`** to prepare **`service-accounts/`** and see expected key paths,
or **`--step 7`** for TLS (Google Part 2 **Step 6** in the install sidebar; cshell keeps
**before you begin** as item **1**, so Google’s numbered steps map to **`--step` (N+1)** for
**N = 1…11**). Checklist step **13** is the **Official Hybrid install hub** (same URL as *Before you begin*).
For **non-prod**, **`hybrid --step 7`** generates a quickstart self-signed
**`keystore_<ENV_GROUP>.pem`/`.key`** by default and syncs **`APIGEE_OVERRIDE_TLS_*`**;
set **`APIGEE_TLS_SKIP_SELF_SIGNED=1`** to disable. Step **1** only requires a readable, non-empty
**`~/.cshell.env`**; steps **2–13** need the same required Hybrid variables as
**`hybrid --check`**. See **Command Reference** for the full matrix.

When cshell runs automation for a step (Helm pull, `kubectl`, `openssl`, `az aks get-credentials`, `mkdir`, and similar), it prints each command on its own line first, with terminal styling (background highlight) when stdout is a TTY and **`NO_COLOR`** is unset—similar to a short inline code block. Pipe stdout or set **`NO_COLOR`** to get plain text without ANSI sequences.

## Production environments

For **production**, Google’s install requires **seven** Apigee service accounts, key
files under `service-accounts/`, Kubernetes secrets named **`apigee-logger-svc-account`**
through **`apigee-runtime-svc-account`** (see **`hybrid --check`** heuristics), and
**CA-signed** TLS material. Choosing **`APIGEE_OVERRIDES_PROFILE=prod`** (or **`prod`**
in the wizard) makes cshell emit an **`overrides.yaml`** that references those secret
names; you must still create the accounts, keys, and secrets per
[Service accounts](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-service-accounts)
and [Service account authentication](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-sa-authentication).

## Non-production environments

For a **non-prod** Apigee hybrid runtime, Google’s install guide expects an
environment-specific service account (often named `apigee-non-prod`), key file
`$PROJECT_ID-apigee-non-prod.json` under your charts/service-accounts layout, and
a Kubernetes secret such as `apigee-non-prod-svc-account`. Align `ENVIRONMENT_NAME`
with the environment you created in the Apigee UI.

For trial-style installs, self-signed TLS in
`$APIGEE_HELM_CHARTS_HOME/apigee-virtualhost/certs/` is acceptable (Google’s quickstart uses
`keystore_$ENV_GROUP.pem` / `keystore_$ENV_GROUP.key`); production should use properly signed
certificates.

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
. ~/.cshell-env-exports.sh
```

Or, after **`cshell hybrid`** refreshed the file:

```bash
eval "$(cshell hybrid --export --print)"
```

**`cshell hybrid`** and **`cshell hybrid --export`** update **`~/.cshell-env-exports.sh`**
only; they do **not** append hooks to **`~/.bashrc`** / **`~/.profile`**. For **new**
Bash sessions, hooks are installed when you run **`cshell setup`**, **`cshell init`**, or
**`cshell config set`** (those commands sync exports and ensure **`~/.bashrc`** (etc.)
sources the snippet). **bash 4+** is required for snippet generation. Do not run the
snippet path as a program (`./…`)—use **`.`** / **`source`**. Avoid `source ~/.cshell.env`
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
