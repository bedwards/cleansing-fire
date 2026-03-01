#!/bin/bash
# =============================================================================
# Fork Monitor — Cleansing Fire
# =============================================================================
# Detects unauthorized forks, impersonation attempts, and tracks
# how the project is being used across GitHub.
#
# Usage:
#   ./scripts/fork-monitor.sh [--check-impersonation] [--full-scan]
#
# Requires: gh CLI authenticated
# =============================================================================

set -euo pipefail

REPO="bedwards/cleansing-fire"
REPORT_FILE="${CF_PROJECT_DIR:-.}/fork-monitor-report.json"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== Fork Monitor: $REPO ==="
echo ""

# ---------------------------------------------------------------------------
# 1. List all forks
# ---------------------------------------------------------------------------
echo "--- Scanning forks ---"
FORKS=$(gh api "repos/$REPO/forks?per_page=100&sort=newest" 2>/dev/null || echo "[]")
FORK_COUNT=$(echo "$FORKS" | jq length)
echo "Total forks found: $FORK_COUNT"

# ---------------------------------------------------------------------------
# 2. Check each fork for concerning patterns
# ---------------------------------------------------------------------------
ALERTS=()
FORK_DETAILS=()

echo "$FORKS" | jq -c '.[]' 2>/dev/null | while read -r fork; do
    FORK_NAME=$(echo "$fork" | jq -r '.full_name')
    FORK_OWNER=$(echo "$fork" | jq -r '.owner.login')
    FORK_DESC=$(echo "$fork" | jq -r '.description // ""')
    FORK_CREATED=$(echo "$fork" | jq -r '.created_at')
    FORK_PUSHED=$(echo "$fork" | jq -r '.pushed_at')
    FORK_HOMEPAGE=$(echo "$fork" | jq -r '.homepage // ""')
    FORK_STARS=$(echo "$fork" | jq -r '.stargazers_count')

    echo -n "  Checking $FORK_NAME... "

    # Check for impersonation signals
    RISK_LEVEL="low"
    ALERTS_FOR_FORK=()

    # Signal 1: Fork has a custom homepage (might be hosting modified content)
    if [ -n "$FORK_HOMEPAGE" ] && [ "$FORK_HOMEPAGE" != "null" ]; then
        ALERTS_FOR_FORK+=("custom-homepage:$FORK_HOMEPAGE")
        RISK_LEVEL="medium"
    fi

    # Signal 2: Fork description differs significantly (potential rebranding)
    if [ -n "$FORK_DESC" ] && [ "$FORK_DESC" != "null" ]; then
        # Check for removed AGPL mentions or project name changes
        if echo "$FORK_DESC" | grep -qi "proprietary\|commercial\|closed"; then
            ALERTS_FOR_FORK+=("possible-license-removal")
            RISK_LEVEL="high"
        fi
    fi

    # Signal 3: Fork has significant activity (many pushes ahead of upstream)
    if [ "$FORK_STARS" -gt 5 ]; then
        ALERTS_FOR_FORK+=("gaining-traction:${FORK_STARS}-stars")
        RISK_LEVEL="medium"
    fi

    # Signal 4: Check if fork has GitHub Pages enabled (serving content)
    PAGES_URL="https://${FORK_OWNER}.github.io/$(echo "$FORK_NAME" | cut -d/ -f2)/"
    if curl -s -o /dev/null -w "%{http_code}" "$PAGES_URL" 2>/dev/null | grep -q "200"; then
        ALERTS_FOR_FORK+=("pages-enabled:$PAGES_URL")
        RISK_LEVEL="medium"
    fi

    # Print result
    if [ "$RISK_LEVEL" = "high" ]; then
        echo -e "${RED}HIGH RISK${NC} - ${ALERTS_FOR_FORK[*]}"
    elif [ "$RISK_LEVEL" = "medium" ]; then
        echo -e "${YELLOW}MEDIUM${NC} - ${ALERTS_FOR_FORK[*]}"
    else
        echo -e "${GREEN}OK${NC}"
    fi

done

# ---------------------------------------------------------------------------
# 3. Check for GitHub search impersonation
# ---------------------------------------------------------------------------
if [[ "${1:-}" == *"impersonation"* ]] || [[ "${1:-}" == *"full"* ]]; then
    echo ""
    echo "--- Searching for impersonation ---"

    # Search for repos with similar names
    SIMILAR=$(gh api "search/repositories?q=cleansing-fire+in:name&per_page=10" \
        --jq '.items[] | select(.full_name != "'"$REPO"'") | .full_name' 2>/dev/null || echo "")

    if [ -n "$SIMILAR" ]; then
        echo "  Repos with similar names:"
        echo "$SIMILAR" | while read -r name; do
            echo "    - $name"
        done
    else
        echo "  No suspicious similar repo names found"
    fi

    # Search for repos using our specific terms
    TERMS=("pyrrhic-lucidity" "cleansing+fire+civic" "firelighter+protocol")
    for term in "${TERMS[@]}"; do
        FOUND=$(gh api "search/repositories?q=$term&per_page=5" \
            --jq '.items[] | select(.full_name != "'"$REPO"'") | .full_name' 2>/dev/null || echo "")
        if [ -n "$FOUND" ]; then
            echo "  Repos matching '$term':"
            echo "$FOUND" | while read -r name; do
                echo "    - $name"
            done
        fi
    done
fi

# ---------------------------------------------------------------------------
# 4. Check AGPL compliance in forks
# ---------------------------------------------------------------------------
if [[ "${1:-}" == *"full"* ]]; then
    echo ""
    echo "--- AGPL Compliance Check ---"
    echo "$FORKS" | jq -r '.[].full_name' 2>/dev/null | head -10 | while read -r fork_name; do
        # Check if fork has LICENSE file with AGPL
        LICENSE=$(gh api "repos/$fork_name/contents/LICENSE" \
            --jq '.content' 2>/dev/null | base64 -d 2>/dev/null | head -5 || echo "")

        if echo "$LICENSE" | grep -qi "affero\|agpl"; then
            echo -e "  $fork_name: ${GREEN}AGPL present${NC}"
        elif [ -z "$LICENSE" ]; then
            echo -e "  $fork_name: ${YELLOW}No LICENSE file${NC}"
        else
            echo -e "  $fork_name: ${RED}LICENSE changed!${NC}"
        fi
    done
fi

# ---------------------------------------------------------------------------
# 5. Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Fork Monitor Summary ==="
echo "  Total forks: $FORK_COUNT"
echo "  Scan completed: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""
echo "Run with --full-scan for AGPL compliance and impersonation checks"
