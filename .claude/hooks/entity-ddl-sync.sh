#!/usr/bin/env bash
# PreToolUse hook: flag edits to JPA entities where the matching schema DDL
# script under docs/design/db/ has not also been touched.
# Matcher: Edit|Write

set -euo pipefail

INPUT=$(cat)

if ! command -v python3 >/dev/null 2>&1; then
  echo "entity-ddl-sync.sh: python3 not found on PATH, skipping entity/DDL sync check" >&2
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
fi

PYCODE=$(cat <<'PYEOF'
import json
import re
import subprocess
import sys

data = json.load(sys.stdin)
tool = data.get("tool_name", "")

if tool not in ("Edit", "Write"):
    sys.exit(0)

tool_input = data.get("tool_input", {})
file_path = tool_input.get("file_path", "")
normalized = file_path.replace("\\", "/")

if not re.search(r"/domain/[^/]+\.java$", normalized):
    sys.exit(0)

def allow():
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}))
    sys.exit(0)

try:
    result = subprocess.run(
        ["git", "status", "--porcelain", "--", "docs/design/db"],
        capture_output=True, text=True, timeout=10, check=False,
    )
except Exception:
    # git unavailable or not a repo — don't block on infrastructure issues
    allow()

if result.returncode != 0:
    allow()

if result.stdout.strip():
    # A DDL script under docs/design/db/ is already staged/modified/untracked
    # in this working tree — assume it's being kept in sync.
    allow()

print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "ask",
        "permissionDecisionReason": (
            f"You're editing entity file '{file_path}' but no schema DDL script under "
            "docs/design/db/ appears to have been changed in this working tree. If this "
            "entity change affects the database schema (new/changed/removed columns, "
            "constraints, tables), update the matching docs/design/db/{create|alter}-"
            "{feature}-tables.sql script by hand in the same change — see .claude/rules/sql.md. "
            "If this edit doesn't affect the schema, it's safe to proceed."
        ),
    }
}))
PYEOF
)

echo "$INPUT" | python3 -c "$PYCODE"
