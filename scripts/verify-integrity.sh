#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Cleansing Fire - Integrity Verification Script
# ============================================================================
#
# Verifies the integrity of core project files against the integrity manifest.
# Designed to run in CI/CD, as a pre-commit hook, or on demand.
#
# Checks performed:
#   1. Manifest file exists and is valid JSON
#   2. SHA-256 hashes of all protected files match manifest
#   3. All 7 Principles of Pyrrhic Lucidity appear in CLAUDE.md
#   4. Key philosophical phrases appear in philosophy.md
#
# Exit codes:
#   0 - All checks passed
#   1 - One or more checks failed
#   2 - Script error (missing dependencies, invalid manifest, etc.)
#
# Usage:
#   ./scripts/verify-integrity.sh              # Run from repo root
#   ./scripts/verify-integrity.sh --quiet      # Suppress pass messages
#   ./scripts/verify-integrity.sh --ci         # CI mode: strict, no color
#
# ============================================================================

# --- Configuration ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST="${REPO_ROOT}/integrity-manifest.json"

# --- Color output (disabled in CI mode) ---

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Parse arguments ---

QUIET=false
CI_MODE=false

for arg in "$@"; do
    case "$arg" in
        --quiet) QUIET=true ;;
        --ci)    CI_MODE=true; RED=''; GREEN=''; YELLOW=''; BLUE=''; BOLD=''; NC='' ;;
        --help)
            echo "Usage: $0 [--quiet] [--ci] [--help]"
            echo ""
            echo "  --quiet   Suppress individual pass messages"
            echo "  --ci      CI mode: no color output"
            echo "  --help    Show this help"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: $0 [--quiet] [--ci] [--help]"
            exit 2
            ;;
    esac
done

# --- Counters ---

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# --- Helper functions ---

pass() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    if [ "$QUIET" = false ]; then
        echo -e "  ${GREEN}PASS${NC}  $1"
    fi
}

fail() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    echo -e "  ${RED}FAIL${NC}  $1"
}

warn() {
    WARNINGS=$((WARNINGS + 1))
    echo -e "  ${YELLOW}WARN${NC}  $1"
}

info() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}$1${NC}"
    fi
}

header() {
    echo ""
    echo -e "${BOLD}$1${NC}"
    echo -e "${BOLD}$(echo "$1" | sed 's/./-/g')${NC}"
}

# --- Dependency check ---

check_dependencies() {
    local missing=false

    if ! command -v shasum &>/dev/null && ! command -v sha256sum &>/dev/null; then
        echo "ERROR: Neither shasum nor sha256sum found. Cannot verify hashes."
        missing=true
    fi

    if ! command -v python3 &>/dev/null; then
        echo "ERROR: python3 not found. Required for JSON parsing."
        missing=true
    fi

    if [ "$missing" = true ]; then
        exit 2
    fi
}

# --- SHA-256 computation (cross-platform) ---

compute_sha256() {
    local file="$1"
    if command -v shasum &>/dev/null; then
        shasum -a 256 "$file" | awk '{print $1}'
    elif command -v sha256sum &>/dev/null; then
        sha256sum "$file" | awk '{print $1}'
    fi
}

# --- JSON parsing via Python (avoids jq dependency) ---

json_get() {
    local json_file="$1"
    local python_expr="$2"
    python3 -c "
import json, sys
with open('${json_file}') as f:
    data = json.load(f)
result = ${python_expr}
if isinstance(result, list):
    for item in result:
        print(item)
elif isinstance(result, dict):
    for key in result:
        print(key)
else:
    print(result)
"
}

json_get_hash() {
    local json_file="$1"
    local file_key="$2"
    python3 -c "
import json
with open('${json_file}') as f:
    data = json.load(f)
print(data['protected_files']['${file_key}']['sha256'])
"
}

json_get_protection_level() {
    local json_file="$1"
    local file_key="$2"
    python3 -c "
import json
with open('${json_file}') as f:
    data = json.load(f)
print(data['protected_files']['${file_key}'].get('protection_level', 'standard'))
"
}

# ============================================================================
# MAIN
# ============================================================================

echo ""
echo -e "${BOLD}================================================================${NC}"
echo -e "${BOLD}  CLEANSING FIRE - INTEGRITY VERIFICATION${NC}"
echo -e "${BOLD}================================================================${NC}"
echo ""
echo "  Repository: ${REPO_ROOT}"
echo "  Timestamp:  $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo ""

# --- Check dependencies ---

check_dependencies

# ============================================================================
# CHECK 1: Manifest exists and is valid
# ============================================================================

header "1. Manifest Validation"

if [ ! -f "$MANIFEST" ]; then
    fail "integrity-manifest.json not found at ${MANIFEST}"
    echo ""
    echo -e "${RED}CRITICAL: Cannot proceed without manifest. Aborting.${NC}"
    exit 2
fi

# Validate JSON
if python3 -c "import json; json.load(open('${MANIFEST}'))" 2>/dev/null; then
    pass "integrity-manifest.json is valid JSON"
else
    fail "integrity-manifest.json is not valid JSON"
    echo ""
    echo -e "${RED}CRITICAL: Manifest is corrupt. Aborting.${NC}"
    exit 2
fi

# Check required fields
MANIFEST_VERSION=$(json_get "$MANIFEST" "data['manifest_version']" 2>/dev/null || echo "")
if [ -n "$MANIFEST_VERSION" ]; then
    pass "Manifest version: ${MANIFEST_VERSION}"
else
    fail "Manifest missing 'manifest_version' field"
fi

PROJECT_NAME=$(json_get "$MANIFEST" "data['project']" 2>/dev/null || echo "")
if [ "$PROJECT_NAME" = "cleansing-fire" ]; then
    pass "Project identifier: ${PROJECT_NAME}"
else
    fail "Unexpected project identifier: '${PROJECT_NAME}' (expected 'cleansing-fire')"
fi

# ============================================================================
# CHECK 2: SHA-256 hash verification of protected files
# ============================================================================

header "2. Protected File Hash Verification"

# Get list of protected files
PROTECTED_FILES=$(json_get "$MANIFEST" "data['protected_files']")

HASH_FAILURES=0

while IFS= read -r file_key; do
    [ -z "$file_key" ] && continue

    file_path="${REPO_ROOT}/${file_key}"
    expected_hash=$(json_get_hash "$MANIFEST" "$file_key")
    protection_level=$(json_get_protection_level "$MANIFEST" "$file_key")

    if [ ! -f "$file_path" ]; then
        fail "[${protection_level}] ${file_key} - FILE MISSING"
        HASH_FAILURES=$((HASH_FAILURES + 1))
        continue
    fi

    actual_hash=$(compute_sha256 "$file_path")

    if [ "$actual_hash" = "$expected_hash" ]; then
        pass "[${protection_level}] ${file_key} - hash verified"
    else
        fail "[${protection_level}] ${file_key} - HASH MISMATCH"
        echo "         Expected: ${expected_hash}"
        echo "         Actual:   ${actual_hash}"
        HASH_FAILURES=$((HASH_FAILURES + 1))
    fi
done <<< "$PROTECTED_FILES"

if [ "$HASH_FAILURES" -gt 0 ]; then
    echo ""
    echo -e "  ${RED}${HASH_FAILURES} file(s) failed hash verification.${NC}"
    echo -e "  ${RED}If these changes are legitimate, update integrity-manifest.json.${NC}"
fi

# ============================================================================
# CHECK 3: Seven Principles present in CLAUDE.md
# ============================================================================

header "3. Seven Principles Verification (CLAUDE.md)"

CLAUDE_FILE="${REPO_ROOT}/CLAUDE.md"

if [ ! -f "$CLAUDE_FILE" ]; then
    fail "CLAUDE.md not found"
else
    PRINCIPLE_FAILURES=0

    while IFS= read -r principle; do
        [ -z "$principle" ] && continue

        if grep -q "$principle" "$CLAUDE_FILE"; then
            pass "Principle found: \"${principle}\""
        else
            fail "Principle MISSING: \"${principle}\""
            PRINCIPLE_FAILURES=$((PRINCIPLE_FAILURES + 1))
        fi
    done <<< "$(json_get "$MANIFEST" "data['required_principles']")"

    if [ "$PRINCIPLE_FAILURES" -gt 0 ]; then
        echo ""
        echo -e "  ${RED}${PRINCIPLE_FAILURES} principle(s) missing from CLAUDE.md.${NC}"
        echo -e "  ${RED}The 7 Principles are constitutional anchors and must not be removed.${NC}"
    fi
fi

# ============================================================================
# CHECK 4: Key philosophical phrases in philosophy.md
# ============================================================================

header "4. Philosophical Integrity Verification (philosophy.md)"

PHILOSOPHY_FILE="${REPO_ROOT}/philosophy.md"

if [ ! -f "$PHILOSOPHY_FILE" ]; then
    fail "philosophy.md not found"
else
    PHRASE_FAILURES=0

    # Read phrases from manifest using Python to handle multi-line/special chars
    python3 -c "
import json
with open('${MANIFEST}') as f:
    data = json.load(f)
for phrase in data['required_phrases']:
    print(phrase)
" | while IFS= read -r phrase; do
        [ -z "$phrase" ] && continue

        if grep -qF "$phrase" "$PHILOSOPHY_FILE"; then
            pass "Key phrase verified: \"${phrase:0:60}...\""
        else
            fail "Key phrase MISSING: \"${phrase:0:60}...\""
            # Write to a temp file so the outer shell can read the count
            echo "1" >> "${REPO_ROOT}/.integrity-phrase-failures"
        fi
    done

    # Check if any phrase failures were recorded
    if [ -f "${REPO_ROOT}/.integrity-phrase-failures" ]; then
        PHRASE_FAILURE_COUNT=$(wc -l < "${REPO_ROOT}/.integrity-phrase-failures" | tr -d ' ')
        FAILED_CHECKS=$((FAILED_CHECKS + PHRASE_FAILURE_COUNT))
        TOTAL_CHECKS=$((TOTAL_CHECKS + PHRASE_FAILURE_COUNT))
        rm -f "${REPO_ROOT}/.integrity-phrase-failures"
        echo ""
        echo -e "  ${RED}${PHRASE_FAILURE_COUNT} key phrase(s) missing from philosophy.md.${NC}"
        echo -e "  ${RED}These phrases are markers of philosophical integrity.${NC}"
        echo -e "  ${RED}Their removal may indicate corruption of the framework.${NC}"
    else
        # Count the passes that happened in the subshell
        PHRASE_PASS_COUNT=$(python3 -c "
import json
with open('${MANIFEST}') as f:
    data = json.load(f)
print(len(data['required_phrases']))
")
        PASSED_CHECKS=$((PASSED_CHECKS + PHRASE_PASS_COUNT))
        TOTAL_CHECKS=$((TOTAL_CHECKS + PHRASE_PASS_COUNT))
    fi
fi

# ============================================================================
# CHECK 5: Structural checks
# ============================================================================

header "5. Structural Checks"

# Check that the verify script itself exists and is executable
if [ -x "${SCRIPT_DIR}/verify-integrity.sh" ]; then
    pass "verify-integrity.sh is executable"
else
    warn "verify-integrity.sh is not executable (chmod +x recommended)"
fi

# Check that integrity-manifest.json is tracked by git
if git -C "$REPO_ROOT" ls-files --error-unmatch integrity-manifest.json &>/dev/null 2>&1; then
    pass "integrity-manifest.json is tracked by git"
else
    warn "integrity-manifest.json is not yet tracked by git"
fi

# Check for unsigned recent commits (advisory, not a hard failure)
if command -v git &>/dev/null; then
    UNSIGNED_COMMITS=$(git -C "$REPO_ROOT" log --format='%H %G?' -10 2>/dev/null | grep ' N$' | wc -l | tr -d ' ')
    if [ "$UNSIGNED_COMMITS" -gt 0 ]; then
        warn "${UNSIGNED_COMMITS} of last 10 commits are unsigned (GPG signing recommended)"
    else
        pass "Recent commits are GPG-signed"
    fi
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo -e "${BOLD}================================================================${NC}"
echo -e "${BOLD}  SUMMARY${NC}"
echo -e "${BOLD}================================================================${NC}"
echo ""
echo "  Total checks:  ${TOTAL_CHECKS}"
echo -e "  Passed:        ${GREEN}${PASSED_CHECKS}${NC}"

if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo -e "  Failed:        ${RED}${FAILED_CHECKS}${NC}"
fi

if [ "$WARNINGS" -gt 0 ]; then
    echo -e "  Warnings:      ${YELLOW}${WARNINGS}${NC}"
fi

echo ""

if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo -e "${RED}${BOLD}  INTEGRITY CHECK FAILED${NC}"
    echo ""
    echo -e "  ${FAILED_CHECKS} check(s) did not pass."
    echo "  If these are legitimate changes, update integrity-manifest.json"
    echo "  and submit the update for multi-party review."
    echo ""
    echo -e "${BOLD}  The 7 Principles are constitutional anchors.${NC}"
    echo -e "${BOLD}  Recursive Accountability demands we scrutinize ourselves${NC}"
    echo -e "${BOLD}  at least as rigorously as we scrutinize external power.${NC}"
    echo ""
    exit 1
else
    echo -e "${GREEN}${BOLD}  INTEGRITY CHECK PASSED${NC}"
    echo ""
    if [ "$WARNINGS" -gt 0 ]; then
        echo "  All critical checks passed. ${WARNINGS} advisory warning(s) noted above."
    else
        echo "  All checks passed. Core principles and protected files are intact."
    fi
    echo ""
    exit 0
fi
