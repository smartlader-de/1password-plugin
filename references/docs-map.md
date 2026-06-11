# 1Password Documentation Map

> Load this reference to answer any 1Password question not covered by a
> dedicated workflow, or to verify current behavior before acting. Snapshot:
> June 2026.

## How To Get Current Docs

The developer docs live at **www.1password.dev** (the old
`developer.1password.com` URLs 301-redirect there). The site is LLM-friendly:

- `https://www.1password.dev/llms.txt` — curated index of every doc page.
- `https://www.1password.dev/llms-full.txt` — all pages concatenated (large).
- Append `.md` to any page URL to fetch raw markdown, e.g.
  `https://www.1password.dev/environments/overview.md`.

When a question depends on version-specific or beta behavior, fetch the `.md`
page instead of answering from memory. Features marked beta below change
often.

End-user (non-developer) docs remain at `support.1password.com`.

## Documentation Index

### Get started / decision guides
- `/get-started.md` — tool overview and auth methods
- `/get-started/secure-developer-secrets.md` — Environments vs Shell Plugins vs CLI vs SDKs
- `/get-started/secure-deployment.md` — CI/CD, containers, runtime secrets
- `/get-started/secure-ssh-git-workflows.md` — SSH/Git decision guide
- `/get-started/secure-ai-access.md` — AI keys, MCP config, agent auth
- `/get-started/build-integrations.md` — CLI vs SDK integration guide
- `/get-started/manage-organization.md` — programmatic user/group/vault admin
- `/get-started/get-data-and-analytics.md` — reporting and SIEM

### Environments (beta)
- `/environments/overview.md` — create, import, share, manage
- `/environments/local-env-file.md` — mounted `.env` files
- `/environments/read-environment-variables.md` — CLI + SDK reads
- `/environments/agent-hook-validate.md` — agent hook validation
- `/environments/aws-secrets-manager.md` — AWS Secrets Manager sync (beta)
- `/environments/mcp-codex-server.md` — MCP server for Codex (beta)

### CLI
- `/cli/get-started.md`, `/cli/reference.md` — install, auth, command index
- `/cli/reference/management-commands/{item,vault,document,environment,user,group,service-account,connect,events-api,plugin,account}.md`
- `/cli/reference/commands/{read,run,inject,signin,signout,whoami}.md`
- `/cli/secret-reference-syntax.md` — `op://` URI syntax
- `/cli/shell-plugins.md` — biometric auth for third-party CLIs (AWS, GitHub, brew, Claude Code CLI, OpenAI CLI, Terraform, ...)

### SDKs (Go, JavaScript, Python)
- `/sdks/overview.md`, `/sdks/concepts.md` — auth, IDs, field types
- `/sdks/{manage-items,list-vaults-items,load-secrets,files,vault-permissions,environments}.md`
- GitHub: `1Password/onepassword-sdk-{go,js,python}`

### AI & agent security
- `/agentic-autofill.md` — Secure Agentic Autofill (human-in-the-loop credential handoff to browser agents)
- `/agent-hooks.md` — validate 1Password config in Claude Code, Cursor, Copilot, Windsurf
- `/building-with-llms.md` — best practices for building on 1Password with LLMs
- `/environments/mcp-codex-server.md` — local MCP server

### Secrets automation
- `/secrets-automation.md` — service accounts vs Connect comparison
- `/service-accounts/{overview,get-started,rate-limits}.md`
- `/connect/{overview,api-reference}.md` — self-hosted REST API

### Integrations
- `/ci-cd/{github-actions,circle-ci,jenkins}.md`
- `/k8s/integrations.md` — operator, injector, External Secrets
- `/terraform.md`, `/pulumi.md`
- `/vscode.md` — secret detection + reference insertion

### APIs
- `/events-api/{overview,reference}.md` — account activity to SIEM
- `/users-api/overview.md` — Users API for partners (public preview)
- `/partnership-api/reference.md`

### Other
- `/watchtower.md` — Developer Watchtower (plaintext SSH key alerts)
- `/web/add-1password-button-website.md`, `/web/compatible-website-design.md`

## Feature Status Snapshot (June 2026)

| Feature | Status |
|---|---|
| Environments | Beta; desktop app required (Mac/Win/Linux, not mobile); Developer mode must be on |
| `op environment read`, `op run --environment` | Beta CLI ≥ 2.33.0-beta.02 |
| Environments SDK reads (`GetVariables`) | Beta SDK releases (Go/JS/Python ~0.4.1-beta) |
| MCP server | Labs/beta; Mac + Linux; official docs cover Codex; works as a local stdio server for other MCP clients |
| AWS Secrets Manager sync | Beta |
| Agent hooks | Supported: Claude Code, Cursor, GitHub Copilot, Windsurf |
| Secure Agentic Autofill | Shipped 2026 ("Unified Access" launch, March 2026) |
| Users API | Public preview, partner-focused |
| Environments + service accounts | Tokens can be scoped to Environments; check current docs for read support per auth method |

## Roadmap Signals (from 1Password announcements, 2026)

- MCP-based just-in-time credential access extends beyond Codex to other
  coding agents (announced direction, May 2026).
- SDK language coverage expansion is under active survey; Go/JS/Python are the
  supported set today.
- Environments is the strategic surface for developer secrets; classic
  vault-item `.env` workflows are legacy-supported but not where new
  capabilities land.

When the user asks "can 1Password do X yet", fetch `llms.txt` and the relevant
page rather than relying on this snapshot.
