#!/usr/bin/env bash
set -euo pipefail

# Pre-push genericity gate: the published plugin must work for ANY user,
# OS, and agent CLI. Fails when maintainer-specific details leak into
# shipped files. Run via `npm test` before every push.
#
# Maintainer-specific marker strings live in tests/genericity-markers.local
# (gitignored, one marker per line) so the markers themselves are never
# published. Generic checks below run everywhere.

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)
cd "$package_root"

# Files that ship publicly: tracked files, excluding this gate itself
# (its patterns would self-match).
shipped_files=$(git ls-files | grep -v '^tests/genericity.test.sh$' || true)

fail=0

# 1. Maintainer-specific markers from the local, gitignored list.
markers_file="$script_dir/genericity-markers.local"
if [ -f "$markers_file" ]; then
  while IFS= read -r marker; do
    [ -n "$marker" ] || continue
    hits=$(echo "$shipped_files" | xargs grep -lni -- "$marker" 2>/dev/null || true)
    if [ -n "$hits" ]; then
      echo "FAIL: personal marker (from local list) found in shipped files:"
      echo "$hits" | sed 's/^/  - /'
      fail=1
    fi
  done < "$markers_file"
else
  echo "NOTE: tests/genericity-markers.local not found - running generic checks only"
fi

# 2. Absolute home-directory paths never belong in shipped files.
home_hits=$(echo "$shipped_files" | xargs grep -EnH '(/Users/[A-Za-z]|/home/[a-z0-9_-]+/)' 2>/dev/null || true)
if [ -n "$home_hits" ]; then
  echo "FAIL: absolute home-directory path in shipped files:"
  echo "$home_hits" | sed 's/^/  - /'
  fail=1
fi

# 3. Real-looking 1Password IDs in docs/tests. Example IDs must be obvious
#    placeholders (EXAMPLE.../example.../zero-padded), never copied from a
#    real account.
id_hits=$(echo "$shipped_files" | grep -E '\.(md|js|sh|json)$' |
  xargs grep -EnH '"[a-z0-9]{26}"' 2>/dev/null |
  grep -viE 'example|placeholder|0{6}' || true)
if [ -n "$id_hits" ]; then
  echo "FAIL: real-looking 26-char 1Password IDs in shipped files (use EXAMPLE... placeholders):"
  echo "$id_hits" | sed 's/^/  - /'
  fail=1
fi

# 4. No personal email addresses (placeholders and vendor docs examples ok).
email_hits=$(echo "$shipped_files" | xargs grep -EnH '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-z]{2,}' 2>/dev/null |
  grep -viE 'example|git@(github|gitlab)\.com|@agilebits|wendy|appleseed|@1password|@anthropic|a@x\.com|b@y\.com' || true)
if [ -n "$email_hits" ]; then
  echo "FAIL: email address in shipped files (use user@example.com):"
  echo "$email_hits" | sed 's/^/  - /'
  fail=1
fi

[ "$fail" -eq 0 ] || exit 1
echo "PASS: genericity gate (no setup-specific details in shipped files)"
