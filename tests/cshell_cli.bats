#!/usr/bin/env bats
# Smoke tests for cshell (no Azure calls).

setup() {
  export REPO_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
  export CSHELL_NO_UPDATE_CHECK=1
}

@test "cshell --version matches semver line" {
  run bash "${REPO_ROOT}/cshell" --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^cshell[[:space:]]+[0-9]+\.[0-9]+\.[0-9] ]]
}

@test "cshell help exits 0" {
  run bash "${REPO_ROOT}/cshell" help
  [ "$status" -eq 0 ]
  [[ "$output" == *Commands:* ]]
}

@test "config show masks storage account key" {
  local thome
  thome="$(mktemp -d)"
  export HOME="${thome}"
  {
    echo "AZURE_STORAGE_ACCOUNT=demoacct"
    echo "AZURE_STORAGE_ACCOUNT_KEY=supersecret"
  } >"${HOME}/.cshell.env"

  run bash "${REPO_ROOT}/cshell" config show
  [ "$status" -eq 0 ]
  [[ "$output" == *"AZURE_STORAGE_ACCOUNT_KEY=********"* ]]
  [[ "$output" == *"AZURE_STORAGE_ACCOUNT=demoacct"* ]]
}

@test "backup --dry-run does not create archive" {
  local thome
  thome="$(mktemp -d)"
  export HOME="${thome}"
  run bash "${REPO_ROOT}/cshell" backup --dry-run
  [ "$status" -eq 0 ]
  [ ! -f "${HOME}/archive.zip" ]
}
