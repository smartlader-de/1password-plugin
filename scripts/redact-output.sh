#!/usr/bin/env bash
# redact-output.sh - defense-in-depth redaction of command output.
# Pipe command output through this script. Does NOT replace the rule to avoid
# printing secrets - use this as a safety net only.

sed -E \
  -e 's/ghp_[A-Za-z0-9]{36,}/[REDACTED]/g' \
  -e 's/sk-[A-Za-z0-9_-]{20,}/[REDACTED]/g' \
  -e 's/ops_[A-Za-z0-9_./+=-]{20,}/[REDACTED]/g' \
  -e 's/password=[^ 	&"'"'"'><;]+/password=[REDACTED]/gi' \
  -e 's/secret=[^ 	&"'"'"'><;]+/secret=[REDACTED]/gi' \
  -e 's/token=[^ 	&"'"'"'><;]+/token=[REDACTED]/gi' \
  -e 's/key=[^ 	&"'"'"'><;]{8,}/key=[REDACTED]/gi'
