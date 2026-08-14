#!/usr/bin/env bash
# Pre-tool-use hook: flag edits to build.gradle.kts or package.json that add new dependencies
# Reminds agents to check the approved catalog before proceeding

set -euo pipefail

INPUT=$(cat)

if ! command -v python3 >/dev/null 2>&1; then
  echo "check-approved-catalog.sh: python3 not found on PATH, skipping catalog check" >&2
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
file_path = tool_input.get("file_path", "")
content = tool_input.get("new_string") or tool_input.get("content") or ""

if not re.search(r"(build\.gradle\.kts|package\.json|requirements\.txt)$", file_path):
    sys.exit(0)

forbidden_patterns = [
    "mongodb",
    "mysql-connector",
    r"com\.oracle",
    "undertow",
    "angularjs",
    "jquery",
    "styled-components",
    "cypress",
    "gatling",
    "selenium",
]

for pattern in forbidden_patterns:
    if re.search(pattern, content, re.IGNORECASE):
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": f"Dependency '{pattern}' is in the Forbidden list of the approved technology catalog. Load the approved-catalog skill and choose an approved alternative.",
            }
        }))
        sys.exit(0)

if re.search(r"<dependency>|\"dependencies\"|\"devDependencies\"", content, re.IGNORECASE):
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": "You are adding or modifying dependencies. Have you verified all additions against the approved-catalog skill? Forbidden technologies will be blocked.",
        }
    }))
    sys.exit(0)

print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}))
PYEOF
)

echo "$INPUT" | python3 -c "$PYCODE"
