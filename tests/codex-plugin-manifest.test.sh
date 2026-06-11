#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)

plugin_root="$package_root/1password-codex"
manifest="$plugin_root/.codex-plugin/plugin.json"

[ -f "$manifest" ] || { echo "FAIL: 1password-codex/.codex-plugin/plugin.json missing"; exit 1; }
[ -d "$plugin_root/skills" ] || { echo "FAIL: 1password-codex/skills missing"; exit 1; }

node -e "
const fs = require('fs');
const path = require('path');
const manifest = JSON.parse(fs.readFileSync('$manifest', 'utf8'));
const pkg = JSON.parse(fs.readFileSync(path.join('$package_root', 'package.json'), 'utf8'));
if (manifest.name !== '1password-codex') throw new Error('Codex plugin name must be 1password-codex');
if (path.basename('$plugin_root') !== manifest.name) throw new Error('Codex plugin directory must match manifest name');
if (manifest.version !== pkg.version) throw new Error('Codex plugin version must match package.json');
if (manifest.skills !== './skills/') throw new Error('Codex plugin skills path must be ./skills/');
for (const field of ['displayName', 'shortDescription', 'longDescription', 'developerName', 'category', 'capabilities', 'websiteURL', 'privacyPolicyURL', 'termsOfServiceURL', 'defaultPrompt']) {
  if (!(field in manifest.interface)) throw new Error('Codex interface missing ' + field);
}
if (!Array.isArray(manifest.interface.defaultPrompt) || manifest.interface.defaultPrompt.length === 0 || manifest.interface.defaultPrompt.length > 3) {
  throw new Error('Codex interface must define one to three default prompts');
}
for (const prompt of manifest.interface.defaultPrompt) {
  if (prompt.length > 128) throw new Error('Codex default prompt too long: ' + prompt);
}
"

for skill in setup environments vaults-items ssh-git cli-auth; do
  wrapper="$plugin_root/skills/$skill/SKILL.md"
  canonical="$package_root/skills/$skill/SKILL.md"
  [ -f "$wrapper" ] || { echo "FAIL: Codex wrapper missing for $skill"; exit 1; }
  [ -f "$canonical" ] || { echo "FAIL: canonical skill missing for $skill"; exit 1; }
  name=$(grep -m1 '^name:' "$wrapper" | sed 's/name: *//')
  [ "$name" = "$skill" ] || { echo "FAIL: Codex wrapper $skill frontmatter name is '$name'"; exit 1; }
  grep -q "../../../skills/$skill/SKILL.md" "$wrapper" || {
    echo "FAIL: Codex wrapper $skill does not route to canonical skill"
    exit 1
  }
done

echo "PASS: Codex plugin manifest valid"
