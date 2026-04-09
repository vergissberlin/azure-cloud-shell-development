#!/usr/bin/env bats
# restore / further backup edge cases.

load test_helper

setup() {
	common_setup
}

@test "restore --dry-run without archive uses Azure hint when storage is configured" {
	export_home_tmp
	{
		echo 'AZURE_STORAGE_ACCOUNT=acct'
		echo 'AZURE_STORAGE_CONTAINER=cntr'
	} >"${HOME}/.cshell.env"

	run_cshell restore --dry-run
	[ "$status" -eq 0 ]
	[[ "$output" == *"[dry-run]"* ]]
	[[ "$output" == *"Azure Blob Storage"* ]]
	[ ! -f "${HOME}/archive.zip" ]
}

@test "restore --dry-run with local archive does not unzip" {
	export_home_tmp
	touch "${HOME}/archive.zip"
	run_cshell restore --dry-run
	[ "$status" -eq 0 ]
	[[ "$output" == *"Would unzip"* ]]
}

@test "restore --dry-run verbose mentions target when archive exists" {
	export_home_tmp
	touch "${HOME}/archive.zip"
	run_cshell restore --dry-run --verbose
	[ "$status" -eq 0 ]
	[[ "$output" == *"Target exists"* ]]
}

@test "restore rejects unknown option" {
	export_home_tmp
	run_cshell restore --bogus
	[ "$status" -eq 1 ]
}

@test "restore without archive and without config exits 1" {
	export_home_tmp
	run_cshell restore
	[ "$status" -eq 1 ]
}

@test "backup --verbose with --dry-run still skips zip (verbose applies after dry-run return)" {
	export_home_tmp
	run_cshell backup --dry-run --verbose
	[ "$status" -eq 0 ]
	[[ "$output" == *"[dry-run]"* ]]
	[ ! -f "${HOME}/archive.zip" ]
}
