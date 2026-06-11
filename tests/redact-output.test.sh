#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$(dirname "$0")/../scripts/redact-output.sh"
PASS=0
FAIL=0

assert_redacted() {
  local desc="$1"
  local input="$2"
  local output
  output=$(printf '%s' "$input" | bash "$SCRIPT")
  if echo "$output" | grep -q '\[REDACTED\]'; then
    echo "PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc"
    echo "  Input:  $input"
    echo "  Output: $output"
    FAIL=$((FAIL + 1))
  fi
}

assert_not_redacted() {
  local desc="$1"
  local input="$2"
  local output
  output=$(printf '%s' "$input" | bash "$SCRIPT")
  if echo "$output" | grep -q '\[REDACTED\]'; then
    echo "FAIL (over-redacted): $desc"
    echo "  Input:  $input"
    echo "  Output: $output"
    FAIL=$((FAIL + 1))
  else
    echo "PASS: $desc"
    PASS=$((PASS + 1))
  fi
}

assert_redacted "GitHub PAT" "token: ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
assert_redacted "OpenAI key" "Authorization: Bearer sk-abcdefghijklmnopqrstuvwxyz1234"
assert_redacted "1Password service account" "ops_eyJhbGciOiJFUzI1NiIsImtpZCI6InRlc3Qi"
assert_redacted "password= assignment" "url=postgres://user:pass@host/db?password=mysecret123"
assert_redacted "secret= assignment" "secret=abc123def456ghi789"
assert_redacted "token= assignment" "token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"

assert_not_redacted "plain text log line" "INFO: server started on port 3000"
assert_not_redacted "short key word (not a value)" "enter your password:"
assert_not_redacted "variable name only" "DATABASE_URL is not set"

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
