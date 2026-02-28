#!/bin/bash
# investigate.sh - Run investigations from the command line
#
# Wraps the pipeline-data-to-fire plugin with a friendly CLI interface.
# Checks gatekeeper health, routes to the right pipeline action,
# saves output, and opens results in a browser when possible.
#
# Usage:
#   scripts/investigate.sh "Palantir"
#   scripts/investigate.sh --bill 12345
#   scripts/investigate.sh --weekly "surveillance,antitrust"
#   scripts/investigate.sh --help
set -euo pipefail

# ---------------------------------------------------------------------------
# Project root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN="$PROJECT_DIR/plugins/pipeline-data-to-fire"
OUTPUT_DIR="$PROJECT_DIR/output"
REPORTS_DIR="$OUTPUT_DIR/reports"

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
${FIRE}CLEANSING FIRE${RESET} - Investigation Runner

Usage:
  $0 <target>                         Full investigation of an entity
  $0 --bill <bill_id>                 Spotlight a specific bill
  $0 --weekly "topic1,topic2,..."     Generate weekly fire digest

Options:
  --no-open         Don't open results in browser
  --output-dir DIR  Override output directory (default: output/)
  --help            Show this message

Examples:
  $0 "Palantir"
  $0 "Lockheed Martin"
  $0 --bill 1234567
  $0 --weekly "surveillance,antitrust,transparency"

${DIM}Every dollar traced is a poem. Every vote recorded is a verse.${RESET}
${DIM}The pipeline turns transparency into narrative.${RESET}
EOF
    exit 0
}

info()  { echo "${CYAN}[info]${RESET}  $*"; }
ok()    { echo "${GREEN}[  ok]${RESET}  $*"; }
fail()  { echo "${RED}[FAIL]${RESET}  $*" >&2; }
ember() { echo "${EMBER}$*${RESET}"; }

open_file() {
    local file="$1"
    if $NO_OPEN; then return; fi
    if [[ "$(uname)" == "Darwin" ]]; then
        open "$file" 2>/dev/null || true
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$file" 2>/dev/null || true
    fi
}

check_gatekeeper() {
    if ! curl -sf http://127.0.0.1:7800/health &>/dev/null; then
        fail "Gatekeeper is not running on port 7800"
        echo ""
        echo "  The gatekeeper serializes GPU access for local LLM tasks."
        echo "  Start it with:"
        echo "    ${DIM}python3 $PROJECT_DIR/daemon/gatekeeper.py${RESET}"
        echo ""
        echo "  Or install as a background service:"
        echo "    ${DIM}$PROJECT_DIR/scripts/gatekeeper-ctl.sh install${RESET}"
        echo ""
        exit 1
    fi
    ok "Gatekeeper is running"
}

check_plugin() {
    if [ ! -x "$PLUGIN" ]; then
        fail "Pipeline plugin not found or not executable: $PLUGIN"
        echo "  Run bootstrap first: scripts/bootstrap.sh"
        exit 1
    fi
}

timestamp() {
    date '+%Y%m%d-%H%M%S'
}

# Pretty-print JSON results
pretty_print_results() {
    local json_file="$1"
    local target="$2"

    echo ""
    ember "=========================================="
    ember "  INVESTIGATION: $target"
    ember "=========================================="
    echo ""

    # Extract key information with Python
    python3 - "$json_file" <<'PYEOF'
import json, sys

with open(sys.argv[1]) as f:
    data = json.load(f)

def section(title):
    print(f"\033[1m{title}\033[0m")
    print("-" * 40)

# Investigation results
inv = data.get("investigation", {})
if inv and not inv.get("error"):
    # Contracts
    contracts = inv.get("contracts", {})
    if contracts.get("awards"):
        section("Federal Contracts")
        total = contracts.get("total_amount", 0)
        print(f"  Total: ${total:,.0f}")
        print(f"  Awards: {len(contracts['awards'])}")
        for a in contracts["awards"][:5]:
            print(f"    - {a.get('description', 'N/A')[:60]}: ${a.get('amount', 0):,.0f}")
        print()

    # Political activity
    politics = inv.get("political_activity", {})
    if politics.get("committees"):
        section("Political Activity")
        for c in politics["committees"][:5]:
            print(f"  - {c.get('name', 'Unknown')}: ${c.get('total_receipts', 0):,.0f}")
        print()

    # AI Analysis
    analysis = inv.get("cross_reference_analysis", "")
    if analysis:
        section("Cross-Reference Analysis")
        # Print first 500 chars
        print(f"  {analysis[:500]}")
        if len(analysis) > 500:
            print(f"  ... [{len(analysis) - 500} more characters]")
        print()

# Assets summary
assets = data.get("assets", {})
if assets:
    section("Generated Assets")
    for key, value in assets.items():
        if isinstance(value, str) and len(value) > 100:
            print(f"  {key}: [{len(value)} chars]")
        elif isinstance(value, list):
            print(f"  {key}: [{len(value)} items]")
        elif isinstance(value, str) and value.endswith(".svg"):
            print(f"  {key}: {value}")
        else:
            display = str(value)[:80]
            print(f"  {key}: {display}")
    print()

# Package file
pkg = data.get("package_file", "")
if pkg:
    print(f"Full package: {pkg}")
PYEOF
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
MODE="investigate"
TARGET=""
BILL_ID=""
TOPICS=""
NO_OPEN=false
CUSTOM_OUTPUT=""

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            usage
            ;;
        --bill|-b)
            MODE="bill"
            BILL_ID="${2:?--bill requires a bill ID}"
            shift 2
            ;;
        --weekly|-w)
            MODE="weekly"
            TOPICS="${2:?--weekly requires comma-separated topics}"
            shift 2
            ;;
        --no-open)
            NO_OPEN=true
            shift
            ;;
        --output-dir)
            CUSTOM_OUTPUT="${2:?--output-dir requires a path}"
            shift 2
            ;;
        -*)
            fail "Unknown option: $1"
            echo "Run $0 --help for usage."
            exit 1
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

# Override output if specified
if [ -n "$CUSTOM_OUTPUT" ]; then
    OUTPUT_DIR="$CUSTOM_OUTPUT"
    REPORTS_DIR="$CUSTOM_OUTPUT"
fi

mkdir -p "$OUTPUT_DIR" "$REPORTS_DIR"

# ---------------------------------------------------------------------------
# Validate input
# ---------------------------------------------------------------------------
case "$MODE" in
    investigate)
        if [ -z "$TARGET" ]; then
            fail "No target specified."
            echo "Usage: $0 <target>"
            echo "Example: $0 \"Palantir\""
            exit 1
        fi
        ;;
    bill)
        if [ -z "$BILL_ID" ]; then
            fail "No bill ID specified."
            exit 1
        fi
        ;;
    weekly)
        if [ -z "$TOPICS" ]; then
            fail "No topics specified."
            exit 1
        fi
        ;;
esac

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
echo ""
ember "  The Forge ignites."
echo ""

check_gatekeeper
check_plugin

# ---------------------------------------------------------------------------
# Run investigation
# ---------------------------------------------------------------------------
TS=$(timestamp)

case "$MODE" in
    investigate)
        info "Running full investigation: $TARGET"
        info "This calls multiple plugins and may take several minutes..."
        echo ""

        RESULT_FILE="$REPORTS_DIR/${TS}-investigate-$(echo "$TARGET" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-').json"

        echo "{\"action\": \"full_investigation\", \"target\": \"$TARGET\"}" \
            | CF_PROJECT_DIR="$PROJECT_DIR" "$PLUGIN" \
            > "$RESULT_FILE" 2>/dev/null

        if [ $? -eq 0 ] && [ -s "$RESULT_FILE" ]; then
            ok "Investigation complete: $RESULT_FILE"
            pretty_print_results "$RESULT_FILE" "$TARGET"

            # Open SVG assets if they exist
            for svg in "$OUTPUT_DIR"/*"$(echo "$TARGET" | tr '[:upper:]' '[:lower:]')"*.svg; do
                [ -f "$svg" ] || continue
                info "SVG: $svg"
                open_file "$svg"
            done
        else
            fail "Investigation failed or produced no output"
            [ -f "$RESULT_FILE" ] && cat "$RESULT_FILE" >&2
            exit 1
        fi
        ;;

    bill)
        info "Running bill spotlight: $BILL_ID"

        RESULT_FILE="$REPORTS_DIR/${TS}-bill-${BILL_ID}.json"

        echo "{\"action\": \"bill_spotlight\", \"bill_id\": $BILL_ID}" \
            | CF_PROJECT_DIR="$PROJECT_DIR" "$PLUGIN" \
            > "$RESULT_FILE" 2>/dev/null

        if [ $? -eq 0 ] && [ -s "$RESULT_FILE" ]; then
            ok "Bill spotlight complete: $RESULT_FILE"
            pretty_print_results "$RESULT_FILE" "Bill #$BILL_ID"

            for svg in "$OUTPUT_DIR"/*bill-${BILL_ID}*.svg; do
                [ -f "$svg" ] || continue
                info "SVG: $svg"
                open_file "$svg"
            done
        else
            fail "Bill spotlight failed"
            exit 1
        fi
        ;;

    weekly)
        # Convert comma-separated to JSON array
        TOPICS_JSON=$(python3 -c "
import json
topics = '$TOPICS'.split(',')
print(json.dumps([t.strip() for t in topics]))
")
        info "Running weekly fire: $TOPICS"

        RESULT_FILE="$REPORTS_DIR/${TS}-weekly-fire.json"

        echo "{\"action\": \"weekly_fire\", \"topics\": $TOPICS_JSON}" \
            | CF_PROJECT_DIR="$PROJECT_DIR" "$PLUGIN" \
            > "$RESULT_FILE" 2>/dev/null

        if [ $? -eq 0 ] && [ -s "$RESULT_FILE" ]; then
            ok "Weekly fire complete: $RESULT_FILE"
            pretty_print_results "$RESULT_FILE" "Weekly: $TOPICS"

            # Try to find and open the newsletter markdown
            NEWSLETTER=$(python3 -c "
import json
with open('$RESULT_FILE') as f:
    d = json.load(f)
nf = d.get('assets', {}).get('newsletter_file', '')
print(nf)
" 2>/dev/null || echo "")
            if [ -n "$NEWSLETTER" ] && [ -f "$NEWSLETTER" ]; then
                info "Newsletter: $NEWSLETTER"
                open_file "$NEWSLETTER"
            fi
        else
            fail "Weekly fire failed"
            exit 1
        fi
        ;;
esac

echo ""
ember "The fire reveals what was hidden."
echo "${DIM}Results saved to: $REPORTS_DIR${RESET}"
echo ""
