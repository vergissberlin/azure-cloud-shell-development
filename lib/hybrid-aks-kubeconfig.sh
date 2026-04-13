#!/usr/bin/env bash
# After cshell hybrid: optionally merge AKS credentials into ~/.kube/config.
# Depends on info/success/warn (misc-cli-utils.sh or cshell fallback banner).
# shellcheck shell=bash
_LIB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${_LIB_ROOT}/hybrid-command-log.sh"

cshell_hybrid_fetch_aks_kubeconfig() {
	local rg="${1:-}"
	local cluster="${2:-}"
	[[ -n "${rg}" && -n "${cluster}" ]] || return 0
	if ! command -v az &>/dev/null; then
		info "Skipping AKS kubeconfig download (Azure CLI not found)."
		return 0
	fi
	info "Fetching kubeconfig for AKS cluster '${cluster}' (resource group '${rg}') ..."
	if cshell_hybrid_run_cmd az aks get-credentials --resource-group "${rg}" --name "${cluster}" --overwrite-existing; then
		success "kubeconfig updated for cluster '${cluster}'"
	else
		# Intentionally non-fatal: hybrid chart pull already succeeded.
		warn "az aks get-credentials failed — verify az login, subscription, resource group, and cluster name."
	fi
}
