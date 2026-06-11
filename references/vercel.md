# Vercel Provider Reference

Reference for syncing 1Password Environment variables to Vercel projects.

## 1. Contexts

Vercel has three primary environment variable targets:

| Target | CLI flag | Use |
|---|---|---|
| Production | `production` | Deployed to production branches |
| Preview | `preview` | All preview deployments |
| Development | `development` | `vercel dev` local runs |

Variables can apply to one, two, or all three primary targets. Vercel also
supports custom environment names, such as `staging`.

Branch-specific preview workflows use the preview environment plus branch
selection in supported commands, such as:

```bash
vercel env pull --environment=preview --git-branch=feature-branch
vercel env ls preview feature-branch
vercel env add KEY_NAME preview feature-branch
```

## 2. Listing Existing Variables

```bash
vercel env ls
```

Returns variable names and their targets. Does not display values.

## 3. Adding a Variable

Interactive (prompts for value - safest for production):

```bash
vercel env add KEY_NAME production
```

Vercel also supports stdin automation for `vercel env add`. For agent
automation, use stdin only inside `op run --environment` and do not use
`echo "$SECRET"` patterns.

Safer placeholder-only pattern:

```bash
op run --environment ENV_ID -- sh -c 'test -n "${KEY_VALUE:-}" || exit 1; node -e "process.stdout.write(process.env.KEY_VALUE)" | vercel env add KEY_NAME production'
```

Branch-specific preview placeholder-only pattern:

```bash
op run --environment ENV_ID -- sh -c 'test -n "${KEY_VALUE:-}" || exit 1; node -e "process.stdout.write(process.env.KEY_VALUE)" | vercel env add KEY_NAME preview feature-branch'
```

`KEY_VALUE` is a placeholder for the environment variable name exposed by the
selected 1Password Environment. Agents must never substitute or print the raw
value. A missing source variable must abort before `vercel env add`.

Unsafe, not for agent automation:

```bash
echo "$KEY_VALUE" | vercel env add KEY_NAME production
```

Always prefer the interactive form for production secrets unless the user has
approved an automated provider write.

## 4. Removing a Variable

```bash
vercel env rm KEY_NAME production
```

Vercel prompts for confirmation. Does not require the current value.

## 5. Safe Sync Pattern

The safest automated pattern when `op run --environment` is available:

```bash
op run --environment ENV_ID -- sh -c 'test -n "${KEY_VALUE:-}" || exit 1; node -e "process.stdout.write(process.env.KEY_VALUE)" | vercel env add KEY_NAME production'
```

This pattern keeps the value in the subprocess environment and streams it to
Vercel over stdin. `KEY_VALUE` is a placeholder for the 1Password Environment
variable name. Do not replace it with, print, log, or paste a raw secret value.

## 6. Verification

After sync, verify by listing names only:

```bash
vercel env ls
```

Expected output: variable names and targets. No values shown.

## 7. Gotchas

- Vercel variable names are case-sensitive.
- `NEXT_PUBLIC_` prefix makes variables available client-side — treat these as
  semi-public even though Vercel stores them in the same place as secrets.
- Vercel framework presets may inject variables automatically; check for
  conflicts before importing.
- Team variables apply to all team projects; project variables are scoped.
  Import to project scope by default.
- For running commands with Vercel project variables without saving them to a
  file, use `vercel env run -- <command>`.
