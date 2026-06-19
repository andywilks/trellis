#!/usr/bin/env bash
# Detects cross-boundary imports between backend and frontend modules.
# Exits non-zero with a message if a violation is found.

FILE="$1"

if [ -z "$FILE" ]; then
  exit 0
fi

# Determine which module the edited file belongs to
case "$FILE" in
  backend/*)
    # Backend Java/Kotlin files must not reference frontend paths
    if grep -qEi '(from ["\x27].*frontend|import.*frontend|require.*frontend|\.\./frontend)' "$FILE" 2>/dev/null; then
      echo "BOUNDARY VIOLATION: $FILE contains a reference to the frontend module."
      echo "Backend must be independently deployable — no cross-boundary imports allowed."
      exit 1
    fi
    # Check for references to a shared/ or common/ directory (which should not exist)
    if grep -qEi '(from ["\x27].*shared/|import.*shared\.|require.*shared/|\.\./shared)' "$FILE" 2>/dev/null; then
      echo "BOUNDARY VIOLATION: $FILE references a shared/ module."
      echo "No shared code between backend and frontend — use API contracts instead."
      exit 1
    fi
    ;;
  frontend/*)
    # Frontend TS/JS files must not reference backend paths
    if grep -qEi '(from ["\x27].*backend|import.*backend|require.*backend|\.\./backend)' "$FILE" 2>/dev/null; then
      echo "BOUNDARY VIOLATION: $FILE contains a reference to the backend module."
      echo "Frontend must be independently deployable — no cross-boundary imports allowed."
      exit 1
    fi
    if grep -qEi '(from ["\x27].*shared/|import.*shared\.|require.*shared/|\.\./shared)' "$FILE" 2>/dev/null; then
      echo "BOUNDARY VIOLATION: $FILE references a shared/ module."
      echo "No shared code between backend and frontend — use API contracts instead."
      exit 1
    fi
    ;;
esac

exit 0
