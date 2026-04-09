#!/usr/bin/env bats
# Core CLI smoke tests (no Azure calls).

load test_helper

setup() {
	common_setup
}

@test "cshell --version matches semver line" {
	run_cshell --version
	[ "$status" -eq 0 ]
	[[ "$output" =~ ^cshell[[:space:]]+[0-9]+\.[0-9]+\.[0-9] ]]
}

@test "cshell help exits 0" {
	run_cshell help
	[ "$status" -eq 0 ]
	[[ "$output" == *Commands:* ]]
}

@test "global --no-update-check before help still works" {
	run bash "${REPO_ROOT}/cshell" --no-update-check help
	[ "$status" -eq 0 ]
	[[ "$output" == *Commands:* ]]
}

@test "cshell docs exits 0 and mentions README" {
	run_cshell docs
	[ "$status" -eq 0 ]
	[[ "$output" == *README* || "$output" == *readme* ]]
}

@test "cshell with no command prints usage and exits 1" {
	run_cshell
	[ "$status" -eq 1 ]
	[[ "$output" == *Usage:* ]]
}

@test "unknown command prints usage and exits 1" {
	run_cshell not-a-real-command
	[ "$status" -eq 1 ]
	[[ "$output" == *Usage:* ]]
}

@test "config show masks storage account key" {
	export_home_tmp
	{
		echo "AZURE_STORAGE_ACCOUNT=demoacct"
		echo "AZURE_STORAGE_ACCOUNT_KEY=supersecret"
	} >"${HOME}/.cshell.env"

	run_cshell config show
	[ "$status" -eq 0 ]
	[[ "$output" == *"AZURE_STORAGE_ACCOUNT_KEY=********"* ]]
	[[ "$output" == *"AZURE_STORAGE_ACCOUNT=demoacct"* ]]
}

@test "backup --dry-run does not create archive" {
	export_home_tmp
	run_cshell backup --dry-run
	[ "$status" -eq 0 ]
	[ ! -f "${HOME}/archive.zip" ]
}

@test "backup rejects unknown option" {
	export_home_tmp
	run_cshell backup --not-a-flag
	[ "$status" -eq 1 ]
}
