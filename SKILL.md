---
name: 1password
description: Use when routing 1Password credential workflows to setup, environments, vaults-items, cli-auth, or SSH/Git skills, or answering any 1Password developer question
---

# 1password

1Password skills collection.

Use `skills/setup/SKILL.md` for first-time setup: choosing CLI/MCP access,
1Password app settings, access verification, and CLAUDE.md wiring.

Use `skills/environments/SKILL.md` for project environment variables,
provider secrets, local runtime secrets, 1Password Environments (including
moving Environments and variables between Environments and accounts), and MCP
setup.

Use `skills/vaults-items/SKILL.md` for vault and item management: creating and
editing items, moving or copying items between vaults or accounts, item
sharing, Document items, vault CRUD, and vault permissions.

Use `skills/ssh-git/SKILL.md` for SSH key generation, provider public-key
registration, Git commit signing, and SSH server access through the 1Password
SSH agent.

Use `skills/cli-auth/SKILL.md` for securing the credentials CLI and AI tools
themselves use — API keys for `claude`, `openai`, `aws`, `gh` via 1Password
Shell Plugins and biometric auth, plus AI-access security (keys in MCP configs,
browser-agent autofill).

For any other 1Password developer topic (SDKs, service accounts, Connect,
CI/CD integrations, Events API, agent security), load
`references/docs-map.md` and fetch current docs from www.1password.dev.
