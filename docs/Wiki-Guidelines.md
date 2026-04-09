# Wiki documentation rules

The GitHub Wiki is **generated from this repository** only: the `wiki-sync`
workflow mirrors [`docs/`](https://github.com/vergissberlin/azure-cloud-shell-development/tree/main/docs/)
into the wiki and **overwrites** wiki content on `main`. Do not edit the wiki
by hand in the browser — changes would be lost on the next sync.

## Source of truth

- All wiki pages live under **`docs/`** in the default branch.
- Keep a **single** canonical tree. Do not maintain a parallel `DOCS/` directory
  (case-sensitive environments may confuse it with `docs/`).
- Write **English** prose unless a page is explicitly localized (not used today).

## When you change behavior

- Update **command reference** and **configuration** pages when CLI flags,
  env vars, or defaults change.
- Keep **internal markdown links** valid: on pull requests, CI validates
  relative targets under `docs/`.
- Prefer **absolute HTTPS links** for external resources (no broken relative
  URLs to hosts).

## Wiki navigation and structure

- Add new pages under `docs/` and link them from **`Home.md`** and
  **`_Sidebar.md`** so the wiki stays navigable.
- GitHub Wiki link style: `[Title](Page-Name)` without `.md` (see existing
  `_Sidebar.md`).
- Optional header/footer/sidebar files (`_Header.md`, `_Footer.md`,
  `_Sidebar.md`) are part of the synced bundle — change them here, not in the
  wiki UI.

## Style and safety

- Do not recommend `source ~/.cshell.env` as the default; prefer documenting
  `cshell config show` unless the flow truly requires exporting every variable.
- For secrets (keys, tokens), document **rotation** and **file permissions**
  (`chmod 600` on `~/.cshell.env`) when relevant.
- Use concrete examples with placeholders (`<storage-account>`) instead of
  real names.

## Review

- Every docs-only PR runs **link validation**; fix reported broken targets
  before merge.
- After merge, wiki sync runs on `main`; confirm the wiki if you changed
  navigation or renamed pages.
