# Secret Handling Rules

> Load this reference when you need to verify approval gates or check whether a command pattern is safe.

## Hard Rules

- Never print secret values to the terminal, chat, or logs.
- Never paste secret values into any message.
- Never write secrets to persistent files unless the user explicitly requests it and there is no safer path.
- Never use `set -x` or shell tracing around commands that handle secret values.
- Never use `echo`, `printf`, or variable expansion in a way that places a secret value in shell history.
- Never pass secret values as command-line arguments because they may be visible in process listings.
- Avoid temp files that contain raw secret values. If unavoidable, create them with `mktemp`, set permissions to `600`, and delete them immediately with a `trap`.

## Approval Gates

Always ask the user for explicit confirmation before:

- Reading raw values through CLI or SDK fallback instead of MCP.
- Writing secrets to any provider, including Netlify and Cloudflare.
- Overwriting existing provider values.
- Deleting provider values.
- Rotating credentials.
- Enabling, installing, or configuring the 1Password MCP server.
- Accessing classic 1Password vault items instead of Environments.
- Moving or copying items between vaults or accounts, and deleting the source after a transfer.
- Creating item share links.
- Creating or deleting vaults, and granting or revoking vault permissions.
- Creating service accounts or Connect tokens.

## Safe Command Patterns

These patterns avoid value exposure:

```bash
# List metadata only - no values.
op item list --vault VAULT_NAME --format json | jq '.[].title'

# Inject secrets into a subprocess without printing them.
op run --environment ENV_ID -- your-command

# Cloudflare interactive secret input - do not type the value into chat.
wrangler secret put MY_SECRET --name my-worker
```

For Netlify automated writes, prefer an API request body created inside an `op run --environment` subprocess. Do not log the request body, do not use `curl -v`, and do not place values in CLI arguments.

## Unsafe Command Patterns

Never use these patterns:

```bash
# UNSAFE - value visible in shell history and process listings.
netlify env:set MY_VAR "actualSecretValue"

# UNSAFE - value echoed through shell expansion.
echo "$MY_SECRET" | wrangler secret put MY_SECRET

# UNSAFE - prints all values to terminal.
op environment read ENV_ID

# UNSAFE - shell tracing exposes values.
set -x; op run --environment ENV_ID -- printenv

# UNSAFE - writes values to a persistent project file.
op environment read ENV_ID > .env.tmp
```

## Acceptable Summary Format

Summaries must contain only:

- Variable names
- Contexts or environments, such as production or staging
- Presence or absence status
- Sync status, such as in sync, missing, extra, created, or skipped

Never include:

- Variable values
- Hashes or checksums of values without explicit user approval
- Lengths of values without explicit user approval

Example:

```text
Audit result: myproject/production Environment vs Netlify production

Common: DATABASE_URL, API_KEY, SENTRY_DSN
Missing in Netlify: FEATURE_FLAG_SECRET
Extra in Netlify: LEGACY_TOKEN

Action required: push FEATURE_FLAG_SECRET to Netlify?
```

## Redaction

`scripts/redact-output.sh` is defense in depth only. It can reduce damage if a command emits a known token pattern, but it does not make unsafe commands safe. Prefer workflows that never produce secret-bearing output.
