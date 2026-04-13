#!/usr/bin/env bats
# Core CLI smoke tests (no Azure calls).

load test_helper

setup() {
	common_setup
}

@test "cshell --version matches semver line" {
	run_cshell --version
	[ "$status" -eq 0 ]
	[[ "$output" =~ ^cshell[[:space:]]+[0-9]+\.[0-9]+\.[0-9] ]]
}

@test "cshell help exits 0" {
	run_cshell help
	[ "$status" -eq 0 ]
	[[ "$output" == *Commands:* ]]
	[[ "$output" == *"Exit codes"* ]]
	[[ "$output" == *NO_COLOR* ]]
}

@test "global --no-update-check before help still works" {
	run bash "${REPO_ROOT}/cshell" --no-update-check help
	[ "$status" -eq 0 ]
	[[ "$output" == *Commands:* ]]
}

@test "cshell docs exits 0 and mentions project docs" {
	run_cshell docs
	[ "$status" -eq 0 ]
	[[ "$output" == *vergissberlin* ]]
}

@test "cshell with no command prints usage and exits 1" {
	run_cshell
	[ "$status" -eq 1 ]
	[[ "$output" == *Usage:* ]]
}

@test "unknown command prints usage and exits 1" {
	run_cshell not-a-real-command
	[ "$status" -eq 1 ]
	[[ "$output" == *Usage:* ]]
}

@test "config set refreshes ~/.cshell-env-exports.sh (bash 4+)" {
	if [[ "${BASH_VERSINFO[0]:-0}" -lt 4 ]]; then
		skip "requires bash 4+ for export snippet"
	fi
	export_home_tmp
	printf '%s\n' "PROJECT_ID=before" >"${HOME}/.cshell.env"
	run_cshell config set PROJECT_ID after
	[ "$status" -eq 0 ]
	[ -f "${HOME}/.cshell-env-exports.sh" ]
	run grep -q '^export PROJECT_ID=' "${HOME}/.cshell-env-exports.sh"
	[ "$status" -eq 0 ]
}

@test "config show masks storage account key" {
	export_home_tmp
	{
		echo "AZURE_STORAGE_ACCOUNT=demoacct"
		echo "AZURE_STORAGE_ACCOUNT_KEY=supersecret"
	} >"${HOME}/.cshell.env"

	run_cshell config show
	[ "$status" -eq 0 ]
	[[ "$output" == *"AZURE_STORAGE_ACCOUNT_KEY=********"* ]]
	[[ "$output" == *"AZURE_STORAGE_ACCOUNT=demoacct"* ]]
}

@test "backup --dry-run does not create archive" {
	export_home_tmp
	run_cshell backup --dry-run
	[ "$status" -eq 0 ]
	[ ! -f "${HOME}/archive.zip" ]
}

@test "backup rejects unknown option" {
	export_home_tmp
	run_cshell backup --not-a-flag
	[ "$status" -eq 1 ]
}

@test "tarball gcloud install symlinks launcher into PATH (does not copy it alone)" {
	run grep -qF 'ln -sf "${gcloud_root}/bin/gcloud"' "${REPO_ROOT}/cshell"
	[ "$status" -eq 0 ]
	run grep -qF 'tar -xzf "${gcloud_tar}" -C "${HOME}"' "${REPO_ROOT}/cshell"
	[ "$status" -eq 0 ]
}

@test "storage account key resolver calls ARM listKeys with curl" {
	run grep -qF 'cshell_arm_fetch_storage_account_key' "${REPO_ROOT}/cshell"
	[ "$status" -eq 0 ]
	run grep -qF 'listKeys?api-version=2023-01-01' "${REPO_ROOT}/cshell"
	[ "$status" -eq 0 ]
	run grep -q 'curl -fsSL' "${REPO_ROOT}/cshell"
	[ "$status" -eq 0 ]
}

@test "setup offers gcloud auth login after fresh SDK install" {
	run grep -qF '"${gcloud_cmd}" auth login' "${REPO_ROOT}/cshell"
	[ "$status" -eq 0 ]
	run grep -qF 'Skipping interactive gcloud auth login' "${REPO_ROOT}/cshell"
	[ "$status" -eq 0 ]
}

@test "hybrid --help prints flag summary and exits 0" {
	run_cshell hybrid --help
	[ "$status" -eq 0 ]
	[[ "$output" == *"--check"* ]]
	[[ "$output" == *"--step"* ]]
	[[ "$output" == *"--export"* ]]
	[[ "$output" == *"--strict"* ]]
}

@test "hybrid -h prints flag summary and exits 0" {
	run_cshell hybrid -h
	[ "$status" -eq 0 ]
	[[ "$output" == *"--check"* ]]
	[[ "$output" == *"--step"* ]]
}

@test "hybrid --check succeeds when all required vars are set" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=/tmp/charts
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell hybrid --check
	[ "$status" -eq 0 ]
	[[ "$output" == *"Session checks"* ]]
	[[ "$output" == *"install checklist"* ]]
	[[ "$output" == *"GCP authentication"* ]]
	[[ "$output" == *"✓"*"Before you begin"* ]]
	[[ "$output" != *"0. Before you begin"* ]]
	[[ "$output" != *"1. Before you begin"* ]]
	[[ "$output" == *"Doc:"*install-before-begin* ]]
	[[ "$output" == *"12. Official Hybrid install hub"* ]]
	[[ "$output" == *"All required"* ]]
}

@test "hybrid --check omits ANSI escapes when NO_COLOR is set" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=/tmp/charts
# END_CSHELL_HYBRID_ENV
EOF
	# Hide kubectl/helm/gcloud so subprocesses do not inject ANSI into merged stdout/stderr.
	local bats_bash bats_path
	bats_bash="$(command -v bash)"
	bats_path="$(hybrid_path_for_local_files_only)"
	run env NO_COLOR=1 PATH="${bats_path}" "${bats_bash}" "${REPO_ROOT}/cshell" hybrid --check
	[ "$status" -eq 0 ]
	[[ "$output" != *$'\e'* ]]
	[[ "$output" != *$'\033'* ]]
}

@test "hybrid --check --json prints schema and steps on stdout" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=/tmp/charts
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell hybrid --check --json
	[ "$status" -eq 0 ]
	[[ "$output" == *'"schema":"cshell.hybrid_check.v1"'* ]]
	[[ "$output" == *'"prechecks"'* ]]
	[[ "$output" == *'"id":"gcp_auth"'* ]]
	[[ "$output" == *'"id":"aks_cluster"'* ]]
	[[ "$output" == *'"checklist_fail_count"'* ]]
	[[ "$output" == *'"steps"'* ]]
	[[ "$output" == *'"id":1'* ]]
	[[ "$output" == *'"status":"pass"'* ]]
	[[ "$output" != *"install checklist"* ]]
	[[ "$output" != *$'\e'* ]]
}

@test "hybrid --check --strict --json emits strict true in JSON" {
	export_home_tmp
	local charts="${HOME}/hybrid-charts"
	hybrid_make_chart_fixture "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell_with_path "$(hybrid_path_for_local_files_only)" hybrid --check --strict --json
	[ "$status" -eq 0 ]
	[[ "$output" == *'"strict":true'* ]]
}

@test "hybrid --check fails when a required var is missing" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=desc
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
APIGEE_HELM_CHARTS_HOME=/tmp/charts
EOF
	run_cshell hybrid --check
	[ "$status" -eq 1 ]
	[[ "$output" == *"✗"*"Before you begin"* ]]
	[[ "$output" != *"1. Before you begin"* ]]
	[[ "$output" == *Missing* ]]
	[[ "$output" == *DOMAIN* ]]
}

@test "hybrid --check rejects extra arguments" {
	export_home_tmp
	printf '%s\n' "PROJECT_ID=x" >"${HOME}/.cshell.env"
	run_cshell hybrid --check extra
	[ "$status" -eq 1 ]
}

@test "hybrid --check --json rejects extra arguments" {
	export_home_tmp
	printf '%s\n' "PROJECT_ID=x" >"${HOME}/.cshell.env"
	run_cshell hybrid --check --json trailing
	[ "$status" -eq 1 ]
}

hybrid_make_chart_fixture() {
	local charts="$1"
	mkdir -p "${charts}/service-accounts"
	mkdir -p "${charts}/apigee-virtualhost/certs"
	touch "${charts}/apigee-virtualhost/certs/tls.crt" "${charts}/apigee-virtualhost/certs/tls.key"
	touch "${charts}/service-accounts/p-demo-apigee-non-prod.json"
	printf '%s\n' 'projectID: p-demo' >"${charts}/overrides.yaml"
	local c
	for c in apigee-operator apigee-datastore apigee-env apigee-ingress-manager apigee-org apigee-redis apigee-telemetry apigee-virtualhost; do
		mkdir -p "${charts}/${c}"
	done
}

# Drop dirs that expose kubectl/helm/gcloud so heuristic checks stay ○ (not ✗) without a real cluster.
# When a directory like /usr/bin is dropped because it contains kubectl, core utilities there (grep,
# curl, …) would also disappear and cshell can exit before finishing. Append a temp dir of symlinks to
# those binaries (resolved before PATH is rewritten) so CI behaves like a dev laptop.
hybrid_path_for_local_files_only() {
	local out="" d
	while IFS= read -r d; do
		[[ -z "${d}" ]] && continue
		[[ -x "${d}/kubectl" ]] && continue
		[[ -x "${d}/helm" ]] && continue
		[[ -x "${d}/gcloud" ]] && continue
		out="${out:+$out:}${d}"
	done <<<"$(printf '%s' "${PATH:-}" | tr ':' '\n')"
	out="${out:-/usr/bin:/bin:/usr/sbin:/sbin}"
	local mini util p
	mini="$(mktemp -d)"
	for util in grep curl awk sed tr mktemp wc cat head tail cut dirname basename sort env; do
		p="$(command -v "${util}" 2>/dev/null || true)"
		[[ -n "${p}" && "${p}" == */* && -x "${p}" ]] && ln -sf "${p}" "${mini}/${util}"
	done
	printf '%s:%s\n' "${out}" "${mini}"
}

@test "hybrid --check --strict succeeds when checklist has no failures" {
	export_home_tmp
	local charts="${HOME}/hybrid-charts"
	hybrid_make_chart_fixture "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell_with_path "$(hybrid_path_for_local_files_only)" hybrid --check --strict
	[ "$status" -eq 0 ]
	[[ "$output" == *"All required"* ]]
}

@test "hybrid --check --strict fails when a checklist step fails" {
	export_home_tmp
	local charts="${HOME}/hybrid-charts"
	hybrid_make_chart_fixture "${charts}"
	rm -f "${charts}/overrides.yaml"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell_with_path "$(hybrid_path_for_local_files_only)" hybrid --check --strict
	[ "$status" -eq 1 ]
	[[ "$output" == *"failed item"* ]]
}

@test "hybrid --check --strict --json still prints JSON before strict failure" {
	export_home_tmp
	local charts="${HOME}/hybrid-charts"
	hybrid_make_chart_fixture "${charts}"
	rm -f "${charts}/overrides.yaml"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell_with_path "$(hybrid_path_for_local_files_only)" hybrid --check --strict --json
	[ "$status" -eq 1 ]
	[[ "$output" == *'"schema":"cshell.hybrid_check.v1"'* ]]
	[[ "$output" == *'"checklist_fail_count":'* ]]
	[[ "$output" != *"install checklist"* ]]
}

@test "hybrid --check --strict rejects extra arguments" {
	export_home_tmp
	printf '%s\n' "PROJECT_ID=x" >"${HOME}/.cshell.env"
	run_cshell hybrid --check --strict extra
	[ "$status" -eq 1 ]
}

@test "hybrid --check fails when env file is missing" {
	export_home_tmp
	run_cshell hybrid --check
	[ "$status" -eq 1 ]
	[[ "$output" == *missing* ]] || [[ "$output" == *Missing* ]]
}

@test "hybrid --check fails when env file is empty" {
	export_home_tmp
	: >"${HOME}/.cshell.env"
	run_cshell hybrid --check
	[ "$status" -eq 1 ]
	[[ "$output" == *empty* ]] || [[ "$output" == *Empty* ]]
}

@test "hybrid --export refreshes export snippet (bash 4+)" {
	if [[ "${BASH_VERSINFO[0]:-0}" -lt 4 ]]; then
		skip "requires bash 4+ for export snippet"
	fi
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=/tmp/charts
EOF
	run_cshell hybrid --export
	[ "$status" -eq 0 ]
	[[ "$output" == *".cshell-env-exports.sh"* ]]
	[ -f "${HOME}/.cshell-env-exports.sh" ]
	grep -q '^export DOMAIN=' "${HOME}/.cshell-env-exports.sh"
}

@test "hybrid --export --print writes only export lines to stdout (bash 4+)" {
	if [[ "${BASH_VERSINFO[0]:-0}" -lt 4 ]]; then
		skip "requires bash 4+ for export snippet"
	fi
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=/tmp/charts
EOF
	run_cshell hybrid --export --print
	[ "$status" -eq 0 ]
	local bad
	bad="$(printf '%s\n' "${output}" | grep '.' | grep -v '^export ' || true)"
	[[ -z "${bad}" ]]
	[[ "${output}" == *"export DOMAIN="* ]]
}

@test "hybrid --export fails when a required var is missing" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=desc
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
APIGEE_HELM_CHARTS_HOME=/tmp/charts
EOF
	run_cshell hybrid --export
	[ "$status" -eq 1 ]
	[[ "$output" == *Missing* ]]
}

@test "hybrid --export rejects extra arguments" {
	export_home_tmp
	printf '%s\n' "PROJECT_ID=x" >"${HOME}/.cshell.env"
	run_cshell hybrid --export extra
	[ "$status" -eq 1 ]
}

@test "hybrid --step requires a number 1-13" {
	export_home_tmp
	printf '%s\n' "PROJECT_ID=x" >"${HOME}/.cshell.env"
	run_cshell hybrid --step
	[ "$status" -eq 1 ]
	run_cshell hybrid --step 0
	[ "$status" -eq 1 ]
	run_cshell hybrid --step 14
	[ "$status" -eq 1 ]
	run_cshell hybrid --step foo
	[ "$status" -eq 1 ]
}

@test "hybrid --step rejects trailing arguments" {
	export_home_tmp
	printf '%s\n' "PROJECT_ID=x" >"${HOME}/.cshell.env"
	run_cshell hybrid --step 3 extra
	[ "$status" -eq 1 ]
}

@test "hybrid --step 1 exits 1 when required vars missing" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=desc
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
APIGEE_HELM_CHARTS_HOME=/tmp/charts
EOF
	run_cshell hybrid --step 1
	[ "$status" -eq 1 ]
	[[ "$output" == *"Before you begin"* ]]
	[[ "$output" != *"1. Before you begin"* ]]
	[[ "$output" == *Missing* ]]
}

@test "hybrid --step 1 succeeds when all required vars are set" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=/tmp/charts
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell hybrid --step 1
	[ "$status" -eq 0 ]
	[[ "$output" == *"Before you begin"* ]]
	[[ "$output" != *"1. Before you begin"* ]]
	[[ "$output" == *"All required"* ]] || [[ "$output" == *".cshell.env"* ]]
}

@test "hybrid --step 3 uses helm from PATH (stub)" {
	export_home_tmp
	local stub_bin charts hp
	stub_bin="$(mktemp -d)"
	charts="${HOME}/hybrid-charts"
	mkdir -p "${charts}"
	cat >"${stub_bin}/helm" <<'EOF'
#!/bin/sh
if [ "$1" = "version" ] && [ "$2" = "--short" ]; then
	printf '%s\n' "v3.14.0"
	exit 0
fi
if [ "$1" = "pull" ]; then
	exit 0
fi
exit 1
EOF
	chmod +x "${stub_bin}/helm"
	hp="$(hybrid_path_for_local_files_only)"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell_with_path "${stub_bin}:${hp}" hybrid --step 3
	[ "$status" -eq 0 ]
	[[ "$output" == *"Download Helm charts"* ]] || [[ "$output" == *"Helm charts"* ]]
	[[ "$output" == *"helm pull"* ]]
	[[ "$output" == *"oci://us-docker.pkg.dev"* ]] || [[ "$output" == *"apigee-hybrid-helm-charts"* ]]
}

# hybrid --step validations: env file and required variables (step 1 vs steps 2–13)
@test "hybrid --step 1 fails when env file is missing" {
	export_home_tmp
	run_cshell hybrid --step 1
	[ "$status" -eq 1 ]
	[[ "$output" == *missing* ]] || [[ "$output" == *Missing* ]]
}

@test "hybrid --step 2 fails when required Hybrid vars are missing (same gate as --export)" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=desc
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
APIGEE_HELM_CHARTS_HOME=/tmp/charts
EOF
	run_cshell hybrid --step 2
	[ "$status" -eq 1 ]
	[[ "$output" == *Missing* ]]
	[[ "$output" == *DOMAIN* ]]
}

@test "hybrid --step 5 validates full env before running (missing DOMAIN)" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=desc
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
APIGEE_HELM_CHARTS_HOME=/tmp/charts
EOF
	run_cshell hybrid --step 5
	[ "$status" -eq 1 ]
	[[ "$output" == *Missing* ]]
}

@test "hybrid --step 3 fails when helm is not on PATH" {
	export_home_tmp
	local hp charts
	hp="$(hybrid_path_for_local_files_only)"
	charts="${HOME}/hybrid-charts-no-helm"
	mkdir -p "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell_with_path "${hp}" hybrid --step 3
	[ "$status" -eq 1 ]
	[[ "$output" == *helm* ]] || [[ "$output" == *Helm* ]]
}

@test "hybrid --step 3 fails when helm is below minimum version" {
	export_home_tmp
	local stub_bin charts hp
	stub_bin="$(mktemp -d)"
	charts="${HOME}/hybrid-charts"
	mkdir -p "${charts}"
	cat >"${stub_bin}/helm" <<'EOF'
#!/bin/sh
if [ "$1" = "version" ] && [ "$2" = "--short" ]; then
	printf '%s\n' "v3.12.0"
	exit 0
fi
exit 1
EOF
	chmod +x "${stub_bin}/helm"
	hp="$(hybrid_path_for_local_files_only)"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell_with_path "${stub_bin}:${hp}" hybrid --step 3
	[ "$status" -eq 1 ]
	[[ "$output" == *3.14* ]] || [[ "$output" == *helm* ]]
}

@test "hybrid --step 8 fails when APIGEE_INSTANCE_ID is missing" {
	export_home_tmp
	local charts="${HOME}/hybrid-charts-step8"
	mkdir -p "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell hybrid --step 8
	[ "$status" -eq 1 ]
	[[ "$output" == *APIGEE_INSTANCE_ID* ]]
}

@test "hybrid --step 8 writes overrides.yaml in non-interactive mode" {
	export_home_tmp
	local charts="${HOME}/hybrid-charts-step8-ni"
	mkdir -p "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
APIGEE_INSTANCE_ID=hybrid-demo-id
# END_CSHELL_HYBRID_ENV
EOF
	run env APIGEE_SETUP_NONINTERACTIVE=1 bash "${REPO_ROOT}/cshell" hybrid --step 8
	[ "$status" -eq 0 ]
	[ -f "${charts}/overrides.yaml" ]
	grep -qx 'instanceID: hybrid-demo-id' "${charts}/overrides.yaml"
	[[ "$output" != *'--- Proposed overrides.yaml'* ]]
}

@test "hybrid --step 8 interactive: decline write leaves overrides.yaml absent" {
	export_home_tmp
	local charts="${HOME}/hybrid-charts-step8-decline"
	mkdir -p "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
APIGEE_INSTANCE_ID=hybrid-demo-id
# END_CSHELL_HYBRID_ENV
EOF
	run bash -c "printf '%s\n' n | bash \"${REPO_ROOT}/cshell\" hybrid --step 8"
	[ "$status" -eq 0 ]
	[[ ! -f "${charts}/overrides.yaml" ]]
	[[ "$output" == *'Proposed overrides.yaml'* ]]
	[[ "$output" == *'Skipped writing overrides.yaml'* ]]
}

@test "hybrid --step 8 interactive: confirm write creates overrides.yaml" {
	export_home_tmp
	local charts="${HOME}/hybrid-charts-step8-confirm"
	mkdir -p "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
APIGEE_INSTANCE_ID=hybrid-y-ok
# END_CSHELL_HYBRID_ENV
EOF
	run bash -c "printf '%s\n' y | bash \"${REPO_ROOT}/cshell\" hybrid --step 8"
	[ "$status" -eq 0 ]
	[ -f "${charts}/overrides.yaml" ]
	grep -qx 'instanceID: hybrid-y-ok' "${charts}/overrides.yaml"
}

@test "hybrid --step 2 succeeds with full env (smoke, no real cluster)" {
	export_home_tmp
	cat >"${HOME}/.cshell.env" <<'EOF'
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=/tmp/charts
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell hybrid --step 2
	[ "$status" -eq 0 ]
	[[ "$output" == *"1. Create cluster"* ]] || [[ "$output" == *"Create cluster"* ]]
}

@test "hybrid --step 7 generates non-prod keystore and upserts TLS override paths (openssl)" {
	if ! command -v openssl >/dev/null 2>&1; then
		skip "openssl not available"
	fi
	export_home_tmp
	local charts pem key
	charts="${HOME}/hybrid-tls-s7"
	mkdir -p "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=my-env-group
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell hybrid --step 7
	[ "$status" -eq 0 ]
	pem="${charts}/apigee-virtualhost/certs/keystore_my-env-group.pem"
	key="${charts}/apigee-virtualhost/certs/keystore_my-env-group.key"
	[ -f "${pem}" ]
	[ -f "${key}" ]
	grep -qx 'APIGEE_OVERRIDE_TLS_CERT_REL=certs/keystore_my-env-group.pem' "${HOME}/.cshell.env"
	grep -qx 'APIGEE_OVERRIDE_TLS_KEY_REL=certs/keystore_my-env-group.key' "${HOME}/.cshell.env"
}

@test "hybrid --step 7 skips auto self-signed when APIGEE_TLS_SKIP_SELF_SIGNED=1" {
	if ! command -v openssl >/dev/null 2>&1; then
		skip "openssl not available"
	fi
	export_home_tmp
	local charts pem
	charts="${HOME}/hybrid-tls-s7-skip"
	mkdir -p "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=non-prod
ENV_GROUP=envgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
APIGEE_TLS_SKIP_SELF_SIGNED=1
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell hybrid --step 7
	[ "$status" -eq 0 ]
	pem="${charts}/apigee-virtualhost/certs/keystore_envgroup.pem"
	[ ! -f "${pem}" ]
}

@test "hybrid --step 7 does not auto-generate keystore for production-style environment name" {
	if ! command -v openssl >/dev/null 2>&1; then
		skip "openssl not available"
	fi
	export_home_tmp
	local charts pem
	charts="${HOME}/hybrid-tls-s7-prod"
	mkdir -p "${charts}"
	cat >"${HOME}/.cshell.env" <<EOF
# BEGIN_CSHELL_HYBRID_ENV
PROJECT_ID=p-demo
ORG_NAME=p-demo
ORG_DISPLAY_NAME=Demo
ORGANIZATION_DESCRIPTION=Apigee Hybrid organization
ANALYTICS_REGION=europe-west3
RUNTIMETYPE=HYBRID
CLUSTER_NAME=aks-hybrid
CLUSTER_REGION=europe-west3
APIGEE_NAMESPACE=apigee
ENVIRONMENT_NAME=production
ENV_GROUP=prodgroup
ENV_GROUP_RELEASE_NAME=apigee-virtualhost
DOMAIN=api.example.com
APIGEE_HELM_CHARTS_HOME=${charts}
# END_CSHELL_HYBRID_ENV
EOF
	run_cshell hybrid --step 7
	[ "$status" -eq 0 ]
	pem="${charts}/apigee-virtualhost/certs/keystore_prodgroup.pem"
	[ ! -f "${pem}" ]
}
