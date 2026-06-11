'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const { compareNames } = require('../scripts/compare-env-names.js');

const setA = { label: '1password', names: ['DB_URL', 'API_KEY', 'SECRET'] };
const setB = { label: 'netlify', names: ['DB_URL', 'API_KEY', 'EXTRA_VAR'] };

test('identifies variables common to both sets', () => {
  const result = compareNames(setA, setB);
  assert.deepEqual(result.common.sort(), ['API_KEY', 'DB_URL']);
});

test('identifies variables missing in target (present in source, absent in target)', () => {
  const result = compareNames(setA, setB);
  assert.deepEqual(result.missingInTarget, ['SECRET']);
});

test('identifies variables missing in source (present in target, absent in source)', () => {
  const result = compareNames(setA, setB);
  assert.deepEqual(result.missingInSource, ['EXTRA_VAR']);
});

test('labels source and target correctly', () => {
  const result = compareNames(setA, setB);
  assert.equal(result.source, '1password');
  assert.equal(result.target, 'netlify');
});

test('summary counts are accurate', () => {
  const result = compareNames(setA, setB);
  assert.equal(result.summary.commonCount, 2);
  assert.equal(result.summary.missingInSourceCount, 1);
  assert.equal(result.summary.missingInTargetCount, 1);
});

test('handles identical sets', () => {
  const s = { label: 'same', names: ['A', 'B', 'C'] };
  const result = compareNames(s, { label: 'also-same', names: ['A', 'B', 'C'] });
  assert.equal(result.missingInSource.length, 0);
  assert.equal(result.missingInTarget.length, 0);
  assert.equal(result.common.length, 3);
});

test('handles empty source set', () => {
  const result = compareNames(
    { label: 'empty', names: [] },
    { label: 'full', names: ['A', 'B'] }
  );
  assert.deepEqual(result.missingInSource, ['A', 'B']);
  assert.deepEqual(result.missingInTarget, []);
});

test('handles empty target set', () => {
  const result = compareNames(
    { label: 'full', names: ['A', 'B'] },
    { label: 'empty', names: [] }
  );
  assert.deepEqual(result.missingInTarget, ['A', 'B']);
  assert.deepEqual(result.missingInSource, []);
});

test('does not accept or output values', () => {
  const result = compareNames(
    { label: 'source', names: ['KEY'] },
    { label: 'target', names: ['KEY'] }
  );
  const serialized = JSON.stringify(result);
  assert.ok(!serialized.includes('value'));
  assert.ok(!serialized.includes('secret'));
});
