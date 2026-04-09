#!/usr/bin/env bash
# Safe ~/.cshell.env loading (allowlisted keys, no shell sourcing) and managed blocks.

cshell_env_default_path() {
	printf '%s\n' "${HOME}/.cshell.env"
}

cshell_env_is_allowed_key() {
	case "$1" in
		AZURE_SUBSCRIPTION | AZURE_RESOURCE_GROUP | AZURE_LOCATION | AZURE_STORAGE_ACCOUNT | \
			AZURE_STORAGE_CONTAINER | AZURE_STORAGE_ACCOUNT_KEY | AZURE_STORAGE_SKU | \
			AZURE_STORAGE_ACCESS_TIER | AZURE_STORAGE_ALLOW_CROSS_TENANT_REPLICATION | \
			PROJECT_ID | ORG_NAME | ORG_DISPLAY_NAME | ORGANIZATION_DESCRIPTION | \
			ANALYTICS_REGION | RUNTIMETYPE | CLUSTER_NAME | CLUSTER_REGION | \
			AKS_RESOURCE_GROUP | APIGEE_NAMESPACE | ENVIRONMENT_NAME | ENV_GROUP | ENV_GROUP_RELEASE_NAME | \
			DOMAIN | CONTROL_PLANE_LOCATION | \
			APIGEE_INSTANCE_ID | APIGEE_NONPROD_SA_SECRET | APIGEE_INGRESS_NAME | \
			APIGEE_OVERRIDE_TLS_CERT_REL | APIGEE_OVERRIDE_TLS_KEY_REL | \
			APIGEE_INGRESS_SVC_ANNOTATION_KEY | APIGEE_INGRESS_SVC_ANNOTATION_VALUE | \
			APIGEE_OVERRIDE_RUNTIME_TAG | APIGEE_OVERRIDE_LARGE_PAYLOAD | APIGEE_OVERRIDES_OVERWRITE | \
			APIGEE_HELM_CHARTS_HOME | CHART_REPO | CHART_VERSION)
			return 0
			;;
		*)
			return 1
			;;
	esac
}

# Strip optional matching quotes (legacy hand-edited .env lines).
cshell_env_normalize_value() {
	local val="$1"
	val="${val%$'\r'}"
	if [[ "${val}" == \"*\" ]]; then
		val="${val:1:${#val}-2}"
		val="${val//\\\"/\"}"
	elif [[ "${val}" == \'*\' ]]; then
		val="${val:1:${#val}-2}"
		val="${val//\'\\\'\'/\'}"
	fi
	printf '%s\n' "${val}"
}

# Load env file: first '=' separates key from value; value is literal data (not executed).
cshell_env_load() {
	local env_path="$1"
	[[ -f "${env_path}" ]] || return 0

	local line key val
	while IFS= read -r line || [[ -n "${line}" ]]; do
		[[ -z "${line//[[:space:]]/}" ]] && continue
		[[ "${line}" =~ ^[[:space:]]*# ]] && continue
		[[ "${line}" == *=* ]] || continue
		key="${line%%=*}"
		val="${line#*=}"
		key="${key%"${key##*[![:space:]]}"}"
		key="${key#"${key%%[![:space:]]*}"}"
		[[ -n "${key}" ]] || continue
		cshell_env_is_allowed_key "${key}" || continue
		val="$(cshell_env_normalize_value "${val}")"
		# Dynamic variable names from allowlisted keys only (safe assignment, no eval/source).
		# shellcheck disable=SC2178
		printf -v "${key}" '%s' "${val}"
		# Export allowlisted variable by dynamic name (printf -v above set the value).
		# shellcheck disable=SC2163
		export "${key}"
	done <"${env_path}"
}

cshell_env_ensure_permissions() {
	local env_path="$1"
	[[ -f "${env_path}" ]] || return 0
	chmod 600 "${env_path}" 2>/dev/null || warn "Could not chmod 600 on ${env_path}; lock down permissions manually."
}

cshell_env_strip_managed_block() {
	local env_path="$1"
	local begin_pat="$2"
	local end_pat="$3"
	[[ -f "${env_path}" ]] || return 0
	local tmp
	tmp="$(mktemp)"
	awk -v b="${begin_pat}" -v e="${end_pat}" '
    index($0, b) { skip=1; next }
    index($0, e) { skip=0; next }
    skip == 0 { print }
  ' "${env_path}" >"${tmp}"
	mv "${tmp}" "${env_path}"
}

# Remove assignment lines for a key (exact KEY=value at line start). Used before re-writing a value
# that may also appear later in another managed block (last match would win in cshell_env_load).
cshell_env_delete_assignment_lines() {
	local env_path="$1"
	local key="$2"
	[[ -f "${env_path}" ]] || return 0
	[[ -n "${key}" ]] || return 0
	local tmp
	tmp="$(mktemp)"
	grep -v "^${key}=" "${env_path}" >"${tmp}" || true
	mv "${tmp}" "${env_path}"
}

# Idempotent storage snippet from `cshell setup` (replaces prior setup block).
# Optional 5th arg: APIGEE_HELM_CHARTS_HOME (canonical dir; default ~/apigee-hybrid/helm-charts from setup).
cshell_env_write_setup_storage_block() {
	local env_path="$1"
	local storage_account="$2"
	local container_name="$3"
	local storage_account_key="$4"
	local helm_charts_home="${5:-}"

	touch "${env_path}"
	cshell_env_strip_managed_block "${env_path}" "# BEGIN_CSHELL_SETUP_STORAGE" "# END_CSHELL_SETUP_STORAGE"
	if [[ -n "${helm_charts_home}" ]]; then
		cshell_env_delete_assignment_lines "${env_path}" "APIGEE_HELM_CHARTS_HOME"
	fi

	{
		echo ""
		echo "# BEGIN_CSHELL_SETUP_STORAGE"
		echo "# Written by cshell setup"
		printf 'AZURE_STORAGE_ACCOUNT=%s\n' "${storage_account}"
		printf 'AZURE_STORAGE_CONTAINER=%s\n' "${container_name}"
		if [[ -n "${storage_account_key}" ]]; then
			printf 'AZURE_STORAGE_ACCOUNT_KEY=%s\n' "${storage_account_key}"
		fi
		if [[ -n "${helm_charts_home}" ]]; then
			printf 'APIGEE_HELM_CHARTS_HOME=%s\n' "${helm_charts_home}"
		fi
		echo "# END_CSHELL_SETUP_STORAGE"
	} >>"${env_path}"

	cshell_env_ensure_permissions "${env_path}"
}

# Write ~/.cshell-env-exports.sh with `export KEY=…` for each allowlisted KEY=value in env_path
# (non-empty values only). Same allowlist and normalization as cshell_env_load; last assignment wins.
# Intentionally does not execute arbitrary content from the env file.
cshell_env_write_export_snippet() {
	local env_path="$1"
	local out="${HOME}/.cshell-env-exports.sh"

	if [[ ! -f "${env_path}" ]]; then
		rm -f "${out}" 2>/dev/null || true
		return 0
	fi

	if [[ "${BASH_VERSINFO[0]:-0}" -lt 4 ]]; then
		warn "cshell export snippet skipped: bash 4+ required for ${out##*/}."
		return 1
	fi

	local -A _cshell_export_vals
	local line key val

	while IFS= read -r line || [[ -n "${line}" ]]; do
		[[ -z "${line//[[:space:]]/}" ]] && continue
		[[ "${line}" =~ ^[[:space:]]*# ]] && continue
		[[ "${line}" == *=* ]] || continue
		key="${line%%=*}"
		val="${line#*=}"
		key="${key%"${key##*[![:space:]]}"}"
		key="${key#"${key%%[![:space:]]*}"}"
		[[ -n "${key}" ]] || continue
		cshell_env_is_allowed_key "${key}" || continue
		val="$(cshell_env_normalize_value "${val}")"
		_cshell_export_vals["${key}"]="${val}"
	done <"${env_path}"

	local tmp
	tmp="$(mktemp)"
	{
		echo "# Generated by cshell — do not edit; regenerated from ${env_path##*/}"
		echo "# Load into your shell with:  . \"\${HOME}/.cshell-env-exports.sh\"  (do not run this file as an executable — it is not meant to be +x)."
		for key in "${!_cshell_export_vals[@]}"; do
			val="${_cshell_export_vals[$key]}"
			[[ -n "${val}" ]] || continue
			printf 'export %s=%s\n' "${key}" "$(printf '%q' "${val}")"
		done
	} >"${tmp}"
	mv "${tmp}" "${out}"
	chmod 600 "${out}" 2>/dev/null || true
	unset _cshell_export_vals
	return 0
}
