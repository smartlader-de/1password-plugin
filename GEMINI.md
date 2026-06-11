## 1Password Skills

Five skills for securely managing credentials through 1Password.

This Gemini CLI extension bundles slash commands in `commands/1password/` and
Agent Skills in `skills/*/SKILL.md`. For 1Password tasks, use the matching
command or load the matching bundled skill and follow its workflow before
taking action.

Available commands and skills:
- `1password:setup` — guided first-time setup, CLI/MCP choice, app settings, access checks, CLAUDE.md wiring
- `1password:environments` — secrets, environment variables, provider sync, Environment transfers
- `1password:vaults-items` — item CRUD, cross-vault/account moves, sharing, vault permissions
- `1password:ssh-git` — SSH keys, Git signing, server access
- `1password:cli-auth` — biometric auth for CLI/AI tool API keys (Shell Plugins), AI-access security

For any other 1Password developer topic, load `references/docs-map.md` and
fetch current docs from www.1password.dev.

If the task spans multiple workflows, start with root `SKILL.md`; it routes to
the nested skill that should be followed.
