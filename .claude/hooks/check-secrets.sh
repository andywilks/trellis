#!/usr/bin/env bash
# Pre-tool-use hook: scan edits for hardcoded secrets
# Called by Claude Code before any Edit or Write tool use

set -euo pipefail

INPUT=$(cat)

if ! command -v python3 >/dev/null 2>&1; then
  echo "check-secrets.sh: python3 not found on PATH, skipping secret scan" >&2
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

PYCODE=$(cat <<'PYEOF'
import json
import re
import sys

data = json.load(sys.stdin)
tool = data.get("tool_name", "")

if tool not in ("Edit", "Write"):
    sys.exit(0)

tool_input = data.get("tool_input", {})
content = tool_input.get("content") or tool_input.get("new_string") or ""

secret_patterns = [
    r"password\s*=\s*['\"][^'\"]{6,}",
    r"secret\s*=\s*['\"][^'\"]{6,}",
    r"api[_-]?key\s*=\s*['\"][^'\"]{8,}",
    r"AWS_SECRET_ACCESS_KEY\s*=\s*['\"][^'\"]{10,}",
    r"private[_-]?key\s*=\s*['\"][^'\"]{10,}",
]

for pattern in secret_patterns:
    if re.search(pattern, content, re.IGNORECASE):
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": "This edit may contain a hardcoded secret. Please confirm this is intentional and not a real credential.",
            }
        }))
        sys.exit(0)

print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}))
PYEOF
)

echo "$INPUT" | python3 -c "$PYCODE"
