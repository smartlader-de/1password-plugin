# Items And Vaults CLI Reference

> Load this reference for `op item` and `op vault` syntax, move/copy semantics,
> sharing, documents, and vault permission management.
> Verified against www.1password.dev docs, June 2026.

## Contents

- [Item commands](#item-commands)
- [Moving items between vaults](#moving-items-between-vaults)
- [Moving items between accounts](#moving-items-between-accounts)
- [Item sharing](#item-sharing)
- [Document items](#document-items)
- [Vault commands](#vault-commands)
- [Vault permissions](#vault-permissions)
- [Users and groups](#users-and-groups)

## Item Commands

| Command | Purpose |
|---|---|
| `op item list` | List items (metadata). Filter: `--vault`, `--categories`, `--tags`, `--favorite`, `--include-archive` |
| `op item get <name\|id>` | Item details. `--fields label=x`, `--otp`, `--reveal`, `--share-link`, `--format json` |
| `op item create` | Create. `--category`, `--vault`, `--title`, `--generate-password[=recipe]`, `--tags`, `--url`, `--template`, `--dry-run` |
| `op item edit <name\|id>` | Edit. Assignment syntax `[section.]field[type]=value`; `[delete]` removes a field |
| `op item delete <name\|id>` | Delete. `--archive` archives instead (preferred) |
| `op item move <name\|id>` | Move between vaults. `--current-vault`, `--destination-vault` |
| `op item share <name\|id>` | Share link. `--emails`, `--expires-in`, `--view-once` |
| `op item template list/get` | List categories / emit JSON template |

Metadata-only listing pattern:

```bash
op item list --vault "Vault" --format json | jq '.[] | {id, title, category, updated_at}'
```

Create without exposing a value — let 1Password generate it:

```bash
op item create --category "API Credential" --title "stripe-prod" \
  --vault "Infrastructure" --generate-password='letters,digits,32'
```

Create from a template via stdin (values flow through the pipe, never argv):

```bash
op item template get Login | jq '.title = "example"' | op item create --vault "Vault" --template -
```

Caveats:

- Item edits via JSON template overwrite passkeys; use assignment syntax for
  single-field changes.
- Archived items are excluded from `list`/`get` by default; pass
  `--include-archive`.
- Hard-deleted items sit in Recently Deleted for 30 days.
- IDs are 26-character strings and are the stable way to reference objects —
  stable except across vault moves (see below).

## Moving Items Between Vaults

```bash
op item move "ITEM" --current-vault "Source" --destination-vault "Target"
```

Semantics (from official docs):

- Move = copy to destination + delete from source. **The item gets a new ID.**
- Automation keyed to the old ID (Terraform, SDK lookups, ID-based secret
  references) must be updated. Capture the new ID from the move output or by
  re-running `op item get --format json | jq .id`.
- Access control changes to the destination vault's permissions.
- Item history: the moved copy starts fresh in the destination vault.

Bulk move pattern (confirm the list with the user first):

```bash
op item list --vault "Source" --tags migrate --format json | jq -r '.[].id' |
while read -r id; do
  op item move "$id" --current-vault "Source" --destination-vault "Target"
done
```

After moving, check the project tree for stale references:

```bash
grep -rn "op://Source/" . --include='*' 2>/dev/null
```

Copy (keep original) has no dedicated CLI verb. Options: duplicate in the
desktop app, or recreate via template pipe (raw value access — needs approval):

```bash
op item get "ITEM" --format json --reveal | op item create --vault "Target" --template -
```

Warn the user that copies do not stay in sync; the docs recommend moving over
copying for anything that gets edited.

## Moving Items Between Accounts

- `op item move` is single-account. Cross-account moves are supported in the
  1Password desktop apps (drag between accounts, or item menu → Move/Copy);
  the web app cannot do it.
- CLI fallback is the get/create pipe with `--account` on both sides (raw value
  access — explicit approval required):

```bash
op item get "ITEM_ID" --account source.1password.com --format json --reveal |
  op item create --account dest.1password.com --vault "Target" --template -
```

- File attachments and passkeys do not transfer through the JSON pipe. Detect
  attachments first: `op item get ITEM_ID --format json | jq '.files'`.
- The source item is untouched; ask whether to archive or delete it after a
  verified recreate.

## Item Sharing

```bash
op item share "ITEM" --vault "Vault" [--emails a@x.com,b@y.com] [--expires-in 24h] [--view-once]
```

- Expiry format `s/m/h/d/w`, default 7 days.
- Without `--emails` anyone with the link can view.
- Documents and items with file attachments cannot be shared.
- Post-share edits are not reflected in existing links.
- The link grants access to field values — treat it as a secret.

## Document Items

| Command | Purpose |
|---|---|
| `op document list` | List Document items |
| `op document get <name\|id> --out-file path` | Download (content is secret — confirm destination) |
| `op document create <file>` | Upload. `--title`, `--vault`, `--file-name` |
| `op document edit <name\|id> <file>` | Replace content |
| `op document delete <name\|id>` | Delete. `--archive` available |

Downloads write secret content to disk: confirm path, keep out of the repo,
suggest `chmod 600`.

## Vault Commands

| Command | Purpose |
|---|---|
| `op vault list` | List vaults. Filter: `--group`, `--user`, `--permission` |
| `op vault get <name\|id>` | Details: type, item count, versions |
| `op vault create <name>` | Create. `--description`, `--icon`, `--allow-admins-to-manage true\|false` |
| `op vault edit <name\|id>` | `--name`, `--description`, `--icon`, `--travel-mode on\|off` |
| `op vault delete <name\|id>` | Destructive — deletes contained items |

## Vault Permissions

Grant/revoke for users and groups:

```bash
op vault user grant  --vault "Vault" --user  person@example.com --permissions view_items,create_items
op vault user revoke --vault "Vault" --user  person@example.com --permissions edit_items
op vault group grant --vault "Vault" --group "Developers" --permissions allow_viewing
op vault user list "Vault"
```

Permission vocabulary depends on plan:

- **Teams / Families:** `allow_viewing`, `allow_editing`, `allow_managing` only.
- **Business (granular):**
  - viewing: `view_items`, `view_and_copy_passwords`, `view_item_history`
  - editing: `create_items`, `edit_items`, `archive_items`, `delete_items`,
    `import_items`, `export_items`, `copy_and_share_items`, `print_items`
  - managing: `manage_vault`

Granular permissions are hierarchical: narrower permissions require their
broader prerequisites to be granted together (for example `view_and_copy_passwords`
requires `view_items`). If a grant fails, add the prerequisite rather than
escalating to `manage_vault`.

Service-account limits: they cannot access Private/Personal/Employee vaults and
can only manage permissions on vaults the service account itself created.

## Users And Groups

Administrative reads are safe; provisioning writes need explicit confirmation.

```bash
op user list
op user get "Name or email"
op group list
op group user list "Group"
op user provision --name "Name" --email user@example.com   # write — confirm
op group user grant --group "Group" --user user@example.com # write — confirm
```
