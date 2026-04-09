#!/usr/bin/env bash
# Portable helpers for cshell (sourced from cshell or inlined in standalone build).

# Portable in-place sed (GNU vs BSD/macOS).
# Usage: portable_sed_i 'expression' file
portable_sed_i() {
	local expr="$1"
	local target="$2"
	if sed --version >/dev/null 2>&1; then
		sed -i "${expr}" "${target}"
	else
		sed -i '' "${expr}" "${target}"
	fi
}

# Resolve a path to absolute; fall back to cd/dirname if realpath is missing.
cshell_realpath() {
	local p="$1"
	local dir base
	if command -v realpath &>/dev/null; then
		realpath "${p}" 2>/dev/null && return 0
	fi
	if [[ -e "${p}" ]]; then
		dir="$(dirname "${p}")"
		base="$(basename "${p}")"
		printf '%s/%s\n' "$(cd "${dir}" && pwd)" "${base}"
		return 0
	fi
	return 1
}
