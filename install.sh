#!/usr/bin/env bash
# install.sh – Download cshell and install it to a writable bin directory
# Defaults to the latest GitHub release tag (without `v` prefix).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh | bash
#
# Or download manually and run:
#   curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh -o install.sh
#   chmod +x install.sh
#   ./install.sh

set -euo pipefail

REPO="vergissberlin/azure-cloud-shell-development"
DEFAULT_REF="main"
RELEASE_REF=""
RAW_BASE=""
LATEST_RELEASE_API="https://api.github.com/repos/${REPO}/releases/latest"
DEFAULT_INSTALL_DIR="/usr/local/bin"
FALLBACK_INSTALL_DIR="${HOME}/.local/bin"
INSTALL_DIR="${DEFAULT_INSTALL_DIR}"
SCRIPT_NAME="cshell"
INSTALL_PATH="${INSTALL_DIR}/${SCRIPT_NAME}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_UTILS_PATH="${SCRIPT_DIR}/scripts/misc-cli-utils.sh"

if [[ -f "${CLI_UTILS_PATH}" ]]; then
  # shellcheck source=/dev/null
  source "${CLI_UTILS_PATH}"
fi

resolve_release_ref() {
  local latest_json latest_tag
  latest_json="$(curl -fsSL "${LATEST_RELEASE_API}" 2>/dev/null || true)"
  latest_tag="$(printf '%s' "${latest_json}" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"

  if [[ -n "${latest_tag}" ]]; then
    RELEASE_REF="${latest_tag}"
    RAW_BASE="https://raw.githubusercontent.com/${REPO}/${RELEASE_REF}"
    info "Using latest release tag: ${RELEASE_REF}"
  else
    RELEASE_REF="${DEFAULT_REF}"
    RAW_BASE="https://raw.githubusercontent.com/${REPO}/${RELEASE_REF}"
    warn "Could not resolve latest release tag; falling back to ${DEFAULT_REF}."
  fi
}

# Fallback for standalone curl execution where shared utils are unavailable.
if ! declare -F info >/dev/null 2>&1; then
  RESET='\033[0m'
  BLACK='\033[30m'
  CYAN='\033[36m'
  GREEN='\033[32m'
  YELLOW='\033[33m'
  RED='\033[31m'
  BG_CYAN='\033[46m'
  BG_GREEN='\033[42m'
  BG_YELLOW='\033[43m'
  BG_RED='\033[41m'
  CHECKMARK='✓'
  CROSS='✗'

  box() { echo -e "${2:-$BG_CYAN}${3:-$BLACK} $1 ${RESET}"; }
  info() { echo -e "$(box 'INFO' "$BG_CYAN" "$BLACK") ${CYAN}$*${RESET}"; }
  success() { echo -e "$(box 'DONE' "$BG_GREEN" "$BLACK") ${GREEN}${CHECKMARK}${RESET} ${GREEN}$*${RESET}"; }
  warn() { echo -e "$(box 'WARN' "$BG_YELLOW" "$BLACK") ${YELLOW}$*${RESET}"; }
  error() { echo -e "$(box 'ERR' "$BG_RED" "$BLACK") ${RED}${CROSS}${RESET} ${RED}$*${RESET}" >&2; }
  section() {
    local title="$1"
    local desc="${2:-}"
    local color="${3:-cyan}"
    local tone="$CYAN"
    local width title_text line_len

    case "${color}" in
      green) tone="$GREEN" ;;
      yellow) tone="$YELLOW" ;;
      red) tone="$RED" ;;
      blue) tone="$CYAN" ;;
    esac

    title_text="[ ${title} ]"
    width=56
    if [[ -n "${desc}" && ${#desc} -gt 44 ]]; then
      width=$(( ${#desc} + 12 ))
    fi
    line_len=$((width - ${#title_text} - 4))
    (( line_len < 8 )) && line_len=8

    echo
    echo -e "${tone}╭─${title_text}$(printf '─%.0s' $(seq 1 "${line_len}"))╮${RESET}"
    if [[ -n "${desc}" ]]; then
      printf -v _section_desc_pad "%*s" $((width - ${#desc} - 4)) ""
      echo -e "${tone}│${RESET} ${desc}${_section_desc_pad}${tone}│${RESET}"
    fi
    echo -e "${tone}╰$(printf '─%.0s' $(seq 1 $((width - 2))))╯${RESET}"
  }
fi

section "PRECHECK" "Validate dependencies and install target" "cyan"

if ! command -v curl &>/dev/null; then
  error "curl is required but not installed"
  exit 1
fi

resolve_release_ref

if [[ ! -w "${INSTALL_DIR}" ]]; then
  warn "${INSTALL_DIR} is not writable. Falling back to ${FALLBACK_INSTALL_DIR}"
  INSTALL_DIR="${FALLBACK_INSTALL_DIR}"
  INSTALL_PATH="${INSTALL_DIR}/${SCRIPT_NAME}"
fi

section "INSTALL" "Download and install ${SCRIPT_NAME}" "cyan"

info "Downloading ${SCRIPT_NAME} from ${RAW_BASE}/${SCRIPT_NAME} ..."
mkdir -p "${INSTALL_DIR}"
curl -fsSL "${RAW_BASE}/${SCRIPT_NAME}" -o "${INSTALL_PATH}"
chmod +x "${INSTALL_PATH}"

success "${SCRIPT_NAME} installed to ${INSTALL_PATH}"
installed_version="$("${INSTALL_PATH}" --version 2>/dev/null || true)"
if [[ -n "${installed_version}" ]]; then
  info "Installed version: ${installed_version}"
else
  warn "Installed version could not be detected (${INSTALL_PATH} --version failed)."
fi
section "NEXT STEPS" "Complete first-time setup" "green"
if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
  info "Add ${INSTALL_DIR} to your PATH to use '${SCRIPT_NAME}' globally."
  info "Example: echo 'export PATH=\"${INSTALL_DIR}:$PATH\"' >> ~/.bashrc && source ~/.bashrc"
fi
info "Run '${SCRIPT_NAME} init' to create Azure Storage resources, then '${SCRIPT_NAME} setup' to finish first-time configuration."
