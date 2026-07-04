---
name: 1password
description: Use when routing 1Password credential workflows to setup, environments, vaults-items, cli-auth, or SSH/Git skills, or answering any 1Password developer question
---

# 1password

Router for 1Password credential work. This file loads before every lane below —
its rules apply to all of them.

## Golden rules

- **Always store credentials in 1Password.** Never leave a generated or received
  secret only on disk, in `.env`, or in chat. If you create or receive one, put
  it in 1Password (right container per the decision tree) before finishing.
- **Least privilege.** Request exactly the access the operation needs, when it
  needs it — no broader vault/role/scope to make an error go away. Deep rules in
  `references/security.md`.
- **One authorization window per task.** Plan the full set of reads/writes,
  announce the single expected prompt, then execute it as one batch. Do **not**
  mix CLI and MCP in one **value-access operation** — they are separate auth
  channels, so straddling them doubles the biometric prompts. (Locating a target
  via MCP metadata and then reading one value via CLI is the sole sanctioned
  CLI+MCP hop — see the breadcrumb protocol.)
- **Values never printed, logged, or persisted.** Metadata (names, IDs, status)
  only. Locating a credential is metadata-only; reading a raw *value* is a
  separate, gated step — pipe it straight into the consuming command, never to
  the terminal — and only after the user approves that specific access.

## Decision tree — pick the lane

```
What is the request about?
├─ Project/page environment variables, .env, provider secrets
│     → skills/environments/SKILL.md          (MCP-first; values never reach the agent)
├─ A standalone password / login / API key / document as a vault entry
│     → skills/vaults-items/SKILL.md          (CLI)
├─ SSH key / Git commit signing / SSH server access
│     → skills/ssh-git/SKILL.md               (CLI + 1Password SSH agent)
├─ Securing the API key of a CLI/AI tool itself (claude, openai, aws, gh)
│     → skills/cli-auth/SKILL.md              (Shell Plugins, biometric)
├─ Code you are WRITING (app / server / CI) needs secrets at runtime
│     → references/sdks.md                    (SDK + a scoped service account, not interactive)
└─ First-time setup / "CLI or MCP?" / broken integration
      → skills/setup/SKILL.md
```

Env var vs vault item, in one line: if a **running app loads it from the
environment**, it's the environments lane; if it's a **credential you look up
and use**, it's the vaults-items lane.

**When the lane or destination is unclear, ask before acting:**
- "Is this a vault item (a standalone password/key) or an environment variable
  (loaded by a running app)?"
- "Which vault should this go in?" (offer the vault names, metadata only)
- "That vault doesn't exist — may I create it?"

## Breadcrumb protocol — reach a credential without exploring

The reason CLI access *feels* like snooping is re-discovery: listing every vault
and item to find one secret. Don't. Record where each credential lives once, then
go straight there.

```
Need to reach a known credential?
1. Read .1password/breadcrumbs.json (project-local).
   ├─ Breadcrumb found → go STRAIGHT to it — no listing of other vaults,
   │     items, or environments:
   │     env  → MCP list/mount for that environmentId
   │     item → confirm metadata only: op item get <itemId> --format json |
   │            jq '{title,id,fields:[.fields[].label]}'
   └─ No breadcrumb:
        ├─ MCP available → locate VIA MCP (names only, one unlock). Reading the
        │     value then via one CLI call is the sanctioned CLI+MCP hop, and
        │     only if a raw value is truly needed.
        └─ MCP unavailable → one scoped `op item list --vault X`
              (never `op vault list` unless the vault itself is unknown).
2. After locating OR creating a credential, WRITE its breadcrumb.
3. Read a raw value only when required, and only through the gated pipe pattern
   in `references/security.md` — never print it to the terminal.
```

`.1password/breadcrumbs.json` holds locations only — IDs and names, never values:

```json
{
  "stripe-secret-key": { "kind": "env",  "account": "EXAMPLEACCOUNTID0000000000", "environmentId": "EXAMPLEENVIRONMENTID000000" },
  "example-login":     { "kind": "item", "account": "EXAMPLEACCOUNTID0000000000", "vault": "my-vault", "itemId": "EXAMPLEITEMID000000000000" }
}
```

Keep `.1password/` gitignored (the environments lane already ensures this).

## Prompt economy — hold a task to one biometric prompt

- **Batch reads:** one `op item get --fields a,b,c`, or one `op run --environment`
  — never N separate `op read` calls.
- **One process = one prompt.** The agent's shell does not persist state between
  separate command invocations, so N tool-calls means N sign-ins means N prompts.
  When a CLI task genuinely needs several `op` commands, run them inside a
  **single shell invocation** (one script) so the whole task costs one prompt.
- **Env vars:** mount the `.env` once (authorize once per unlock), then read the
  file — zero further prompts. See `skills/environments/SKILL.md`.
- Announce the single prompt before it fires.

## Anything else

For 1Password topics beyond these lanes (service accounts, Connect, CI/CD,
Events API, agent security), load `references/docs-map.md` and fetch current
docs from www.1password.dev before answering.
