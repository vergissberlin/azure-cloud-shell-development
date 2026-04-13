#!/usr/bin/env bats
# shellcheck shell=bash

load test_helper

setup() {
	common_setup
	export_home_tmp
}

@test "prod emit includes distinct service account refs" {
	source "${REPO_ROOT}/lib/hybrid-overrides-prod.sh"
	run cshell_hybrid_emit_prod_overrides_secretrefs \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" "e" "g" "" \
		"apigee-ingress" \
		"certs/tls.crt" "certs/tls.key" "" "" \
		"1.16.0" "0"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"synchronizer: apigee-synchronizer-svc-account"* ]]
	[[ "$output" == *"runtime: apigee-runtime-svc-account"* ]]
	[[ "$output" == *"serviceAccountRef: apigee-guardrails-svc-account"* ]]
	[[ "$output" == *"mintTaskScheduler:"* ]]
	[[ "$output" == *"serviceAccountRef: apigee-synchronizer-svc-account"* ]]
}

@test "prod emit includes contractProvider when control plane location set" {
	source "${REPO_ROOT}/lib/hybrid-overrides-prod.sh"
	run cshell_hybrid_emit_prod_overrides_secretrefs \
		"myorg-aks" "apigee" "p1" "europe-west3" \
		"aks-hybrid" "westeurope" "myorg" \
		"prod" "envgroup" "europe-west3" \
		"apigee-ingress" \
		"certs/tls.crt" "certs/tls.key" "" "" \
		"1.16.0" "0"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"contractProvider: https://europe-west3-apigee.googleapis.com"* ]]
}

@test "prod emit runtime block has serviceAccountRef and image" {
	source "${REPO_ROOT}/lib/hybrid-overrides-prod.sh"
	run cshell_hybrid_emit_prod_overrides_secretrefs \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" "e" "g" "" \
		"ing" "c.crt" "k.key" "" "" "1.16.1" "1"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"serviceAccountRef: apigee-runtime-svc-account"* ]]
	[[ "$output" == *'tag: "1.16.1"'* ]]
	[[ "$output" == *"bin_setenv_max_mem: 4096m"* ]]
}

@test "prod atomic write refuses when file exists and overwrite 0" {
	source "${REPO_ROOT}/lib/hybrid-overrides-prod.sh"
	local d
	d="$(mktemp -d)"
	printf 'x' >"${d}/overrides.yaml"
	run cshell_hybrid_atomic_write_prod_overrides "${d}" "0" \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" "e" "g" "" \
		"ing" "c.crt" "k.key" "" "" "1.16.0" "0"
	[[ "$status" -eq 2 ]]
	[[ "$(cat "${d}/overrides.yaml")" == "x" ]]
}

@test "prod atomic write succeeds with overwrite 1" {
	source "${REPO_ROOT}/lib/hybrid-overrides-prod.sh"
	local d
	d="$(mktemp -d)"
	run cshell_hybrid_atomic_write_prod_overrides "${d}" "1" \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" "e" "g" "" \
		"ing" "c.crt" "k.key" "" "" "1.16.0" "0"
	[[ "$status" -eq 0 ]]
	grep -q 'instanceID: id' "${d}/overrides.yaml"
	grep -q 'Apigee Hybrid production overrides' "${d}/overrides.yaml"
}
