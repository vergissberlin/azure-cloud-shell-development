#!/usr/bin/env bash
# E2E: run the checked-in install.sh inside a dev container (or any Linux env with curl).
# Hits live GitHub (API + raw.githubusercontent.com); does not install the working-tree cshell binary.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "${ROOT}"

rm -f "${HOME}/.local/bin/cshell" 2>/dev/null || true
rm -rf "${HOME}/.local/bin/lib" 2>/dev/null || true

export PATH="${HOME}/.local/bin:/usr/local/bin:${PATH}"

bash "${ROOT}/install.sh"

if ! command -v cshell >/dev/null 2>&1; then
	echo "e2e: cshell not on PATH after install.sh" >&2
	exit 1
fi

ver="$(cshell --version 2>/dev/null || true)"
if [[ -z "${ver}" ]]; then
	echo "e2e: cshell --version returned empty output" >&2
	exit 1
fi

printf 'e2e install ok: %s\n' "${ver}"
