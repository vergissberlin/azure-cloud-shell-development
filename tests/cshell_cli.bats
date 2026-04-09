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
	[[ "$output" == *"All required"* ]]
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
	[[ "$output" == *Missing* ]]
	[[ "$output" == *DOMAIN* ]]
}

@test "hybrid --check rejects extra arguments" {
	export_home_tmp
	printf '%s\n' "PROJECT_ID=x" >"${HOME}/.cshell.env"
	run_cshell hybrid --check extra
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
