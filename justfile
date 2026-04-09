# Task runner: https://github.com/casey/just  ("brew install just" / see CI)
# See also: .github/workflows/standalone-build-check.yml

default:
	@just --list

# Full gate: matches standalone-build-check (build, bash -n, shellcheck, shfmt, bats)
check: syntax lint fmt-check bats

alias ci := check

# Generate dist/cshell and dist/install.sh (embeds lib/*.sh + CLI utils)
build:
	#!/usr/bin/env bash
	set -euo pipefail
	chmod +x scripts/build-standalone-scripts.sh
	./scripts/build-standalone-scripts.sh

# bash -n on repo sources and standalone outputs (requires build for dist/*)
syntax: build
	#!/usr/bin/env bash
	set -euo pipefail
	bash -n cshell install.sh scripts/build-standalone-scripts.sh
	bash -n lib/env-file.sh lib/portable.sh lib/config-cmd.sh
	bash -n dist/cshell dist/install.sh

# ShellCheck on sources and dist/cshell (requires build)
lint: build
	#!/usr/bin/env bash
	set -euo pipefail
	shellcheck -x cshell install.sh scripts/build-standalone-scripts.sh lib/*.sh
	shellcheck -x dist/cshell

# shfmt check-only (CI flags)
fmt-check:
	#!/usr/bin/env bash
	set -euo pipefail
	shfmt -d -ci -bn cshell install.sh lib/*.sh scripts/build-standalone-scripts.sh

# Format shell sources in place
fmt:
	#!/usr/bin/env bash
	set -euo pipefail
	shfmt -w -ci -bn cshell install.sh lib/*.sh scripts/build-standalone-scripts.sh

# Bats smoke tests (needs bats on PATH, or run `just bats-deps` once)
bats:
	#!/usr/bin/env bash
	set -euo pipefail
	BATS_ROOT="${BATS_ROOT:-{{ justfile_directory() }}/.bats-core}"
	if command -v bats >/dev/null 2>&1; then
		bats tests/cshell_cli.bats
	elif [[ -x "${BATS_ROOT}/bin/bats" ]]; then
		"${BATS_ROOT}/bin/bats" tests/cshell_cli.bats
	else
		echo "bats not found. Install (e.g. brew install bats-core) or run: just bats-deps"
		exit 1
	fi

# Vendor bats-core into .bats-core (gitignored) for environments without a global bats
bats-deps:
	#!/usr/bin/env bash
	set -euo pipefail
	target="{{ justfile_directory() }}/.bats-core"
	rm -rf "${target}"
	git clone --depth 1 https://github.com/bats-core/bats-core.git "${target}"
	@echo "Run: just bats"

# Remove generated standalone scripts
clean:
	rm -rf dist/
