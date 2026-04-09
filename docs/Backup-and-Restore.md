# Backup and Restore

## Backup Flow

Run:

```bash
cshell backup
```

Behavior:

- creates `~/archive.zip`
- excludes non-essential cache-like content
- uploads to Azure Blob Storage using configured account/container

## Restore Flow

Run:

```bash
cshell restore
```

Behavior:

- restores from local `~/archive.zip` when present
- otherwise attempts Azure Blob download before restore

## Pre-Requirements

- `cshell setup` completed
- valid Azure credentials (`az login` context in Cloud Shell)
- `AZURE_STORAGE_ACCOUNT` and `AZURE_STORAGE_CONTAINER` present in `~/.cshell.env`

## Operational Tips

- Trigger backup before major environment changes.
- Keep storage lifecycle/retention policies in Azure aligned with recovery needs.
- Validate restore periodically in a safe test context.
