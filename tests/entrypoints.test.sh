#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)

for f in CLAUDE.md AGENTS.md GEMINI.md; do
  [ -f "$package_root/$f" ] || { echo "FAIL: $f not found"; exit 1; }
done
echo "PASS: cross-LLM entrypoints present"
