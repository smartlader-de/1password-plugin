# Changelog

All notable changes to the 1password plugin are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/), versioning: [SemVer](https://semver.org/).
The plugin version lives in `.claude-plugin/plugin.json` and must match `package.json`.

## [1.0.0] - 2026-06-11

First release as a Claude Code plugin.

### Added
- Plugin packaging: `.claude-plugin/plugin.json` manifest and
  `.claude-plugin/marketplace.json` for git-based installs. Skills are
  auto-discovered from `skills/*/SKILL.md` and namespaced as
  `1password:<skill>`.
- `1password:setup` — guided onboarding: state detection, CLI vs MCP choice
  with trade-offs, 1Password app settings walkthrough, access verification,
  working-style preferences, CLAUDE.md wiring.
- `1password:environments` — `.env` import, provider audit/sync (Netlify,
  Cloudflare, Vercel), local runtime injection, MCP-first Environment
  management, infrastructure secret creation, Environment/variable transfer
  between Environments and accounts.
- `1password:vaults-items` — item CRUD, moving/copying items between vaults
  and accounts (with item-ID-change semantics), item share links, Document
  items, vault CRUD and user/group permissions.
- `1password:ssh-git` — SSH key generation into 1Password, GitHub/GitLab
  registration, Git commit signing, SSH server access via the 1Password SSH
  agent.
- Expert references: docs map for www.1password.dev (llms.txt + raw `.md`
  endpoints), items/vaults CLI reference, secret references, shell plugins
  (biometric auth for third-party CLIs incl. Claude Code), service accounts
  and Connect, SDKs, Environment transfer playbooks, MCP setup and
  quickstart, account binding, provider guides, security rules.
- Developer Watchtower hygiene check in `ssh-git` (plaintext key / outdated
  crypto alerts after key workflows).
- Test suite: entrypoints, skill paths (including reference-link
  integrity), plugin manifest validation, dotenv parsing, name comparison,
  account binding, output redaction.

### Notes
- Metadata-first safety model throughout: secret values never reach the
  agent by default; writes, moves, deletes, shares, and raw value access
  require explicit confirmation.
- Planned for 1.1.0 (see ROADMAP.md): three-mode secret-loading choice at
  setup, frictionless project onboarding with mounted `.env` files and
  agent-hook validation, least-privilege/prompt-economy doctrine, SSH
  agent.toml/bookmarks/autofill coverage.
