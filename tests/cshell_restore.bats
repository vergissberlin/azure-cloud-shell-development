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

@test "backup archive excludes google-cloud-sdk but keeps other paths" {
	export_home_tmp
	mkdir -p "${HOME}/google-cloud-sdk" "${HOME}/other"
	printf 'omit\n' >"${HOME}/google-cloud-sdk/ignored.txt"
	printf 'keep\n' >"${HOME}/other/keep"

	run env CSHELL_NO_UPDATE_CHECK=1 bash "${REPO_ROOT}/cshell" backup
	[ "$status" -eq 0 ]
	[ -f "${HOME}/archive.zip" ]

	run unzip -l "${HOME}/archive.zip"
	[ "$status" -eq 0 ]
	[[ "$output" != *google-cloud-sdk* ]]
	[[ "$output" == *other/keep* ]]
}

@test "backup upload invokes az storage blob upload with --overwrite" {
	export_home_tmp
	local stub_bin="${HOME}/stub-bin"
	mkdir -p "${stub_bin}"
	cat >"${stub_bin}/az" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"${AZ_STUB_LOG}"
exit 0
STUB
	chmod +x "${stub_bin}/az"

	export AZ_STUB_LOG="${HOME}/az-invocation.log"
	: >"${AZ_STUB_LOG}"

	{
		echo 'AZURE_STORAGE_ACCOUNT=testacct'
		echo 'AZURE_STORAGE_CONTAINER=testcnt'
	} >"${HOME}/.cshell.env"

	run env PATH="${stub_bin}:${PATH}" CSHELL_NO_UPDATE_CHECK=1 bash "${REPO_ROOT}/cshell" backup
	[ "$status" -eq 0 ]
	run grep -q 'storage blob upload' "${AZ_STUB_LOG}"
	[ "$status" -eq 0 ]
	run grep -q -- '--overwrite' "${AZ_STUB_LOG}"
	[ "$status" -eq 0 ]
}
