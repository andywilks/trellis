#!/usr/bin/env bash
# Pre-tool-use hook: block edits to existing Flyway migration files

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.path // empty')

if [[ "$TOOL" != "Edit" ]]; then
  exit 0
fi

if [[ "$FILE_PATH" =~ db/migration/V[0-9]+__.+\.sql$ ]]; then
  # Allow creation of new files, block edits to existing ones
  if [[ -f "$FILE_PATH" ]]; then
    echo '{"decision": "deny", "message": "Flyway migration scripts are immutable once created. Create a new migration script instead of editing an existing one."}'
    exit 0
  fi
fi

echo '{"decision": "allow"}'
