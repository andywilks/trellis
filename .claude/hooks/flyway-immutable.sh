#!/usr/bin/env bash
# PreToolUse hook: block edits to existing Flyway migration files.
# Matcher: Edit

set -euo pipefail

INPUT=$(cat)

if ! command -v python3 >/dev/null 2>&1; then
  echo "flyway-immutable.sh: python3 not found on PATH, skipping immutability check" >&2
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

PYCODE=$(cat <<'PYEOF'
import json
import re
import sys
import os

data = json.load(sys.stdin)
file_path = data.get("tool_input", {}).get("file_path", "")

if not file_path:
    sys.exit(0)

normalized = file_path.replace("\\", "/")

if re.search(r"db/migration/V[0-9]+__.+\.sql$", normalized) and os.path.isfile(file_path):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": "Flyway migration scripts are immutable once created. Create a new migration script instead of editing an existing one.",
        }
    }))
    sys.exit(0)

sys.exit(0)
PYEOF
)

echo "$INPUT" | python3 -c "$PYCODE"
