# SSH Agent Integration

Reference for connecting 1Password SSH agent to projects managed by this skill.

## 1. What It Is

1Password can act as the local SSH agent. Private keys are stored in 1Password
and SSH operations require 1Password approval. This extends the same trust model
(nothing on disk, approval gate) to server access.

## 2. Setup

Add to `~/.ssh/config`:

```
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

Enable in 1Password app: Settings → Developer → "Use the SSH agent".

After enabling, test with:

```bash
ssh-add -l
```

Keys stored in 1Password will appear in the list.

## 3. Why It Matters for This Skill

When managing server secrets, SSH access to that server is itself a credential.
With 1Password SSH agent:

- No private keys on disk
- SSH access audited through 1Password
- Fits the same approval-gate model as secret access via MCP

If you're managing secrets for a server (Dokploy, Docker Swarm, VPS), route SSH
to that server through 1Password SSH agent as well.

## 4. Storing Server Credentials

SSH host keys and server passwords can be stored in 1Password Environments or
classic vault items alongside the secrets this skill manages.

For consistency:
- Store infrastructure access credentials (SSH keys, server passwords, API tokens)
  in the same Environment as the application secrets for that server.
- Use `concealed: true` when writing via `append_variables`.
- See `references/one-password-environments.md` for variable storage patterns.

## 5. Scoping Offered Keys (`agent.toml`)

By default the 1Password SSH agent offers every eligible key in the built-in
Personal/Private/Employee vaults. To scope which keys are offered — required
for shared or custom vaults, and to stay under server limits — author
`~/.config/1Password/ssh/agent.toml`:

```toml
# Offer keys from a specific vault, plus one named item.
[[ssh-keys]]
vault = "Private"

[[ssh-keys]]
item = "prod-server-admin"
```

Least privilege (see `security.md`): list only the vaults/items the session
needs, not every eligible key. Confirm the schema against
`https://www.1password.dev/ssh/agent-config.md` — `agent.toml` keys are beta.

## 6. The Six-Key Server Limit

OpenSSH offers identities to a server sequentially, and most servers close the
connection after ~6 offers (`MaxAuthTries`). With many keys loaded, the right
key may never be offered and auth fails with "too many authentication
failures." Fixes:

- Scope offered keys with `agent.toml` (section 5) so fewer are presented.
- Pin a specific key to a host with `IdentitiesOnly yes` + an identity/bookmark
  in `~/.ssh/config` (section 7).

This is the usual cause of "the agent can't use my key" on servers.

## 7. SSH Bookmarks (pinning keys to hosts)

Bookmarks tie an SSH Key item to a host so 1Password offers the right key
without exhausting the six-offer budget. Create one by:

- Adding an `ssh://user@host` URL custom field on the SSH Key item, or
- Using the SSH activity log in the 1Password app to bookmark a recent host.

Then a `Host` block with `IdentitiesOnly yes` keeps that host to its pinned
key.

## 8. Public-Key Autofill (preferred manual registration)

When registering a public key with a provider (GitHub, GitLab, Bitbucket,
Azure DevOps, AWS CodeCommit), the 1Password browser extension can fill the
public key directly into the provider's "add SSH key" form. Prefer this over
copy-paste or CLI for manual registration — no key material is handled by the
agent. CLI paths (`gh ssh-key add`, `glab ssh-key add`) remain available for
scripted registration.

## 9. Key Eligibility Rules

A key appears in the agent only if all hold — state these up front so "the
agent can't see my key" is diagnosable:

- The item is the **SSH Key** type (Ed25519 or RSA).
- It lives in a vault the agent offers (built-in vaults by default, or those
  listed in `agent.toml`).
- It is **active**, not archived.
