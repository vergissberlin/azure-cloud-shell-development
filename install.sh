#!/usr/bin/env bash
# install.sh – Download cshell and install it to /usr/local/bin
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
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="cshell"
INSTALL_PATH="${INSTALL_DIR}/${SCRIPT_NAME}"

info()    { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
success() { echo -e "\033[1;32m[OK]\033[0m    $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------

if ! command -v curl &>/dev/null; then
  error "curl is required but not installed."
  exit 1
fi

if [[ ! -w "${INSTALL_DIR}" ]]; then
  error "${INSTALL_DIR} is not writable. Try: sudo bash install.sh"
  exit 1
fi

# ---------------------------------------------------------------------------
# Download and install
# ---------------------------------------------------------------------------

info "Downloading ${SCRIPT_NAME} from ${RAW_BASE}/${SCRIPT_NAME} …"
curl -fsSL "${RAW_BASE}/${SCRIPT_NAME}" -o "${INSTALL_PATH}"
chmod +x "${INSTALL_PATH}"

success "${SCRIPT_NAME} installed to ${INSTALL_PATH}"
info  "Run '${SCRIPT_NAME} init' to create Azure Storage resources, then '${SCRIPT_NAME} setup' to finish first-time configuration."
