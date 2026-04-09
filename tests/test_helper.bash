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

# Run cshell with a custom PATH (e.g. hide kubectl/helm/gcloud) without losing bash.
# Resolves bash from the current PATH before applying custom_path so /usr/bin can be
# dropped when it only existed to ship kubectl (CI runners).
run_cshell_with_path() {
	local custom_path="$1"
	shift
	local bash_path
	bash_path="$(command -v bash)"
	run env PATH="${custom_path}" "${bash_path}" "${REPO_ROOT}/cshell" "$@"
}
