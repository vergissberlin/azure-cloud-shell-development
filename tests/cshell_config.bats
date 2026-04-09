#!/usr/bin/env bats
# cshell config subcommand tests.

load test_helper

setup() {
	common_setup
}

@test "config set writes allowlisted key" {
	export_home_tmp
	run_cshell config set AZURE_STORAGE_ACCOUNT myaccount
	[ "$status" -eq 0 ]
	[ -f "${HOME}/.cshell.env" ]
	grep -qx 'AZURE_STORAGE_ACCOUNT=myaccount' "${HOME}/.cshell.env"
}

@test "config set replaces existing key" {
	export_home_tmp
	echo 'AZURE_STORAGE_ACCOUNT=old' >"${HOME}/.cshell.env"
	run_cshell config set AZURE_STORAGE_ACCOUNT newname
	[ "$status" -eq 0 ]
	grep -qx 'AZURE_STORAGE_ACCOUNT=newname' "${HOME}/.cshell.env"
	! grep -q 'old' "${HOME}/.cshell.env"
}

@test "config set with empty value removes key" {
	export_home_tmp
	echo 'AZURE_STORAGE_ACCOUNT=gone' >"${HOME}/.cshell.env"
	run_cshell config set AZURE_STORAGE_ACCOUNT
	[ "$status" -eq 0 ]
	! grep -q '^AZURE_STORAGE_ACCOUNT=' "${HOME}/.cshell.env"
}

@test "config set rejects non-allowlisted key" {
	export_home_tmp
	run_cshell config set EVIL_KEY value
	[ "$status" -eq 1 ]
	[[ "$output" == *allowlisted* ]]
}

@test "config show ignores non-allowlisted lines in file" {
	export_home_tmp
	{
		echo 'PROJECT_ID=safe-project'
		echo 'FOO=should-not-appear-in-masked-loop'
		echo 'MALICIOUS=does-not-matter'
	} >"${HOME}/.cshell.env"

	run_cshell config show
	[ "$status" -eq 0 ]
	[[ "$output" == *"PROJECT_ID=safe-project"* ]]
	[[ "$output" != *FOO=* ]]
	[[ "$output" != *MALICIOUS=* ]]
}

@test "config help exits 0" {
	run_cshell config help
	[ "$status" -eq 0 ]
	[[ "$output" == *"config show"* ]]
}

@test "config without subcommand shows usage" {
	run_cshell config
	[ "$status" -eq 0 ]
	[[ "$output" == *"config show"* ]]
}

@test "config validate exits 0 without Azure" {
	export_home_tmp
	# No .cshell.env — validate still runs generic branch
	run_cshell config validate
	[ "$status" -eq 0 ]
}
