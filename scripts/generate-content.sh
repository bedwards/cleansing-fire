#!/bin/bash
# generate-content.sh - Generate content for distribution
#
# Wraps the forge-voice plugin to produce social posts, threads,
# poetry, agitprop, and other narrative content from the command line.
#
# Usage:
#   scripts/generate-content.sh --social "topic" --platform mastodon --tone sardonic
#   scripts/generate-content.sh --thread "topic" --max-posts 8
#   scripts/generate-content.sh --poem "raw data" --form haiku
#   scripts/generate-content.sh --agitprop "issue" --audience youth
#   scripts/generate-content.sh --digest items.json --period weekly
set -euo pipefail

# ---------------------------------------------------------------------------
# Project root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN="$PROJECT_DIR/plugins/forge-voice"
OUTPUT_DIR="$PROJECT_DIR/output/content"
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
${FIRE}CLEANSING FIRE${RESET} - Content Forge

Usage:
  $0 --social "topic or data" [OPTIONS]
  $0 --thread "topic" [OPTIONS]
  $0 --poem "raw data or topic" [OPTIONS]
  $0 --agitprop "issue" [OPTIONS]
  $0 --digest items.json [OPTIONS]

Content Types:
  --social TEXT       Generate a social media post
  --thread TEXT       Generate a threaded series of posts
  --poem TEXT         Transform data or topics into poetry
  --agitprop TEXT     Generate agitprop content (headline, body, CTA)
  --digest FILE       Generate a newsletter digest from JSON items

Options:
  --platform PLAT     Platform: mastodon, bluesky, matrix (default: mastodon)
  --tone TONE         Tone: urgent, analytical, poetic, sardonic, invitational, furious
                      (default: urgent)
  --form FORM         Poetry form: haiku, sonnet, prose, free, spoken (default: free)
  --audience AUD      Audience: general, youth, workers, elders, technical (default: general)
  --max-posts N       Max posts in a thread (default: 8)
  --period PERIOD     Digest period: daily, weekly, monthly (default: weekly)
  --copy              Copy output to clipboard
  --raw               Output raw JSON instead of pretty-printing
  --save              Save output to file in output/content/
  --help              Show this message

Examples:
  $0 --social "Palantir got \$2.4B in federal contracts" --tone sardonic
  $0 --thread "How dark money flows through 501(c)(4) organizations" --max-posts 6
  $0 --poem "Defense spending: \$886B. Education: \$79B." --form haiku
  $0 --agitprop "algorithmic wage theft" --audience workers

${DIM}Every dataset is a story. The Forge turns transparency into narrative.${RESET}
EOF
    exit 0
}

info()  { echo "${CYAN}[info]${RESET}  $*" >&2; }
ok()    { echo "${GREEN}[  ok]${RESET}  $*" >&2; }
fail()  { echo "${RED}[FAIL]${RESET}  $*" >&2; }
ember() { echo "${EMBER}$*${RESET}" >&2; }

check_gatekeeper() {
    if ! curl -sf http://127.0.0.1:7800/health &>/dev/null; then
        fail "Gatekeeper is not running on port 7800"
        echo "  Start with: python3 $PROJECT_DIR/daemon/gatekeeper.py" >&2
        exit 1
    fi
}

check_plugin() {
    if [ ! -x "$PLUGIN" ]; then
        fail "forge-voice plugin not found or not executable: $PLUGIN"
        echo "  Run bootstrap first: scripts/bootstrap.sh" >&2
        exit 1
    fi
}

copy_to_clipboard() {
    local text="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "$text" | pbcopy && ok "Copied to clipboard"
    elif command -v xclip &>/dev/null; then
        echo "$text" | xclip -selection clipboard && ok "Copied to clipboard"
    elif command -v xsel &>/dev/null; then
        echo "$text" | xsel --clipboard && ok "Copied to clipboard"
    elif command -v wl-copy &>/dev/null; then
        echo "$text" | wl-copy && ok "Copied to clipboard"
    else
        info "No clipboard tool found (pbcopy/xclip/xsel/wl-copy)"
    fi
}

timestamp() {
    date '+%Y%m%d-%H%M%S'
}

# Pretty-print based on content type
pretty_print() {
    local json_result="$1"
    local content_type="$2"

    echo "" >&2

    python3 - "$content_type" <<PYEOF "$json_result"
import json, sys, textwrap

data = json.loads(sys.argv[2]) if len(sys.argv) > 2 else json.loads(sys.stdin.read())
content_type = sys.argv[1]
width = 72

def hr():
    print("=" * width)

def box(text, label=""):
    hr()
    if label:
        print(f"  {label}")
        print("-" * width)
    for line in text.split("\\n"):
        for wrapped in textwrap.wrap(line, width - 4) or [""]:
            print(f"  {wrapped}")
    hr()

if content_type == "social":
    platform = data.get("platform", "")
    chars = data.get("char_count", len(data.get("content", "")))
    box(data.get("content", ""), f"[{platform.upper()}] ({chars} chars)")

elif content_type == "thread":
    posts = data.get("posts", [])
    count = len(posts)
    hr()
    print(f"  THREAD ({count} posts)")
    hr()
    for i, post in enumerate(posts, 1):
        print(f"\\n  --- Post {i}/{count} ---")
        for line in post.split("\\n"):
            for wrapped in textwrap.wrap(line, width - 4) or [""]:
                print(f"  {wrapped}")
    print()
    hr()

elif content_type == "poem":
    form = data.get("form", "free")
    box(data.get("poem", ""), f"[{form.upper()}]")

elif content_type == "agitprop":
    audience = data.get("audience", "general")
    box(data.get("content", ""), f"AGITPROP (audience: {audience})")

elif content_type == "digest":
    period = data.get("period", "weekly")
    box(data.get("content", ""), f"{period.upper()} DIGEST")

else:
    print(json.dumps(data, indent=2))
PYEOF
}

# Extract the displayable text from result JSON
extract_text() {
    local json_result="$1"
    python3 -c "
import json, sys
data = json.loads(sys.argv[1])
# Try various content fields
for key in ['content', 'poem', 'posts']:
    val = data.get(key)
    if val:
        if isinstance(val, list):
            print('\\n---\\n'.join(val))
        else:
            print(val)
        sys.exit(0)
print(json.dumps(data, indent=2))
" "$json_result"
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
MODE=""
INPUT_TEXT=""
PLATFORM="mastodon"
TONE="urgent"
FORM="free"
AUDIENCE="general"
MAX_POSTS=8
PERIOD="weekly"
DO_COPY=false
RAW_OUTPUT=false
DO_SAVE=false

if [ $# -eq 0 ]; then
    usage
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            usage
            ;;
        --social|-s)
            MODE="social"
            INPUT_TEXT="${2:?--social requires text}"
            shift 2
            ;;
        --thread|-t)
            MODE="thread"
            INPUT_TEXT="${2:?--thread requires a topic}"
            shift 2
            ;;
        --poem|-p)
            MODE="poem"
            INPUT_TEXT="${2:?--poem requires text/data}"
            shift 2
            ;;
        --agitprop|-a)
            MODE="agitprop"
            INPUT_TEXT="${2:?--agitprop requires an issue}"
            shift 2
            ;;
        --digest|-d)
            MODE="digest"
            INPUT_TEXT="${2:?--digest requires a JSON file path}"
            shift 2
            ;;
        --platform)
            PLATFORM="${2:?--platform requires a value}"
            shift 2
            ;;
        --tone)
            TONE="${2:?--tone requires a value}"
            shift 2
            ;;
        --form)
            FORM="${2:?--form requires a value}"
            shift 2
            ;;
        --audience)
            AUDIENCE="${2:?--audience requires a value}"
            shift 2
            ;;
        --max-posts)
            MAX_POSTS="${2:?--max-posts requires a number}"
            shift 2
            ;;
        --period)
            PERIOD="${2:?--period requires a value}"
            shift 2
            ;;
        --copy)
            DO_COPY=true
            shift
            ;;
        --raw)
            RAW_OUTPUT=true
            shift
            ;;
        --save)
            DO_SAVE=true
            shift
            ;;
        -*)
            fail "Unknown option: $1"
            echo "Run $0 --help for usage." >&2
            exit 1
            ;;
        *)
            # If no mode set yet, treat as social post
            if [ -z "$MODE" ]; then
                MODE="social"
                INPUT_TEXT="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$MODE" ]; then
    fail "No content type specified."
    echo "Run $0 --help for usage." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------
ember "  The Forge heats."

check_gatekeeper
check_plugin

# ---------------------------------------------------------------------------
# Build plugin input and run
# ---------------------------------------------------------------------------
info "Generating $MODE content..."

case "$MODE" in
    social)
        PLUGIN_INPUT=$(python3 -c "
import json
print(json.dumps({
    'action': 'social',
    'data': $(python3 -c "import json; print(json.dumps('$INPUT_TEXT'))" 2>/dev/null),
    'platform': '$PLATFORM',
    'tone': '$TONE',
}))
")
        ;;
    thread)
        PLUGIN_INPUT=$(python3 -c "
import json
print(json.dumps({
    'action': 'thread',
    'topic': '$INPUT_TEXT',
    'platform': '$PLATFORM',
    'max_posts': $MAX_POSTS,
}))
")
        ;;
    poem)
        PLUGIN_INPUT=$(python3 -c "
import json
print(json.dumps({
    'action': 'poeticize',
    'raw_data': '$INPUT_TEXT',
    'form': '$FORM',
}))
")
        ;;
    agitprop)
        PLUGIN_INPUT=$(python3 -c "
import json
print(json.dumps({
    'action': 'agitprop',
    'issue': '$INPUT_TEXT',
    'audience': '$AUDIENCE',
}))
")
        ;;
    digest)
        # Input is a JSON file
        if [ ! -f "$INPUT_TEXT" ]; then
            fail "Digest input file not found: $INPUT_TEXT"
            exit 1
        fi
        ITEMS=$(cat "$INPUT_TEXT")
        PLUGIN_INPUT=$(python3 -c "
import json, sys
items = json.loads('''$ITEMS''')
if isinstance(items, list):
    pass
elif isinstance(items, dict) and 'items' in items:
    items = items['items']
else:
    items = [items]
print(json.dumps({
    'action': 'digest',
    'items': items,
    'period': '$PERIOD',
}))
")
        ;;
esac

# Run the plugin
RESULT=$(echo "$PLUGIN_INPUT" | CF_PROJECT_DIR="$PROJECT_DIR" "$PLUGIN" 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    fail "Content generation failed"
    echo "$RESULT" >&2
    exit 1
fi

# Check for error in result
HAS_ERROR=$(python3 -c "
import json, sys
d = json.loads(sys.argv[1])
print('yes' if d.get('error') else 'no')
" "$RESULT" 2>/dev/null || echo "no")

if [ "$HAS_ERROR" = "yes" ]; then
    ERROR_MSG=$(python3 -c "import json,sys; print(json.loads(sys.argv[1]).get('error','unknown'))" "$RESULT" 2>/dev/null)
    fail "Generation error: $ERROR_MSG"
    exit 1
fi

# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------
if $RAW_OUTPUT; then
    echo "$RESULT"
else
    pretty_print "$RESULT" "$MODE"
    echo ""
    # Also print to stdout for piping
    extract_text "$RESULT"
fi

# Copy to clipboard if requested
if $DO_COPY; then
    TEXT=$(extract_text "$RESULT")
    copy_to_clipboard "$TEXT"
fi

# Save to file if requested
if $DO_SAVE; then
    TS=$(timestamp)
    SAVE_FILE="$OUTPUT_DIR/${TS}-${MODE}.json"
    echo "$RESULT" > "$SAVE_FILE"
    ok "Saved to $SAVE_FILE"

    # Also save plain text version
    TEXT_FILE="$OUTPUT_DIR/${TS}-${MODE}.txt"
    extract_text "$RESULT" > "$TEXT_FILE"
    ok "Text saved to $TEXT_FILE"
fi

echo "" >&2
ember "Words forged. What burns in them is yours to spread." >&2
