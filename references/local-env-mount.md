# Local Mounted `.env` Files & Agent Hook

> Load this reference for the frictionless local-dev path: a 1Password-mounted
> `.env` plus the optional agent hook. Mac/Linux only. Snapshot: June 2026 —
> mounted `.env` is beta; confirm current behavior at
> `https://www.1password.dev/environments/local-env-file.md` and
> `https://www.1password.dev/environments/agent-hook-validate.md`.

## What A Mounted `.env` Is

1Password mounts a project `.env` as an in-memory FIFO backed by an
Environment. Reading it triggers **one** authorization prompt; after that it
stays readable until 1Password locks. Nothing plaintext lands on disk. It is
compatible with dotenv libraries and Docker Compose, so existing tooling reads
it unchanged.

This is the local-dev default for Environments mode. `op run --environment`
remains the scripted/CI pattern (see `one-password-environments.md`).

## Prerequisites & Limits (state these before mounting)

- **Mac/Linux only.** On Windows, fall back to secret-references mode
  (`secret-references.md`) — do not attempt a mount.
- **Existing git-tracked `.env` must go first.** If `.env` is tracked, delete
  it and commit the deletion before mounting at that path. Verify:
  `git ls-files --error-unmatch .env` (exit 0 = still tracked).
- **Max 10 enabled mounts per device.** Check existing mounts before adding.
- **No concurrent readers.** If an IDE or extension holds the FIFO open, the
  dev server's read blocks. Tell the user to close other readers if startup
  hangs.

## Mount Flow

1. Confirm the Environment exists (metadata only) and the project is bound to
   the right account — load `account-binding.md` first.
2. Announce the prompt: "you'll get one approval to mount `.env`; nothing else
   this session."
3. Create the mount via 1Password MCP (preferred) or the desktop app, mapping
   the Environment to the project `.env` path. Confirm the exact MCP call /
   menu path against `local-env-file.md` on www.1password.dev — mount tooling
   is beta; feature-detect, do not assume a fixed command name.
4. Add the mount path to `.gitignore` and verify: `git check-ignore .env`.
5. Verify the mount by names only — the dev server starts and the expected
   variable *names* are present. Never print values to confirm.

## Agent Hook (optional)

The official 1Password agent hook reads `.1password/environments.toml` and
blocks the agent from running project commands until the declared mounts are
live. It is **fail-open**: if 1Password is unavailable, commands proceed. Say
this honestly — it is a guardrail, not a hard gate.

Requirements: `sqlite3` in PATH and Mac/Linux. Detect with
`command -v sqlite3`; if missing, skip the hook and note why.

Install the hook for the user's agent (Claude Code, Cursor, GitHub Copilot,
Windsurf marketplace plugin) per `https://www.1password.dev/agent-hooks.md`,
then author the project config:

```toml
# .1password/environments.toml — read by the official 1Password agent hook.
# Declares which mounts must be live before the agent runs commands.
mount_paths = [".env"]
```

Confirm with the user before installing the hook or writing this file.

## Do Not Confuse The Two `.1password/` Files

- `.1password/environments.toml` — official agent hook config; holds
  `mount_paths`. Written only by this onboarding flow / the hook.
- `.1password/environments.json` — this skill's account-binding metadata (see
  `account-binding.md`). Holds account/Environment IDs, never `mount_paths`.

Never write `mount_paths` into the JSON, and never write binding data into the
TOML.
