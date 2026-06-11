# 1password — agent-safe credential workflows

An OpenCode, Claude Code, Codex, and Cursor plugin (and cross-agent skill
collection) that teaches your coding agent to work with 1Password **without
ever seeing your secrets**.

Your agent can import `.env` files into 1Password Environments, keep Netlify /
Cloudflare / Vercel secrets in sync, run your dev server with injected
credentials, move passwords between vaults and accounts, generate SSH keys,
sign your Git commits — while raw secret values stay inside 1Password. The
agent works with variable *names*, contexts, and status; values flow
process-to-process (1Password → your app), never through the chat.

**Try prompts like:**

> "Import this project's .env into 1Password"
> "Check if my Netlify env vars are in sync with 1Password"
> "Move these API keys from my personal vault to the team vault"
> "Copy the staging environment to my work account"
> "Generate an SSH key, store it in 1Password, and add it to GitHub"
> "Sign my commits with 1Password"

## What's Inside

Five skills, routed automatically by what you ask:

| Skill | Use for |
|---|---|
| `1password:setup` | Guided first-time setup: CLI vs MCP choice with trade-offs, 1Password app settings, access verification, agent-instruction wiring |
| `1password:environments` | `.env` import, provider secret audit/sync, local runtime injection (`op run`), 1Password MCP, infrastructure secret creation, moving Environments/variables between Environments and accounts |
| `1password:vaults-items` | Item create/edit/archive/delete, moving/copying items between vaults and accounts, time-limited share links, Document items, vault permissions |
| `1password:ssh-git` | SSH key generation into 1Password, GitHub/GitLab key registration, Git commit signing, server SSH via the 1Password SSH agent |
| `1password:cli-auth` | Biometric auth for CLI/AI tool API keys (claude, openai, aws, gh) via 1Password Shell Plugins; AI-access security (MCP-config keys, browser-agent autofill) |

Plus expert references the skills load on demand: a live documentation map for
www.1password.dev, `op` CLI item/vault reference, secret references
(`op://` URIs), shell plugins (biometric auth for `claude`, `openai`, `aws`,
`gh`, and 60+ other CLIs), service accounts and Connect, SDKs, and Environment
transfer playbooks.

## Requirements

- A [1Password account](https://1password.com/pricing/password-manager) and the
  desktop app (Mac, Windows, or Linux)
- Optional but recommended: [1Password CLI](https://www.1password.dev/cli/get-started)
  (`brew install 1password-cli` on macOS) and/or the 1Password MCP server
  (beta, Mac/Linux)

Don't worry about getting this right up front — `1password:setup` detects what
you have, explains the options, and walks you through the rest.

## Install

### Claude Code (plugin — recommended)

Paste into Claude Code:

```text
/plugin marketplace add smartlader-de/1password-plugin
```

```text
/plugin install 1password@smartlader
```

From a local checkout instead: `/plugin marketplace add /path/to/1password-plugin`.

### OpenCode (native plugin)

After this package is published, add it to `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["1password"]
}
```

From a local checkout, symlink or copy the checkout into an OpenCode plugin
directory, then list it in `opencode.json`:

```bash
mkdir -p .opencode/plugins
ln -s /path/to/1password-plugin .opencode/plugins/1password
```

OpenCode also supports global plugins from `~/.config/opencode/plugins/`.
Restart OpenCode after changing plugin configuration.

The native plugin registers these tools:

| OpenCode tool | Loads |
|---|---|
| `skills_1password` | Root skill router |
| `skills_1password_setup` | `1password:setup` |
| `skills_1password_environments` | `1password:environments` |
| `skills_1password_vaults_items` | `1password:vaults-items` |
| `skills_1password_ssh_git` | `1password:ssh-git` |

If you prefer generic skill discovery instead of the native plugin, install the
community `opencode-skills` plugin and copy this repository to
`.opencode/skills/1password` or `~/.config/opencode/skills/1password`.

### Cursor (plugin)

Cursor discovers this repository as a plugin through `.cursor-plugin/plugin.json`.
The plugin bundles Cursor rules plus the same five skills in `skills/*/SKILL.md`.

Install it as a Cursor plugin from the repository or a local checkout using
Cursor's plugin flow. After installation, ask Cursor:

> "Set up the 1password skill"

Cursor MCP setup is intentionally guided instead of bundled as an active
`mcp.json`: 1Password MCP depends on local 1Password app settings and explicit
approval. The setup skill will walk you through Cursor Settings → Features →
MCP when MCP is the right path.

### Any agent CLI (Codex, Copilot, Gemini, OpenCode, ...)

The [`skills` CLI](https://github.com/vercel-labs/skills) detects your
installed agents and routes the skills to each. Paste into your terminal:

```bash
npx skills add smartlader-de/1password-plugin
```

Target specific agents with `-a` (for example `-a claude-code -a codex`), or a
single skill with `--skill environments`.

### Codex CLI (manual)

Codex loads skills from `~/.codex/skills/` (or `.codex/skills/` per project).
Paste into your terminal:

```bash
git clone https://github.com/smartlader-de/1password-plugin ~/.codex/skills/1password
```

Restart Codex; the root `SKILL.md` routes to the nested skills.

### Codex plugin surface

`1password-codex/` is the compact Codex plugin surface used for Plugin Eval
and Codex plugin metadata. It contains wrapper skills that load the canonical
skills in this repository, so evaluate that directory instead of the repository
root:

```bash
plugin-eval analyze ./1password-codex --format markdown
```

### Gemini CLI (extension)

Gemini CLI installs this repository as an extension through
`gemini-extension.json`. Paste into your terminal:

```bash
gemini extensions install https://github.com/smartlader-de/1password-plugin
```

For local development from a checkout:

```bash
gemini extensions link .
```

Manual fallback: Gemini also loads skills from `~/.gemini/skills/` (or
`.gemini/skills/` per project). If you cannot use extensions, clone the skill
collection directly:

```bash
git clone https://github.com/smartlader-de/1password-plugin ~/.gemini/skills/1password
```

### Anything else

SKILL.md is an open, cross-agent format. Copy this repository into your
agent's skills directory and keep the folder structure intact (nested skills
reference shared files via relative paths):

```bash
git clone https://github.com/smartlader-de/1password-plugin /path/to/your/skills/1password
```

`AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` are ready-made entrypoint notes for
the respective runtimes; `agents/openai.yaml` is an agent definition for
OpenAI-style agent configs.

## Quick Start

After installing, say:

> "Set up the 1password skill"

Setup detects your current state (app, CLI, MCP), explains **CLI vs MCP** with
honest trade-offs, walks you through the right 1Password app settings
(Developer mode, CLI integration, MCP server, SSH agent), verifies access
without reading any values, asks how you want to work, and offers to wire the
skill into your project or global agent instructions.

Then try a real task, for example: *"import this project's .env into
1Password and run the dev server with it"*.

## Safety Model

Metadata-first, deny-by-default:

- Raw secret values are never printed, pasted, logged, hashed, or diffed by
  default. Workflows report variable **names**, contexts, and sync status only.
- When values must move (imports, transfers, provider sync), they flow
  process-to-process — `op run` subprocess injection, stdin pipes between `op`
  commands — never through the agent transcript.
- Private SSH key material never touches disk outside a locked-down temporary
  directory that is deleted immediately after import; it is never printed or
  passed as a command-line argument.
- Every write asks first: provider writes/overwrites/deletes, vault and item
  changes, moves between vaults or accounts, share links, permission grants,
  MCP configuration, and SSH/Git config changes all require explicit
  confirmation — and are verified afterwards by names/status only.
- When the 1Password MCP server is available, Environment management prefers
  it: MCP performs metadata operations without returning secret values to the
  agent at all.

## Repository Layout

```text
.claude-plugin/
├── plugin.json          # Claude Code plugin manifest (SemVer source of truth)
└── marketplace.json     # Claude Code marketplace entry for git installs
.cursor-plugin/
└── plugin.json          # Cursor plugin manifest
1password-codex/
├── .codex-plugin/plugin.json  # Codex plugin manifest
└── skills/              # compact wrappers around canonical skills
gemini-extension.json    # Gemini CLI extension manifest
opencode/index.mjs       # native OpenCode plugin entrypoint
SKILL.md                 # routing entrypoint (non-plugin runtimes)
CLAUDE.md / AGENTS.md / GEMINI.md   # runtime entrypoint notes
agents/openai.yaml       # OpenAI-style agent definition
CHANGELOG.md
commands/                # Gemini CLI slash command wrappers
rules/                   # Cursor .mdc rules
skills/
├── setup/SKILL.md
├── environments/SKILL.md
├── vaults-items/SKILL.md
├── ssh-git/SKILL.md
└── cli-auth/SKILL.md
references/              # on-demand expert references (docs map, CLI, SDKs, ...)
scripts/                 # metadata-safe helpers (dotenv name parsing, diffing, redaction)
tests/
```

## Versioning

SemVer. The authoritative version is `package.json`; plugin manifests and
skill frontmatter keep static copies synced by `npm run sync:version`
(enforced by tests). Current version: **1.1.0** — see `CHANGELOG.md` and the
[releases](https://github.com/smartlader-de/1password-plugin/releases).

## Development

```bash
npm test
```

The suite validates entrypoints, skill/reference path integrity, Claude,
Codex, Cursor, Gemini, and OpenCode plugin manifests/tool registration, dotenv
parsing, metadata-only name comparison, account-binding checks, output
redaction — and a **genericity gate** that fails if setup-specific details
(personal paths, emails, real account IDs) ever land in shipped files. See
`CLAUDE.md` for the contributor workflow.

## License

[MIT](LICENSE)
