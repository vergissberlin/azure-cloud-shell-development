#!/usr/bin/env bats
# cshell_hybrid_fetch_aks_kubeconfig — stub az, no real Azure calls.

load test_helper

setup() {
	common_setup
}

@test "cshell_hybrid_fetch_aks_kubeconfig invokes az with resource group and cluster" {
	export_home_tmp
	local stub_bin="${HOME}/stub-bin"
	mkdir -p "${stub_bin}"
	cat >"${stub_bin}/az" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${AZ_STUB_LOG}"
exit 0
STUB
	chmod +x "${stub_bin}/az"

	export AZ_STUB_LOG="${HOME}/az-invocation.log"
	: >"${AZ_STUB_LOG}"

	# shellcheck source=/dev/null
	source "${REPO_ROOT}/scripts/misc-cli-utils.sh"
	# shellcheck source=/dev/null
	source "${REPO_ROOT}/lib/portable.sh"
	# shellcheck source=/dev/null
	source "${REPO_ROOT}/lib/hybrid-aks-kubeconfig.sh"

	PATH="${stub_bin}:${PATH}" cshell_hybrid_fetch_aks_kubeconfig "rg-hybrid" "aks-hybrid"
	run grep -q 'aks get-credentials' "${AZ_STUB_LOG}"
	[ "$status" -eq 0 ]
	run grep -q -- '--resource-group rg-hybrid' "${AZ_STUB_LOG}"
	[ "$status" -eq 0 ]
	run grep -q -- '--name aks-hybrid' "${AZ_STUB_LOG}"
	[ "$status" -eq 0 ]
	run grep -q -- '--overwrite-existing' "${AZ_STUB_LOG}"
	[ "$status" -eq 0 ]
}

@test "cshell_hybrid_fetch_aks_kubeconfig skips when resource group is empty" {
	export_home_tmp
	local stub_bin="${HOME}/stub-bin"
	mkdir -p "${stub_bin}"
	cat >"${stub_bin}/az" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "invoked" >>"${AZ_STUB_LOG}"
exit 0
STUB
	chmod +x "${stub_bin}/az"

	export AZ_STUB_LOG="${HOME}/az-invocation.log"
	rm -f "${AZ_STUB_LOG}"

	# shellcheck source=/dev/null
	source "${REPO_ROOT}/scripts/misc-cli-utils.sh"
	# shellcheck source=/dev/null
	source "${REPO_ROOT}/lib/portable.sh"
	# shellcheck source=/dev/null
	source "${REPO_ROOT}/lib/hybrid-aks-kubeconfig.sh"

	PATH="${stub_bin}:${PATH}" cshell_hybrid_fetch_aks_kubeconfig "" "aks-hybrid"
	[ ! -f "${AZ_STUB_LOG}" ]
}
