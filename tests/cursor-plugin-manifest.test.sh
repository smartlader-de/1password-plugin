#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)

cursor_manifest="$package_root/.cursor-plugin/plugin.json"
claude_manifest="$package_root/.claude-plugin/plugin.json"
rules_dir="$package_root/rules"

[ -f "$cursor_manifest" ] || { echo "FAIL: .cursor-plugin/plugin.json missing"; exit 1; }
[ -d "$rules_dir" ] || { echo "FAIL: rules/ directory missing"; exit 1; }

node -e "
const fs = require('fs');
const cursor = JSON.parse(fs.readFileSync('$cursor_manifest', 'utf8'));
const claude = JSON.parse(fs.readFileSync('$claude_manifest', 'utf8'));
const pkg = JSON.parse(fs.readFileSync('$package_root/package.json', 'utf8'));

if (cursor.name !== '1password') throw new Error('Cursor plugin name must be 1password, got ' + cursor.name);
if (cursor.version !== pkg.version) throw new Error('Cursor plugin version (' + cursor.version + ') != package.json version (' + pkg.version + ')');

for (const field of ['name', 'version', 'description', 'repository', 'license']) {
  if (cursor[field] !== claude[field]) {
    throw new Error('Cursor plugin field ' + field + ' must match Claude plugin manifest');
  }
}

if (JSON.stringify(cursor.author) !== JSON.stringify(claude.author)) {
  throw new Error('Cursor plugin author must match Claude plugin manifest');
}

if (JSON.stringify(cursor.keywords) !== JSON.stringify(claude.keywords)) {
  throw new Error('Cursor plugin keywords must match Claude plugin manifest');
}
"

plain_md=$(find "$rules_dir" -maxdepth 1 -type f -name '*.md' -print)
if [ -n "$plain_md" ]; then
  echo "FAIL: Cursor rules must use .mdc, not .md:"
  echo "$plain_md" | sed 's/^/  - /'
  exit 1
fi

mdc_count=0
while IFS= read -r rule; do
  [ -n "$rule" ] || continue
  mdc_count=$((mdc_count + 1))

  first_line=$(sed -n '1p' "$rule")
  [ "$first_line" = "---" ] || { echo "FAIL: $rule missing opening YAML frontmatter"; exit 1; }

  grep -q '^description: .\+' "$rule" || { echo "FAIL: $rule missing description frontmatter"; exit 1; }
  grep -q '^alwaysApply: \(true\|false\)$' "$rule" || { echo "FAIL: $rule missing alwaysApply boolean frontmatter"; exit 1; }

  closing_count=$(grep -n '^---$' "$rule" | wc -l | tr -d ' ')
  [ "$closing_count" -ge 2 ] || { echo "FAIL: $rule missing closing YAML frontmatter"; exit 1; }
done < <(find "$rules_dir" -maxdepth 1 -type f -name '*.mdc' -print)

[ "$mdc_count" -gt 0 ] || { echo "FAIL: no Cursor .mdc rules found"; exit 1; }

echo "PASS: Cursor plugin manifest valid"
