# 1Password Environments Reference

> Load this reference when working with 1Password Environments, local runtime injection, mounted `.env` files, or CLI feature detection.

## Storage Model

A 1Password Environment stores individual variables. It is not a single stored `.env` file blob.

Each variable has:

- `name`
- `value`
- hidden or masked display behavior

Dotenv files are interfaces around this variable collection:

- Import converts dotenv lines into individual Environment variables.
- Reading an Environment may present variables as `KEY=value` lines and can expose values.
- Runtime injection with `op run --environment ENV_ID -- command` injects variables into a subprocess.
- MCP-mounted `.env` files are in-memory compatibility surfaces for tools that expect dotenv files.

## CLI Feature Detection

Environment CLI support is version- and channel-dependent. Always feature-detect instead of trusting an installed version number.

```bash
op --version
op environment read --help 2>/dev/null && echo "Environment reads supported" || echo "Environment reads unavailable"
op run --help 2>/dev/null | rg -- '--environment' && echo "op run --environment supported"
```

If `op environment` is unavailable, prefer MCP setup or the 1Password desktop workflow before any classic vault/item fallback.

## Runtime Injection

Use `op run` when a command needs secrets but the agent does not.

```bash
op run --environment ENV_ID -- npm run dev
```

Do not verify this with `printenv` in an agent transcript. If a runtime command fails, inspect non-secret errors only.

## Reading Variables

`op environment read ENV_ID` can output key-value pairs. Treat it as raw value access:

- Require explicit user approval.
- Do not print the output.
- Do not pipe it into commands that log, trace, cache, or persist values.
- Prefer MCP metadata operations for listing Environment names and variable names.

## Local Mounted Dotenv Files

1Password Environments can provide local mounted `.env` files for development tools. These files are intended to avoid persistent plaintext credentials on disk.

Rules:

- Prefer MCP-managed mounted files when dotenv compatibility is required.
- Add configured mount paths to `.gitignore`.
- Treat mount paths as runtime compatibility surfaces, not the source of truth.
- Use the 1Password agent hook validation flow when supported to prevent agents from running before required mounted files are available.

## Import Guidance

For importing existing `.env` files:

1. Parse and show variable names only.
2. Propose target Environment names.
3. Prefer MCP import or guided 1Password desktop import.
4. Use CLI fallback only with explicit approval because values are read from the file.

Comments and ordering do not need to be preserved in the MVP.

## Naming Convention

Recommended Environment names:

- `projectname/local`
- `projectname/staging`
- `projectname/production`
- `projectname/preview`

Use exact variable-name matching in MVP. Provider-specific renames are deferred.
