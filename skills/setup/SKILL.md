---
name: setup
version: 1.0.0
description: Use when installing, configuring, or onboarding the 1password skill collection - choosing between CLI and MCP access, enabling the right 1Password app settings, verifying access, and wiring instructions into CLAUDE.md
---

# 1password:setup

Guided first-time setup for the 1password skill collection. Interview-driven:
detect what already works, explain the options, let the user choose, verify,
then wire the skill into the user's agent instructions.

## When To Use

Use this skill when a user asks to:

- Set up or configure the 1password skill after installing it.
- Decide between 1Password CLI and 1Password MCP access.
- Fix a broken or partial 1Password integration ("op not found", "MCP tools missing").
- Add 1Password guidance to their CLAUDE.md.

## Core Flow

Run the steps in order. Never change 1Password app settings yourself — they
require the desktop app UI; guide the user and verify afterwards.

### Step 1: Detect Current State

Check silently first, then show the user a status summary before asking
anything:

```bash
# Desktop app (macOS)
test -d "/Applications/1Password.app" && echo "app: installed" || echo "app: missing"

# CLI
command -v op >/dev/null && op --version || echo "cli: missing"
op whoami 2>/dev/null && echo "cli auth: ok" || echo "cli auth: not signed in"

# Environments support in this CLI build
op environment read --help >/dev/null 2>&1 && echo "cli environments: supported" || echo "cli environments: not in this build"

# MCP binary (macOS)
test -x "/Applications/1Password.app/Contents/MacOS/onepassword-mcp" && echo "mcp binary: present" || echo "mcp binary: missing"
```

Also check whether 1Password MCP tools are already visible in the current
agent session. Present the results as a short table: app, CLI, CLI auth,
Environments support, MCP binary, MCP tools in session.

### Step 2: Choose Access Path

Ask the user: CLI, MCP, or both. Lay out the trade-offs honestly:

| | 1Password MCP | 1Password CLI (`op`) |
|---|---|---|
| Secret exposure | Values never reach the agent — metadata tools plus desktop approval prompts | Values *can* reach the agent; safety depends on the guarded workflows in these skills |
| Coverage | Environments only: create, list names, mounted `.env` files | Full surface: items, vaults, documents, users, SSH, service accounts, Connect |
| Maturity | Beta (1Password Labs), Mac and Linux only | Stable, all platforms; Environments commands need the beta CLI build |
| Requirements | Desktop app running and unlocked; per-client registration | Desktop app integration for biometric auth, or service account token for headless |
| Best for | Agent-managed environment variables | Vault items, moves between vaults, SSH/Git, automation |

Recommendation to present: **both** — MCP as the default path for
`1password:environments`, CLI for `1password:vaults-items` and
`1password:ssh-git`. MCP-only is fine if the user only cares about env vars;
CLI-only works everywhere but every secret-touching operation needs the
guarded fallback gates.

Separate offer while the CLI is being set up: if the user keeps API keys for
CLI tools (`claude`, `openai`, `aws`, `gh`) in shell profiles or plaintext
configs, 1Password Shell Plugins can replace those with biometric auth — load
`../../references/shell-plugins.md`. This is about the tools' own
credentials, independent of the project-secrets choice above.

### Step 3: 1Password App Settings

Walk the user through the desktop app (they click, you verify):

1. **Developer mode** (required for Environments and the CLI integration):
   Settings → Developer → turn on **Show 1Password Developer experience**.
2. **CLI integration** (biometric unlock for `op`):
   Settings → Developer → **Integrate with 1Password CLI**.
3. **MCP server** (only if MCP was chosen):
   Settings → Labs → **Enable local MCP server**, then
   Settings → Developer → **Integrate with MCP clients**.
   Business accounts: an admin may need to allow this under
   Policies → Agentic permissions → Local MCP server.
4. **SSH agent** (optional, only if the user wants `1password:ssh-git`):
   Settings → Developer → **Use the SSH agent**.

These are beta-era menu paths; if a setting is missing, load
`../../references/docs-map.md` and fetch the current docs instead of guessing.

### Step 4: Verify CLI Access

If the CLI path was chosen:

1. Install if missing — macOS: `brew install 1password-cli`; other platforms:
   point at https://www.1password.dev/cli/get-started.
2. `op --version`, then `op whoami`. First run triggers the desktop approval
   prompt — tell the user to expect it.
3. Verify metadata-only: `op vault list`. Never demonstrate access by reading
   a value.
4. If the user wants Environments via CLI, feature-detect
   (`op environment read --help`) and mention the beta build channel if
   unsupported.

### Step 5: Verify MCP Access

If the MCP path was chosen, load `../../references/mcp-setup.md` and
`../../references/mcp-quickstart.md`. Registration is per-runtime (Claude Code
settings, Codex `~/.codex/config.toml`) and usually needs a session restart —
ask before editing any agent config. Verify with `authenticate` followed by a
metadata-only `list_environments`. If a call hangs, a desktop approval prompt
is waiting — say so instead of retrying.

### Step 6: Ask How They Want To Work

Ask the user three preference questions and respect the answers for the rest
of the session (and bake them into the CLAUDE.md snippet in step 7):

1. **Strictness** — metadata-only always (default), or allow guarded raw-value
   access with per-case approval?
2. **Default account** — if `op account list` shows more than one, which
   account should these skills bind to by default?
3. **Environment naming** — confirm the `project/context` convention
   (`myapp/production`) or record their preferred scheme.

### Step 7: Wire Into CLAUDE.md

Detect where the skill collection is installed (e.g. `~/.claude/skills/`,
`~/.agents/skills/`, or a project-local `.claude/skills/`):

- **Global install** → offer to add the snippet to `~/.claude/CLAUDE.md`.
- **Project-local install** → offer to add it to the project's `CLAUDE.md`.
  Also mention — once, without pressure — that adding the snippet globally
  wouldn't hurt: the safety rules then protect every project, not just this
  one. If they decline, drop it.

Show the snippet before writing and adapt it to their step 6 answers:

```markdown
## 1Password Skills

When handling project environment variables, `.env` files, provider secrets,
or secret sync/audit/import work, use the `1password:environments` skill
before taking action.

For vault items — creating, editing, moving between vaults or accounts,
sharing — use `1password:vaults-items`. For SSH keys, Git signing, or SSH
server access, use `1password:ssh-git`.

Default to metadata-only workflows: variable names, contexts, and status.
Do not print, log, persist, or diff raw secret values unless explicitly
approved. Ask before raw value access, provider writes, deletes, moves
between vaults, share links, or MCP configuration.
```

Never overwrite existing 1Password sections — if one exists, show a diff of
what would change and ask.

### Step 8: Summarize

Close with a status checklist: access paths configured, app settings
confirmed, verification results, recorded preferences, and where instructions
were written. Suggest a first real task (for example "import this project's
`.env`") as the smoke test.

## If The User Declines Everything

That's fine. Leave the system untouched, summarize what would be needed later,
and point out that the skills will still work in degraded, ask-every-time mode.
