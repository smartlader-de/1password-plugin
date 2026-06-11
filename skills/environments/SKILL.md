---
name: environments
version: 1.1.0
description: Use when managing project environment variables, provider secrets, or local runtime secrets through 1Password Environments, 1Password MCP, or guarded op CLI workflows - including moving or copying Environments and variables between Environments and accounts
---

# 1password:environments

Manage project environment variables through 1Password Environments. MCP-first. Values never reach the agent by default.

## When To Use

Use this skill when a user asks to:

- Import `.env` files or project secrets into 1Password.
- Check whether 1Password and a deployment provider are in sync.
- Push secrets from 1Password to Netlify or Cloudflare.
- Set up local development so secrets come from 1Password at runtime.
- Understand or configure the 1Password MCP server for secret management.
- Generate new credentials during infrastructure or service setup.
- Move or copy an Environment to another account, copy variables between
  Environments, or move secrets between vault items and Environments.

Do not use this skill for vault/item management (moving passwords between
vaults, item sharing, vault permissions) — use `1password:vaults-items`.
Secret rotation is deferred.

## Core Workflow

Follow this order every time:

1. Classify intent: setup, import, audit, sync, local runtime, transfer, or fallback.
2. Load `../../references/security.md`.
3. Detect 1Password MCP availability.
4. If MCP is missing, recommend MCP setup before any value-based CLI fallback.
5. Determine source, destination, provider, and context.
6. Load `../../references/account-binding.md` and check project-local account binding
   after MCP authentication, before any Environment write.
7. Run metadata-only comparison first: names, contexts, and status only.
8. Ask for explicit confirmation before production writes, overwrites, deletes, rotations, MCP configuration, or raw value access.
9. Execute the chosen workflow.
10. Verify by names, contexts, and status only.
11. Summarize without secrets.

## Project Onboarding (Least-Friction Path)

Use this when the user says "make this project's secrets work." Goal: a working
dev server with **≤1 biometric approval and ≤3 confirmations** (import plan,
mount path, hook install). Only for Environments or hybrid mode; in
secret-references mode, skip mounting and use `op run --env-file` with `op://`
references instead.

1. **Import names-only.** Detect `.env*` files, run the Import Workflow to
   create an Environment named `project/context`. Confirmation #1: the import
   plan (names only).
2. **Mount the `.env`.** Configure a locally mounted FIFO `.env` as the
   local-dev destination — one authorization, readable until 1Password locks,
   nothing plaintext on disk. Load `../../references/local-env-mount.md` for
   the mount flow and the documented gotchas (git-tracked `.env` deleted and
   committed first; max 10 mounts; no concurrent readers; Mac/Linux only — on
   Windows fall back to secret-references mode). Confirmation #2: the mount
   path. This is the single biometric approval.
3. **Offer the agent hook.** Optionally install the official 1Password agent
   hook and author `.1password/environments.toml` with the project's
   `mount_paths` so the agent is blocked from running commands before mounts
   are live (fail-open: if 1Password is down, commands proceed). Needs
   `sqlite3` + Mac/Linux. Confirmation #3: hook install. Details in
   `../../references/local-env-mount.md`.
4. **Hygiene + verify.** Ensure `.env` and `.1password/` are gitignored
   (`git check-ignore`), then verify by variable *names* only — never print
   values. Summarize names imported, mount path, and hook status.

Announce expected prompts before each step (prompt economy — see
`../../references/security.md`).

## MCP Detection

Check in this order:

1. Are 1Password MCP tools available in this agent session?
2. Does the local MCP binary exist, such as `/Applications/1Password.app/Contents/MacOS/onepassword-mcp` on macOS?
3. Is Codex configured to launch that MCP server?
4. If MCP tools are not in this session, load `../../references/mcp-quickstart.md` for registration and bootstrap instructions before proceeding.

If MCP is missing, offer setup. Do not proceed to CLI fallback until setup is declined or unavailable.

Load `../../references/mcp-setup.md` for setup details.

## Account Binding Guard

When MCP authentication succeeds, treat the returned `account_id` as the only
valid account for the current session. Before imports, syncs, mounted files, or
secret creation, load `../../references/account-binding.md` and compare that
`account_id` against `.1password/environments.json` when it exists.

If the saved account differs from the authenticated account, stop before writes
and tell the user that authentication worked but the project is bound to a
different 1Password account. Do not retry MCP operations in a loop. Ask the
user to switch accounts or explicitly approve rebinding after metadata-only
Environment discovery.

## Access Path Priority

1. 1Password MCP for Environment management and metadata-only workflows.
   > Note: In Codex sessions, MCP tools require a `config.toml` entry and session restart. See `../../references/mcp-quickstart.md`.
2. `op run --environment` for subprocess runtime injection when supported.
3. `op environment read` only as guarded raw-value fallback.
4. `op run --env-file` with `op://` references for classic compatibility.
5. Classic vault/item workflows only with explicit approval.
6. Manual desktop workflow when automation is unavailable.

Always feature-detect CLI support. Do not assume the installed `op` version supports Environments.

Load `../../references/one-password-environments.md` for storage model and CLI guidance.

## Import Workflow

For importing project `.env` files into 1Password:

1. Run `node ../../scripts/parse-dotenv.js <file...>` to extract names only
   (`.env`, `.env.local`, `.env.production`, provider variants).
2. Infer target Environment names from project name and file suffix
   (`project/context`).
3. Present a proposed import plan — file names, target Environment names, and
   variable names only — and confirm before proceeding.
4. Prefer MCP import or guided desktop import; CLI fallback only with explicit
   approval. See `../../references/one-password-environments.md` (Import
   Guidance) for details.

## Audit Workflow

For drift checks between 1Password and a provider, load
`../../references/provider-sync.md` and follow its Audit procedure (metadata
only; `node ../../scripts/compare-env-names.js`). Provider specifics:
`../../references/netlify.md`, `../../references/cloudflare.md`,
`../../references/vercel.md`.

## Provider Sync Workflow

For pushing 1Password secrets to a provider, load
`../../references/provider-sync.md` and follow its Sync procedure: audit first,
confirm the diff, announce the approval prompt, prefer one
`op run --environment` injection, verify every write by names afterward.

## Local Runtime Workflow

1. Default (Environments/hybrid mode): a 1Password-mounted `.env` — authorize
   once per unlock, dotenv-compatible. Load
   `../../references/local-env-mount.md`. Announce the single approval prompt.
2. Scripted/CI or when no mount is wanted: `op run --environment ENV_ID --
   your-command` — one injection, not N reads.
3. Classic compatibility (secret-references mode): `op run --env-file .env --
   your-command` with `op://` references.

Always ensure generated or mounted dotenv paths are in `.gitignore`. Do not
update project scripts without user confirmation.

## Infrastructure Secret Creation Workflow

When generating new secrets during infrastructure setup, load
`../../references/one-password-environments.md` (Infrastructure Secret
Creation) — generate locally, pipe to MCP `append_variables` with
`concealed: true`, inject via `op run`, never print values.

## Transfer Workflow

For moving or copying an Environment to another account, copying variables
between Environments, or moving secrets between vault items and Environments,
load `../../references/environments-transfer.md` and follow it — it holds the
full procedure (clarify account vs Environment vs vault item; list names
metadata-only; prefer the desktop-guided value path; verify by names; re-point
consumers; ask about deleting the source only after verification).

## CLI Fallback

If MCP is unavailable and the user declines setup, say:

```text
1Password MCP is not available. I can use a guarded CLI fallback, but this may require raw value access. Do you approve?
```

Never read values without explicit approval. Pipe displayed command output through `../../scripts/redact-output.sh`, but remember redaction is only defense in depth.

## Scripts

| Script | Purpose | Usage |
|---|---|---|
| `../../scripts/parse-dotenv.js` | Extract variable names from dotenv files | `node ../../scripts/parse-dotenv.js .env .env.local` |
| `../../scripts/compare-env-names.js` | Compare two name sets | `node ../../scripts/compare-env-names.js source.json target.json` |
| `../../scripts/check-account-binding.js` | Stop on saved-account mismatch before writes | `node ../../scripts/check-account-binding.js --account-id ACCOUNT_ID --environment-name project/production` |
| `../../scripts/redact-output.sh` | Redact common token patterns from output | `some-command | bash ../../scripts/redact-output.sh` |

## Beyond This Skill

- Vault and item operations (moves between vaults, sharing, permissions):
  `1password:vaults-items`.
- AWS Secrets Manager sync exists as a native beta destination in the desktop
  app (Environment > Destinations). Prefer it over hand-rolled AWS sync; fetch
  current docs via `../../references/docs-map.md`.
- Service accounts, Connect, CI/CD and Kubernetes integrations:
  `../../references/service-accounts-connect.md`.
- `op://` secret reference syntax and `op read`/`op inject` patterns:
  `../../references/secret-references.md`.
- API keys for third-party CLI tools themselves (`claude`, `openai`, `aws`,
  `gh`, ...) are not project env vars — use Shell Plugins:
  `../../references/shell-plugins.md`.
- Any other 1Password developer topic: `../../references/docs-map.md` — fetch
  current docs from www.1password.dev before answering.

## Not Supported

- Provider-specific variable renaming
- Vercel, Supabase, or CI adapters
- Secret rotation
- Reverse sync from provider to 1Password
- Value hash comparison
