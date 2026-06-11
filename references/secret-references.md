# Secret References (op:// URIs)

> Load this reference when wiring secrets into config files, scripts, CI, or
> when replacing plaintext secrets in code with references.

## Syntax

```
op://<vault>/<item>/[section/]<field>[?attribute=<value>]
```

Names or 26-character IDs both work for each segment. References resolve to
the current value at runtime, so rotations propagate automatically — this is
the main reason to prefer references over copied values.

Query parameters:

- `?attribute=otp` — resolve the current TOTP code from a one-time-password field.
- `?ssh-format=openssh` — fetch a private SSH key converted to OpenSSH format.

Stability note: references by item ID survive renames but **break when the
item moves to another vault** (new item ID). References by name survive moves
only if vault and item names stay identical. After any vault move, grep the
project for `op://` and update.

## Getting References Without Exposing Values

```bash
op item get "ITEM" --format json --fields label=password | jq .reference
```

Run without `--fields` to get references for all fields (the JSON also
contains values — pipe to `jq '.fields[].reference'`, never print the whole
document).

The desktop app (with CLI integration on) offers "Copy Secret Reference" on
every field, and the VS Code extension inserts references and flags plaintext
secrets in code.

## Resolving References

| Command | Use case |
|---|---|
| `op read "op://..."` | Single value to stdout — raw value access, needs approval; only pipe, never display |
| `op run --env-file .env -- cmd` | `.env` contains references; values injected into subprocess env only |
| `op run --environment ENV_ID -- cmd` | Same, sourced from a 1Password Environment (beta) |
| `op inject -i config.tpl -o config` | Replace references in a template file — output file contains plaintext; confirm destination and gitignore |

`op run` masks secrets that appear in the subprocess output unless
`--no-masking` is set. Precedence when sources overlap: Environments >
environment files > shell variables.

Safe `.env` for repos — references are not secrets and may be committed:

```bash
# .env — safe to commit, resolved by `op run`
DATABASE_URL="op://myproject-prod/database/connection-url"
STRIPE_KEY="op://myproject-prod/stripe/api-key"
```

`op inject` output and `op read` redirection produce plaintext on disk. Treat
both as guarded operations: explicit approval, gitignored destination,
`chmod 600`.

## In SDKs

All three SDKs resolve references via `Resolve`/`resolve()` (and batch
variants), including the `otp` and `ssh-format` query parameters. See
`sdks.md`.
