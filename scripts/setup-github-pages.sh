#!/bin/bash
# setup-github-pages.sh - Automate GitHub Pages setup for Cleansing Fire
#
# Ensures the docs/ directory has a valid index.html, configures GitHub Pages
# via the gh CLI, verifies deployment, and prints the Pages URL.
#
# Usage:
#   scripts/setup-github-pages.sh
#   scripts/setup-github-pages.sh --help
set -euo pipefail

# ---------------------------------------------------------------------------
# Project root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

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
${FIRE}CLEANSING FIRE${RESET} - GitHub Pages Setup

Usage: $0 [OPTIONS]

Options:
  --branch BRANCH   Source branch for Pages (default: main)
  --path PATH       Source path for Pages (default: /docs)
  --skip-verify     Don't wait for deployment verification
  --help            Show this message

This script:
  1. Ensures docs/ directory exists with index.html
  2. Commits any new docs/ files if needed
  3. Pushes to remote
  4. Configures GitHub Pages via gh CLI
  5. Verifies deployment
  6. Prints the live URL

Requires: gh CLI (authenticated)

${DIM}The fire must be visible. Opacity is the enemy.${RESET}
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
SOURCE_BRANCH="main"
SOURCE_PATH="/docs"
SKIP_VERIFY=false

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)      usage ;;
        --branch)       SOURCE_BRANCH="${2:?--branch requires a value}"; shift 2 ;;
        --path)         SOURCE_PATH="${2:?--path requires a value}"; shift 2 ;;
        --skip-verify)  SKIP_VERIFY=true; shift ;;
        *)              fail "Unknown option: $1"; usage ;;
    esac
done

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
echo ""
ember "  Setting the fire where everyone can see it."
echo ""

# Check for gh CLI
if ! command -v gh &>/dev/null; then
    fail "gh CLI is not installed"
    echo "  Install: https://cli.github.com/"
    echo "  macOS:   brew install gh"
    echo "  Linux:   https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    exit 1
fi
ok "gh CLI found"

# Check gh auth
if ! gh auth status &>/dev/null 2>&1; then
    fail "gh CLI is not authenticated"
    echo "  Run: gh auth login"
    exit 1
fi
ok "gh CLI is authenticated"

# Check we're in a git repo with a remote
if ! git rev-parse --git-dir &>/dev/null; then
    fail "Not a git repository"
    exit 1
fi

REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$REMOTE_URL" ]; then
    fail "No 'origin' remote configured"
    echo "  Add one with: git remote add origin <url>"
    exit 1
fi
ok "Remote: $REMOTE_URL"

# Extract owner/repo from remote URL
REPO_SLUG=$(echo "$REMOTE_URL" | sed -E 's|.*[:/]([^/]+/[^/]+)(\.git)?$|\1|')
if [ -z "$REPO_SLUG" ]; then
    fail "Could not parse repository from remote URL: $REMOTE_URL"
    exit 1
fi
info "Repository: $REPO_SLUG"

# ---------------------------------------------------------------------------
# Step 1: Ensure docs/ directory
# ---------------------------------------------------------------------------
info "Checking docs/ directory..."

DOCS_DIR="$PROJECT_DIR/docs"

if [ ! -d "$DOCS_DIR" ]; then
    mkdir -p "$DOCS_DIR"
    ok "Created docs/ directory"
fi

if [ ! -f "$DOCS_DIR/index.html" ]; then
    fail "docs/index.html not found"
    echo "  The docs/index.html file is the entry point for GitHub Pages."
    echo "  Create it first, then re-run this script."
    exit 1
fi

ok "docs/index.html exists"

# Check for basic HTML validity
if ! grep -q '<html' "$DOCS_DIR/index.html" 2>/dev/null; then
    warn "docs/index.html may not be valid HTML (no <html> tag found)"
fi

# Count docs files
DOC_COUNT=$(find "$DOCS_DIR" -type f | wc -l | tr -d ' ')
info "docs/ contains $DOC_COUNT files"

# ---------------------------------------------------------------------------
# Step 2: Ensure .nojekyll (we don't use Jekyll)
# ---------------------------------------------------------------------------
if [ ! -f "$DOCS_DIR/.nojekyll" ]; then
    touch "$DOCS_DIR/.nojekyll"
    ok "Created docs/.nojekyll (bypass Jekyll processing)"
fi

# ---------------------------------------------------------------------------
# Step 3: Commit and push
# ---------------------------------------------------------------------------
info "Checking for uncommitted docs/ changes..."

git add docs/ 2>/dev/null || true

if ! git diff --cached --quiet 2>/dev/null; then
    info "Committing docs/ changes..."
    git commit -m "docs: prepare for GitHub Pages deployment

Ensure index.html and .nojekyll are present.
Automated by scripts/setup-github-pages.sh" 2>/dev/null
    ok "Committed docs/ changes"
else
    ok "docs/ is clean"
fi

# Push current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
info "Pushing to origin/$CURRENT_BRANCH..."

if git push origin "$CURRENT_BRANCH" 2>/dev/null; then
    ok "Pushed to remote"
else
    fail "Push failed"
    echo "  Check your remote access permissions."
    echo "  You may need to: gh auth refresh"
    exit 1
fi

# ---------------------------------------------------------------------------
# Step 4: Configure GitHub Pages
# ---------------------------------------------------------------------------
info "Configuring GitHub Pages..."

# Check current Pages config
CURRENT_PAGES=$(gh api "repos/$REPO_SLUG/pages" 2>/dev/null || echo "")

if [ -n "$CURRENT_PAGES" ]; then
    CURRENT_URL=$(python3 -c "import json; print(json.loads('$CURRENT_PAGES').get('html_url', 'unknown'))" 2>/dev/null || echo "unknown")
    info "Pages already configured at: $CURRENT_URL"

    # Update source if needed
    gh api -X PUT "repos/$REPO_SLUG/pages" \
        -f source[branch]="$SOURCE_BRANCH" \
        -f source[path]="$SOURCE_PATH" \
        2>/dev/null && ok "Updated Pages source: $SOURCE_BRANCH $SOURCE_PATH"
else
    # Enable Pages
    info "Enabling GitHub Pages for the first time..."

    if gh api -X POST "repos/$REPO_SLUG/pages" \
        -f source[branch]="$SOURCE_BRANCH" \
        -f source[path]="$SOURCE_PATH" \
        2>/dev/null; then
        ok "GitHub Pages enabled"
    else
        # Try the alternative approach via repo settings
        fail "Could not enable Pages via API"
        echo ""
        echo "  You may need to enable Pages manually:"
        echo "  1. Go to https://github.com/$REPO_SLUG/settings/pages"
        echo "  2. Under 'Source', select '$SOURCE_BRANCH' and '$SOURCE_PATH'"
        echo "  3. Click Save"
        echo ""
        echo "  This can happen if the repo doesn't have Pages permissions."
        echo "  For private repos, Pages requires a paid plan."
        exit 1
    fi
fi

# ---------------------------------------------------------------------------
# Step 5: Verify deployment
# ---------------------------------------------------------------------------
if ! $SKIP_VERIFY; then
    info "Waiting for deployment..."

    PAGES_URL=""
    MAX_WAIT=120
    WAITED=0

    while [ $WAITED -lt $MAX_WAIT ]; do
        PAGES_INFO=$(gh api "repos/$REPO_SLUG/pages" 2>/dev/null || echo "")
        if [ -n "$PAGES_INFO" ]; then
            PAGES_STATUS=$(python3 -c "import json; print(json.loads('$PAGES_INFO').get('status', 'unknown'))" 2>/dev/null || echo "unknown")
            PAGES_URL=$(python3 -c "import json; print(json.loads('$PAGES_INFO').get('html_url', ''))" 2>/dev/null || echo "")

            if [ "$PAGES_STATUS" = "built" ]; then
                ok "Pages deployed successfully"
                break
            fi
            info "Status: $PAGES_STATUS (waiting...)"
        fi

        sleep 5
        WAITED=$((WAITED + 5))
    done

    if [ $WAITED -ge $MAX_WAIT ]; then
        info "Deployment still in progress (timed out waiting)"
        info "It may take a few more minutes. Check manually."
    fi
else
    PAGES_INFO=$(gh api "repos/$REPO_SLUG/pages" 2>/dev/null || echo "")
    PAGES_URL=$(python3 -c "import json; print(json.loads('$PAGES_INFO').get('html_url', ''))" 2>/dev/null || echo "")
fi

# ---------------------------------------------------------------------------
# Step 6: Print results
# ---------------------------------------------------------------------------
echo ""
echo "${BOLD}========================================${RESET}"
ember "  GitHub Pages Deployment"
echo "${BOLD}========================================${RESET}"
echo ""

if [ -n "$PAGES_URL" ]; then
    echo "  ${GREEN}${BOLD}URL: $PAGES_URL${RESET}"
    echo ""
    status_line() {
        printf "  %-16s %s\n" "$1" "$2"
    }
    status_line "Repository:" "$REPO_SLUG"
    status_line "Branch:" "$SOURCE_BRANCH"
    status_line "Path:" "$SOURCE_PATH"
    status_line "Files:" "$DOC_COUNT"
else
    echo "  URL will be available at:"
    echo "  https://${REPO_SLUG%%/*}.github.io/${REPO_SLUG##*/}/"
fi

echo ""
echo "  ${DIM}To update: commit changes to docs/ and push.${RESET}"
echo "  ${DIM}Pages rebuilds automatically on every push.${RESET}"
echo ""
ember "  Transparency is not optional. The fire must be visible."
echo ""
