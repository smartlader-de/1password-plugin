# Cloudflare Worker Secrets Reference

> Load this reference when auditing or syncing secrets to Cloudflare Workers. Read `references/security.md` first.

## Secret Model

Cloudflare distinguishes between:

- Worker secrets: sensitive values stored securely and not readable after creation.
- Worker vars: non-sensitive configuration values in Wrangler config.

MVP focus: Worker secrets through `wrangler secret`.

## Feature Detection

```bash
wrangler --version
wrangler whoami
```

If not authenticated, use `wrangler login` after user approval.

## Listing Secret Names

Cloudflare Worker secrets are not read back as values. Listing returns names/metadata only.

```bash
wrangler secret list --name my-worker
```

Compare listed names against 1Password Environment names with `scripts/compare-env-names.js`.

## Setting One Secret

Default safe path is interactive input:

```bash
wrangler secret put MY_SECRET_NAME --name my-worker
```

Wrangler prompts for the value. The user must type or approve the value entry outside chat.

## Automated Input

Wrangler also supports piped input. Use this only after explicit approval and only from inside a subprocess where 1Password injects the value.

```bash
op run --environment ENV_ID -- sh -c 'printf "%s" "$MY_SECRET_NAME" | wrangler secret put MY_SECRET_NAME --name my-worker'
```

This avoids shell history, but the secret still flows through stdin. Do not enable shell tracing. Confirm the command works with the installed Wrangler version before production writes.

## Bulk Secrets

`wrangler secret bulk` can upload multiple secrets from a file or stdin. For this skill, avoid bulk files by default because they create raw-value artifacts.

If bulk upload is unavoidable:

```bash
TMP=$(mktemp)
chmod 600 "$TMP"
trap 'rm -f "$TMP"' EXIT
# Write the minimal JSON, upload it, then cleanup via trap.
```

Never print the temp file path if doing so could reveal workflow details tied to secrets, and never print file contents.

## Environments

Cloudflare Workers can have named environments in Wrangler config.

```toml
[env.production]
name = "my-worker-production"

[env.staging]
name = "my-worker-staging"
```

Set secrets per environment/Worker target:

```bash
wrangler secret put MY_SECRET --name my-worker-production --env production
```

## Verification

```bash
wrangler secret list --name my-worker
```

Report only names, target Worker, environment, and write status.

## Deletion Or Replacement

Cloudflare secrets cannot be read back. Updating a secret is effectively replacing it. Require explicit approval before overwriting or deleting a secret.
