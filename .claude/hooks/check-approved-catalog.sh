#!/usr/bin/env bash
# Pre-tool-use hook: flag edits to pom.xml or package.json that add new dependencies
# Reminds agents to check the approved catalog before proceeding

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.new_str // .content // empty')

if [[ "$TOOL" != "Edit" && "$TOOL" != "Write" ]]; then
  exit 0
fi

# Check if editing dependency files
if [[ "$FILE_PATH" =~ pom\.xml$ ]] || [[ "$FILE_PATH" =~ package\.json$ ]] || [[ "$FILE_PATH" =~ requirements\.txt$ ]]; then

  # Check for forbidden patterns
  FORBIDDEN_PATTERNS=(
    "mongodb"
    "mysql-connector"
    "com\.oracle"
    "undertow"
    "angularjs"
    "jquery"
    "styled-components"
    "cypress"
    "gatling"
    "selenium"
  )

  for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if echo "$CONTENT" | grep -qi "$pattern"; then
      echo "{\"decision\": \"deny\", \"message\": \"Dependency '$pattern' is in the Forbidden list of the approved technology catalog. Load the approved-catalog skill and choose an approved alternative.\"}"
      exit 0
    fi
  done

  # Warn for any new dependency addition to prompt catalog check
  if echo "$CONTENT" | grep -qiE "<dependency>|\"dependencies\"|\"devDependencies\""; then
    echo "{\"decision\": \"ask\", \"message\": \"You are adding or modifying dependencies. Have you verified all additions against the approved-catalog skill? Forbidden technologies will be blocked.\"}"
    exit 0
  fi
fi

echo '{"decision": "allow"}'
