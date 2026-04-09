#!/usr/bin/env bash
# Safe ~/.cshell.env loading (allowlisted keys, no shell sourcing) and managed blocks.

cshell_env_default_path() {
  printf '%s\n' "${HOME}/.cshell.env"
}

cshell_env_is_allowed_key() {
  case "$1" in
    AZURE_SUBSCRIPTION | AZURE_RESOURCE_GROUP | AZURE_LOCATION | AZURE_STORAGE_ACCOUNT \
      | AZURE_STORAGE_CONTAINER | AZURE_STORAGE_ACCOUNT_KEY | AZURE_STORAGE_SKU \
      | AZURE_STORAGE_ACCESS_TIER | AZURE_STORAGE_ALLOW_CROSS_TENANT_REPLICATION \
      | PROJECT_ID | ORG_NAME | ORG_DISPLAY_NAME | ORGANIZATION_DESCRIPTION \
      | ANALYTICS_REGION | RUNTIMETYPE | CLUSTER_NAME | CLUSTER_REGION \
      | APIGEE_HELM_CHARTS_HOME | CHART_REPO | CHART_VERSION)
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
    printf -v "${key}" '%s' "${val}"
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

# Idempotent storage snippet from `cshell setup` (replaces prior setup block).
cshell_env_write_setup_storage_block() {
  local env_path="$1"
  local storage_account="$2"
  local container_name="$3"
  local storage_account_key="$4"

  touch "${env_path}"
  cshell_env_strip_managed_block "${env_path}" "# BEGIN_CSHELL_SETUP_STORAGE" "# END_CSHELL_SETUP_STORAGE"

  {
    echo ""
    echo "# BEGIN_CSHELL_SETUP_STORAGE"
    echo "# Written by cshell setup"
    printf 'AZURE_STORAGE_ACCOUNT=%s\n' "${storage_account}"
    printf 'AZURE_STORAGE_CONTAINER=%s\n' "${container_name}"
    if [[ -n "${storage_account_key}" ]]; then
      printf 'AZURE_STORAGE_ACCOUNT_KEY=%s\n' "${storage_account_key}"
    fi
    echo "# END_CSHELL_SETUP_STORAGE"
  } >>"${env_path}"

  cshell_env_ensure_permissions "${env_path}"
}
