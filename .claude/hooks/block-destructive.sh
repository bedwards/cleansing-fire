#!/bin/bash
# .claude/hooks/block-destructive.sh
# PreToolUse hook for Bash: blocks dangerous shell commands
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Block destructive or dangerous commands
if echo "$COMMAND" | grep -qE 'rm -rf /|rm -rf \*|sudo |curl.*\| ?sh|curl.*\| ?bash|wget.*\| ?sh|wget.*\| ?bash|mkfs\.|dd if=|:(){ :|shutdown|reboot|init 0|init 6'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive or dangerous command blocked by Cleansing Fire safety hook"
    }
  }'
else
  exit 0
fi
