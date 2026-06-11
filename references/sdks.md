# 1Password SDKs

> Load this reference when the user is building an integration in Go,
> JavaScript, or Python, or asks what the SDKs can do.

Official SDKs: Go (`github.com/1password/onepassword-sdk-go`), JavaScript
(`@1password/sdk`), Python (`onepassword-sdk`). Source and full type docs live
in the `1Password/onepassword-sdk-{go,js,python}` GitHub repos.

## Authentication

Two modes (see `sdks/concepts.md` for the full comparison table):

- **Desktop app**: human-in-the-loop authorization prompts; access covers
  everything the user can reach, expires after 10 minutes of inactivity or app
  lock. Best for local tools.
- **Service account token**: headless, least-privilege, scoped to vaults and
  Environments. Best for servers and CI. Rate limits apply.

```python
from onepassword import Client
client = await Client.authenticate(
    auth=os.environ["OP_SERVICE_ACCOUNT_TOKEN"],  # never hardcode
    integration_name="my-integration", integration_version="1.0",
)
```

## Capabilities

| Area | Notes |
|---|---|
| Secrets | `resolve("op://vault/item/field")` incl. `?attribute=otp`, `?ssh-format=openssh`; batch resolve |
| Items | Create/get/update/delete, archive state; **IDs required, not names** |
| Vaults | List vaults/items; manage group permissions (Business/Teams) |
| Files | Document files and field attachments: read, save, replace, remove |
| Environments | `get_variables(environment_id)` returns name/value/masked per variable (beta) |

Important constraints:

- SDK item operations require IDs (26-char) — list vaults/items first to map
  names to IDs.
- Items containing unsupported field types cannot be updated or deleted via
  SDK; fall back to CLI or the app.
- Login/Password items need field IDs `username`/`password` (types
  Text/Concealed) for autofill to work; website entries control where
  autofill offers them (`AnywhereOnWebsite` | `ExactDomain` | `Never`).
- TOTP fields accept a full TOTP URL or bare seed; invalid seeds surface only
  when reading the computed code.

## Agent Guardrails

SDK code written for a user must follow the same rules as CLI workflows: token
from the runtime environment (never literal in code), no printing of resolved
secrets, resolve directly into the consuming call. When generating example
code, use placeholder references (`op://vault/item/field`), never real values.

## Building On 1Password With LLMs

For best practices on building LLM-powered integrations on top of 1Password,
see `https://www.1password.dev/building-with-llms.md`. For the broader AI
credential surface (CLI keys, MCP configs, browser-agent autofill), see
`ai-access.md`.
