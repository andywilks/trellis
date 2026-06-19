#!/usr/bin/env bash
# Pre-tool-use hook: scan edits for hardcoded secrets
# Called by Claude Code before any Edit or Write tool use

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // empty')
CONTENT=$(echo "$INPUT" | jq -r '.content // empty')

if [[ "$TOOL" != "Edit" && "$TOOL" != "Write" ]]; then
  exit 0
fi

# Patterns that suggest hardcoded secrets
SECRET_PATTERNS=(
  "password\s*=\s*['\"][^'\"]{6,}"
  "secret\s*=\s*['\"][^'\"]{6,}"
  "api[_-]?key\s*=\s*['\"][^'\"]{8,}"
  "AWS_SECRET_ACCESS_KEY\s*=\s*['\"][^'\"]{10,}"
  "private[_-]?key\s*=\s*['\"][^'\"]{10,}"
)

for pattern in "${SECRET_PATTERNS[@]}"; do
  if echo "$CONTENT" | grep -qiE "$pattern"; then
    echo '{"decision": "ask", "message": "This edit may contain a hardcoded secret. Please confirm this is intentional and not a real credential."}'
    exit 0
  fi
done

echo '{"decision": "allow"}'
