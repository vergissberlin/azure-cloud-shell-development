#!/usr/bin/env bash
# install.sh – Download cshell and install it to a writable bin directory
# Defaults to the latest GitHub release tag (without `v` prefix).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh | bash
# Forks: export CSHELL_REPO_SLUG=owner/repo before running to resolve releases from another GitHub repo.
#
# Or download manually and run:
#   curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh -o install.sh
#   chmod +x install.sh
#   ./install.sh

set -euo pipefail

REPO="${CSHELL_REPO_SLUG:-vergissberlin/azure-cloud-shell-development}"
DEFAULT_REF="main"
RELEASE_REF=""
RAW_BASE=""
LATEST_RELEASE_API="https://api.github.com/repos/${REPO}/releases/latest"
DEFAULT_INSTALL_DIR="/usr/local/bin"
FALLBACK_INSTALL_DIR="${HOME}/.local/bin"
INSTALL_DIR="${DEFAULT_INSTALL_DIR}"
SCRIPT_NAME="cshell"
INSTALL_PATH="${INSTALL_DIR}/${SCRIPT_NAME}"

SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_SOURCE}")" && pwd)"
CLI_UTILS_PATH="${SCRIPT_DIR}/scripts/misc-cli-utils.sh"

if [[ -f "${CLI_UTILS_PATH}" ]]; then
	# shellcheck source=/dev/null
	source "${CLI_UTILS_PATH}"
fi

curl_github() {
	curl -fsSL --max-time 25 --connect-timeout 10 "$@"
}

release_asset_urls_from_json() {
	local json="$1"
	local version="$2"
	if ! command -v python3 &>/dev/null; then
		printf '\n'
		return 1
	fi
	python3 -c '
import json, sys
payload = sys.stdin.read()
ver = sys.argv[1]
try:
    j = json.loads(payload)
except json.JSONDecodeError:
    sys.exit(1)
want_tgz = "cshell-%s.tar.gz" % ver
want_sha = want_tgz + ".sha256"
assets = {a.get("name"): a.get("browser_download_url") for a in j.get("assets", []) if a.get("name")}
print(assets.get(want_tgz, "") or "")
print(assets.get(want_sha, "") or "")
' "${version}" <<<"${json}" 2>/dev/null || printf '\n'
}

try_install_verified_release() {
	local ver="$1"
	local json="$2"
	local tgz_url sha_url work tgz sha_file url_lines

	if ! command -v python3 &>/dev/null || ! command -v sha256sum &>/dev/null; then
		return 1
	fi

	url_lines="$(release_asset_urls_from_json "${json}" "${ver}")"
	tgz_url="$(printf '%s\n' "${url_lines}" | sed -n '1p')"
	sha_url="$(printf '%s\n' "${url_lines}" | sed -n '2p')"
	[[ -n "${tgz_url}" && -n "${sha_url}" ]] || return 1

	work="$(mktemp -d)"
	tgz="${work}/cshell-${ver}.tar.gz"
	sha_file="${work}/cshell-${ver}.tar.gz.sha256"

	if ! curl_github "${tgz_url}" -o "${tgz}"; then
		rm -rf "${work}"
		return 1
	fi
	if ! curl_github "${sha_url}" -o "${sha_file}"; then
		rm -rf "${work}"
		return 1
	fi

	if ! (cd "${work}" && sha256sum -c "$(basename "${sha_file}")"); then
		warn "Checksum verification failed for ${tgz##*/}."
		rm -rf "${work}"
		return 1
	fi

	if ! tar -xzf "${tgz}" -C "${work}"; then
		rm -rf "${work}"
		return 1
	fi

	if [[ ! -f "${work}/cshell" ]]; then
		warn "Release archive did not contain cshell."
		rm -rf "${work}"
		return 1
	fi

	chmod +x "${work}/cshell"
	mkdir -p "${INSTALL_DIR}"
	mv -f "${work}/cshell" "${INSTALL_PATH}"
	rm -rf "${work}"
	return 0
}

download_cshell_support_libs_from_raw() {
	local ref="$1"
	local bin_dir="$2"
	local base work name

	base="https://raw.githubusercontent.com/${REPO}/${ref}/lib"
	work="$(mktemp -d)"
	for name in env-file.sh portable.sh config-cmd.sh hybrid-checklist.sh hybrid-command-log.sh hybrid-aks-kubeconfig.sh hybrid-overrides-nonprod.sh hybrid-overrides-prod.sh; do
		if ! curl_github "${base}/${name}" -o "${work}/${name}"; then
			rm -rf "${work}"
			error "Failed to download ${name}"
			return 1
		fi
	done
	mkdir -p "${bin_dir}/lib"
	mv -f "${work}/"* "${bin_dir}/lib/"
	rmdir "${work}" 2>/dev/null || rm -rf "${work}"
	return 0
}

resolve_release_ref() {
	local latest_json latest_tag
	latest_json="$(curl_github "${LATEST_RELEASE_API}" 2>/dev/null || true)"
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

# BEGIN_CLI_UTILS_FALLBACK
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

		case "${color}" in
			green) tone="$GREEN" ;;
			yellow) tone="$YELLOW" ;;
			red) tone="$RED" ;;
			blue) tone="$CYAN" ;;
		esac

		echo
		echo -e "${tone}[${title}]${RESET} ${desc}"
	}
fi
# END_CLI_UTILS_FALLBACK

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

verified=0
if [[ "${RELEASE_REF}" != "${DEFAULT_REF}" ]]; then
	ver="${RELEASE_REF#v}"
	rel_json="$(curl_github "https://api.github.com/repos/${REPO}/releases/tags/${RELEASE_REF}" 2>/dev/null || true)"
	if [[ -n "${rel_json}" ]] && try_install_verified_release "${ver}" "${rel_json}"; then
		info "Installed from verified release tarball (${RELEASE_REF})."
		verified=1
	else
		warn "Could not install from verified release assets; falling back to raw ${SCRIPT_NAME} download."
	fi
fi

if [[ "${verified}" -eq 1 ]]; then
	if ! "${INSTALL_PATH}" --version &>/dev/null; then
		warn "Installed release binary failed self-check (--version); falling back to raw ${SCRIPT_NAME} download."
		verified=0
	fi
fi

if [[ "${verified}" -eq 0 ]]; then
	info "Downloading ${SCRIPT_NAME} from ${RAW_BASE}/${SCRIPT_NAME} ..."
	mkdir -p "${INSTALL_DIR}"
	tmp_cshell="$(mktemp "${INSTALL_DIR}/${SCRIPT_NAME}.XXXXXX")"
	if ! curl_github "${RAW_BASE}/${SCRIPT_NAME}" -o "${tmp_cshell}"; then
		rm -f "${tmp_cshell}"
		error "Download failed."
		exit 1
	fi
	info "Downloading ${SCRIPT_NAME} library files (raw install) ..."
	if ! download_cshell_support_libs_from_raw "${RELEASE_REF}" "${INSTALL_DIR}"; then
		rm -f "${tmp_cshell}"
		error "Library download failed."
		exit 1
	fi
	chmod +x "${tmp_cshell}"
	mv -f "${tmp_cshell}" "${INSTALL_PATH}"
	warn "Raw script install has no checksum verification. Prefer a release that publishes cshell-${ver:-X.Y.Z}.tar.gz + .sha256."
fi

if [[ -f "${HOME}/.cshell.env" ]]; then
	chmod 600 "${HOME}/.cshell.env" 2>/dev/null || true
fi

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
