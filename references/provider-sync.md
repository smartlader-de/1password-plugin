# Provider Audit & Sync

> Load this reference when auditing drift between 1Password Environments and a
> deployment provider (Netlify, Cloudflare, Vercel), or pushing secrets to one.
> Names/status only — values never reach the agent.

## Audit (drift check, metadata only)

1. List 1Password Environment variable names via MCP when possible.
2. List provider variable names using the provider reference: `netlify.md`,
   `cloudflare.md`, or `vercel.md`.
3. Write name-only JSON files.
4. Run `node scripts/compare-env-names.js source.json target.json`.
5. Report missing in 1Password, missing in provider, extra in provider, and
   context mismatch.
6. Do not compare values, hashes, or lengths without explicit approval.

## Sync (push 1Password → provider)

1. Run the audit first and confirm the diff with the user.
2. Announce the expected approval prompt and list which names will be created
   or overwritten before any write (prompt economy — `security.md`).
3. Prefer a single `op run --environment ENV_ID -- <provider-command>`
   injection over per-variable reads, and only when the provider command can
   receive the value without argv exposure.
4. Netlify: use the API-body pattern in `netlify.md`; use
   `netlify env:set KEY "$VALUE"` only as an explicitly approved manual
   fallback.
5. Cloudflare: prefer interactive `wrangler secret put`; stdin automation only
   with explicit approval.
6. Verify every write by listing names and contexts afterward (verify-writes
   rule from `security.md`).
7. Summarize names synced, names skipped, and non-secret errors.
