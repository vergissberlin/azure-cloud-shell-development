# Task runner: https://github.com/casey/just  ("brew install just" / see CI)
# See also: .github/workflows/standalone-build-check.yml
#
# Note: `just` often inherits a minimal PATH. Recipes prepend Homebrew bins so
# `shellcheck` / `shfmt` / `bats` work without a login shell.

default:
	@just --list

# Show whether lint/format/test tools are visible (after PATH fix used in recipes)
doctor:
	#!/usr/bin/env bash
	set -euo pipefail
	export PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:${PATH:-}"
	printf 'PATH (first hops): %s\n' "${PATH%%:*}"
	for c in shellcheck shfmt bats bash; do
		if command -v "${c}" >/dev/null 2>&1; then
			printf 'ok  %s -> %s\n' "${c}" "$(command -v "${c}")"
		else
			hint="brew install ${c}"
			if [[ "${c}" == bats ]]; then hint="brew install bats-core"; fi
			printf 'MISSING %s (%s)\n' "${c}" "${hint}"
		fi
	done

# Full gate: matches standalone-build-check (build, bash -n, shellcheck, shfmt, bats)
check: syntax lint fmt-check bats

alias ci := check

alias test := bats

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
	bash -n lib/env-file.sh lib/portable.sh lib/config-cmd.sh lib/hybrid-checklist.sh lib/hybrid-command-log.sh lib/hybrid-aks-kubeconfig.sh lib/hybrid-overrides-nonprod.sh lib/hybrid-overrides-prod.sh
	bash -n dist/cshell dist/install.sh

# ShellCheck on sources and dist/cshell (requires build)
lint: build
	#!/usr/bin/env bash
	set -euo pipefail
	export PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:${PATH:-}"
	if ! command -v shellcheck >/dev/null 2>&1; then
		echo "shellcheck not found. Install:  brew install shellcheck"
		echo "Or run:  just doctor"
		exit 127
	fi
	shellcheck -x cshell install.sh scripts/build-standalone-scripts.sh lib/*.sh
	shellcheck -x dist/cshell

# shfmt check-only (CI flags)
fmt-check:
	#!/usr/bin/env bash
	set -euo pipefail
	export PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:${PATH:-}"
	if ! command -v shfmt >/dev/null 2>&1; then
		echo "shfmt not found. Install:  brew install shfmt"
		echo "Or run:  just doctor"
		exit 127
	fi
	shfmt -d -ci -bn cshell install.sh lib/*.sh scripts/build-standalone-scripts.sh

# Format shell sources in place
fmt:
	#!/usr/bin/env bash
	set -euo pipefail
	export PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:${PATH:-}"
	if ! command -v shfmt >/dev/null 2>&1; then
		echo "shfmt not found. Install:  brew install shfmt"
		exit 127
	fi
	shfmt -w -ci -bn cshell install.sh lib/*.sh scripts/build-standalone-scripts.sh

# Bats smoke tests (needs bats on PATH, or run `just bats-deps` once)
bats:
	#!/usr/bin/env bash
	set -euo pipefail
	export PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/.local/bin:${PATH:-}"
	BATS_ROOT="${BATS_ROOT:-{{ justfile_directory() }}/.bats-core}"
	if command -v bats >/dev/null 2>&1; then
		bats tests
	elif [[ -x "${BATS_ROOT}/bin/bats" ]]; then
		"${BATS_ROOT}/bin/bats" tests
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
