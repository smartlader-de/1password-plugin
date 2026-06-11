# Secure AI Access

> Load this reference when securing the credentials AI tools use: AI CLI API
> keys, keys embedded in MCP config files, and browser-agent credential
> handoff. Snapshot: June 2026. Decision guide:
> `https://www.1password.dev/get-started/secure-ai-access.md`.

## AI CLI API Keys → Shell Plugins

`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, and similar must never live in shell
profiles, `.env` files, or plaintext configs. Use 1Password Shell Plugins — the
`claude-code` and `openai` plugins inject the key biometrically into the tool's
process only. Load `shell-plugins.md` for the setup pattern.

## Keys In MCP Config Files

MCP server configs sometimes embed API keys inline. Replace the literal with a
secret reference resolved at launch via `op run`, or move the credential to a
shell plugin so it is injected into the MCP server process. Load
`secret-references.md` for `op://` syntax. Never commit a config file with a
literal key.

## Browser-Agent Credential Handoff → Secure Agentic Autofill

When a browser agent needs to log in on the user's behalf, the answer is
1Password **Secure Agentic Autofill**: a human-in-the-loop, end-to-end
encrypted handoff — the agent requests a credential, the user approves, and the
value is filled without entering the agent's context or transcript. This is a
guided pointer, not an automated flow: direct the user to
`https://www.1password.dev/agentic-autofill.md` to enable and use it. Do not
attempt to script credential entry for a browser agent by other means.

## Building On 1Password With LLMs

For developers building their own LLM integrations, see
`https://www.1password.dev/building-with-llms.md` (best practices) and
`sdks.md` for SDK auth and guardrails.
