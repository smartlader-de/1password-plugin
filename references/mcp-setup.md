# 1Password MCP Setup Reference

> Load this reference when detecting MCP availability, configuring Codex to use 1Password MCP, or explaining 1Password app requirements.

## What MCP Provides

The 1Password MCP Server for Codex is a beta bridge for 1Password Environments. It can help Codex:

- Create and manage Environments.
- List Environment variable names.
- Handle local `.env` files in authenticated workflows.
- Keep secret values inside 1Password instead of returning them to the agent.

The MCP server should be the first choice for agent workflows because it is designed not to return secret values to the AI agent.

## Detection Checks

Run these checks in order.

### 1. Check Current Agent Tools

Look for available MCP tools that clearly belong to 1Password. Tool names may vary by client. If present, verify with metadata-only operations such as listing Environments or variable names.

### 2. Check Local Binary

```bash
# macOS
test -x /Applications/1Password.app/Contents/MacOS/onepassword-mcp \
  && echo "1Password MCP binary found" \
  || echo "1Password MCP binary not found"

# Linux path depends on the installed beta package.
command -v onepassword-mcp 2>/dev/null || true
```

### 3. Check Codex Configuration

Codex MCP configuration may be managed through the Codex UI or config files. Do not assume a file path is authoritative; inspect current Codex documentation or visible settings when needed.

Look for a local server entry whose command is the 1Password MCP binary, for example:

```text
/Applications/1Password.app/Contents/MacOS/onepassword-mcp
```

## Setup Rules

Ask for explicit approval before enabling, installing, or configuring MCP.

Current setup assumptions from 1Password documentation:

- The 1Password desktop app must be installed and running.
- The user may need to enable the local MCP server in 1Password settings under Labs / MCP Server.
- Codex must be configured with a local MCP server command.
- Enterprise admins can control MCP access through agentic or local MCP server policies.
- The feature is beta, so settings names and paths may change.

## Codex Server Command

Use the OS-appropriate command shown by current 1Password docs.

```text
# macOS
/Applications/1Password.app/Contents/MacOS/onepassword-mcp

# Linux beta examples may use a built binary such as:
./dist/onepassword-mcp
```

Do not silently edit Codex configuration. Explain the change and ask first.

## Verification

After setup, restart or reload the agent session if required, then verify with metadata only:

- Confirm 1Password MCP tools are visible.
- List Environments or variable names.
- Do not read or print secret values.

## If Setup Is Declined

Do not silently fall through to raw CLI access. Say that MCP is unavailable and ask whether the user wants a guarded fallback path. Raw value access, provider writes, and classic vault access all require explicit approval.
