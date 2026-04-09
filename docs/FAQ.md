# FAQ

## Is `cshell` only for Azure Cloud Shell?

It is optimized for Azure Cloud Shell constraints, but many commands also run in other Bash environments.

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
