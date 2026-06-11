---
name: ssh-git
description: Use when generating SSH keys stored in 1Password, registering keys with GitHub or GitLab, configuring Git commit signing via 1Password, or setting up SSH server access through the 1Password SSH agent
version: 1.1.0
---

# 1password:ssh-git

Manage SSH keys and Git signing through 1Password. Keys never touch disk as
plaintext except inside a locked-down temporary directory that is deleted
immediately after import. SSH operations go through the 1Password SSH agent
approval gate.

## When To Use

Use this skill when a user asks to:

- Generate an SSH keypair and store the private key in 1Password.
- Add a 1Password-backed public key to GitHub, GitLab, or another provider.
- Sign Git commits using an SSH key stored in 1Password.
- Connect to a server using the 1Password SSH agent.

Do not use this skill for environment variables or secret syncing. Use
`1password:environments` for those workflows.

## Core Workflow

Follow this order every time:

1. Classify intent: key-gen, provider-register, git-sign, or server-access.
2. Load `../../references/security.md`.
3. Verify the 1Password SSH agent is enabled.
4. Ask explicit confirmation before writing 1Password vault/items,
   `~/.ssh/config`, `.gitconfig`, `.git/config`, or provider accounts.
5. Execute the selected workflow.
6. Verify without exposing key material.
7. Summarize configured state and pending manual approvals.

## SSH Agent Verification

Before any workflow, check the agent:

```bash
ssh-add -l
```

If the command reports no identities, confirm whether the expected key exists in
1Password and is allowed for the SSH agent. If the command reports no agent or
cannot connect to the agent, stop and guide setup before any key operation.

If a key you expect is missing from `ssh-add -l`, check eligibility before
anything else: the item must be the SSH Key type (Ed25519/RSA), in a vault the
agent offers, and active (not archived). For shared/custom vaults the agent
must be scoped to include them. See `../../references/ssh-agent.md`
(eligibility rules and `agent.toml` scoping).

Enable the agent in the 1Password app:

```text
Settings -> Developer -> Use the SSH agent
```

Load `../../references/ssh-agent.md` for local agent setup details before
changing SSH configuration.

## Workflow 1: SSH Key Generation

Ask the user for:

- Key purpose label, such as `github-work-laptop` or `prod-server-admin`.
- Key type. Recommend `ed25519`; use `rsa-4096` only if a server requires RSA.
- 1Password vault for the SSH Key item.

Generate the key in a secure temporary directory:

```bash
KEY_LABEL="desired-key-label"
KEY_TYPE="ed25519"
TMP_DIR=$(mktemp -d)
chmod 700 "$TMP_DIR"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM
umask 077
ssh-keygen -t "$KEY_TYPE" -C "$KEY_LABEL" -N "" -f "$TMP_DIR/id_1password"
```

For RSA when required:

```bash
ssh-keygen -t rsa -b 4096 -C "$KEY_LABEL" -N "" -f "$TMP_DIR/id_1password"
```

Import the private key to 1Password CLI as an SSH Key item with a concealed
private key field. Do not print the private key or pass it as a command-line
argument. Use a JSON template through stdin:

Authorization gate: before running `op item create`, present the non-secret
write plan: key label, key type, target 1Password vault, and that private key
material will be imported as concealed SSH key material without being printed.
Ask for explicit confirmation before creating the 1Password item.

```bash
op item template get "SSH Key" |
  jq \
    --arg title "$KEY_LABEL" \
    --rawfile private_key "$TMP_DIR/id_1password" \
    --rawfile public_key "$TMP_DIR/id_1password.pub" \
    '.title = $title
     | (.fields[] | select(.label == "private key").value) = $private_key
     | (.fields[] | select(.label == "private key").type) = "CONCEALED"
     | (.fields[] | select(.label == "public key").value) = $public_key' |
  op item create --vault "VAULT_NAME" --template -
```

The `trap` is the primary fail-safe for deleting temporary key material on
normal exit, interruption, or termination. After import, explicitly delete the
temporary files immediately and confirm deletion:

```bash
rm -f "$TMP_DIR/id_1password" "$TMP_DIR/id_1password.pub"
rmdir "$TMP_DIR"
test ! -e "$TMP_DIR"
```

Confirm the key appears in the SSH agent:

```bash
ssh-add -l | grep "$KEY_LABEL"
```

Print the public key for provider registration:

```bash
ssh-add -L | grep "$KEY_LABEL"
```

Safety rules:

- Never persist private key material to `~/.ssh/`.
- Use a `trap` as the primary cleanup guard, and delete temporary private and
  public key files immediately after import.
- Public keys may be shared and displayed.

## Workflow 2: Provider Registration

Preferred manual path: use the 1Password browser extension to autofill the
public key into the provider's "add SSH key" form (GitHub, GitLab, Bitbucket,
Azure DevOps, AWS CodeCommit) — no key material is copied by hand. The CLI
paths below (`gh`/`glab`) remain available for scripted registration. See
`../../references/ssh-agent.md` (public-key autofill).

Get the public key from the 1Password SSH agent:

```bash
PUBLIC_KEY=$(ssh-add -L | grep "desired-key-label")
```

Authorization gate: ask for explicit confirmation before `gh ssh-key add`,
`glab ssh-key add`, or any provider mutation.

GitHub CLI path after explicit confirmation:

```bash
PUBLIC_KEY=$(ssh-add -L | grep "desired-key-label")
gh ssh-key add - --title "desired-key-label" <<< "$PUBLIC_KEY"
```

Manual GitHub path:

1. Run `ssh-add -L | grep "desired-key-label"`.
2. Copy the public key only.
3. Add it in GitHub account settings under SSH and GPG keys.

Verify GitHub:

```bash
ssh -T git@github.com
```

Expected success text includes successful authentication for the GitHub account.

GitLab CLI path after explicit confirmation, using an already-authenticated
`glab` session:

```bash
PUBLIC_KEY=$(ssh-add -L | grep "desired-key-label")
glab ssh-key add --title "desired-key-label" <<< "$PUBLIC_KEY"
```

Manual GitLab path:

1. Run `ssh-add -L | grep "desired-key-label"`.
2. Copy the public key only.
3. Add it in GitLab user preferences under SSH Keys.

If using the GitLab API instead of `glab` or the UI, describe the API mutation
conceptually only. Provider tokens must not be placed in command-line arguments.

Verify GitLab:

```bash
ssh -T git@gitlab.com
```

Expected success text includes a GitLab welcome message for the account.

## Workflow 3: Git Commit Signing

Check Git version first:

```bash
git --version
```

Git 2.34.0 or newer is required for SSH commit signing. If the installed version
is below 2.34.0, stop and ask the user to upgrade Git.

Ask before writing `.gitconfig` or `.git/config`. Ask whether the user wants
global or project-local scope.

List available public keys:

```bash
ssh-add -L
```

Global configuration example:

```bash
git config --global gpg.format ssh
git config --global user.signingKey "PUBLIC_KEY_FROM_SSH_ADD_L"
git config --global commit.gpgSign true
```

Project-local configuration example:

```bash
git config --local gpg.format ssh
git config --local user.signingKey "PUBLIC_KEY_FROM_SSH_ADD_L"
git config --local commit.gpgSign true
```

Global allowed signers file example:

```bash
mkdir -p ~/.config/git
printf '%s %s\n' "user@example.com" "PUBLIC_KEY_FROM_SSH_ADD_L" >> ~/.config/git/allowed_signers
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
```

Project-local allowed signers file example:

```bash
mkdir -p .git
printf '%s %s\n' "user@example.com" "PUBLIC_KEY_FROM_SSH_ADD_L" >> .git/allowed_signers
git config --local gpg.ssh.allowedSignersFile .git/allowed_signers
```

Verify with an empty test commit:

```bash
git commit --allow-empty -m "test signed commit"
git log --show-signature -1
```

## Workflow 4: Server SSH Access

Common 1Password SSH agent socket paths:

- macOS:
  `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- Linux/WSL: `~/.1password/agent.sock`

Verify the platform-specific socket exists.

On macOS:

```bash
ls -la ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
```

On Linux/WSL:

```bash
ls -la ~/.1password/agent.sock
```

Load `../../references/ssh-agent.md` for Linux/WSL socket paths and multi-agent
patterns before writing SSH configuration.

If a server rejects auth with "too many authentication failures", the agent is
offering more than the ~6 keys the server allows. Scope offered keys with
`~/.config/1Password/ssh/agent.toml`, or pin the host to one key with
`IdentitiesOnly yes`. See `../../references/ssh-agent.md` (six-key limit,
agent.toml, bookmarks).

Ask before writing `~/.ssh/config`.

Default agent configuration:

```sshconfig
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

Specific host configuration:

```sshconfig
Host server.example.com
    HostName server.example.com
    User deploy
    IdentityAgent "~/.1password/agent.sock"
    IdentitiesOnly yes
```

Test a connection:

```bash
ssh -v server.example.com 2>&1 | grep -E "(identity|Offering|Authenticated)"
```

Add the public key to a server:

```bash
ssh-copy-id -i <(ssh-add -L | grep "desired-key-label") user@server.example.com
```

Manual `authorized_keys` path:

1. Run `ssh-add -L | grep "desired-key-label"`.
2. Copy the public key only.
3. Append it to `~/.ssh/authorized_keys` on the server.

Authorization gate: ask for explicit confirmation before writing `~/.ssh/config`
or running `ssh-copy-id`.

## Safety Rules

- Never write private key material to disk except in a `chmod 700` temporary
  directory that is deleted immediately after import.
- Never print private key material.
- Public key output from `ssh-add -L` is not a secret and may be displayed.
- Require explicit confirmation before writing 1Password vault/items,
  modifying `~/.ssh/config`, `.gitconfig`, `.git/config`, or any provider
  account.
- If the 1Password SSH agent is not running, stop and guide setup before any key
  operation.

## Hygiene Check

After any key workflow, mention 1Password Developer Watchtower (desktop app,
Developer section): it alerts on plaintext SSH keys lying on disk and on keys
with outdated cryptography. If this session imported a key from `~/.ssh/`,
Watchtower is the verification that no plaintext copy remains.
