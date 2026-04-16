# FAQ

## Is `cshell` only for Azure Cloud Shell?

It is optimized for Azure Cloud Shell constraints, but many commands also run in other Bash environments.

## Can I simulate Azure Cloud Shell locally?

Mostly you do **not** need to: use Linux or **WSL2** with Bash and the same CLIs (`az`, `kubectl`, `helm`, `gcloud` as needed). `cshell` does not depend on the Cloud Shell kernel or hostname.

To trigger the same **“Azure Cloud Shell detected”** hint that `cshell setup` prints when it thinks it is in Cloud Shell, set **one** of these in your environment before running `cshell`:

- **`CSHELL_SIMULATE_CLOUD_SHELL=1`** — explicit, documented opt-in for local testing.
- **`CLOUD_SHELL=1`** or **`ACC_CLOUD=1`** — match variables present in real Azure Cloud Shell sessions.

Unset or set to anything other than **`1`** for `CSHELL_SIMULATE_CLOUD_SHELL` so normal local runs are unchanged.

## Where is configuration stored?

In `~/.cshell.env`.

## Is setup idempotent?

Yes. `cshell setup` is intended to be re-run safely.

## Do I need root permissions?

Not by default. The project favors user-space install paths and no-root flows.

## How do I get the latest script?

Run:

```bash
cshell update
```

## How do I discover relevant docs quickly?

Run:

```bash
cshell docs
```
