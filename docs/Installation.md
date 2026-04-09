# Installation

## Recommended Install

```bash
curl -fsSL https://raw.githubusercontent.com/vergissberlin/azure-cloud-shell-development/main/install.sh | bash
```

This installer resolves the latest release and installs `cshell` into a writable
location. When release assets include `cshell-<version>.tar.gz` and the matching
`.sha256` file, the installer verifies the checksum before extracting the
standalone binary; otherwise it falls back to downloading the raw `cshell` script
(verify manually when you need supply-chain guarantees — see the repository
README).

## Install From Local Clone

```bash
bash cshell setup
```

`setup` installs:

- `cshell` binary (user-space by default)
- Bash completion for `cshell`
- Google Cloud SDK (`gcloud`) if missing
- Azure Blob backup configuration prompts

## Validate Installation

```bash
cshell --version
cshell help
```

## Path and Completion

If needed, ensure `~/.local/bin` is in `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Reload your shell:

```bash
source ~/.bashrc
```
