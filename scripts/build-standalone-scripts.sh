#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS_FILE="${ROOT_DIR}/scripts/misc-cli-utils.sh"
DIST_DIR="${ROOT_DIR}/dist"
FALLBACK_START="# BEGIN_CLI_UTILS_FALLBACK"
FALLBACK_END="# END_CLI_UTILS_FALLBACK"

if [[ ! -f "${UTILS_FILE}" ]]; then
  echo "Missing utils file: ${UTILS_FILE}" >&2
  exit 1
fi

mkdir -p "${DIST_DIR}"

utils_payload="$(<"${UTILS_FILE}")"

build_fallback_block() {
  cat <<'EOF'
# BEGIN_CLI_UTILS_FALLBACK
if ! declare -F info >/dev/null 2>&1; then
  # shellcheck source=/dev/null
  source /dev/stdin <<'__CSHELL_CLI_UTILS__'
EOF
  printf '%s\n' "${utils_payload}"
  cat <<'EOF'
__CSHELL_CLI_UTILS__
fi
# END_CLI_UTILS_FALLBACK
EOF
}

replace_fallback_block() {
  local source_file="$1"
  local target_file="$2"
  local fallback_block
  fallback_block="$(build_fallback_block)"

  python3 - "${source_file}" "${target_file}" "${FALLBACK_START}" "${FALLBACK_END}" "${fallback_block}" <<'PY'
import pathlib
import sys

source_path = pathlib.Path(sys.argv[1])
target_path = pathlib.Path(sys.argv[2])
start_marker = sys.argv[3]
end_marker = sys.argv[4]
replacement = sys.argv[5]

text = source_path.read_text(encoding="utf-8")
start = text.find(start_marker)
if start == -1:
    raise SystemExit(f"start marker missing in {source_path}")

end = text.find(end_marker, start)
if end == -1:
    raise SystemExit(f"end marker missing in {source_path}")

end += len(end_marker)
if end < len(text) and text[end] == "\n":
    end += 1

new_text = text[:start] + replacement + "\n" + text[end:]
target_path.write_text(new_text, encoding="utf-8")
PY
}

replace_fallback_block "${ROOT_DIR}/cshell" "${DIST_DIR}/cshell"
replace_fallback_block "${ROOT_DIR}/install.sh" "${DIST_DIR}/install.sh"

chmod +x "${DIST_DIR}/cshell" "${DIST_DIR}/install.sh"

echo "Generated standalone scripts:"
echo "  - ${DIST_DIR}/cshell"
echo "  - ${DIST_DIR}/install.sh"
