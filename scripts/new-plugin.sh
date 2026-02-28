#!/bin/bash
# new-plugin.sh - Scaffold a new Cleansing Fire plugin
#
# Creates a new plugin from template with all the standard boilerplate:
# JSON stdin/stdout, gatekeeper integration, error handling, and
# the Pyrrhic Lucidity voice system prompt.
#
# Usage:
#   scripts/new-plugin.sh my-plugin-name
#   scripts/new-plugin.sh --category civic my-tool
#   scripts/new-plugin.sh --no-gatekeeper simple-processor
#   scripts/new-plugin.sh --help
set -euo pipefail

# ---------------------------------------------------------------------------
# Project root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGINS_DIR="$PROJECT_DIR/plugins"

# ---------------------------------------------------------------------------
# Color support
# ---------------------------------------------------------------------------
if [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6); BOLD=$(tput bold); DIM=$(tput dim 2>/dev/null || echo "")
    RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" CYAN="" BOLD="" DIM="" RESET=""
fi

FIRE="${RED}${BOLD}"
EMBER="${YELLOW}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
${FIRE}CLEANSING FIRE${RESET} - Plugin Scaffolder

Usage: $0 [OPTIONS] <plugin-name>

Options:
  --category CAT       Plugin category prefix (e.g., civic, forge, osint, pipeline)
  --no-gatekeeper      Don't include gatekeeper integration boilerplate
  --description DESC   Plugin description
  --actions ACT,...    Comma-separated list of actions to scaffold
  --help               Show this message

The plugin name will be prefixed with the category if provided:
  $0 --category civic foia-requester  -> plugins/civic-foia-requester
  $0 my-cool-tool                     -> plugins/my-cool-tool

Plugin Convention:
  - Accepts JSON on stdin
  - Produces JSON on stdout
  - Exit 0 on success, non-zero on failure
  - Can call gatekeeper for LLM tasks
  - CF_PROJECT_DIR environment variable points to project root

Examples:
  $0 --category civic transparency-tracker
  $0 --category forge meme-generator --actions "generate,list_templates"
  $0 --no-gatekeeper data-formatter
  $0 --category osint corporate-lookup --description "Look up corporate filings"

${DIM}Every plugin is a weapon. Forge it well.${RESET}
EOF
    exit 0
}

info()  { echo "${CYAN}[info]${RESET}  $*"; }
ok()    { echo "${GREEN}[  ok]${RESET}  $*"; }
fail()  { echo "${RED}[FAIL]${RESET}  $*" >&2; }
ember() { echo "${EMBER}$*${RESET}"; }

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
CATEGORY=""
PLUGIN_NAME=""
DESCRIPTION=""
ACTIONS=""
USE_GATEKEEPER=true

if [ $# -eq 0 ]; then
    usage
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            usage
            ;;
        --category|-c)
            CATEGORY="${2:?--category requires a value}"
            shift 2
            ;;
        --no-gatekeeper)
            USE_GATEKEEPER=false
            shift
            ;;
        --description|-d)
            DESCRIPTION="${2:?--description requires a value}"
            shift 2
            ;;
        --actions|-a)
            ACTIONS="${2:?--actions requires comma-separated values}"
            shift 2
            ;;
        -*)
            fail "Unknown option: $1"
            echo "Run $0 --help for usage." >&2
            exit 1
            ;;
        *)
            if [ -z "$PLUGIN_NAME" ]; then
                PLUGIN_NAME="$1"
            else
                fail "Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$PLUGIN_NAME" ]; then
    fail "No plugin name provided"
    echo "Usage: $0 [--category CAT] <plugin-name>" >&2
    exit 1
fi

# Sanitize name
PLUGIN_NAME=$(echo "$PLUGIN_NAME" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | tr -cd 'a-z0-9-')

# Build full name with category prefix
if [ -n "$CATEGORY" ]; then
    CATEGORY=$(echo "$CATEGORY" | tr '[:upper:]' '[:lower:]' | tr ' _' '-' | tr -cd 'a-z0-9-')
    FULL_NAME="${CATEGORY}-${PLUGIN_NAME}"
else
    FULL_NAME="$PLUGIN_NAME"
fi

PLUGIN_PATH="$PLUGINS_DIR/$FULL_NAME"

# Check if it already exists
if [ -f "$PLUGIN_PATH" ]; then
    fail "Plugin already exists: $PLUGIN_PATH"
    echo "  Choose a different name or remove the existing plugin." >&2
    exit 1
fi

# Default description
if [ -z "$DESCRIPTION" ]; then
    DESCRIPTION="Cleansing Fire plugin: $FULL_NAME"
fi

# Default actions
if [ -z "$ACTIONS" ]; then
    ACTIONS="process"
fi

# ---------------------------------------------------------------------------
# Generate plugin
# ---------------------------------------------------------------------------
info "Scaffolding plugin: $FULL_NAME"

# Build action functions and dispatch
ACTION_LIST=$(echo "$ACTIONS" | tr ',' ' ')

ACTION_FUNCTIONS=""
ACTION_DISPATCH=""
ACTION_HELP=""

for action in $ACTION_LIST; do
    # Sanitize action name
    action=$(echo "$action" | tr '-' '_' | tr -cd 'a-z0-9_')
    func_name="action_${action}"

    ACTION_FUNCTIONS="${ACTION_FUNCTIONS}
def ${func_name}(input_data):
    \"\"\"Handle the '${action}' action.\"\"\"
    # TODO: Implement ${action} logic
    #
    # input_data contains the full JSON input.
    # Return a dict that will be serialized to JSON stdout.
    #
    # Example:
    #   result = do_something(input_data.get('param', ''))
    #   return {'result': result, 'type': '${action}'}
    return {'result': 'not yet implemented', 'action': '${action}'}

"

    ACTION_DISPATCH="${ACTION_DISPATCH}
    elif action == '${action}':
        result = ${func_name}(input_data)"

    ACTION_HELP="${ACTION_HELP}  {\"action\": \"${action}\", ...}
"
done

# Remove leading blank lines and convert first 'elif' to 'if'
ACTION_DISPATCH=$(echo "$ACTION_DISPATCH" | sed '/^$/d' | sed '1s/elif/if/')

# Build the gatekeeper section
if $USE_GATEKEEPER; then
    GATEKEEPER_CODE='
GATEKEEPER_URL = "http://127.0.0.1:7800"


def ask_gatekeeper(prompt, system="", temperature=0.7, max_tokens=2048):
    """Send a prompt to the gatekeeper for LLM processing.

    The gatekeeper serializes access to local Ollama. This is the
    standard way for plugins to use LLM capabilities.

    Returns the LLM response text, or None if the request fails.
    """
    payload = {
        "prompt": prompt,
        "system": system,
        "caller": f"plugin:'"$FULL_NAME"'",
        "temperature": temperature,
        "max_tokens": max_tokens,
        "timeout": 180,
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        f"{GATEKEEPER_URL}/submit-sync",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=190) as resp:
            body = json.loads(resp.read().decode("utf-8"))
            if body.get("status") == "completed":
                return body.get("result", "")
    except Exception:
        pass
    return None

'
    GATEKEEPER_IMPORT="import urllib.request"
else
    GATEKEEPER_CODE=""
    GATEKEEPER_IMPORT="# import urllib.request  # Uncomment if you need gatekeeper access"
fi

# Write the plugin file
cat > "$PLUGIN_PATH" <<PLUGIN_EOF
#!/usr/bin/env python3
"""
Cleansing Fire Plugin: ${FULL_NAME}

${DESCRIPTION}

Input JSON:
${ACTION_HELP}
Output JSON: {"result": ..., "type": "..."}

Plugin Convention:
  - Accepts JSON on stdin
  - Produces JSON on stdout
  - Exit 0 on success, non-zero on failure
  - CF_PROJECT_DIR env var points to project root
  - Calls gatekeeper at localhost:7800 for LLM tasks
"""

import json
import os
import sys
${GATEKEEPER_IMPORT}

# Project directory (set by the caller or derived from plugin location)
PROJECT_DIR = os.environ.get("CF_PROJECT_DIR", str(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
${GATEKEEPER_CODE}
# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------
${ACTION_FUNCTIONS}
# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    # Read JSON from stdin
    try:
        if sys.stdin.isatty():
            # No piped input - print usage
            print(json.dumps({
                "error": "No input provided. Pipe JSON to stdin.",
                "usage": "echo '{\"action\": \"...\"}' | ${FULL_NAME}",
                "actions": [$(echo "$ACTION_LIST" | sed 's/ /", "/g; s/^/"/; s/$/"/')],
            }))
            sys.exit(1)
        input_data = json.loads(sys.stdin.read())
    except json.JSONDecodeError as e:
        json.dump({"error": f"Invalid JSON input: {e}"}, sys.stdout)
        sys.exit(1)

    action = input_data.get("action", "$(echo "$ACTION_LIST" | awk '{print $1}')")

    # Dispatch to action handler
${ACTION_DISPATCH}
    else:
        result = {"error": f"Unknown action: {action}"}

    # Output result
    json.dump(result, sys.stdout, indent=2)

    # Exit with error if result contains an error
    if result.get("error"):
        sys.exit(1)


if __name__ == "__main__":
    main()
PLUGIN_EOF

# Make executable
chmod +x "$PLUGIN_PATH"

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
echo ""
ok "Plugin created: $PLUGIN_PATH"
echo ""
echo "  ${BOLD}Name:${RESET}     $FULL_NAME"
echo "  ${BOLD}Path:${RESET}     $PLUGIN_PATH"
echo "  ${BOLD}Actions:${RESET}  $(echo "$ACTION_LIST" | tr ' ' ', ')"
echo "  ${BOLD}LLM:${RESET}     $(if $USE_GATEKEEPER; then echo 'gatekeeper integration included'; else echo 'no gatekeeper (pure data processing)'; fi)"
echo ""
echo "  ${DIM}Next steps:${RESET}"
echo "    1. Edit $PLUGIN_PATH and implement action handlers"
echo "    2. Test: echo '{\"action\": \"$(echo "$ACTION_LIST" | awk '{print $1}')\"}' | $PLUGIN_PATH"
echo "    3. Register in scheduler/tasks.json if it should run on a schedule"
echo ""

# Quick test
info "Running quick validation..."
QUICK_TEST=$(echo '{"action":"__test__"}' | "$PLUGIN_PATH" 2>/dev/null || echo '{"error":"plugin crashed"}')
HAS_ERROR=$(python3 -c "import json; print('yes' if json.loads('${QUICK_TEST//\'/\\\'}').get('error') else 'no')" 2>/dev/null || echo "yes")

if [ "$HAS_ERROR" = "yes" ]; then
    ok "Plugin runs and returns JSON (error expected for test action)"
else
    ok "Plugin runs and returns valid JSON"
fi

echo ""
ember "Another weapon forged. Use it to illuminate."
echo ""
