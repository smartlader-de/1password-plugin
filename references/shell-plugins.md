# Shell Plugins (Third-Party CLI Authentication)

> Load this reference when the user wants to stop keeping API keys for CLI
> tools in plaintext — `claude`, `openai`, `aws`, `gh`, `glab`, `ngrok`,
> `brew`, `terraform`, and 60+ others — and authenticate them with biometrics
> through 1Password instead.

Shell plugins solve a different problem than Environments: not *project*
secrets, but the credentials of the **tools themselves**. The plugin wraps the
CLI in a shell alias; on invocation, 1Password injects the credential as an
environment variable for that process only, gated by fingerprint / Apple
Watch / system authentication. Nothing lives in `~/.zshrc`, `~/.aws/`, or a
plaintext config.

Requirements: 1Password desktop app (Mac/Linux), CLI ≥ 2.34.0 for the newer
plugins (feature-detect, don't assume), app integration enabled, Bash/Zsh/fish.

## Setup Pattern (same for every tool)

```bash
op plugin init claude-code        # or: openai, aws, github, ngrok, ...
```

The init flow imports an existing key (or lets the user pick an existing
item), stores it as a 1Password item, and prints the exact `source` command.
Then:

```bash
source ~/.config/op/plugins.sh    # path may vary; trust the init output
```

Persist by adding that source line to the user's RC file — ask before editing
`~/.zshrc`/`~/.bashrc`/fish config, and show the exact line first.

After import, walk the user through **removing the plaintext original** (the
docs make this an explicit step): the old export line, config file entry, or
key file. That removal is the actual security win — confirm before deleting,
and tell the user what was removed.

## Useful Commands

| Command | Purpose |
|---|---|
| `op plugin list` | Plugins configured and available |
| `op plugin init <tool>` | Configure a tool (import/select credential) |
| `op plugin inspect <tool>` | Show configuration and credential sources |
| `op plugin clear <tool>` | Remove a tool's configuration |
| `op plugin run -- <tool> ...` | Run once through the plugin without the alias |

## Field Name Contract

Plugins map item fields to environment variables. If the user stores the
credential manually instead of via `op plugin init`, the field label must
match what the plugin expects — for example Claude Code:

| 1Password field | Injected variable |
|---|---|
| `API Key` | `ANTHROPIC_API_KEY` |

On mismatch the plugin prompts to rename a field. Prefer `op plugin init`
imports to avoid the issue entirely.

## Agent-Relevant Notes

- For vibecoders this is the answer to "where should my `ANTHROPIC_API_KEY` /
  `OPENAI_API_KEY` live": in 1Password via the `claude-code` / `openai`
  plugins, not in shell profiles or `.env` files.
- Context switching: plugins support per-environment and per-account
  configurations (e.g. different AWS credentials per project directory) — see
  `/cli/shell-plugins/environments.md` and
  `/cli/shell-plugins/multiple-accounts.md` on www.1password.dev.
- Prompt economy: the biometric prompt appears per authorization window, not
  per keystroke; batching work in one CLI invocation behaves the same as any
  other `op`-mediated call.
- A tool without a plugin can still be wrapped manually with
  `op run --env-file` + secret references (`secret-references.md`), or the
  user can build a plugin (`/cli/shell-plugins/contribute.md`).
- Inside agent sessions, plugin-wrapped CLIs work normally — the injected
  variable exists only in the tool's process, so the secret never enters the
  transcript.
