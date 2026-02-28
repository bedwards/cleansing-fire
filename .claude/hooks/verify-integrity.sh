#!/bin/bash
# .claude/hooks/verify-integrity.sh
# PostToolUse hook for Edit|Write: logs file changes for integrity tracking
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Log the change for integrity tracking
if [ -n "$CLAUDE_PROJECT_DIR" ] && [ -d "$CLAUDE_PROJECT_DIR/.claude" ]; then
  LOG_FILE="$CLAUDE_PROJECT_DIR/.claude/change.log"
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) CHANGED: $FILE_PATH" >> "$LOG_FILE"
fi

exit 0
