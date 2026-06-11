## Contributor Workflow (read before pushing)

This plugin is public and must work for **any** setup — any OS, any agent CLI
(Claude Code, Codex, Gemini CLI, Cursor, Copilot, ...), any 1Password account
shape. Before pushing anything:

1. Run `npm test`. It includes `tests/genericity.test.sh`, which fails on
   maintainer-specific details: personal names, emails, home paths, private
   project names, or real 1Password account/environment/item IDs.
2. Review new content for setup assumptions: examples use placeholder names
   (`my-app`, `user@example.com`, `EXAMPLE...` IDs); platform-specific
   instructions list alternatives or state the limitation; agent-runtime
   instructions never assume one specific CLI.
3. If a new personal detail slips through review, add a marker line for it to
   `tests/genericity-markers.local` (gitignored — the markers themselves must
   never be published) so it cannot recur.

Internal planning lives in gitignored files (`PRD.md`, `.clavix/`, `docs/`,
`.remember/`) — never commit it.

## 1Password Skills

This collection provides five skills for securely managing credentials through 1Password.

### 1password:setup
Use when handling:
- First-time configuration of this skill collection
- Choosing between CLI and MCP access (pros/cons)
- 1Password app settings (Developer mode, CLI integration, MCP server, SSH agent)
- Verifying CLI or MCP access
- Adding 1Password instructions to CLAUDE.md

Trigger phrase examples:
- "set up the 1password skill"
- "should I use the CLI or the MCP server?"
- "op command not found"
- "1Password MCP tools are missing"

### 1password:environments
Use when handling:
- Project `.env` files or environment variables
- 1Password Environments import, audit, or sync
- Provider secrets (Netlify, Cloudflare, Vercel)
- Local runtime injection via `op run --environment`
- Infrastructure secret creation
- 1Password MCP server setup
- Moving or copying Environments and variables between Environments or accounts

Trigger phrase examples:
- "import this project's .env into 1Password"
- "sync 1Password to Netlify production"
- "check if Cloudflare is in sync"
- "generate a new database password"
- "copy the staging environment to my work account"

### 1password:vaults-items
Use when handling:
- Creating, editing, archiving, or deleting vault items
- Moving or copying items (passwords, logins, API keys) between vaults or accounts
- Item share links
- Document items
- Vault creation, deletion, and user/group permissions

Trigger phrase examples:
- "move these passwords to the shared vault"
- "copy this login to my work account"
- "share this credential with a contractor for 24 hours"
- "give the Developers group access to the Infrastructure vault"

### 1password:ssh-git
Use when handling:
- Generating a new SSH keypair stored in 1Password
- Registering an SSH key with GitHub or GitLab
- Configuring Git commit signing via 1Password SSH key
- Setting up SSH server access via the 1Password SSH agent

Trigger phrase examples:
- "generate an SSH key and store it in 1Password"
- "add my 1Password SSH key to GitHub"
- "sign my commits with 1Password"
- "connect to this server using 1Password SSH"

### 1password:cli-auth
Use when handling:
- Securing API keys for CLI/AI tools themselves (claude, openai, aws, gh) via Shell Plugins
- Replacing plaintext keys in shell profiles or MCP config files
- Biometric auth for developer CLIs
- Browser-agent credential handoff (Secure Agentic Autofill)

Trigger phrase examples:
- "stop storing my OpenAI key in plaintext"
- "biometric auth for my gh CLI"
- "my MCP config has an API key in it"
- "secure my ANTHROPIC_API_KEY"

### Anything else 1Password
For 1Password topics beyond these workflows (SDKs, service accounts, Connect,
CI/CD integrations, Events API, agent security), load
`references/docs-map.md` and fetch current docs from www.1password.dev before
answering.
