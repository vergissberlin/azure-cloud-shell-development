# Agent Rules

## Execution Environment

- Environment is an Azure Linux Cloud Shell sandbox.
- No root privileges are available.
- Azure CLI (`az`) is already authenticated.
- Only tools available inside the sandbox may be used.

## Operational Constraints

- Never use `sudo` or assume elevated permissions.
- Prefer user-space paths and non-root workflows.
- Avoid installation steps that require system package managers or root access.
- Adapt commands and scripts for Cloud Shell limitations by default.
