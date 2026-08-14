#!/usr/bin/env bash
# PostToolUse hook: detect cross-boundary imports between backend and frontend.
# Matcher: Write|Edit

set -euo pipefail

INPUT=$(cat)

if ! command -v python3 >/dev/null 2>&1; then
  echo "check-boundary-imports.sh: python3 not found on PATH, skipping boundary check" >&2
  exit 0
fi

PYCODE=$(cat <<'PYEOF'
import json
import re
import sys
import os

data = json.load(sys.stdin)
tool_input = data.get("tool_input", {})
tool_response = data.get("tool_response", {})
file_path = tool_input.get("file_path") or tool_response.get("filePath") or ""

if not file_path or not os.path.isfile(file_path):
    sys.exit(0)

with open(file_path, encoding="utf-8", errors="ignore") as f:
    text = f.read()

def check_violation(pattern, message):
    if re.search(pattern, text, re.IGNORECASE):
        print(json.dumps({
            "decision": "block",
            "reason": f"BOUNDARY VIOLATION: {file_path} — {message}",
        }))
        sys.exit(0)

normalized = file_path.replace("\\", "/")

if "/backend/" in normalized:
    check_violation(
        r"(from ['\"].*frontend|import.*frontend|require.*frontend|\.\./frontend)",
        "Backend references frontend module. Backend must be independently deployable.",
    )
    check_violation(
        r"(from ['\"].*shared/|import.*shared\.|require.*shared/|\.\./shared)",
        "Backend references a shared/ module. Use API contracts instead.",
    )
elif "/frontend/" in normalized:
    check_violation(
        r"(from ['\"].*backend|import.*backend|require.*backend|\.\./backend)",
        "Frontend references backend module. Frontend must be independently deployable.",
    )
    check_violation(
        r"(from ['\"].*shared/|import.*shared\.|require.*shared/|\.\./shared)",
        "Frontend references a shared/ module. Use API contracts instead.",
    )

sys.exit(0)
PYEOF
)

echo "$INPUT" | python3 -c "$PYCODE"
