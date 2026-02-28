#!/usr/bin/env bash
# =============================================================================
# test-plugins.sh — Validate all Cleansing Fire plugins
# =============================================================================
# Runs basic validation checks on every plugin in the plugins/ directory:
#   1. Is the file executable?
#   2. Does it accept JSON stdin and produce JSON stdout?
#   3. Does it handle unknown actions with proper error JSON?
#   4. Does it exit with correct codes?
#
# Usage:
#   scripts/test-plugins.sh           # Test all plugins
#   scripts/test-plugins.sh forge-*   # Test matching plugins
#   scripts/test-plugins.sh --verbose # Show full output
#
# Exit: 0 if all pass, 1 if any fail
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="$PROJECT_DIR/plugins"

# Colors (if TTY)
if [ -t 1 ]; then
    GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[0;33m'
    BLUE='\033[0;34m'; DIM='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'
else
    GREEN=''; RED=''; YELLOW=''; BLUE=''; DIM=''; BOLD=''; NC=''
fi

VERBOSE=false
PATTERN=""
PASSED=0
FAILED=0
SKIPPED=0
WARNINGS=0
RESULTS=()

# Parse args
for arg in "$@"; do
    case "$arg" in
        --verbose|-v) VERBOSE=true ;;
        --help|-h)
            echo "Usage: scripts/test-plugins.sh [--verbose] [pattern]"
            echo "  pattern: glob pattern to match plugin names (e.g., forge-*)"
            exit 0
            ;;
        *) PATTERN="$arg" ;;
    esac
done

# Utilities
pass() { PASSED=$((PASSED + 1)); RESULTS+=("${GREEN}PASS${NC} $1"); }
fail() { FAILED=$((FAILED + 1)); RESULTS+=("${RED}FAIL${NC} $1: $2"); }
warn() { WARNINGS=$((WARNINGS + 1)); RESULTS+=("${YELLOW}WARN${NC} $1: $2"); }
skip() { SKIPPED=$((SKIPPED + 1)); RESULTS+=("${DIM}SKIP${NC} $1: $2"); }

is_json() {
    python3 -c "import json,sys; json.load(sys.stdin)" <<< "$1" 2>/dev/null
}

# Header
echo -e "${BOLD}Cleansing Fire Plugin Test Suite${NC}"
echo -e "${DIM}$(date -u +%Y-%m-%dT%H:%M:%SZ)${NC}"
echo ""

# Collect plugins
PLUGINS=()
for plugin in "$PLUGIN_DIR"/*; do
    name="$(basename "$plugin")"
    # Skip README and non-files
    [ "$name" = "README" ] && continue
    [ ! -f "$plugin" ] && continue
    # Apply pattern filter
    if [ -n "$PATTERN" ]; then
        case "$name" in
            $PATTERN) ;; # Match
            *) continue ;;
        esac
    fi
    PLUGINS+=("$name")
done

echo -e "Testing ${BOLD}${#PLUGINS[@]}${NC} plugins in $PLUGIN_DIR"
echo ""

# Export project dir for plugins
export CF_PROJECT_DIR="$PROJECT_DIR"

for name in "${PLUGINS[@]}"; do
    plugin="$PLUGIN_DIR/$name"
    echo -e "${BLUE}--- $name ---${NC}"
    test_count=0
    test_fail=0

    # Test 1: Is it executable?
    if [ -x "$plugin" ]; then
        if $VERBOSE; then echo -e "  ${GREEN}✓${NC} executable"; fi
        test_count=$((test_count + 1))
    else
        fail "$name" "not executable (chmod +x needed)"
        echo -e "  ${RED}✗${NC} not executable"
        continue
    fi

    # Test 2: Has a shebang line?
    first_line="$(head -1 "$plugin")"
    if [[ "$first_line" == "#!/usr/bin/env python3" ]] || [[ "$first_line" == "#!/usr/bin/env bash" ]] || [[ "$first_line" == "#!"* ]]; then
        if $VERBOSE; then echo -e "  ${GREEN}✓${NC} shebang: $first_line"; fi
        test_count=$((test_count + 1))
    else
        warn "$name" "no shebang line (first line: ${first_line:0:40})"
    fi

    # Test 3: Send unknown action, expect error JSON with exit code != 0
    unknown_input='{"action": "__test_unknown_action_xyz__"}'
    unknown_output=""
    unknown_exit=0
    unknown_output=$(echo "$unknown_input" | timeout 10 "$plugin" 2>/dev/null) || unknown_exit=$?

    if [ $unknown_exit -ne 0 ]; then
        # Good: non-zero exit for unknown action
        if is_json "$unknown_output"; then
            # Check for error field
            has_error=$(python3 -c "import json,sys; d=json.loads(sys.stdin.read()); print('yes' if 'error' in d else 'no')" <<< "$unknown_output" 2>/dev/null || echo "no")
            if [ "$has_error" = "yes" ]; then
                if $VERBOSE; then echo -e "  ${GREEN}✓${NC} unknown action: error JSON with exit $unknown_exit"; fi
                test_count=$((test_count + 1))
            else
                warn "$name" "unknown action returns JSON without 'error' field"
            fi
        else
            warn "$name" "unknown action returns non-JSON on stderr (exit=$unknown_exit)"
            if $VERBOSE; then echo -e "  ${YELLOW}!${NC} output: ${unknown_output:0:100}"; fi
        fi
    else
        warn "$name" "unknown action exits 0 (should be non-zero)"
    fi

    # Test 4: Send empty JSON, expect graceful handling
    empty_output=""
    empty_exit=0
    empty_output=$(echo '{}' | timeout 10 "$plugin" 2>/dev/null) || empty_exit=$?

    if [ $empty_exit -ne 0 ]; then
        if is_json "$empty_output"; then
            if $VERBOSE; then echo -e "  ${GREEN}✓${NC} empty input: error JSON with exit $empty_exit"; fi
            test_count=$((test_count + 1))
        else
            if $VERBOSE; then echo -e "  ${YELLOW}!${NC} empty input: non-JSON output"; fi
        fi
    else
        # Exit 0 on empty input is acceptable if it returns valid JSON
        if is_json "$empty_output"; then
            if $VERBOSE; then echo -e "  ${GREEN}✓${NC} empty input: valid JSON (exit 0)"; fi
            test_count=$((test_count + 1))
        else
            warn "$name" "empty input: invalid output"
        fi
    fi

    # Test 5: Send garbage, expect graceful handling (no crash)
    garbage_exit=0
    echo "not json at all {{{" | timeout 10 "$plugin" > /dev/null 2>&1 || garbage_exit=$?
    if [ $garbage_exit -ne 0 ]; then
        if $VERBOSE; then echo -e "  ${GREEN}✓${NC} garbage input: exits $garbage_exit (graceful)"; fi
        test_count=$((test_count + 1))
    else
        warn "$name" "garbage input exits 0 (should reject invalid JSON)"
    fi

    # Test 6: Check for common patterns (quick static analysis)
    if grep -q "json.load\|json.loads" "$plugin" 2>/dev/null; then
        if $VERBOSE; then echo -e "  ${GREEN}✓${NC} uses JSON parsing"; fi
        test_count=$((test_count + 1))
    fi

    if grep -q "json.dump\|json.dumps" "$plugin" 2>/dev/null; then
        if $VERBOSE; then echo -e "  ${GREEN}✓${NC} uses JSON output"; fi
        test_count=$((test_count + 1))
    fi

    # Summary for this plugin
    if [ $test_count -ge 4 ]; then
        pass "$name ($test_count checks passed)"
        echo -e "  ${GREEN}PASS${NC} ($test_count checks)"
    elif [ $test_count -ge 2 ]; then
        warn "$name" "partial pass ($test_count checks)"
        echo -e "  ${YELLOW}WARN${NC} ($test_count checks)"
    else
        fail "$name" "too few checks passed ($test_count)"
        echo -e "  ${RED}FAIL${NC} ($test_count checks)"
    fi
    echo ""
done

# Summary
echo -e "${BOLD}═══════════════════════════════════════${NC}"
echo -e "${BOLD}Test Summary${NC}"
echo -e "${BOLD}═══════════════════════════════════════${NC}"
echo ""
echo -e "  ${GREEN}Passed${NC}:   $PASSED"
echo -e "  ${RED}Failed${NC}:   $FAILED"
echo -e "  ${YELLOW}Warnings${NC}: $WARNINGS"
echo -e "  ${DIM}Skipped${NC}:  $SKIPPED"
echo -e "  Total:    ${#PLUGINS[@]} plugins tested"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed.${NC}"
    echo ""
    for r in "${RESULTS[@]}"; do
        echo -e "  $r"
    done
    exit 1
else
    echo -e "${GREEN}All plugins passed basic validation.${NC}"
    exit 0
fi
