# Azure Cloud Shell Development Docs

This documentation covers installation, operations, and maintenance for `cshell`.

## Start Here

- [Installation](Installation.md)
- [Command Reference](Command-Reference.md)
- [Configuration](Configuration.md)
- [Backup and Restore](Backup-and-Restore.md)
- [Hybrid Setup](Hybrid-Setup.md)
- [Release and CI](Release-and-CI.md)
- [Troubleshooting](Troubleshooting.md)
- [FAQ](FAQ.md)
- [Contributing](Contributing.md)

## Project Scope

`cshell` is a Bash-first helper for Azure Cloud Shell workflows:

- first-time setup for tools and shell completion
- backup/restore of home directory data to Azure Blob Storage
- Apigee Hybrid environment bootstrap
- self-update and release-aware messaging

## Execution Environment

- No root privileges are assumed by default.
- Commands are designed for Cloud Shell constraints.
- Configuration is persisted in `~/.cshell.env`.

## Support Paths

- Repository README: <https://github.com/vergissberlin/azure-cloud-shell-development#readme>
- Issues: <https://github.com/vergissberlin/azure-cloud-shell-development/issues>
- Releases: <https://github.com/vergissberlin/azure-cloud-shell-development/releases>
