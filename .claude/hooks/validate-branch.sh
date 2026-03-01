#!/bin/bash
# .claude/hooks/validate-branch.sh
# PreToolUse hook for Bash(git push*): validates branch naming convention
# Branch names must follow cf/<issue>-<description> format per CLAUDE.md
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Only run on git push commands
if ! echo "$COMMAND" | grep -qE '^git push'; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

BRANCH=$(git branch --show-current 2>/dev/null) || exit 0

# main is always ok to push
if [ "$BRANCH" = "main" ]; then
  exit 0
fi

# Validate branch naming: cf/<number>-<description>
if ! echo "$BRANCH" | grep -qE '^cf/[0-9]+-[a-z][a-z0-9-]+$'; then
  jq -n --arg branch "$BRANCH" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("Branch name does not follow convention: cf/<issue-number>-<description>. Current: " + $branch)
    }
  }'
else
  exit 0
fi
