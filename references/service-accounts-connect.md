# Service Accounts And Connect

> Load this reference when automating 1Password access without a human present:
> CI/CD, servers, containers, Kubernetes, Terraform, or when choosing between
> service accounts and a Connect server.

## Service Accounts

Token-based CLI/SDK authentication not tied to a person.

- Scoped at creation to specific **vaults** and **Environments**, with
  per-vault permissions. Follow least privilege: one service account per
  pipeline or system, scoped to exactly the vaults it needs.
- Cannot access built-in Private/Personal/Employee vaults.
- Can only manage permissions for vaults the service account itself created.
- Up to 100 service accounts per account; hourly and daily rate limits apply
  (also through SDKs) — see `/service-accounts/rate-limits.md` if a pipeline
  hits 429s.
- Usage is auditable in 1Password reports.

Create one (the token is shown once — it is a secret):

```bash
op service-account create "ci-myproject" \
  --expires-in 90d \
  --vault Infrastructure:read_items
```

Never echo the token. Hand it to the target system directly, e.g. piped into a
provider secret store, or have the user copy it from the desktop flow on
1password.com (Developer > Infrastructure Secrets Management > Other > Service
Account).

Use in a pipeline:

```bash
export OP_SERVICE_ACCOUNT_TOKEN   # provided by the CI secret store, never by the agent
op item get ... / op read ... / op run ...
```

With `OP_SERVICE_ACCOUNT_TOKEN` set, `op` commands authenticate automatically;
`op item` commands then require `--vault` to be explicit.

## Connect (self-hosted)

A self-hosted server (two containers: API + sync) that caches account data
inside your infrastructure and exposes a REST API, authenticated with Connect
tokens.

Choose Connect over service accounts when:

- request volume would exceed service-account rate limits,
- secrets access must stay inside a private network,
- many internal services need concurrent access with low latency.

Choose service accounts for: CI jobs, scripts, single deployments, anything
where running infrastructure is overhead. Default to service accounts; Connect
is the scale-up path.

CLI: `op connect server create|get|list`, `op connect token create|list|revoke`,
`op connect group|vault grant`. REST reference: `/connect/api-reference.md`.

## Prebuilt CI/CD Integrations

All accept either a service account token or Connect credentials:

| Target | Integration |
|---|---|
| GitHub Actions | `1password/load-secrets-action` — maps `op://` references to step env/outputs |
| CircleCI | 1Password Secrets orb |
| Jenkins | 1Password Secrets plugin |
| Kubernetes | Operator, Secrets Injector, External Secrets Operator support |
| Terraform | `1Password/onepassword` provider (Connect, service account, or desktop app) |
| Pulumi | 1Password provider |

For exact setup fetch the matching page from `docs-map.md` — these integrations
version quickly.

## Choosing An Auth Method (summary)

| Situation | Use |
|---|---|
| Interactive developer machine | Desktop app integration (biometric unlock) |
| Agent-managed Environments on this machine | 1Password MCP server |
| CI/CD, headless automation | Service account |
| High-volume / private-network API access | Connect |
