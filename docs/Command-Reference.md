# Command Reference

## Global

- `cshell --version`: print current script version
- `cshell help`: print usage, command list, and documentation links
- `cshell docs`: print project and Apigee documentation links

## `cshell init`

Creates or reuses Azure backup resources:

- resource group
- storage account
- blob container

Writes resulting config values to `~/.cshell.env`.

## `cshell setup`

Performs first-time setup:

- installs `cshell`
- configures Bash completion
- installs `gcloud` if missing
- prompts for Azure Blob backup parameters

## `cshell hybrid`

Prepares Apigee Hybrid environment variables and pulls required Helm charts.

## `cshell backup`

- creates `~/archive.zip`
- uploads archive to configured Azure Blob container
- uses login auth first, then account-key fallback if available

## `cshell restore`

- restores from local `~/archive.zip`
- or downloads from Azure Blob if local archive is missing

## `cshell update`

Downloads and installs latest released `cshell` version to an appropriate writable path.
