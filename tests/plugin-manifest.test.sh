#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)

manifest="$package_root/.claude-plugin/plugin.json"
marketplace="$package_root/.claude-plugin/marketplace.json"

[ -f "$manifest" ] || { echo "FAIL: .claude-plugin/plugin.json missing"; exit 1; }
[ -f "$marketplace" ] || { echo "FAIL: .claude-plugin/marketplace.json missing"; exit 1; }

node -e "
const fs = require('fs');
const m = JSON.parse(fs.readFileSync('$manifest', 'utf8'));
if (m.name !== '1password') throw new Error('plugin name must be 1password, got ' + m.name);
if (!/^\d+\.\d+\.\d+$/.test(m.version)) throw new Error('version must be semver, got ' + m.version);
const pkg = JSON.parse(fs.readFileSync('$package_root/package.json', 'utf8'));
if (pkg.version !== m.version) throw new Error('package.json version (' + pkg.version + ') != plugin.json version (' + m.version + ')');
const mp = JSON.parse(fs.readFileSync('$marketplace', 'utf8'));
if (!mp.plugins.some(p => p.name === '1password')) throw new Error('marketplace.json must list the 1password plugin');
"

# Plugin skills must use bare kebab-case names; the plugin supplies the 1password: namespace.
for skill in environments vaults-items ssh-git setup cli-auth; do
  name=$(grep -m1 '^name:' "$package_root/skills/$skill/SKILL.md" | sed 's/name: *//')
  [ "$name" = "$skill" ] || { echo "FAIL: skills/$skill frontmatter name is '$name', expected '$skill'"; exit 1; }
done

echo "PASS: plugin manifest valid"
