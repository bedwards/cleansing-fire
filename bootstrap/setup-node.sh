#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# CLEANSING FIRE — Node Bootstrap Script
# Sets up a complete autonomous civic intelligence node.
# Run by Claude Code during the bootstrap sequence.
# ============================================================================

FIRE_HOME="${FIRE_HOME:-$HOME/cleansing-fire}"
FIRE_CONFIG="$HOME/.cleansing-fire"
LOG="$FIRE_CONFIG/bootstrap.log"

# Colors
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[FIRE]${NC} $*" | tee -a "$LOG"; }
warn() { echo -e "${ORANGE}[WARN]${NC} $*" | tee -a "$LOG"; }
fail() { echo -e "${RED}[FAIL]${NC} $*" | tee -a "$LOG"; exit 1; }
info() { echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG"; }

# ============================================================================
# Phase 0: Pre-flight checks
# ============================================================================

mkdir -p "$FIRE_CONFIG"
echo "Bootstrap started: $(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$LOG"

log "=== CLEANSING FIRE NODE BOOTSTRAP ==="
log "See clearly. Act anyway. Bear the cost."
echo ""

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Darwin) log "Platform: macOS" ;;
    Linux)  log "Platform: Linux" ;;
    *)      fail "Unsupported platform: $OS" ;;
esac

# Detect architecture
ARCH="$(uname -m)"
log "Architecture: $ARCH"

# ============================================================================
# Phase 1: Check and install dependencies
# ============================================================================

log ""
log "=== Phase 1: Dependencies ==="

# Python 3
if command -v python3 &>/dev/null; then
    PYTHON_VERSION="$(python3 --version 2>&1)"
    log "Python: $PYTHON_VERSION"
else
    fail "Python 3 is required. Install it first: https://python.org/downloads/"
fi

# Git
if command -v git &>/dev/null; then
    log "Git: $(git --version)"
else
    fail "Git is required. Install it first."
fi

# GitHub CLI
if command -v gh &>/dev/null; then
    log "GitHub CLI: $(gh --version | head -1)"
    if gh auth status &>/dev/null 2>&1; then
        log "GitHub CLI: authenticated"
    else
        warn "GitHub CLI: not authenticated. Run 'gh auth login' for full functionality."
    fi
else
    warn "GitHub CLI not found. Some features will be limited."
    info "Install: https://cli.github.com/"
fi

# Node.js / npm (for wrangler)
if command -v node &>/dev/null; then
    log "Node.js: $(node --version)"
else
    warn "Node.js not found. Cloudflare Workers deployment requires it."
    info "Install: https://nodejs.org/ or 'brew install node'"
fi

# Wrangler CLI
if command -v wrangler &>/dev/null; then
    log "Wrangler: $(wrangler --version 2>/dev/null || echo 'installed')"
else
    if command -v npm &>/dev/null; then
        log "Installing wrangler CLI..."
        npm install -g wrangler 2>>"$LOG" || warn "Could not install wrangler globally"
    else
        warn "Wrangler not found and npm not available. Cloudflare deployment will be skipped."
    fi
fi

# Ollama (optional — for local GPU inference)
if command -v ollama &>/dev/null; then
    log "Ollama: found (local AI inference available)"
    HAVE_OLLAMA=true
else
    info "Ollama not found. Local AI inference will use Cloudflare Workers AI instead."
    info "Optional install: https://ollama.ai/"
    HAVE_OLLAMA=false
fi

# ============================================================================
# Phase 2: Clone or update repository
# ============================================================================

log ""
log "=== Phase 2: Repository ==="

if [ -d "$FIRE_HOME/.git" ]; then
    log "Repository exists at $FIRE_HOME"
    cd "$FIRE_HOME"
    git pull --rebase 2>>"$LOG" || warn "Could not pull latest changes"
else
    log "Cloning repository to $FIRE_HOME..."
    git clone https://github.com/bedwards/cleansing-fire.git "$FIRE_HOME" 2>>"$LOG"
    cd "$FIRE_HOME"
fi

log "Repository: $(git log --oneline -1)"

# ============================================================================
# Phase 3: Configure local environment
# ============================================================================

log ""
log "=== Phase 3: Local Configuration ==="

# Create .env if it doesn't exist
if [ ! -f "$FIRE_HOME/.env" ]; then
    log "Creating .env from template..."
    cat > "$FIRE_HOME/.env" << 'ENVEOF'
# Cleansing Fire - Environment Variables
# NEVER commit this file. It is in .gitignore.

# Ollama Gatekeeper
GATEKEEPER_URL=http://127.0.0.1:7800

# API keys (add as needed)
# GEMINI_API_KEY=
# LEGISCAN_API_KEY=
# FEC_API_KEY=
# NEWSAPI_KEY=
# MEDIASTACK_KEY=
ENVEOF
    log ".env created"
else
    log ".env already exists"
fi

# Make all scripts and plugins executable
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x plugins/* 2>/dev/null || true
chmod +x bin/* 2>/dev/null || true
log "Scripts and plugins: executable"

# ============================================================================
# Phase 4: Generate node identity
# ============================================================================

log ""
log "=== Phase 4: Node Identity ==="

NODE_KEY="$FIRE_CONFIG/node.key"
NODE_PUB="$FIRE_CONFIG/node.pub"
NODE_ID_FILE="$FIRE_CONFIG/node.id"

if [ -f "$NODE_KEY" ] && [ -f "$NODE_PUB" ]; then
    log "Node identity already exists"
    NODE_ID="$(cat "$NODE_ID_FILE" 2>/dev/null || echo 'unknown')"
    log "Node ID: $NODE_ID"
else
    log "Generating Ed25519 keypair..."
    # Generate Ed25519 key pair using openssl
    openssl genpkey -algorithm Ed25519 -out "$NODE_KEY" 2>>"$LOG"
    openssl pkey -in "$NODE_KEY" -pubout -out "$NODE_PUB" 2>>"$LOG"
    chmod 600 "$NODE_KEY"
    chmod 644 "$NODE_PUB"

    # Generate node ID from public key hash
    NODE_ID="fire-$(openssl pkey -in "$NODE_KEY" -pubout -outform DER 2>/dev/null | openssl dgst -sha256 -hex 2>/dev/null | cut -d' ' -f2 | head -c 16)"
    echo "$NODE_ID" > "$NODE_ID_FILE"
    log "Node ID: $NODE_ID"
    log "Keypair stored in $FIRE_CONFIG/"
fi

# ============================================================================
# Phase 5: Set up local services
# ============================================================================

log ""
log "=== Phase 5: Local Services ==="

# Gatekeeper daemon (if Ollama is available)
if [ "$HAVE_OLLAMA" = true ]; then
    if curl -sf http://127.0.0.1:7800/health >/dev/null 2>&1; then
        log "Gatekeeper daemon: already running"
    else
        log "Starting gatekeeper daemon..."
        nohup python3 "$FIRE_HOME/daemon/gatekeeper.py" >> "$FIRE_CONFIG/gatekeeper.log" 2>&1 &
        sleep 2
        if curl -sf http://127.0.0.1:7800/health >/dev/null 2>&1; then
            log "Gatekeeper daemon: started on port 7800"
        else
            warn "Gatekeeper daemon: failed to start (will use Cloudflare Workers AI)"
        fi
    fi
else
    info "Skipping gatekeeper (no Ollama). Using Cloudflare Workers AI for inference."
fi

# ============================================================================
# Phase 6: Start autonomous scheduler
# ============================================================================

log ""
log "=== Phase 6: Autonomous Scheduler ==="

# The scheduler tasks are defined in scheduler/tasks.json (25 tasks across
# the SENSE -> ANALYZE -> CREATE -> DISTRIBUTE -> IMPROVE -> REPEAT cycle).
# Start the scheduler daemon which manages the full autonomous loop.

if [ -f "$FIRE_HOME/scripts/scheduler-ctl.sh" ]; then
    log "Starting scheduler daemon..."
    bash "$FIRE_HOME/scripts/scheduler-ctl.sh" start 2>>"$LOG" && \
        log "Scheduler: started (status API on port 7802)" || \
        warn "Scheduler: failed to start"
else
    warn "scheduler-ctl.sh not found — scheduler must be started manually"
fi

# Show configured task count
TASK_COUNT=$(python3 -c "
import json
with open('$FIRE_HOME/scheduler/tasks.json') as f:
    d = json.load(f)
enabled = [t for t in d.get('scheduled_tasks', []) if t.get('enabled', True)]
print(len(enabled))
" 2>/dev/null || echo "?")
log "Autonomous tasks: $TASK_COUNT enabled"
log "Categories: sense, analyze, create, distribute, improve, system"
log "Control: scripts/scheduler-ctl.sh status|tasks|results|reload"

# ============================================================================
# Phase 7: Cloudflare deployment (if wrangler available)
# ============================================================================

log ""
log "=== Phase 7: Cloudflare Edge Deployment ==="

if command -v wrangler &>/dev/null; then
    if wrangler whoami &>/dev/null 2>&1; then
        log "Wrangler: authenticated"

        # Deploy workers
        for worker in fire-api fire-ai fire-markdown; do
            WORKER_DIR="$FIRE_HOME/edge/$worker"
            if [ -d "$WORKER_DIR" ]; then
                log "Deploying $worker..."
                (cd "$WORKER_DIR" && wrangler deploy 2>>"$LOG") && \
                    log "$worker: deployed" || \
                    warn "$worker: deployment failed (will retry later)"
            fi
        done
    else
        warn "Wrangler not authenticated. Run 'wrangler login' to deploy edge workers."
        info "The node will operate in local-only mode until Cloudflare is configured."
    fi
else
    info "Wrangler not available. Skipping Cloudflare deployment."
    info "The node will operate in local-only mode."
fi

# ============================================================================
# Phase 8: Summary
# ============================================================================

log ""
log "============================================"
log "  CLEANSING FIRE NODE BOOTSTRAP COMPLETE"
log "============================================"
log ""
log "Node ID:        $(cat "$NODE_ID_FILE" 2>/dev/null || echo 'generated')"
log "Home:           $FIRE_HOME"
log "Config:         $FIRE_CONFIG"
log "Gatekeeper:     $(curl -sf http://127.0.0.1:7800/health >/dev/null 2>&1 && echo 'running on :7800' || echo 'not running')"
log "Scheduler:      $(curl -sf http://127.0.0.1:7802/health >/dev/null 2>&1 && echo 'running on :7802' || echo 'not running')"
log "FireWire:       $(curl -sf http://127.0.0.1:7801/health >/dev/null 2>&1 && echo 'running on :7801' || echo 'not running')"
log "Ollama:         $(command -v ollama >/dev/null 2>&1 && echo 'available' || echo 'not installed')"
log "Wrangler:       $(command -v wrangler >/dev/null 2>&1 && echo 'available' || echo 'not installed')"
log "GitHub CLI:     $(command -v gh >/dev/null 2>&1 && echo 'available' || echo 'not installed')"
log ""
log "Docs:           $(ls "$FIRE_HOME"/docs/*.md 2>/dev/null | wc -l | tr -d ' ') research documents"
log "Plugins:        $(ls "$FIRE_HOME"/plugins/* 2>/dev/null | wc -l | tr -d ' ') plugins"
log "Investigations: $(ls "$FIRE_HOME"/investigations/*.md 2>/dev/null | grep -v README | wc -l | tr -d ' ') templates"
log "Tasks:          $TASK_COUNT autonomous tasks enabled"
log ""
log "To interact:    cd $FIRE_HOME && claude"
log "To investigate:  claude -p '/investigate [entity name]'"
log "Scheduler:      scripts/scheduler-ctl.sh status"
log "Node status:    scripts/node-status.sh"
log ""
log "The fire is lit. This node is operational."
log "Ignis purgat. Luciditas liberat."
