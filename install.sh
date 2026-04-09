#!/usr/bin/env bash
# install.sh – Download cshell and install it to a writable bin directory
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
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
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

# Fallback for standalone curl execution where shared utils are unavailable.
if ! declare -F info >/dev/null 2>&1; then
  info()    { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
  success() { echo -e "\033[1;32m[OK]\033[0m    $*"; }
  error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }
fi

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------

if ! command -v curl &>/dev/null; then
  error "curl is required but not installed."
  exit 1
fi

if [[ ! -w "${INSTALL_DIR}" ]]; then
  info "${INSTALL_DIR} is not writable. Falling back to ${FALLBACK_INSTALL_DIR}."
  INSTALL_DIR="${FALLBACK_INSTALL_DIR}"
  INSTALL_PATH="${INSTALL_DIR}/${SCRIPT_NAME}"
fi

# ---------------------------------------------------------------------------
# Download and install
# ---------------------------------------------------------------------------

if declare -F section >/dev/null 2>&1; then
  section "INSTALL" "Download and install ${SCRIPT_NAME}" "cyan"
fi

info "Downloading ${SCRIPT_NAME} from ${RAW_BASE}/${SCRIPT_NAME} ..."
mkdir -p "${INSTALL_DIR}"
curl -fsSL "${RAW_BASE}/${SCRIPT_NAME}" -o "${INSTALL_PATH}"
chmod +x "${INSTALL_PATH}"

success "${SCRIPT_NAME} installed to ${INSTALL_PATH}"
if [[ ":${PATH}:" != *":${INSTALL_DIR}:"* ]]; then
  info "Add ${INSTALL_DIR} to your PATH to use '${SCRIPT_NAME}' globally."
  info "Example: echo 'export PATH=\"${INSTALL_DIR}:$PATH\"' >> ~/.bashrc && source ~/.bashrc"
fi
info  "Run '${SCRIPT_NAME} init' to create Azure Storage resources, then '${SCRIPT_NAME} setup' to finish first-time configuration."
