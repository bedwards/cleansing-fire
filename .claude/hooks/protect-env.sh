#!/bin/bash
# .claude/hooks/protect-env.sh
# PreToolUse hook for Read: prevents reading .env files
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Block reading .env files and secrets directory
if echo "$FILE_PATH" | grep -qE '\.env($|\.)|/secrets/'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Reading .env and secrets files is blocked for security"
    }
  }'
else
  exit 0
fi
