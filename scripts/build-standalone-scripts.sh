#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS_FILE="${ROOT_DIR}/scripts/misc-cli-utils.sh"
DIST_DIR="${ROOT_DIR}/dist"
FALLBACK_START="# BEGIN_CLI_UTILS_FALLBACK"
FALLBACK_END="# END_CLI_UTILS_FALLBACK"
LIB_START="# BEGIN_CSHELL_LIBS"
LIB_END="# END_CSHELL_LIBS"

LIB_FILES=(
  "${ROOT_DIR}/lib/env-file.sh"
  "${ROOT_DIR}/lib/portable.sh"
  "${ROOT_DIR}/lib/config-cmd.sh"
)

if [[ ! -f "${UTILS_FILE}" ]]; then
  echo "Missing utils file: ${UTILS_FILE}" >&2
  exit 1
fi

for lf in "${LIB_FILES[@]}"; do
  if [[ ! -f "${lf}" ]]; then
    echo "Missing lib file: ${lf}" >&2
    exit 1
  fi
done

mkdir -p "${DIST_DIR}"

utils_payload="$(<"${UTILS_FILE}")"

strip_leading_shebang() {
  local f="$1"
  if head -n 1 "${f}" | grep -q '^#!'; then
    tail -n +2 "${f}"
  else
    cat "${f}"
  fi
}

bundle_lib_block() {
  echo "# Inlined cshell libraries (dev sources: lib/*.sh)"
  for lf in "${LIB_FILES[@]}"; do
    echo "# ----- ${lf##*/} -----"
    strip_leading_shebang "${lf}"
    echo ""
  done
  echo "CSHELL_LIBS_INLINED=1"
}

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

replace_block() {
  local source_file="$1"
  local target_file="$2"
  local start_marker="$3"
  local end_marker="$4"
  local replacement="$5"

  python3 - "${source_file}" "${target_file}" "${start_marker}" "${end_marker}" "${replacement}" <<'PY'
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

fallback_block="$(build_fallback_block)"
lib_block="$(bundle_lib_block)"

TMP_CSHELL="$(mktemp)"
TMP_INSTALL="$(mktemp)"
replace_block "${ROOT_DIR}/cshell" "${TMP_CSHELL}" "${FALLBACK_START}" "${FALLBACK_END}" "${fallback_block}"
replace_block "${TMP_CSHELL}" "${DIST_DIR}/cshell" "${LIB_START}" "${LIB_END}" "${lib_block}"
replace_block "${ROOT_DIR}/install.sh" "${TMP_INSTALL}" "${FALLBACK_START}" "${FALLBACK_END}" "${fallback_block}"
cp "${TMP_INSTALL}" "${DIST_DIR}/install.sh"
rm -f "${TMP_CSHELL}" "${TMP_INSTALL}"

chmod +x "${DIST_DIR}/cshell" "${DIST_DIR}/install.sh"

echo "Generated standalone scripts:"
echo "  - ${DIST_DIR}/cshell"
echo "  - ${DIST_DIR}/install.sh"
