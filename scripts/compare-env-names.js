'use strict';
const fs = require('node:fs');

function compareNames(source, target) {
  const sourceSet = new Set(source.names);
  const targetSet = new Set(target.names);

  const common = source.names.filter(n => targetSet.has(n));
  const missingInTarget = source.names.filter(n => !targetSet.has(n));
  const missingInSource = target.names.filter(n => !sourceSet.has(n));

  return {
    source: source.label,
    target: target.label,
    common,
    missingInTarget,
    missingInSource,
    summary: {
      commonCount: common.length,
      missingInTargetCount: missingInTarget.length,
      missingInSourceCount: missingInSource.length,
    },
  };
}

function loadNames(filePath) {
  const raw = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  if (Array.isArray(raw) && raw.length > 0 && typeof raw[0] === 'string') {
    return { label: filePath, names: raw };
  }
  if (Array.isArray(raw) && raw.length > 0 && Array.isArray(raw[0].names)) {
    return { label: filePath, names: raw[0].names };
  }
  throw new Error(`Cannot parse name list from ${filePath}`);
}

function main() {
  const args = process.argv.slice(2);
  if (args.length < 2) {
    process.stderr.write(
      'Usage: compare-env-names.js <source.json> <target.json>\n' +
      '  Files must contain a plain string array or parse-dotenv.js output.\n'
    );
    process.exit(1);
  }

  const source = loadNames(args[0]);
  const target = loadNames(args[1]);
  process.stdout.write(JSON.stringify(compareNames(source, target), null, 2) + '\n');
}

if (require.main === module) {
  main();
}

module.exports = { compareNames };
