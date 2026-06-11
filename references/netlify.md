# Netlify Environment Variables Reference

> Load this reference when auditing or syncing secrets to Netlify. Read `references/security.md` first.

## Context Model

Netlify environment variables can be scoped by deploy context:

- `production`
- `deploy-preview`
- `branch-deploy`
- `dev`
- branch-specific contexts, such as `branch:feature-name`

They can also be scoped to surfaces such as builds, functions, and runtime.

MVP focus: production context, exact variable-name matching.

## Feature Detection

```bash
netlify --version
netlify status
```

If the site is not linked, use `netlify link` after user approval.

## Listing Names

`netlify env:list --json` may include values depending on CLI behavior and secret status. Always reduce output before showing it.

```bash
netlify env:list --json | jq 'keys'
netlify env:list --context production --json | jq 'keys'
```

For summaries, report only keys, contexts, scopes, `is_secret`, and sync status.

## Automated Writes

Do not use `netlify env:set KEY "$VALUE"` for unattended agent sync. Netlify documents that CLI syntax, but the value is passed as a command-line argument and may be visible through local process inspection.

Preferred automated pattern:

1. Use `op run --environment ENV_ID -- node -` so 1Password injects the value into the subprocess.
2. Build the Netlify API JSON body in memory.
3. Send the value through the HTTPS request body.
4. Never log the body or run verbose HTTP tracing.

Example create request:

```bash
op run --environment ENV_ID -- node - <<'JS'
const https = require('node:https');

const key = 'MY_VAR_NAME';
const value = process.env[key];
const token = process.env.NETLIFY_TOKEN;
const accountId = process.env.NETLIFY_ACCOUNT_ID;
const siteId = process.env.NETLIFY_SITE_ID;

if (!value || !token || !accountId || !siteId) {
  throw new Error('Missing required Netlify sync environment variables');
}

const body = JSON.stringify([{
  key,
  scopes: ['builds', 'functions', 'runtime'],
  values: [{ context: 'production', value }],
  is_secret: true
}]);

const req = https.request({
  method: 'POST',
  hostname: 'api.netlify.com',
  path: `/api/v1/accounts/${encodeURIComponent(accountId)}/env?site_id=${encodeURIComponent(siteId)}`,
  headers: {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(body)
  }
}, res => {
  res.resume();
  res.on('end', () => {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      process.stderr.write(`Netlify env create failed with HTTP ${res.statusCode}\n`);
      process.exit(1);
    }
    process.stdout.write(`Netlify env variable synced: ${key}\n`);
  });
});

req.on('error', err => {
  process.stderr.write(`Netlify env create failed: ${err.message}\n`);
  process.exit(1);
});
req.write(body);
req.end();
JS
```

## Updates And Overwrites

Always check whether a variable exists before writing. Netlify CLI/API operations can overwrite existing values.

Use Netlify API endpoints intentionally:

- Create variables: `POST /api/v1/accounts/ACCOUNT_ID/env?site_id=SITE_ID`
- Replace a variable definition: `PUT /api/v1/accounts/ACCOUNT_ID/env/KEY?site_id=SITE_ID`
- Update one context value: `PATCH /api/v1/accounts/ACCOUNT_ID/env/KEY?site_id=SITE_ID`

Use `PATCH` for one context such as production. Use `PUT` only when the user approved replacing the complete definition across scopes or contexts.

## Manual Fallback

Use CLI writes only after explicit approval and after telling the user the value may be visible to local process inspection.

```bash
# Manual fallback only.
netlify env:set MY_VAR_NAME "$MY_VAR_VALUE" --context production --secret
```

`netlify env:import` is also a fallback. It requires a local dotenv file, so it is only acceptable with explicit approval, restrictive permissions, immediate cleanup, and no file-content output.

## Verification

```bash
netlify env:list --json | jq 'to_entries | map({key: .key, contexts: (.value | keys)})'
```

If API responses include values, discard them before summarizing.

## Deletion

Requires explicit approval.

```bash
netlify env:unset MY_VAR_NAME
```
