# Command Reference

## Global

- `cshell --version`: print current script version
- `cshell help`: print usage, command list, documentation links, and exit-code summary
- `cshell docs`: print project and Apigee documentation links
- `cshell --no-update-check` (or `CSHELL_NO_UPDATE_CHECK=1`): skip the optional
  “newer release available” hint (cached by default for 24 hours)
- **`NO_COLOR`**: when set and non-empty, or when stdout is not a terminal, `cshell`
  omits ANSI colors (pipe- and log-friendly output).

### Exit codes

- **0** — success
- **1** — error (missing env file, validation failure, unknown command, etc.)
- **`cshell hybrid --check`**: **1** if `~/.cshell.env` is missing or empty, any required
  Hybrid variable is missing or empty, or (with **`--strict`**) any checklist row is **✗**.
  Rows **○** do not fail `--strict`. Without `--strict`, the numbered checklist is
  informational for exit status except for the required-variable / env-file errors above.

**Note:** `-v` at the top level means `--version`. `backup` / `restore` use `-v` as
`--verbose`.

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
- creates **`~/apigee-hybrid/helm-charts`** if needed and writes **`APIGEE_HELM_CHARTS_HOME`**
  (canonical path) to `~/.cshell.env`
- prompts for Azure Blob backup parameters

## `cshell hybrid`

Prepares Apigee Hybrid environment variables (including namespace, environment
name, environment group, hostname, optional **`AKS_RESOURCE_GROUP`** for Azure
Kubernetes Service, and optional control-plane location for data residency),
prompts for non-prod **Helm `overrides.yaml`** settings (with defaults from the
same wizard / `~/.cshell.env` where applicable), then pulls required Helm charts and
writes **`${APIGEE_HELM_CHARTS_HOME}/overrides.yaml`** (non-prod, Kubernetes Secrets)
unless the file already exists and you decline replacement, or in non-interactive
mode unless **`APIGEE_OVERRIDES_OVERWRITE=1`**. When **`AKS_RESOURCE_GROUP`** and
**`CLUSTER_NAME`** are set and **`az`** is on `PATH`, merges kubeconfig with
`az aks get-credentials --overwrite-existing` (non-fatal if the command fails).
Replaces only the Hybrid block in `~/.cshell.env` so unrelated Azure keys stay
intact. Requires **Helm v3.14+** and GCP auth to pull OCI charts. With
`APIGEE_SETUP_NONINTERACTIVE=1`, uses defaults from the environment /
`~/.cshell.env` (no prompts). Prints the full Google Hybrid v1.16 install link
list (same as `cshell docs`).

- `hybrid --check`: read-only validation that `~/.cshell.env` exists and all
  required Hybrid variables are **non-empty** (`PROJECT_ID`, `ORG_*`,
  `ANALYTICS_REGION`, `RUNTIMETYPE`, `CLUSTER_*`, `APIGEE_NAMESPACE`,
  `ENVIRONMENT_NAME`, `ENV_GROUP`, `ENV_GROUP_RELEASE_NAME`, `DOMAIN`,
  `APIGEE_HELM_CHARTS_HOME`). **DOMAIN must be set** for a successful check (stricter
  than `APIGEE_SETUP_NONINTERACTIVE`, which only warns when `DOMAIN` is empty).
  `CONTROL_PLANE_LOCATION` is optional. `CHART_REPO` / `CHART_VERSION` need not
  appear in the file when built-in defaults apply. After loading the env file it
  prints a **numbered checklist** (items 1–13) in the same order as the Google
  Apigee Hybrid v1.16 install topics (plus the community guide link), each item
  with a separate **`Doc:`** line for the documentation URL (and optional **`↳`** notes), indented to
  match the **first character of the step title**. **✓** /
  **✗** / **○** use the following heuristics (status on the first line without `[` `]`):
  1. Required Hybrid variables (before you begin).
  2. Cluster reachability (`kubectl cluster-info`) when `kubectl` is on `PATH`.
  3. Unpacked chart directories under `APIGEE_HELM_CHARTS_HOME`.
  4. Namespace exists when `kubectl` uses a working context.
  5. **Service accounts:** non-prod key file `…/service-accounts/${PROJECT_ID}-apigee-non-prod.json`
     or matching GCP SA email via `gcloud`; production expects **seven** key files
     (logger, guardrails, metrics, watcher, mart, synchronizer, runtime) or the same
     seven `@…` service accounts; **○** when neither keys nor `gcloud` are available
     (Vault / Workload Identity).
  6. **SA auth:** `apigee-non-prod-svc-account` (non-prod) or the seven production
     `apigee-*-svc-account` secrets in `APIGEE_NAMESPACE` when the cluster checks
     apply; **○** if `kubectl` or the namespace is unavailable.
  7. **TLS:** files under `apigee-virtualhost/certs/`, or a cert-manager `Certificate`
     / `kubernetes.io/tls` secret in the namespace when cluster checks apply.
  8. **Overrides:** non-empty `overrides.yaml` in `APIGEE_HELM_CHARTS_HOME`.
  9. **Control plane access:** `GET …/organizations/${ORG_NAME}/controlPlaneAccess`
     (respecting `CONTROL_PLANE_LOCATION` for data residency) with `gcloud`’s access
     token; **✓** only when the response lists synchronizer service accounts; **○**
     on non-200 HTTP or missing credentials/network.
  10. **cert-manager:** CRD `certificates.cert-manager.io` and a non-empty
      `cert-manager` pod list when the cluster is reachable.
  11. **CRDs:** `apigeeorganizations.apigee.cloud.google.com` installed.
  12. **Helm:** release name `apigee-operator` in `APIGEE_NAMESPACE`.
  13. **Community guide:** HTTP 2xx on the linked GitHub doc; **○** if unreachable
      (offline), not **✗**.

  **`hybrid --check --strict`:** same checks; **exit status 1** if any row shows **✗**.
  Rows marked **○** (not verifiable in this environment) do **not** fail `--strict`.
  Without `--strict`, **exit status** still reflects **only** required-variable
  validation (and env file presence), not the checklist. No file writes and no chart
  downloads.

  **`hybrid --check --json`:** prints one JSON object on **stdout** (schema
  `cshell.hybrid_check.v1`) with `strict`, `checklist_fail_count`, and a `steps`
  array (`id`, `title`, `url`, `symbol`, `status` as `pass` / `fail` / `skip`, `note`).
  No ANSI styling or banner lines on stdout (errors still go to **stderr**). Can be
  combined with **`--strict`** (either order after `--check`). **Exit codes** match the non-JSON
  `--check` behavior.

- `hybrid --export`: same required-variable checks as `--check`, then regenerates
  **`~/.cshell-env-exports.sh`** and ensures **`~/.bashrc`**, **`~/.profile`**, and
  **`~/.bash_profile`** (if present) source it (same as `cshell_env_sync_exports`
  after setup/hybrid/config). Use this when you only want exports refreshed
  without running the full interactive hybrid flow. In the **current** shell,
  run `. ~/.cshell-env-exports.sh` (or `source ~/.bashrc` / open a new terminal).
  **Requires bash 4+** for the snippet writer.

- `hybrid --export --print`: after the same validation, writes the snippet file and
  prints **only** `export …` lines to **stdout** (no banners). Intended for:
  `eval "$(cshell hybrid --export --print)"` to load allowlisted variables into
  the **current** shell in one step. **Requires bash 4+**.

- `hybrid --step <1-13>`: run a **single** Hybrid install checklist item (same numbering
  and **Doc:** URLs as `hybrid --check`). This mirrors **Part 2: Hybrid runtime setup** in
  Google’s sidebar: cshell **1** = *Before you begin*, cshell **2–12** = Google **Step 1–11**
  (e.g. **`hybrid --step 7`** = Google **Step 6: Create TLS certificates**), and cshell **13**
  is the extra community guide link. Prints that row’s status (✓ / ✗ / ○), then runs the
  matching automation where cshell can do so safely:
  - **1** — same required-variable gate as `--check` for step 1 only (exits **1** if any
    required Hybrid variable is missing); no chart or cluster changes.
  - **2** — prints the cluster doc link; runs `az aks get-credentials` when
    **`AKS_RESOURCE_GROUP`** and **`CLUSTER_NAME`** are set (same behavior as the end of
    interactive `hybrid`).
  - **3** — **Helm v3.14+** check and `helm pull` for all bundled Apigee charts into
    **`APIGEE_HELM_CHARTS_HOME`** (needs GCP OCI auth).
  - **4** — `kubectl create namespace` for **`APIGEE_NAMESPACE`** when `kubectl` is available
    and the namespace is missing; otherwise warns with the namespace doc link.
  - **5** — creates **`…/service-accounts`** and lists expected key paths (non-prod vs
    seven production keys); does not create Google service accounts.
  - **6** — hints and a non-prod **kubectl** secret example; does not apply secrets
    automatically.
  - **7** — TLS (Google [Step 6](https://docs.cloud.google.com/apigee/docs/hybrid/v1.16/install-create-tls-certificates)):
    ensures directories under **`apigee-virtualhost`**. For **non-prod** (non-prod key/setup
    detection or **`ENVIRONMENT_NAME`** matching `non[-_]prod` / `nonprod`), **by default**
    runs `openssl req -nodes -new -x509` for **`certs/keystore_<ENV_GROUP>.pem`** and
    **`.key`** (**3650** days, **CN=`DOMAIN`**), then updates **`APIGEE_OVERRIDE_TLS_*`** in
    **`~/.cshell.env`** and refreshes export hooks when possible. Set
    **`APIGEE_TLS_SKIP_SELF_SIGNED=1`** to skip that automatic quickstart cert. Outside
    non-prod (or after skipping), **`APIGEE_TLS_SELF_SIGNED=1`** generates at the paths from
    **`APIGEE_OVERRIDE_TLS_CERT_REL`** / **`APIGEE_OVERRIDE_TLS_KEY_REL`** (defaults
    **`certs/tls.crt`** / **`certs/tls.key`**). Existing files are not overwritten.
  - **8** — writes **`overrides.yaml`** like interactive `hybrid` (needs
    **`APIGEE_INSTANCE_ID`** and other override keys in **`~/.cshell.env`**; respects the
    same overwrite rules as **`APIGEE_SETUP_NONINTERACTIVE`** / **`APIGEE_OVERRIDES_OVERWRITE`**
    / confirm).
  - **9–13** — prints the relevant documentation link; complete those steps on the
    cluster / in GCP per Google’s guides.

## `cshell backup`

- creates `~/archive.zip`
- uploads archive to configured Azure Blob container (replaces an existing `archive.zip` blob)
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
