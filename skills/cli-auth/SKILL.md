---
name: cli-auth
version: 1.0.0
description: Use when securing the credentials that CLI and AI developer tools themselves authenticate with - API keys for claude, openai, aws, gh, glab, terraform and other CLIs - through 1Password Shell Plugins and biometric auth, and for AI-access security (API keys embedded in MCP config files, browser-agent credential handoff via Secure Agentic Autofill). Not for project .env variables - use 1password:environments for those.
---

# 1password:cli-auth

Secure the credentials developer tools authenticate with — a different problem
than project env vars. Shell Plugins inject a tool's API key biometrically into
that process only; nothing lives in shell profiles or plaintext config.

## When To Use

Use this skill when a user asks to:

- Stop keeping API keys for CLIs (`claude`, `openai`, `aws`, `gh`, ...) in
  `~/.zshrc`, `~/.aws/`, or plaintext configs.
- Secure `ANTHROPIC_API_KEY` / `OPENAI_API_KEY` for AI CLIs.
- Remove an API key embedded in an MCP server config file.
- Hand a credential to a browser agent safely (Secure Agentic Autofill).

Do not use this skill for project `.env` variables or provider sync — use
`1password:environments`. Do not use it for SSH keys — use `1password:ssh-git`.

## Core Workflow

1. Classify intent: shell-plugin-setup, ai-key-security, or
   agentic-autofill-pointer.
2. Load `../../references/security.md`.
3. For tool-credential setup, load `../../references/shell-plugins.md` and
   follow its setup pattern (`op plugin init <tool>`, source line, remove the
   plaintext original).
4. For the AI-specific surface (keys in MCP configs, browser agents, building
   on 1Password), load `../../references/ai-access.md`.
5. Confirm before editing shell RC files, deleting plaintext originals, or
   installing plugins.
6. Verify by listing configured plugins (`op plugin list`) — never print the
   injected value.
7. Summarize what was secured and which plaintext original was removed.

## Beyond This Skill

- Project env vars and `.env`: `1password:environments`.
- SSH keys / Git signing: `1password:ssh-git`.
- Any other 1Password topic: `../../references/docs-map.md`.
