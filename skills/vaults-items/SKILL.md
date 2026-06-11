---
name: vaults-items
version: 1.0.0
description: Use when managing 1Password vaults and items - creating or editing items, moving or copying items between vaults or accounts, sharing items, managing documents, or granting vault permissions to users and groups
---

# 1password:vaults-items

Manage 1Password vaults and items through guarded `op` CLI workflows.
Metadata-first: titles, categories, vault names, and IDs only. Field values are
never printed unless the user explicitly approves that specific access.

## When To Use

Use this skill when a user asks to:

- Create, edit, archive, or delete items in 1Password vaults.
- Move or copy items (passwords, logins, API keys) between vaults.
- Move items between 1Password accounts.
- Share an item with a person via a share link.
- Store or retrieve Document items.
- Create, edit, or delete vaults.
- Grant or revoke vault access for users or groups.

Do not use this skill for environment variables or `.env` workflows — use
`1password:environments`. Do not use it for SSH keys or Git signing — use
`1password:ssh-git`.

## Core Workflow

Follow this order every time:

1. Classify intent: item-crud, item-move, item-share, document, vault-crud, or vault-access.
2. Load `../../references/security.md`.
3. Verify CLI auth: `op whoami`. If multiple accounts exist, confirm the target
   account with the user and pass `--account` explicitly on every command.
4. Load `../../references/items-vaults.md` for command syntax and caveats.
5. Run metadata-only discovery first: `op vault list`, `op item list --vault X --format json | jq '.[] | {id, title, category}'`.
6. Present a plan naming the items, source, and destination. Ask for explicit
   confirmation before any write, move, delete, share, or permission change.
7. Execute.
8. Verify by listing metadata only.
9. Summarize without field values.

## Moving Items Between Vaults

```bash
op item move "ITEM_NAME_OR_ID" --current-vault "Source" --destination-vault "Target"
```

Critical semantics to tell the user before moving:

- A move is copy-then-delete. **The item receives a new ID in the destination
  vault.** Anything pinned to the old ID breaks: secret references using IDs,
  Terraform/Pulumi data sources, SDK integrations, scripts.
- Access control follows the destination vault. Moving an item into a shared
  vault exposes it to everyone with access there; state who gains access before
  confirming.
- Name-based secret references (`op://Vault/Item/field`) break too if the vault
  name changes. After a move, offer to grep the project for `op://` references
  to the old vault and update them.

For bulk moves, list candidate items by metadata, confirm the full list once,
then move in a loop. Verify with `op item list` on both vaults afterwards.

## Moving Items Between Accounts

`op item move` cannot cross accounts. Two paths:

1. **Preferred — desktop app:** the 1Password app (not the web interface) can
   move or copy items between accounts via drag or the item menu. Guide the
   user through it; no values touch the agent.
2. **CLI fallback (explicit approval required — raw value access):** export the
   item as JSON from the source account and recreate it in the destination,
   piping without printing:

   ```bash
   op item get "ITEM_ID" --account SOURCE --format json --reveal |
     op item create --account DEST --vault "Target" --template -
   ```

   Then ask whether the user wants the original archived or deleted. Note that
   file attachments and passkeys do not survive this path — check for them
   first with metadata (`op item get ITEM_ID --format json | jq '.files, .category'`).

## Item Sharing

`op item share` creates a time-limited link:

```bash
op item share "ITEM_NAME" --vault "Vault" --emails person@example.com --expires-in 24h
```

- Default expiry is 7 days; `--view-once` for single view.
- Document items and file attachments cannot be shared by link.
- Edits made after sharing are not reflected in the link.
- Treat the generated link itself as sensitive: display it once for the user,
  never log or persist it.

Confirm recipient, expiry, and item before creating any link.

## Vault Management And Access

Vault CRUD and permission grants are administrative writes — always show the
exact permission set and audience before executing. Permission vocabularies
differ between Teams/Families (`allow_viewing`, `allow_editing`,
`allow_managing`) and Business (granular: `view_items`, `create_items`,
`manage_vault`, ...). See `../../references/items-vaults.md` for the full
matrix and grant/revoke syntax.

Service accounts can only manage permissions on vaults they created, and can
never access Private/Personal/Employee vaults. If the session authenticates via
a service account token, check those limits before promising a workflow. Load
`../../references/service-accounts-connect.md` when service accounts or Connect
are involved.

## Safety Rules

- Never print field values, share-link tokens, or document contents.
- Never pass secret values as command-line arguments.
- `--reveal` output must only ever be piped directly into another `op` command,
  never to the terminal, a file, or a log.
- Deletes: prefer `op item delete --archive` over hard delete. Mention that
  hard-deleted items remain recoverable in Recently Deleted for 30 days.
- Vault deletion is destructive and takes its items with it — require the user
  to name the vault back to you before running it.

## Anything Else 1Password

For topics beyond this skill's workflows (Events API, Connect deployment,
CI/CD integrations, Terraform, shell plugins), load
`../../references/docs-map.md` and fetch the current official docs from
www.1password.dev before answering.
