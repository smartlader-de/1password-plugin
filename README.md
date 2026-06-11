# 1password

1Password skill collection for agent-safe credential workflows.

This collection contains four nested skills:

| Skill | Use For |
|---|---|
| `1password:setup` | Guided first-time setup: CLI vs MCP choice with trade-offs, 1Password app settings, access verification, CLAUDE.md wiring |
| `1password:environments` | Project environment variables, `.env` import, provider secret audit/sync, local runtime injection, 1Password MCP setup, moving Environments/variables between Environments and accounts |
| `1password:vaults-items` | Item CRUD, moving/copying items between vaults and accounts, item sharing, Document items, vault management and permissions |
| `1password:ssh-git` | SSH key generation, GitHub/GitLab public-key registration, Git commit signing, SSH server access through the 1Password SSH agent |

A documentation map (`references/docs-map.md`) covers the rest of the
1Password developer surface — SDKs, service accounts, Connect, CI/CD
integrations, Events API, shell plugins — with instructions to fetch current
docs from www.1password.dev (`llms.txt` index, raw-markdown `.md` endpoints).

## Install

### As a Claude Code plugin (recommended)

This repository is a Claude Code plugin (`.claude-plugin/plugin.json`,
version-managed via SemVer, see `CHANGELOG.md`):

```text
/plugin marketplace add smartlader-de/1password-plugin
/plugin install 1password@smartlader
```

Or from a local checkout:

```text
/plugin marketplace add /path/to/1password-plugin
/plugin install 1password@smartlader
```

Skills are auto-discovered from `skills/*/SKILL.md` and namespaced as
`1password:setup`, `1password:environments`, `1password:vaults-items`, and
`1password:ssh-git`. After installing, run `1password:setup`.

### As a plain skill collection

```bash
npx skills add smartlader-de/1password-plugin
```

Manual install:

```bash
cp -r . ~/.claude/skills/1password
```

For Codex or other agents that use an installed skills directory, copy the
folder to the runtime's skills location and load the nested skill that matches
the task. Note: outside the plugin runtime, skill IDs derive from the loader's
conventions; the SKILL.md frontmatter uses bare names (`environments`,
`ssh-git`, ...) which the plugin namespace prefixes with `1password:`.

## Invocation

Use `1password:setup` for:

- first-time configuration after installing the collection
- choosing between CLI, MCP, or both (with pros and cons)
- enabling the right 1Password app settings (Developer mode, CLI integration, MCP server, SSH agent)
- verifying CLI and MCP access
- adding 1Password instructions to a project or global CLAUDE.md

Use `1password:environments` for:

- importing dotenv files into 1Password Environments
- auditing drift between 1Password and Netlify, Cloudflare, or Vercel
- syncing provider secret names and values through guarded workflows
- running local commands with `op run --environment`
- configuring or using the 1Password MCP server
- generating infrastructure secrets into 1Password Environments
- moving or copying Environments and variables between Environments and accounts

Use `1password:vaults-items` for:

- creating, editing, archiving, and deleting vault items
- moving or copying items between vaults and between accounts
- creating time-limited item share links
- storing and retrieving Document items
- vault creation and user/group permission management

Use `1password:ssh-git` for:

- generating SSH keypairs stored in 1Password
- registering public keys with GitHub or GitLab
- configuring Git SSH commit signing
- routing server SSH access through the 1Password SSH agent

The root `SKILL.md` is a routing entrypoint. The actionable instructions live in
`skills/setup/SKILL.md`, `skills/environments/SKILL.md`,
`skills/vaults-items/SKILL.md`, and `skills/ssh-git/SKILL.md`.

## Safety Model

The collection is metadata-first:

- environment workflows report variable names, contexts, and sync status only
- raw secret values are never printed, pasted, logged, hashed, or diffed by default
- private SSH key material is never printed and is not passed as a command-line argument
- public SSH keys may be displayed for provider registration
- provider writes, overwrites, deletes, MCP configuration, vault/item writes, and SSH/Git config changes require explicit confirmation

When 1Password MCP is available, `1password:environments` prefers it for
Environment management because it can perform metadata operations without
returning secret values to the agent.

## Included Files

```text
.claude-plugin/
├── plugin.json          # plugin manifest (name, version)
└── marketplace.json     # marketplace entry for git installs
SKILL.md                 # routing entrypoint (non-plugin runtimes)
CLAUDE.md
AGENTS.md
GEMINI.md
CHANGELOG.md
skills/
├── setup/SKILL.md
├── environments/SKILL.md
├── vaults-items/SKILL.md
└── ssh-git/SKILL.md
references/
scripts/
tests/
```

## Versioning

The plugin follows SemVer. The authoritative version is
`.claude-plugin/plugin.json` and must match `package.json` (enforced by
`tests/plugin-manifest.test.sh`). Current version: **1.0.0**. Changes are
tracked in `CHANGELOG.md`.

## Test

```bash
npm test
```

The test suite validates entrypoint files, nested skill paths, dotenv parsing,
metadata-only name comparison, account-binding checks, and redaction helpers.
