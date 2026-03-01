#!/bin/bash
# .claude/hooks/protect-critical.sh
# PreToolUse hook for Edit|Write: protects safety-critical files from modification
# Requires explicit human approval before modifying core framework files
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Protected files that require human confirmation before modification
PROTECTED_FILES=(
  "integrity-manifest.json"
  "specs/agent-capabilities.yaml"
  "philosophy.md"
  "LICENSE"
  ".claude/settings.json"
  ".claude/hooks/"
)

BASENAME=$(basename "$FILE_PATH")
for protected in "${PROTECTED_FILES[@]}"; do
  if echo "$FILE_PATH" | grep -qF "$protected"; then
    jq -n --arg file "$FILE_PATH" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "ask",
        permissionDecisionReason: ("Safety-critical file modification: " + $file + ". This file is protected by the Recursive Accountability principle. Please confirm this change.")
      }
    }'
    exit 0
  fi
done

exit 0
