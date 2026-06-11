#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const checkOnly = process.argv.includes('--check');

const packagePath = path.join(root, 'package.json');
const pkg = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
const version = pkg.version;

if (!/^\d+\.\d+\.\d+$/.test(version)) {
  throw new Error(`package.json version must be SemVer x.y.z, got ${version}`);
}

const changed = [];

function writeIfChanged(relativePath, next) {
  const filePath = path.join(root, relativePath);
  const current = fs.readFileSync(filePath, 'utf8');

  if (current === next) return;

  changed.push(relativePath);
  if (!checkOnly) fs.writeFileSync(filePath, next);
}

function syncJsonVersion(relativePath) {
  const filePath = path.join(root, relativePath);
  const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  data.version = version;
  writeIfChanged(relativePath, `${JSON.stringify(data, null, 2)}\n`);
}

function syncSkillVersion(relativePath) {
  const filePath = path.join(root, relativePath);
  const current = fs.readFileSync(filePath, 'utf8');
  const lines = current.split('\n');

  if (lines[0] !== '---') {
    throw new Error(`${relativePath} is missing YAML frontmatter`);
  }

  const end = lines.indexOf('---', 1);
  if (end === -1) {
    throw new Error(`${relativePath} is missing closing YAML frontmatter`);
  }

  const versionIndex = lines.findIndex((line, index) => {
    return index > 0 && index < end && /^version:\s*/.test(line);
  });

  if (versionIndex === -1) {
    throw new Error(`${relativePath} is missing frontmatter version`);
  }

  lines[versionIndex] = `version: ${version}`;
  const next = lines.join('\n');
  writeIfChanged(relativePath, next);
}

function syncReadmeVersion() {
  const relativePath = 'README.md';
  const filePath = path.join(root, relativePath);
  const current = fs.readFileSync(filePath, 'utf8');
  const next = current.replace(
    /Current version: \*\*[^*]+\*\*/,
    `Current version: **${version}**`
  );
  writeIfChanged(relativePath, next);
}

[
  '.claude-plugin/plugin.json',
  '.cursor-plugin/plugin.json',
  '1password-codex/.codex-plugin/plugin.json',
  'gemini-extension.json',
].forEach(syncJsonVersion);

[
  'skills/setup/SKILL.md',
  'skills/environments/SKILL.md',
  'skills/vaults-items/SKILL.md',
  'skills/ssh-git/SKILL.md',
  'skills/cli-auth/SKILL.md',
].forEach(syncSkillVersion);

syncReadmeVersion();

if (checkOnly && changed.length > 0) {
  console.error('Version metadata is out of sync with package.json:');
  for (const file of changed) console.error(`  - ${file}`);
  console.error('Run `npm run sync:version` and commit the result.');
  process.exit(1);
}

if (!checkOnly && changed.length > 0) {
  console.log(`Synced ${changed.length} version file(s) to ${version}.`);
}
