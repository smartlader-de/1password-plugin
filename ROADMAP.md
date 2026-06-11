# Roadmap

Plugin versioning follows SemVer; the authoritative version is
`.claude-plugin/plugin.json`. Everything from "Full 1Password Surface
Coverage" up to and including the "Frictionless, least-privilege secrets"
block below shipped in **plugin 1.1.0** (the pre-plugin internal milestones
V1.1/V1.2 are kept for history). See `CHANGELOG.md`.

## 1.1.0 (shipped)

Frictionless, least-privilege secrets:

- Three-mode secret-loading choice in setup: Environments, secret references,
  or hybrid — persisted per project.
- Frictionless project onboarding: import → mounted FIFO `.env` → agent hook
  + `.1password/environments.toml` → verify, targeting ≤1 biometric approval.
- Least-privilege / prompt-economy doctrine across all workflows (read scopes
  for reads, read+write only for writes with post-write verification, batched
  op calls, announced prompts).
- SSH completion: `agent.toml` scoping, six-key limit, bookmarks, public-key
  autofill, key eligibility rules.
- Resolve `.1password/environments.toml` vs `environments.json` naming
  collision.
- AI access security: Shell Plugins surfaced in setup/onboarding for AI CLI
  keys, Secure AI Access guide in the setup interview, Secure Agentic
  Autofill pointer for browser agents.

## V1.2 (shipped in plugin 1.0.0)

### Full 1Password Surface Coverage

- New `1password:vaults-items` skill: item CRUD, moving/copying items between
  vaults and accounts (`op item move` semantics including ID change), item
  share links, Document items, vault CRUD, user/group vault permissions.
- Environment transfer workflows: move/copy Environments between accounts,
  copy variables between Environments, move secrets between vault items and
  Environments (`references/environments-transfer.md`).
- Expert references: `docs-map.md` (www.1password.dev index with llms.txt and
  `.md` fetch instructions), `items-vaults.md`, `secret-references.md`,
  `service-accounts-connect.md`, `sdks.md`.
- New `1password:setup` skill: guided onboarding — detect current state,
  CLI vs MCP choice with trade-offs, 1Password app settings walkthrough,
  access verification, working-style preferences, CLAUDE.md wiring (project
  or global).

## Next

### AWS Secrets Manager Sync Workflow

1Password ships a native AWS Secrets Manager destination for Environments
(beta). Add a guided workflow once the feature stabilizes: configure the
destination, audit drift between 1Password and AWS by name only.

### Secret Rotation

Still deferred. Revisit when 1Password exposes rotation primitives via MCP or
CLI; until then rotation is generate-new + update-consumers via existing
workflows.

## V1.1

### Project-Local Account Binding

Add a gitignored `.1password/environments.json` metadata file that records the
expected 1Password account and Environment for each project/context.

This prevents prompt loops and wrong-account writes when MCP authentication
succeeds against a different 1Password account than the one originally used for
the project.

Rules:

- Store metadata only: account IDs, Environment names, Environment IDs, and
  context labels.
- Never store variable values, hashes, lengths, vault item IDs, or classic vault
  references.
- Check the binding after MCP authentication and before any Environment write.
- On mismatch, stop before writes and ask the user to switch accounts or approve
  metadata-only rebinding.

## Post-MVP

### Provider Variable Mapping

Support an optional project-level mapping file, for example `secrets.map.json`, for provider-specific variable renames.

MVP should require exact variable-name matches between 1Password Environments and provider destinations. Mapping support can be added later after the MCP-first import, audit, and sync workflows are reliable.

Example future use case:

```json
{
  "production": {
    "DATABASE_URL": {
      "netlify": "POSTGRES_URL",
      "cloudflare": "DATABASE_URL"
    }
  }
}
```

Open design questions:

- What mapping-file schema should be used?
- Should mappings be environment-specific, provider-specific, or both?
- How should the skill verify mapped variables without exposing values?
- Should reverse sync from providers to 1Password be allowed when names differ?
