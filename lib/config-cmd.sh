#!/usr/bin/env bash
# cshell config subcommands (sourced from cshell or inlined in standalone build).

cmd_config_usage() {
	cat <<EOF
Usage: ${SCRIPT_NAME} config <show|set|validate>

  show              Print allowlisted variables from ${ENV_FILE} (secrets masked)
  set KEY VALUE     Set an allowlisted KEY (empty VALUE removes the key line)
  validate          Run lightweight checks for Azure CLI and storage settings
EOF
}

cmd_config_show() {
	section "CONFIG" "Environment file (masked)" "cyan"
	if [[ ! -f "${ENV_FILE}" ]]; then
		warn "No ${ENV_FILE} yet. Run '${SCRIPT_NAME} init' or '${SCRIPT_NAME} setup'."
		return 0
	fi
	cshell_env_load "${ENV_FILE}"
	local k
	for k in AZURE_SUBSCRIPTION AZURE_RESOURCE_GROUP AZURE_LOCATION AZURE_STORAGE_ACCOUNT \
		AZURE_STORAGE_CONTAINER AZURE_STORAGE_SKU AZURE_STORAGE_ACCESS_TIER \
		AZURE_STORAGE_ALLOW_CROSS_TENANT_REPLICATION AZURE_STORAGE_ACCOUNT_KEY \
		PROJECT_ID ORG_NAME ORG_DISPLAY_NAME ORGANIZATION_DESCRIPTION ANALYTICS_REGION \
		RUNTIMETYPE CLUSTER_NAME CLUSTER_REGION AKS_RESOURCE_GROUP APIGEE_NAMESPACE ENVIRONMENT_NAME \
		ENV_GROUP ENV_GROUP_RELEASE_NAME DOMAIN CONTROL_PLANE_LOCATION \
		APIGEE_INSTANCE_ID APIGEE_NONPROD_SA_SECRET APIGEE_INGRESS_NAME \
		APIGEE_OVERRIDE_TLS_CERT_REL APIGEE_OVERRIDE_TLS_KEY_REL \
		APIGEE_INGRESS_SVC_ANNOTATION_KEY APIGEE_INGRESS_SVC_ANNOTATION_VALUE \
		APIGEE_OVERRIDE_RUNTIME_TAG APIGEE_OVERRIDE_LARGE_PAYLOAD APIGEE_OVERRIDES_OVERWRITE \
		APIGEE_HELM_CHARTS_HOME CHART_REPO CHART_VERSION; do
		# shellcheck disable=SC2248
		if [[ -n "${!k:-}" ]]; then
			if [[ "${k}" == *KEY* ]]; then
				info "${k}=********"
			else
				# shellcheck disable=SC2248
				info "${k}=${!k}"
			fi
		fi
	done
}

cmd_config_set() {
	local key="${1:-}"
	if [[ -z "${key}" ]]; then
		cmd_config_usage
		exit 1
	fi
	shift
	local val=""
	if (($# > 0)); then
		val="$*"
	fi
	if ! cshell_env_is_allowed_key "${key}"; then
		error "Key '${key}' is not an allowlisted cshell configuration key."
		exit 1
	fi
	touch "${ENV_FILE}"
	local tmp
	tmp="$(mktemp)"
	if [[ -f "${ENV_FILE}" ]]; then
		grep -v "^${key}=" "${ENV_FILE}" >"${tmp}" || true
	else
		: >"${tmp}"
	fi
	if [[ -n "${val}" ]]; then
		printf '%s=%s\n' "${key}" "${val}" >>"${tmp}"
	fi
	mv "${tmp}" "${ENV_FILE}"
	cshell_env_ensure_permissions "${ENV_FILE}"
	if declare -F cshell_env_sync_exports >/dev/null 2>&1; then
		cshell_env_sync_exports || warn "Could not refresh shell export snippet."
	fi
	success "Updated ${ENV_FILE} (${key})"
}

cmd_config_validate() {
	section "CONFIG" "Validation" "cyan"
	if [[ -f "${ENV_FILE}" ]]; then
		cshell_env_load "${ENV_FILE}"
	else
		warn "${ENV_FILE} not found — only generic checks will run."
	fi

	if command_exists az; then
		if az account show &>/dev/null; then
			success "Azure CLI session is active."
			info "Subscription: $(az account show --query name -o tsv 2>/dev/null || echo "?")"
		else
			warn "Azure CLI is installed but no authenticated session was found. Run 'az login'."
		fi
	else
		warn "Azure CLI (az) not found — skip Azure-specific checks."
	fi

	if [[ -n "${AZURE_STORAGE_ACCOUNT:-}" && -n "${AZURE_RESOURCE_GROUP:-}" ]]; then
		if command_exists az && az storage account show \
			--name "${AZURE_STORAGE_ACCOUNT}" \
			--resource-group "${AZURE_RESOURCE_GROUP}" &>/dev/null; then
			success "Storage account '${AZURE_STORAGE_ACCOUNT}' is reachable in group '${AZURE_RESOURCE_GROUP}'."
		else
			warn "Could not verify storage account '${AZURE_STORAGE_ACCOUNT:-?}' in group '${AZURE_RESOURCE_GROUP:-?}' (check login and names)."
		fi
	elif [[ -n "${AZURE_STORAGE_ACCOUNT:-}" ]]; then
		info "AZURE_STORAGE_ACCOUNT is set; AZURE_RESOURCE_GROUP is missing — skipping account show check."
	fi

	if [[ -n "${AZURE_STORAGE_CONTAINER:-}" ]]; then
		info "Blob container target: ${AZURE_STORAGE_CONTAINER}"
	fi
}

cmd_config() {
	local sub="${1:-help}"
	shift || true
	case "${sub}" in
		show) cmd_config_show "$@" ;;
		set)
			cmd_config_set "$@"
			;;
		validate) cmd_config_validate "$@" ;;
		help | -h | --help) cmd_config_usage ;;
		*)
			cmd_config_usage
			exit 1
			;;
	esac
}
