#!/bin/bash
# visualize.sh - Generate visualizations from the command line
#
# Wraps the forge-vision plugin to produce SVG diagrams, ASCII art,
# corruption meters, timelines, and more. The visual arm of the Forge.
#
# Usage:
#   scripts/visualize.sh --money-flow data.json
#   scripts/visualize.sh --corruption-meter 7.5
#   scripts/visualize.sh --timeline events.json
#   scripts/visualize.sh --ascii "CLEANSING FIRE"
#   scripts/visualize.sh --mermaid "corporate lobbying network"
#   scripts/visualize.sh --prompt "surveillance capitalism"
set -euo pipefail

# ---------------------------------------------------------------------------
# Project root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN="$PROJECT_DIR/plugins/forge-vision"
OUTPUT_DIR="$PROJECT_DIR/output/svg"
mkdir -p "$OUTPUT_DIR"

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
${FIRE}CLEANSING FIRE${RESET} - Visual Forge

Usage:
  $0 --money-flow FILE       Sankey diagram of money flows (JSON input)
  $0 --corruption-meter N    Corruption gauge (score 0-10)
  $0 --timeline FILE         Timeline visualization (JSON events)
  $0 --ascii "TEXT"           ASCII art with fire aesthetic
  $0 --mermaid "DESCRIPTION" Generate Mermaid.js diagram via LLM
  $0 --prompt "CONCEPT"      Generate image prompt for SD/FLUX

Options:
  --output FILE    Override output filename
  --no-open        Don't open result in browser/viewer
  --raw            Output raw JSON from plugin
  --help           Show this message

Input Formats:
  money-flow JSON:  {"flows": [{"from": "Corp", "to": "Senator", "amount": 50000}]}
  timeline JSON:    [{"date": "2024-01-15", "title": "Event", "description": "..."}]

Examples:
  $0 --corruption-meter 8.2
  $0 --ascii "FOLLOW THE MONEY"
  $0 --money-flow contracts.json
  $0 --timeline bill-history.json
  $0 --mermaid "how a bill becomes captured by corporate interests"
  $0 --prompt "the weight of surveillance on a city"

${DIM}Raw data goes in. Visual weapons come out.${RESET}
EOF
    exit 0
}

info()  { echo "${CYAN}[info]${RESET}  $*" >&2; }
ok()    { echo "${GREEN}[  ok]${RESET}  $*" >&2; }
fail()  { echo "${RED}[FAIL]${RESET}  $*" >&2; }
ember() { echo "${EMBER}$*${RESET}" >&2; }

check_gatekeeper() {
    # Only needed for LLM-backed actions (mermaid, prompt)
    if ! curl -sf http://127.0.0.1:7800/health &>/dev/null; then
        fail "Gatekeeper is not running on port 7800"
        echo "  Start with: python3 $PROJECT_DIR/daemon/gatekeeper.py" >&2
        exit 1
    fi
}

check_plugin() {
    if [ ! -x "$PLUGIN" ]; then
        fail "forge-vision plugin not found or not executable: $PLUGIN"
        echo "  Run bootstrap first: scripts/bootstrap.sh" >&2
        exit 1
    fi
}

open_file() {
    local file="$1"
    if $NO_OPEN; then return; fi
    if [[ "$(uname)" == "Darwin" ]]; then
        open "$file" 2>/dev/null || true
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$file" 2>/dev/null || true
    fi
}

timestamp() {
    date '+%Y%m%d-%H%M%S'
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
MODE=""
INPUT=""
CUSTOM_OUTPUT=""
NO_OPEN=false
RAW_OUTPUT=false
NEEDS_GATEKEEPER=false

if [ $# -eq 0 ]; then
    usage
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            usage
            ;;
        --money-flow)
            MODE="money_flow"
            INPUT="${2:?--money-flow requires a JSON file}"
            shift 2
            ;;
        --corruption-meter)
            MODE="corruption_meter"
            INPUT="${2:?--corruption-meter requires a score (0-10)}"
            shift 2
            ;;
        --timeline)
            MODE="timeline"
            INPUT="${2:?--timeline requires a JSON file}"
            shift 2
            ;;
        --ascii)
            MODE="ascii_fire"
            INPUT="${2:?--ascii requires text}"
            shift 2
            ;;
        --mermaid)
            MODE="mermaid"
            INPUT="${2:?--mermaid requires a description}"
            NEEDS_GATEKEEPER=true
            shift 2
            ;;
        --prompt)
            MODE="prompt"
            INPUT="${2:?--prompt requires a concept}"
            NEEDS_GATEKEEPER=true
            shift 2
            ;;
        --output|-o)
            CUSTOM_OUTPUT="${2:?--output requires a filename}"
            shift 2
            ;;
        --no-open)
            NO_OPEN=true
            shift
            ;;
        --raw)
            RAW_OUTPUT=true
            shift
            ;;
        -*)
            fail "Unknown option: $1"
            echo "Run $0 --help for usage." >&2
            exit 1
            ;;
        *)
            fail "Unexpected argument: $1"
            echo "Run $0 --help for usage." >&2
            exit 1
            ;;
    esac
done

if [ -z "$MODE" ]; then
    fail "No visualization type specified."
    echo "Run $0 --help for usage." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------
ember "  The visual forge ignites."

check_plugin
if $NEEDS_GATEKEEPER; then
    check_gatekeeper
fi

# ---------------------------------------------------------------------------
# Build plugin input
# ---------------------------------------------------------------------------
info "Generating $MODE visualization..."

case "$MODE" in
    money_flow)
        if [ ! -f "$INPUT" ]; then
            fail "File not found: $INPUT"
            exit 1
        fi
        # Validate JSON
        if ! python3 -c "import json; json.load(open('$INPUT'))" 2>/dev/null; then
            fail "Invalid JSON: $INPUT"
            exit 1
        fi
        PLUGIN_INPUT=$(python3 -c "
import json
with open('$INPUT') as f:
    data = json.load(f)
# Accept either {flows: [...]} or [{from, to, amount}, ...]
if isinstance(data, list):
    data = {'flows': data}
print(json.dumps({'action': 'money_flow', 'data': data}))
")
        ;;

    corruption_meter)
        # Validate score
        if ! python3 -c "s=float('$INPUT'); assert 0<=s<=10" 2>/dev/null; then
            fail "Score must be a number between 0 and 10, got: $INPUT"
            exit 1
        fi
        PLUGIN_INPUT="{\"action\": \"corruption_meter\", \"score\": $INPUT}"
        ;;

    timeline)
        if [ ! -f "$INPUT" ]; then
            fail "File not found: $INPUT"
            exit 1
        fi
        if ! python3 -c "import json; json.load(open('$INPUT'))" 2>/dev/null; then
            fail "Invalid JSON: $INPUT"
            exit 1
        fi
        PLUGIN_INPUT=$(python3 -c "
import json
with open('$INPUT') as f:
    data = json.load(f)
events = data if isinstance(data, list) else data.get('events', [data])
print(json.dumps({'action': 'timeline', 'events': events}))
")
        ;;

    ascii_fire)
        PLUGIN_INPUT=$(python3 -c "
import json
print(json.dumps({'action': 'ascii_fire', 'text': '$INPUT'}))
")
        ;;

    mermaid)
        PLUGIN_INPUT=$(python3 -c "
import json
print(json.dumps({'action': 'mermaid', 'description': '$INPUT'}))
")
        ;;

    prompt)
        PLUGIN_INPUT=$(python3 -c "
import json
print(json.dumps({'action': 'prompt', 'concept': '$INPUT'}))
")
        ;;
esac

# ---------------------------------------------------------------------------
# Run plugin
# ---------------------------------------------------------------------------
RESULT=$(echo "$PLUGIN_INPUT" | CF_PROJECT_DIR="$PROJECT_DIR" "$PLUGIN" 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    fail "Visualization generation failed"
    echo "$RESULT" >&2
    exit 1
fi

# Check for error
HAS_ERROR=$(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
print('yes' if d.get('error') else 'no')
" "$RESULT" 2>/dev/null || echo "no")

if [ "$HAS_ERROR" = "yes" ]; then
    ERROR_MSG=$(python3 -c "import json,sys; print(json.loads(sys.argv[1]).get('error','unknown'))" "$RESULT" 2>/dev/null)
    fail "Error: $ERROR_MSG"
    exit 1
fi

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
TS=$(timestamp)

if $RAW_OUTPUT; then
    echo "$RESULT"
    exit 0
fi

case "$MODE" in
    money_flow|corruption_meter|timeline)
        # Extract SVG and save to file
        SVG_FILE="${CUSTOM_OUTPUT:-$OUTPUT_DIR/${TS}-${MODE}.svg}"
        python3 -c "
import json, sys
d = json.loads(sys.argv[1])
svg = d.get('svg', '')
if svg:
    print(svg)
else:
    print('No SVG generated', file=sys.stderr)
    sys.exit(1)
" "$RESULT" > "$SVG_FILE"

        if [ -s "$SVG_FILE" ]; then
            ok "SVG saved: $SVG_FILE"
            info "Size: $(wc -c < "$SVG_FILE" | tr -d ' ') bytes"
            open_file "$SVG_FILE"
        else
            fail "Empty SVG output"
            rm -f "$SVG_FILE"
            exit 1
        fi
        ;;

    ascii_fire)
        # Print ASCII art to terminal
        ASCII=$(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
print(d.get('ascii', ''))
" "$RESULT")

        echo ""
        echo "${FIRE}${ASCII}${RESET}"
        echo ""

        # Also save to file
        TEXT_FILE="${CUSTOM_OUTPUT:-$OUTPUT_DIR/${TS}-ascii.txt}"
        echo "$ASCII" > "$TEXT_FILE"
        ok "Saved: $TEXT_FILE"
        ;;

    mermaid)
        # Print Mermaid syntax and save
        MERMAID=$(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
print(d.get('mermaid', ''))
" "$RESULT")

        echo ""
        echo "${BOLD}Mermaid.js Diagram:${RESET}"
        echo "${DIM}---${RESET}"
        echo "$MERMAID"
        echo "${DIM}---${RESET}"
        echo ""

        MERMAID_FILE="${CUSTOM_OUTPUT:-$OUTPUT_DIR/${TS}-diagram.mmd}"
        echo "$MERMAID" > "$MERMAID_FILE"
        ok "Saved: $MERMAID_FILE"
        info "Render at: https://mermaid.live or with: mmdc -i $MERMAID_FILE -o diagram.svg"

        # Create a simple HTML wrapper for viewing
        HTML_FILE="${MERMAID_FILE%.mmd}.html"
        cat > "$HTML_FILE" <<HTMLEOF
<!DOCTYPE html>
<html><head>
<title>Cleansing Fire - Diagram</title>
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<style>body{background:#0a0a0a;display:flex;justify-content:center;padding:2em;}
.mermaid{background:#111;padding:2em;border:1px solid #333;border-radius:8px;}</style>
</head><body>
<div class="mermaid">
$MERMAID
</div>
<script>mermaid.initialize({startOnLoad:true, theme:'dark'});</script>
</body></html>
HTMLEOF
        ok "HTML viewer: $HTML_FILE"
        open_file "$HTML_FILE"
        ;;

    prompt)
        # Print image generation prompt
        PROMPT_TEXT=$(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
print(d.get('prompt', ''))
" "$RESULT")

        echo ""
        echo "${BOLD}Image Generation Prompt:${RESET}"
        echo "${EMBER}---${RESET}"
        echo "$PROMPT_TEXT"
        echo "${EMBER}---${RESET}"
        echo ""

        PROMPT_FILE="${CUSTOM_OUTPUT:-$OUTPUT_DIR/${TS}-image-prompt.txt}"
        echo "$PROMPT_TEXT" > "$PROMPT_FILE"
        ok "Saved: $PROMPT_FILE"
        ;;
esac

echo "" >&2
ember "Vision forged from data. See what was hidden." >&2
