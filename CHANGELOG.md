# Changelog

All notable changes to the 1password plugin are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/), versioning: [SemVer](https://semver.org/).
The plugin version lives in `.claude-plugin/plugin.json` and must match `package.json`.

## [1.1.0] - 2026-06-11

Frictionless, least-privilege secrets — plus two modularity moves.

### Added
- Three-mode secret-loading choice in `1password:setup` (Environments /
  secret references / hybrid), persisted per project in the CLAUDE.md snippet.
- Frictionless **Project Onboarding** workflow in `1password:environments`:
  names-only import → mounted FIFO `.env` → optional agent hook
  (`.1password/environments.toml`) → gitignore + names-only verify, targeting
  ≤1 biometric approval.
- New `1password:cli-auth` skill: biometric auth for CLI/AI tool API keys
  (`claude`, `openai`, `aws`, `gh`) via Shell Plugins, and AI-access security
  (keys in MCP config files, Secure Agentic Autofill pointer). Owns
  `shell-plugins.md` and the new `ai-access.md`.
- References: `local-env-mount.md` (mount mechanics, gotchas, fail-open agent
  hook), `provider-sync.md` (audit + sync procedures), `ai-access.md`.
- SSH completion in `1password:ssh-git` / `ssh-agent.md`: `agent.toml` vault
  scoping, six-key server limit, bookmarks, browser-extension public-key
  autofill, key-eligibility rules.
- Capability coverage matrix in `docs-map.md`.

### Changed
- `references/security.md` gains a least-privilege & prompt-economy doctrine
  (NIST least privilege; read scopes for reads, verified writes, batched op
  calls, announced prompts) applied across all skills.
- `1password:environments` router-ized: `SKILL.md` is now a thin dispatcher;
  audit/sync moved to `provider-sync.md`, infra-secret to
  `one-password-environments.md`, transfer routes to `environments-transfer.md`.
- Mounted `.env` is now the documented local-dev default; `op run` is the
  scripted/CI pattern.
- `account-binding.md` documents the `.1password/environments.toml` (hook) vs
  `environments.json` (binding) distinction with a never-cross-write rule.

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
- The 1.1.0 features (three-mode setup, frictionless onboarding,
  least-privilege doctrine, cli-auth skill, SSH agent.toml/bookmarks/autofill)
  shipped — see the [1.1.0] entry above.
