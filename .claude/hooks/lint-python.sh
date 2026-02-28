#!/bin/bash
# .claude/hooks/lint-python.sh
# PostToolUse hook for Edit|Write: checks Python syntax after edits
set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only check Python files
if [[ "$FILE_PATH" == *.py ]]; then
  if ! python3 -m py_compile "$FILE_PATH" 2>/dev/null; then
    # Report syntax error but don't block (exit 0, not exit 2)
    # The error output will be visible to Claude
    echo "Python syntax error in $FILE_PATH" >&2
    python3 -m py_compile "$FILE_PATH" 2>&1 || true
  fi
fi

exit 0
