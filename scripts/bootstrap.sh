#!/bin/bash
# bootstrap.sh - First-time setup for a Cleansing Fire node
#
# Checks dependencies, creates directories, sets up git hooks,
# and offers to install optional tooling. Designed to make a fresh
# clone fully operational in one invocation.
#
# Usage: scripts/bootstrap.sh [--help] [--skip-optional] [--quiet]
set -euo pipefail

# ---------------------------------------------------------------------------
# Project root (resolve from script location)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---------------------------------------------------------------------------
# Color support (degrade gracefully)
# ---------------------------------------------------------------------------
if [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    ORANGE=$(tput setaf 208 2>/dev/null || tput setaf 3)
    CYAN=$(tput setaf 6)
    BOLD=$(tput bold)
    DIM=$(tput dim 2>/dev/null || echo "")
    RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" ORANGE="" CYAN="" BOLD="" DIM="" RESET=""
fi

FIRE="${RED}${BOLD}"
EMBER="${YELLOW}"
ASH="${DIM}"
OK="${GREEN}"

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------
SKIP_OPTIONAL=false
QUIET=false
ERRORS=0
WARNINGS=0

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
${FIRE}CLEANSING FIRE${RESET} - Node Bootstrap

Usage: $0 [OPTIONS]

Options:
  --help            Show this message
  --skip-optional   Don't prompt for optional tools (Ollama, gh, etc.)
  --quiet           Minimal output

What this does:
  1. Checks for required tools (python3, git, curl)
  2. Checks for optional tools (ollama, claude, gh)
  3. Creates output and log directories
  4. Sets up git hooks
  5. Offers to install missing optional tools
  6. Tests gatekeeper connectivity
  7. Prints next steps

${ASH}See clearly. Act anyway. Bear the cost.${RESET}
EOF
    exit 0
}

info()    { $QUIET || echo "${CYAN}[info]${RESET}  $*"; }
ok()      { $QUIET || echo "${OK}[  ok]${RESET}  $*"; }
warn()    { echo "${YELLOW}[warn]${RESET}  $*"; WARNINGS=$((WARNINGS + 1)); }
fail()    { echo "${RED}[FAIL]${RESET}  $*"; ERRORS=$((ERRORS + 1)); }
fire()    { echo "${FIRE}$*${RESET}"; }
ember()   { echo "${EMBER}$*${RESET}"; }
section() { $QUIET || echo ""; $QUIET || echo "${BOLD}--- $* ---${RESET}"; }

prompt_yn() {
    local prompt="$1"
    local default="${2:-n}"
    if $SKIP_OPTIONAL; then
        return 1
    fi
    local yn
    read -r -p "${EMBER}${prompt}${RESET} [y/N] " yn
    case "$yn" in
        [Yy]*) return 0 ;;
        *)     return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
for arg in "$@"; do
    case "$arg" in
        --help|-h)          usage ;;
        --skip-optional)    SKIP_OPTIONAL=true ;;
        --quiet|-q)         QUIET=true ;;
        *)                  echo "Unknown option: $arg"; usage ;;
    esac
done

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
if ! $QUIET; then
    cat <<'BANNER'

         )
        ) \        CLEANSING FIRE
       / ) (       Node Bootstrap
       \(_)/
                   "Lucidity before liberation."

BANNER
fi

# ---------------------------------------------------------------------------
# 1. Required tools
# ---------------------------------------------------------------------------
section "Required Tools"

check_required() {
    local cmd="$1"
    local purpose="$2"
    local install_hint="${3:-}"
    if command -v "$cmd" &>/dev/null; then
        local version
        version=$("$cmd" --version 2>&1 | head -1 || echo "unknown")
        ok "$cmd found: $version"
    else
        fail "$cmd not found ($purpose)"
        [ -n "$install_hint" ] && echo "       Install: $install_hint"
    fi
}

check_required python3 "Core runtime" "https://python.org or: brew install python3"
check_required git "Version control" "https://git-scm.com"
check_required curl "HTTP requests" "Should be pre-installed; try: brew install curl"

# Check Python version >= 3.9
if command -v python3 &>/dev/null; then
    PY_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
    PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)
    if [ "$PY_MAJOR" -ge 3 ] && [ "$PY_MINOR" -ge 9 ]; then
        ok "Python $PY_VERSION (>= 3.9 required)"
    else
        fail "Python $PY_VERSION is too old (>= 3.9 required)"
    fi
fi

# ---------------------------------------------------------------------------
# 2. Optional tools
# ---------------------------------------------------------------------------
section "Optional Tools"

OLLAMA_PRESENT=false
CLAUDE_PRESENT=false
GH_PRESENT=false

check_optional() {
    local cmd="$1"
    local purpose="$2"
    if command -v "$cmd" &>/dev/null; then
        local version
        version=$("$cmd" --version 2>&1 | head -1 || echo "unknown")
        ok "$cmd found: $version"
        return 0
    else
        warn "$cmd not found ($purpose)"
        return 1
    fi
}

if check_optional ollama "Local LLM via gatekeeper"; then
    OLLAMA_PRESENT=true
fi
if check_optional claude "Claude Code CLI - the human interface"; then
    CLAUDE_PRESENT=true
fi
if check_optional gh "GitHub CLI - issues, PRs, Pages"; then
    GH_PRESENT=true
fi
check_optional jq "JSON processing (nice to have)" || true

# ---------------------------------------------------------------------------
# 3. Create directories
# ---------------------------------------------------------------------------
section "Directory Structure"

ensure_dir() {
    local dir="$1"
    local purpose="$2"
    if [ -d "$dir" ]; then
        ok "$dir exists ($purpose)"
    else
        mkdir -p "$dir"
        ok "Created $dir ($purpose)"
    fi
}

ensure_dir "$PROJECT_DIR/output" "Investigation output and generated content"
ensure_dir "$PROJECT_DIR/output/svg" "Generated SVG visualizations"
ensure_dir "$PROJECT_DIR/output/reports" "Investigation reports"
ensure_dir "$PROJECT_DIR/output/content" "Generated social/narrative content"
ensure_dir "/tmp/cleansing-fire" "Logs and temporary files"

# Ensure output is gitignored
GITIGNORE="$PROJECT_DIR/.gitignore"
if [ -f "$GITIGNORE" ]; then
    if ! grep -q "^output/" "$GITIGNORE" 2>/dev/null; then
        echo "output/" >> "$GITIGNORE"
        ok "Added output/ to .gitignore"
    else
        ok "output/ already in .gitignore"
    fi
else
    cat > "$GITIGNORE" <<'GITIGNORE_CONTENT'
# Cleansing Fire
output/
/tmp/
*.pyc
__pycache__/
.env
.claude/worktrees/
GITIGNORE_CONTENT
    ok "Created .gitignore"
fi

# ---------------------------------------------------------------------------
# 4. Git hooks
# ---------------------------------------------------------------------------
section "Git Hooks"

HOOKS_DIR="$PROJECT_DIR/.git/hooks"
if [ -d "$HOOKS_DIR" ]; then
    # Pre-commit hook: check for secrets, validate JSON plugins
    PRECOMMIT="$HOOKS_DIR/pre-commit"
    cat > "$PRECOMMIT" <<'HOOK'
#!/bin/bash
# Cleansing Fire pre-commit hook
# Checks for accidentally committed secrets and validates structure

set -euo pipefail

# Check for common secrets patterns
SECRETS_PATTERN='(API_KEY|SECRET|PASSWORD|TOKEN|PRIVATE_KEY)\s*=\s*["\x27][^"\x27]{8,}'
if git diff --cached --diff-filter=ACM | grep -iE "$SECRETS_PATTERN" 2>/dev/null; then
    echo "WARNING: Possible secret detected in staged changes."
    echo "Review carefully before committing."
    echo "If intentional (e.g., documentation), use: git commit --no-verify"
    exit 1
fi

# Check that plugin files are executable
for plugin in $(git diff --cached --name-only --diff-filter=ACM | grep '^plugins/' || true); do
    if [ -f "$plugin" ] && [ ! -x "$plugin" ]; then
        echo "WARNING: Plugin $plugin is not executable. Run: chmod +x $plugin"
        exit 1
    fi
done

exit 0
HOOK
    chmod +x "$PRECOMMIT"
    ok "Installed pre-commit hook (secret detection, plugin validation)"

    # Post-merge hook: remind about bootstrap
    POSTMERGE="$HOOKS_DIR/post-merge"
    cat > "$POSTMERGE" <<'HOOK'
#!/bin/bash
# After pulling changes, remind to re-bootstrap if scripts changed
CHANGED=$(git diff-tree -r --name-only ORIG_HEAD HEAD 2>/dev/null || echo "")
if echo "$CHANGED" | grep -q "^scripts/"; then
    echo ""
    echo "[Cleansing Fire] Scripts changed in this merge."
    echo "Consider re-running: scripts/bootstrap.sh"
    echo ""
fi
HOOK
    chmod +x "$POSTMERGE"
    ok "Installed post-merge hook (bootstrap reminder)"
else
    warn "No .git/hooks directory found (not a git repo?)"
fi

# ---------------------------------------------------------------------------
# 5. Ensure plugins are executable
# ---------------------------------------------------------------------------
section "Plugin Permissions"

PLUGIN_DIR="$PROJECT_DIR/plugins"
if [ -d "$PLUGIN_DIR" ]; then
    plugin_count=0
    for plugin in "$PLUGIN_DIR"/*; do
        [ -f "$plugin" ] || continue
        name=$(basename "$plugin")
        [ "$name" = "README" ] && continue
        if [ ! -x "$plugin" ]; then
            chmod +x "$plugin"
            ok "Made executable: plugins/$name"
        else
            ok "plugins/$name is executable"
        fi
        plugin_count=$((plugin_count + 1))
    done
    info "$plugin_count plugins found"
else
    warn "No plugins/ directory"
fi

# Ensure scripts are executable
for script in "$SCRIPT_DIR"/*.sh; do
    [ -f "$script" ] || continue
    if [ ! -x "$script" ]; then
        chmod +x "$script"
        ok "Made executable: scripts/$(basename "$script")"
    fi
done

# Ensure bin/ tools are executable
BIN_DIR="$PROJECT_DIR/bin"
if [ -d "$BIN_DIR" ]; then
    for tool in "$BIN_DIR"/*; do
        [ -f "$tool" ] || continue
        if [ ! -x "$tool" ]; then
            chmod +x "$tool"
            ok "Made executable: bin/$(basename "$tool")"
        fi
    done
fi

# ---------------------------------------------------------------------------
# 6. Ollama setup (optional)
# ---------------------------------------------------------------------------
section "Ollama Setup"

if $OLLAMA_PRESENT; then
    # Check if Ollama is running
    if curl -sf http://localhost:11434/api/tags &>/dev/null; then
        ok "Ollama is running"

        # List available models
        MODELS=$(curl -sf http://localhost:11434/api/tags 2>/dev/null | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for m in data.get('models', []):
        print(f\"  {m['name']}\")
except: pass
" 2>/dev/null || echo "  (could not list)")
        info "Available models:"
        echo "$MODELS"

        # Check for recommended model
        if echo "$MODELS" | grep -q "mistral-large"; then
            ok "Recommended model (mistral-large) is available"
        else
            warn "Recommended model (mistral-large:123b) not found"
            if prompt_yn "Pull mistral-large:123b? (This is large, ~70GB)"; then
                info "Pulling mistral-large:123b (this will take a while)..."
                ollama pull mistral-large:123b &
                echo "       Pull started in background. Monitor with: ollama list"
            fi
        fi
    else
        warn "Ollama is installed but not running"
        info "Start with: ollama serve"
    fi
else
    warn "Ollama not installed (needed for local LLM via gatekeeper)"
    if prompt_yn "Install Ollama? (Recommended for local LLM operations)"; then
        info "Installing Ollama..."
        if [[ "$(uname)" == "Darwin" ]]; then
            if command -v brew &>/dev/null; then
                brew install ollama
            else
                curl -fsSL https://ollama.com/install.sh | sh
            fi
        else
            curl -fsSL https://ollama.com/install.sh | sh
        fi
        ok "Ollama installed. Start with: ollama serve"
        info "Then pull the recommended model: ollama pull mistral-large:123b"
    fi
fi

# ---------------------------------------------------------------------------
# 7. Gatekeeper connectivity
# ---------------------------------------------------------------------------
section "Gatekeeper"

GATEKEEPER_URL="http://127.0.0.1:7800"
if curl -sf "${GATEKEEPER_URL}/health" &>/dev/null; then
    HEALTH=$(curl -sf "${GATEKEEPER_URL}/health" 2>/dev/null)
    QUEUE=$(echo "$HEALTH" | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'{d[\"queue_depth\"]}/{d[\"queue_capacity\"]}')" 2>/dev/null || echo "?/?")
    MODEL=$(echo "$HEALTH" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['default_model'])" 2>/dev/null || echo "unknown")
    ok "Gatekeeper is running (queue: $QUEUE, model: $MODEL)"
else
    warn "Gatekeeper is not running on port 7800"
    info "Start with: python3 $PROJECT_DIR/daemon/gatekeeper.py"
    info "Or install as service: $PROJECT_DIR/scripts/gatekeeper-ctl.sh install"
fi

# ---------------------------------------------------------------------------
# 8. Summary and next steps
# ---------------------------------------------------------------------------
section "Bootstrap Complete"

echo ""
if [ "$ERRORS" -gt 0 ]; then
    fire "  $ERRORS errors, $WARNINGS warnings"
    echo ""
    echo "  Fix the errors above before proceeding."
    echo "  Required tools must be installed for the system to function."
elif [ "$WARNINGS" -gt 0 ]; then
    ember "  0 errors, $WARNINGS warnings"
    echo ""
    echo "  The system is functional but some features are limited."
    echo "  Address warnings above for full capability."
else
    ok "  All checks passed. Node is ready."
fi

echo ""
if ! $QUIET; then
    cat <<EOF
${BOLD}Next Steps:${RESET}

  ${EMBER}1.${RESET} Start the gatekeeper (if not running):
     ${DIM}python3 daemon/gatekeeper.py${RESET}

  ${EMBER}2.${RESET} Open an interactive session:
     ${DIM}claude${RESET}

  ${EMBER}3.${RESET} Run an investigation:
     ${DIM}scripts/investigate.sh "Palantir"${RESET}

  ${EMBER}4.${RESET} Check node status:
     ${DIM}scripts/node-status.sh${RESET}

  ${EMBER}5.${RESET} Set up daily automation:
     ${DIM}crontab -e  # add: 0 6 * * * $PROJECT_DIR/scripts/daily-fire.sh${RESET}

${FIRE}The fire is lit.${RESET} ${ASH}What you do with the light is yours to decide.${RESET}
${ASH}See clearly. Act anyway. Bear the cost.${RESET}
EOF
fi

# Exit with error if required tools are missing
if [ "$ERRORS" -gt 0 ]; then
    exit 1
fi
exit 0
