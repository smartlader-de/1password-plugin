#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)
cd "$package_root"

shipped_files=$(git ls-files | grep -E '\.(md|toml|json|yaml|mjs|sh)$' || true)

if echo "$shipped_files" | xargs grep -n -- 'brew install --cask 1password/tap/1password-cli@beta' >/dev/null 2>&1; then
  echo "FAIL: bad Homebrew-qualified 1Password beta CLI cask guidance found"
  exit 1
fi

grep -q 'brew install --cask 1password-cli@beta' skills/setup/SKILL.md
grep -q 'Settings → Developer → \*\*Integrate with MCP clients\*\*' skills/setup/SKILL.md
grep -q 'Clear MCP Authorizations' skills/setup/SKILL.md
grep -q 'Check for developer credentials on disk' skills/setup/SKILL.md

echo "PASS: setup guidance avoids stale 1Password beta/MCP instructions"
