#!/usr/bin/env bash
# Echo shell commands for Hybrid automation with optional "code block" terminal styling.
# Expects: RESET, HYBRID_CMD_BG, HYBRID_CMD_FG when colors are on; optional cshell_cli_colors_active.
# shellcheck shell=bash
if [[ -n "${_CSHELL_HYBRID_COMMAND_LOG_LOADED:-}" ]]; then
	[[ "${BASH_SOURCE[0]:-$0}" != "${0}" ]] && return 0
fi
_CSHELL_HYBRID_COMMAND_LOG_LOADED=1

cshell_hybrid_emit_shell_cmd_line() {
	local text="$1"
	if declare -F cshell_cli_colors_active >/dev/null 2>&1 && cshell_cli_colors_active && [[ -n "${HYBRID_CMD_BG:-}" ]]; then
		echo -e "  ${HYBRID_CMD_BG}${HYBRID_CMD_FG:-}${text}${RESET}"
	else
		printf '  %s\n' "${text}"
	fi
}

# Print a shell-quoted command line, then execute it. Exit status is the command's status.
cshell_hybrid_run_cmd() {
	local q="" a
	for a in "$@"; do
		q+="$(printf '%q ' "${a}")"
	done
	q="${q% }"
	cshell_hybrid_emit_shell_cmd_line "${q}"
	"$@"
}
