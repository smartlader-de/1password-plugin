'use strict';

const { test } = require('node:test');
const assert = require('node:assert/strict');
const { checkAccountBinding } = require('../scripts/check-account-binding.js');

const bindingFile = {
  version: 1,
  bindings: [
    {
      project: 'my-app',
      context: 'production',
      environment_name: 'my-app/production',
      account_id: 'EXAMPLEACCOUNTID0000000000',
      environment_id: 'exampleenvironmentid000000',
    },
  ],
};

test('allows matching authenticated account', () => {
  const result = checkAccountBinding(bindingFile, {
    accountId: 'EXAMPLEACCOUNTID0000000000',
    environmentName: 'my-app/production',
  });

  assert.equal(result.status, 'match');
  assert.equal(result.okToContinue, true);
});

test('stops on account mismatch before writes', () => {
  const result = checkAccountBinding(bindingFile, {
    accountId: 'DIFFERENTACCOUNTID',
    environmentName: 'my-app/production',
  });

  assert.equal(result.status, 'account_mismatch');
  assert.equal(result.okToContinue, false);
  assert.equal(result.savedAccountId, 'EXAMPLEACCOUNTID0000000000');
  assert.equal(result.currentAccountId, 'DIFFERENTACCOUNTID');
});

test('finds binding by project and context when environment name is absent', () => {
  const result = checkAccountBinding(bindingFile, {
    accountId: 'EXAMPLEACCOUNTID0000000000',
    project: 'my-app',
    context: 'production',
  });

  assert.equal(result.status, 'match');
});

test('allows metadata discovery when no binding exists', () => {
  const result = checkAccountBinding(bindingFile, {
    accountId: 'EXAMPLEACCOUNTID0000000000',
    environmentName: 'other/project',
  });

  assert.equal(result.status, 'no_binding');
  assert.equal(result.okToContinue, true);
});

test('does not include secret-shaped fields in output', () => {
  const result = checkAccountBinding(bindingFile, {
    accountId: 'DIFFERENTACCOUNTID',
    environmentName: 'my-app/production',
  });
  const serialized = JSON.stringify(result);

  assert.ok(!serialized.includes('value'));
  assert.ok(!serialized.includes('secret'));
  assert.ok(!serialized.includes('hash'));
});
