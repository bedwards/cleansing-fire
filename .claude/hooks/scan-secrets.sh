#!/bin/bash
# .claude/hooks/scan-secrets.sh
# PreToolUse hook for Bash(git commit*): scans staged files for secret patterns
# Part of issue #77 and #98 (defense in depth — hooks + CI)
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Only run on git commit commands
if ! echo "$COMMAND" | grep -qE '^git commit'; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

# Get list of staged files
STAGED=$(git diff --cached --name-only 2>/dev/null) || exit 0
if [ -z "$STAGED" ]; then
  exit 0
fi

# Secret patterns to scan for
PATTERNS=(
  'sk-ant-[a-zA-Z0-9_-]{20,}'
  'AIzaSy[a-zA-Z0-9_-]{33}'
  'AKIA[A-Z0-9]{16}'
  'ghp_[a-zA-Z0-9]{36}'
  'sk-[a-zA-Z0-9]{48}'
  '-----BEGIN.*PRIVATE KEY-----'
)

FOUND=0
for pattern in "${PATTERNS[@]}"; do
  for file in $STAGED; do
    [ -f "$file" ] || continue
    if grep -qE "$pattern" "$file" 2>/dev/null; then
      echo "SECRET DETECTED in $file matching pattern: ${pattern:0:20}..." >&2
      FOUND=$((FOUND + 1))
    fi
  done
done

if [ $FOUND -gt 0 ]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Potential secret detected in staged files. Review and remove before committing."
    }
  }'
else
  exit 0
fi
