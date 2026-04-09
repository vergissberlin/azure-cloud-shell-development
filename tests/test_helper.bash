# Shared helpers for Bats — use: load test_helper
# shellcheck shell=bash

repo_root() {
	cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd
}

common_setup() {
	export REPO_ROOT
	REPO_ROOT="$(repo_root)"
	export CSHELL_NO_UPDATE_CHECK=1
}

export_home_tmp() {
	export HOME
	HOME="$(mktemp -d)"
}

run_cshell() {
	run bash "${REPO_ROOT}/cshell" "$@"
}
