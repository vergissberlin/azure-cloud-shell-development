# Security policy

## Supported versions

Security fixes are applied to the latest release on the default branch (`main`) and
published through the normal [Release Please](https://github.com/googleapis/release-please)
workflow. Use the newest `cshell` tag from [Releases](https://github.com/vergissberlin/azure-cloud-shell-development/releases).

## Reporting a vulnerability

Please **do not** open a public issue for undisclosed security problems.

- Prefer [GitHub private vulnerability reporting](https://github.com/vergissberlin/azure-cloud-shell-development/security/advisories/new)
  if enabled for this repository, or
- Open a **private** discussion with the maintainers using a channel they publish in the
  repository README or org profile.

Include: affected version or Git ref, steps to reproduce, impact, and any suggested fix.

## Install integrity

For highest confidence when installing `cshell`, use release assets that include a
`.sha256` checksum (see [README.md](README.md) — verify the tarball before extracting).
The bootstrap `install.sh` path from `main` prefers those assets when available.
