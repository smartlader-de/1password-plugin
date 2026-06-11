# Moving Environments, Variables, And Items

> Load this reference when the user wants to move or copy: an Environment to
> another account, variables between Environments, a vault item's secret into
> an Environment, or an Environment variable into a vault item.

## The Landscape

Environments do not live inside vaults — they are a separate per-account
structure. So "move an environment to another vault" cannot be literal; clarify
what the user means:

| User says | Actual operation |
|---|---|
| "move this environment to another vault" | Usually: share it, or move it to another **account** |
| "move env to my work account" | Recreate in target account + transfer variables |
| "copy staging vars to production env" | Variable transfer between Environments (same account) |
| "put this API key from my vault into the env" | Item field → Environment variable |
| "move passwords between vaults" | `op item move` — use `1password:vaults-items` |

There is no native move/copy for Environments (as of June 2026). Every
transfer is create-target + transfer-variables, and the variable **values**
must travel. Plan that value path deliberately.

## Value-Path Options, Safest First

1. **Desktop-guided (no agent exposure)** — preferred.
   The user mounts or exports the source Environment as a `.env` file via the
   desktop app (Destinations > Local .env file), then imports that file into
   the new Environment ("Import .env file") — in the other account if needed
   (Environments are per-account; the account picker appears at creation).
   The agent's role: create the target Environment via MCP, verify by variable
   names afterwards, and remind the user to delete any exported plaintext file.

2. **Agent-orchestrated pipe (values bypass the transcript)** — needs explicit
   approval as raw value access, even though nothing is printed.
   Read the source with the CLI and feed the MCP `append_variables` call from
   a local script, so values flow process-to-process:

   - `op environment read SRC_ENV_ID` output goes only into a pipe or a
     variable inside a script — never to the terminal, a file, or the chat.
   - The script parses `KEY=value` lines and calls MCP `append_variables` with
     `concealed: true` per variable (stdio bridge pattern in
     `mcp-quickstart.md` section 6).
   - Cross-account: authenticate MCP against the target account; run the
     CLI read with `--account` for the source.

3. **Manual re-entry** — for one or two variables, the user copies values in
   the desktop app directly. Zero tooling, zero exposure.

Never do: `op environment read` printed to terminal "so the user can copy it",
or written to an unapproved file. That is the unsafe pattern from
`security.md`.

## Workflow: Move An Environment To Another Account

1. Metadata first: list source variable names (`MCP list_variables`).
2. Confirm: target account, target Environment name, and whether the source
   should be deleted after (move) or kept (copy).
3. Check `.1password/environments.json` account binding for the target project
   (see `account-binding.md`).
4. Create the target Environment (MCP `create_environment` against the target
   account).
5. Transfer values via option 1 or 2 above.
6. Verify by names: source list vs target list must match exactly.
7. Re-point consumers: mounted `.env` files, `op run --environment` IDs in
   scripts, service-account Environment scopes, AWS Secrets Manager syncs.
   The Environment ID is new — anything holding the old ID still points at
   the source.
8. Only after verification ask whether to delete the source Environment.
   Deletion is irreversible and breaks integrations still attached to it.

## Workflow: Copy Variables Between Environments

Same as above minus the account hop; commonly "seed staging from production".
Confirm name collisions up front: list both sides, report which names would be
added vs already exist. MCP `append_variables` adds variables — do not blindly
overwrite existing ones without showing the collision list.

## Workflow: Vault Item Field → Environment Variable

For promoting classic vault secrets into Environments:

1. Identify the field by metadata (`op item get ITEM --format json | jq '.fields[].label'`).
2. Confirm variable name and target Environment.
3. Pipe the value process-to-process (raw value access — approval required):
   `op read "op://Vault/Item/field"` feeding the MCP `append_variables` call
   inside a script, `concealed: true`.
4. Verify by name. Ask whether the vault item should remain the source of
   truth (then prefer keeping only one copy and pointing consumers at one
   place) or be archived.

## Workflow: Environment Variable → Vault Item

Reverse direction (e.g. a credential needs item features: sharing, TOTP,
attachments). Use `op item create` fed via template stdin inside the same
process-to-process pattern; never put the value in argv. See
`items-vaults.md` for the template pipe.

## After Any Transfer

Report names moved, source/target Environment names and accounts, consumers
that need re-pointing, and what was deliberately not done (deletions left
pending). No values, lengths, or hashes.
