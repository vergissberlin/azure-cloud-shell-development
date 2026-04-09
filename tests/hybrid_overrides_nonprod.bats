#!/usr/bin/env bats
# shellcheck shell=bash

load test_helper

setup() {
	common_setup
	export_home_tmp
}

@test "cshell_hybrid_validate_ingress_name accepts apigee-ingress" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	cshell_hybrid_validate_ingress_name apigee-ingress
}

@test "cshell_hybrid_validate_ingress_name rejects name longer than 17" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	run cshell_hybrid_validate_ingress_name this-name-is-far-too-long
	[[ "$status" -ne 0 ]]
}

@test "emit includes contractProvider when control plane location set" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	run cshell_hybrid_emit_nonprod_overrides_secretrefs \
		"myorg-aks" "apigee" "p1" "europe-west3" \
		"aks-hybrid" "westeurope" "myorg" \
		"non-prod" "envgroup" "europe-west3" \
		"apigee-non-prod-svc-account" "apigee-ingress" \
		"certs/tls.crt" "certs/tls.key" "" "" \
		"1.16.0" "0"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"contractProvider: https://europe-west3-apigee.googleapis.com"* ]]
}

@test "emit omits contractProvider when control plane location empty" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	run cshell_hybrid_emit_nonprod_overrides_secretrefs \
		"myorg-aks" "apigee" "p1" "europe-west3" \
		"aks-hybrid" "westeurope" "myorg" \
		"non-prod" "envgroup" "" \
		"apigee-non-prod-svc-account" "apigee-ingress" \
		"certs/tls.crt" "certs/tls.key" "" "" \
		"1.16.0" "0"
	[[ "$status" -eq 0 ]]
	[[ "$output" != *"contractProvider:"* ]]
}

@test "emit includes single runtime block with image and large payload" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	run cshell_hybrid_emit_nonprod_overrides_secretrefs \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" \
		"e" "g" "" \
		"sec" "ing" \
		"c.crt" "k.key" "" "" \
		"1.16.1" "1"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"runtime:"* ]]
	[[ "$(grep -c '^runtime:' <<<"${output}")" -eq 1 ]]
	[[ "$output" == *'tag: "1.16.1"'* ]]
	[[ "$output" == *"bin_setenv_max_mem: 4096m"* ]]
	[[ "$output" == *"memory: 4Gi"* ]]
}

@test "emit includes serviceAccountSecretRefs for non-prod" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	run cshell_hybrid_emit_nonprod_overrides_secretrefs \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" "e" "g" "" \
		"apigee-non-prod-svc-account" "ing" \
		"c.crt" "k.key" "" "" "1.16.0" "0"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"serviceAccountSecretRefs:"* ]]
	[[ "$output" == *"synchronizer: apigee-non-prod-svc-account"* ]]
}

@test "emit includes svcAnnotations when key and value set" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	run cshell_hybrid_emit_nonprod_overrides_secretrefs \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" \
		"e" "g" "" \
		"sec" "ing" \
		"c.crt" "k.key" "service.beta.kubernetes.io/azure-load-balancer-internal" "true" \
		"1.16.0" "0"
	[[ "$status" -eq 0 ]]
	[[ "$output" == *"svcAnnotations:"* ]]
	[[ "$output" == *"service.beta.kubernetes.io/azure-load-balancer-internal: true"* ]]
}

@test "atomic write refuses when file exists and overwrite 0" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	local d
	d="$(mktemp -d)"
	printf 'x' >"${d}/overrides.yaml"
	run cshell_hybrid_atomic_write_nonprod_overrides "${d}" "0" \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" "e" "g" "" \
		"sec" "ing" "c.crt" "k.key" "" "" "1.16.0" "0"
	[[ "$status" -eq 2 ]]
	[[ "$(cat "${d}/overrides.yaml")" == "x" ]]
}

@test "atomic write succeeds with overwrite 1" {
	source "${REPO_ROOT}/lib/hybrid-overrides-nonprod.sh"
	local d
	d="$(mktemp -d)"
	run cshell_hybrid_atomic_write_nonprod_overrides "${d}" "1" \
		"id" "apigee" "p1" "europe-west3" \
		"c" "r" "o" "e" "g" "" \
		"sec" "ing" "c.crt" "k.key" "" "" "1.16.0" "0"
	[[ "$status" -eq 0 ]]
	grep -q 'instanceID: id' "${d}/overrides.yaml"
}
