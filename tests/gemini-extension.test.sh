#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
package_root=$(cd "$script_dir/.." && pwd)

manifest="$package_root/gemini-extension.json"

[ -f "$manifest" ] || { echo "FAIL: gemini-extension.json missing"; exit 1; }

node -e "
const fs = require('fs');
const path = require('path');
const root = '$package_root';
const manifestPath = '$manifest';
const m = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
if (m.name !== '1password') throw new Error('Gemini extension name must be 1password, got ' + m.name);
const pkg = JSON.parse(fs.readFileSync(path.join(root, 'package.json'), 'utf8'));
const claude = JSON.parse(fs.readFileSync(path.join(root, '.claude-plugin/plugin.json'), 'utf8'));
if (m.version !== pkg.version) throw new Error('gemini-extension.json version (' + m.version + ') != package.json version (' + pkg.version + ')');
if (m.version !== claude.version) throw new Error('gemini-extension.json version (' + m.version + ') != .claude-plugin/plugin.json version (' + claude.version + ')');
if (m.contextFileName !== 'GEMINI.md') throw new Error('contextFileName must be GEMINI.md');
if (!fs.existsSync(path.join(root, m.contextFileName))) throw new Error('contextFileName points to missing file: ' + m.contextFileName);
if (Object.prototype.hasOwnProperty.call(m, 'mcpServers')) throw new Error('Gemini extension must not bundle mcpServers; 1Password MCP setup is guided');
if (Object.prototype.hasOwnProperty.call(m, 'settings')) throw new Error('Gemini extension must not declare sensitive settings');
"

for command in setup environments vaults-items ssh-git; do
  file="$package_root/commands/1password/$command.toml"
  [ -f "$file" ] || { echo "FAIL: commands/1password/$command.toml missing"; exit 1; }
  grep -q '^description = ' "$file" || { echo "FAIL: commands/1password/$command.toml missing description"; exit 1; }
  grep -q '^prompt = ' "$file" || { echo "FAIL: commands/1password/$command.toml missing prompt"; exit 1; }
done

echo "PASS: Gemini extension valid"
