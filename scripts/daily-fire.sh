#!/bin/bash
# daily-fire.sh - Daily autonomous operation for a Cleansing Fire node
#
# Designed to run from cron or launchd. Performs the full daily cycle:
# health checks, legislative scans, spending watchdog, digest generation,
# git commit, and push. Logs everything.
#
# Usage:
#   scripts/daily-fire.sh              Run full daily cycle
#   scripts/daily-fire.sh --dry-run    Show what would happen without doing it
#   scripts/daily-fire.sh --help
#
# Crontab example:
#   0 6 * * * /path/to/cleansing-fire/scripts/daily-fire.sh
#
# Launchd: see daemon/com.cleansingfire.daily.plist
set -euo pipefail

# ---------------------------------------------------------------------------
# Project root
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
LOG_DIR="/tmp/cleansing-fire"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/daily.log"
RUN_LOG="$LOG_DIR/daily-$(date '+%Y%m%d-%H%M%S').log"

# Tee to both run-specific and rolling log
exec > >(tee -a "$RUN_LOG" >> "$LOG_FILE") 2>&1

# Keep last 30 daily logs
find "$LOG_DIR" -name "daily-*.log" -mtime +30 -delete 2>/dev/null || true

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
GATEKEEPER_URL="http://127.0.0.1:7800"
PLUGINS_DIR="$PROJECT_DIR/plugins"
OUTPUT_DIR="$PROJECT_DIR/output"
RESULTS_TODAY="$OUTPUT_DIR/daily-$(date '+%Y%m%d')"

DRY_RUN=false

# ---------------------------------------------------------------------------
# Color (disabled when not a terminal, e.g., cron)
# ---------------------------------------------------------------------------
if [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
    RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
    CYAN=$(tput setaf 6); BOLD=$(tput bold); DIM=$(tput dim 2>/dev/null || echo "")
    RESET=$(tput sgr0)
else
    RED="" GREEN="" YELLOW="" CYAN="" BOLD="" DIM="" RESET=""
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
CLEANSING FIRE - Daily Autonomous Operation

Usage: $0 [OPTIONS]

Options:
  --dry-run    Show what would happen without executing
  --help       Show this message

This script runs the daily cycle:
  1. System health checks (gatekeeper, Ollama)
  2. Legislative scans (privacy, antitrust, transparency)
  3. Spending watchdog queries
  4. Daily digest generation (if results found)
  5. Git commit of new output
  6. Push to remote
  7. Log everything

Designed for cron/launchd. All output goes to $LOG_DIR/daily.log

Example crontab:
  0 6 * * * $PROJECT_DIR/scripts/daily-fire.sh
EOF
    exit 0
}

log()     { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
log_ok()  { log "${GREEN}[OK]${RESET}  $*"; }
log_warn(){ log "${YELLOW}[WARN]${RESET} $*"; }
log_fail(){ log "${RED}[FAIL]${RESET} $*"; }
log_info(){ log "${CYAN}[INFO]${RESET} $*"; }

run_plugin() {
    local name="$1"
    local input="$2"
    local output_name="$3"
    local plugin_path="$PLUGINS_DIR/$name"

    if [ ! -x "$plugin_path" ]; then
        log_warn "Plugin not found or not executable: $name"
        return 1
    fi

    if $DRY_RUN; then
        log_info "[DRY RUN] Would run plugin: $name"
        log_info "  Input: $input"
        return 0
    fi

    local output_file="$RESULTS_TODAY/${output_name}.json"
    log_info "Running plugin: $name -> $output_file"

    if echo "$input" | CF_PROJECT_DIR="$PROJECT_DIR" timeout 300 "$plugin_path" > "$output_file" 2>/dev/null; then
        local size
        size=$(wc -c < "$output_file" | tr -d ' ')
        log_ok "Plugin $name completed ($size bytes)"

        # Check for errors in output
        if python3 -c "import json; d=json.load(open('$output_file')); exit(1 if d.get('error') else 0)" 2>/dev/null; then
            log_warn "Plugin $name returned an error in output"
        fi
        return 0
    else
        log_fail "Plugin $name failed or timed out"
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
for arg in "$@"; do
    case "$arg" in
        --help|-h)  usage ;;
        --dry-run)  DRY_RUN=true ;;
        *)          echo "Unknown option: $arg"; usage ;;
    esac
done

# ===========================================================================
# DAILY CYCLE START
# ===========================================================================
log "========================================"
log "CLEANSING FIRE - Daily Cycle Starting"
log "========================================"
log "Project: $PROJECT_DIR"
log "Date:    $(date '+%Y-%m-%d %H:%M:%S %Z')"
log "Mode:    $(if $DRY_RUN; then echo 'DRY RUN'; else echo 'LIVE'; fi)"
log ""

# ---------------------------------------------------------------------------
# Phase 1: System Health
# ---------------------------------------------------------------------------
log "--- Phase 1: System Health ---"

SYSTEM_OK=true

# Check git repo
if git rev-parse --git-dir &>/dev/null; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    log_ok "Git repo OK (branch: $BRANCH)"
else
    log_fail "Not a git repository"
    SYSTEM_OK=false
fi

# Check gatekeeper
GATEKEEPER_OK=false
if curl -sf "${GATEKEEPER_URL}/health" &>/dev/null; then
    HEALTH=$(curl -sf "${GATEKEEPER_URL}/health")
    QUEUE=$(python3 -c "import json; d=json.loads('$HEALTH'); print(f'{d[\"queue_depth\"]}/{d[\"queue_capacity\"]}')" 2>/dev/null || echo "?")
    log_ok "Gatekeeper running (queue: $QUEUE)"
    GATEKEEPER_OK=true
else
    log_warn "Gatekeeper not running - LLM-dependent tasks will be skipped"
fi

# Check Ollama
OLLAMA_OK=false
if curl -sf http://localhost:11434/api/tags &>/dev/null; then
    MODEL_COUNT=$(curl -sf http://localhost:11434/api/tags | python3 -c "import json,sys; print(len(json.load(sys.stdin).get('models',[])))" 2>/dev/null || echo "?")
    log_ok "Ollama running ($MODEL_COUNT models available)"
    OLLAMA_OK=true
else
    log_warn "Ollama not running"
fi

# Check disk space
DISK_AVAIL=$(df -h "$PROJECT_DIR" | tail -1 | awk '{print $4}')
log_info "Disk available: $DISK_AVAIL"

log ""

# ---------------------------------------------------------------------------
# Phase 2: Create output directory
# ---------------------------------------------------------------------------
mkdir -p "$RESULTS_TODAY"
log_info "Output directory: $RESULTS_TODAY"

# ---------------------------------------------------------------------------
# Phase 3: Legislative Scans
# ---------------------------------------------------------------------------
log "--- Phase 2: Legislative Scans ---"

# These don't require gatekeeper (they call external APIs)
SCAN_RESULTS=0

# Privacy scan
if run_plugin "civic-legiscan" \
    '{"action":"monitor","keywords":["surveillance","encryption","privacy","facial recognition","data collection"]}' \
    "legiscan-privacy"; then
    SCAN_RESULTS=$((SCAN_RESULTS + 1))
fi

# Antitrust scan
if run_plugin "civic-legiscan" \
    '{"action":"monitor","keywords":["antitrust","monopoly","merger","competition","market concentration"]}' \
    "legiscan-antitrust"; then
    SCAN_RESULTS=$((SCAN_RESULTS + 1))
fi

# Transparency scan
if run_plugin "civic-legiscan" \
    '{"action":"monitor","keywords":["FOIA","transparency","whistleblower","public records","disclosure"]}' \
    "legiscan-transparency"; then
    SCAN_RESULTS=$((SCAN_RESULTS + 1))
fi

log_info "Legislative scans completed: $SCAN_RESULTS/3"
log ""

# ---------------------------------------------------------------------------
# Phase 4: Spending Watchdog
# ---------------------------------------------------------------------------
log "--- Phase 3: Spending Watchdog ---"

FISCAL_YEAR=$(date '+%Y')
SPENDING_RESULTS=0

if run_plugin "civic-spending" \
    "{\"action\":\"search\",\"keyword\":\"surveillance technology\",\"fiscal_year\":$FISCAL_YEAR}" \
    "spending-surveillance"; then
    SPENDING_RESULTS=$((SPENDING_RESULTS + 1))
fi

if run_plugin "civic-spending" \
    "{\"action\":\"search\",\"keyword\":\"consulting services\",\"fiscal_year\":$FISCAL_YEAR}" \
    "spending-consulting"; then
    SPENDING_RESULTS=$((SPENDING_RESULTS + 1))
fi

if run_plugin "civic-spending" \
    "{\"action\":\"search\",\"keyword\":\"artificial intelligence\",\"fiscal_year\":$FISCAL_YEAR}" \
    "spending-ai"; then
    SPENDING_RESULTS=$((SPENDING_RESULTS + 1))
fi

log_info "Spending watchdog queries: $SPENDING_RESULTS/3"
log ""

# ---------------------------------------------------------------------------
# Phase 5: Daily Digest (if gatekeeper available and we have results)
# ---------------------------------------------------------------------------
log "--- Phase 4: Daily Digest ---"

TOTAL_RESULTS=$((SCAN_RESULTS + SPENDING_RESULTS))

if [ "$TOTAL_RESULTS" -gt 0 ] && $GATEKEEPER_OK; then
    if $DRY_RUN; then
        log_info "[DRY RUN] Would generate daily digest from $TOTAL_RESULTS result files"
    else
        # Collect items from today's results for digest
        DIGEST_ITEMS=$(python3 - "$RESULTS_TODAY" <<'PYEOF'
import json, glob, sys, os

results_dir = sys.argv[1]
items = []

for f in sorted(glob.glob(os.path.join(results_dir, "*.json"))):
    try:
        with open(f) as fh:
            data = json.load(fh)

        name = os.path.basename(f).replace(".json", "")

        # Extract relevant items depending on plugin type
        if "bills" in data:
            for bill in data.get("bills", [])[:5]:
                items.append({
                    "title": f"{bill.get('number', '')} ({bill.get('state', '')}): {bill.get('title', '')}",
                    "source": name,
                })
        elif "awards" in data or "results" in data:
            awards = data.get("awards", data.get("results", []))
            for award in awards[:5]:
                desc = award.get("description", award.get("recipient_name", ""))
                amt = award.get("amount", award.get("total_obligation", 0))
                items.append({
                    "title": f"${amt:,.0f} - {desc[:60]}" if amt else desc[:80],
                    "source": name,
                })
        elif not data.get("error"):
            items.append({"title": f"Result from {name}", "source": name})
    except Exception:
        continue

print(json.dumps(items[:20]))
PYEOF
        )

        if [ -n "$DIGEST_ITEMS" ] && [ "$DIGEST_ITEMS" != "[]" ]; then
            DIGEST_INPUT=$(python3 -c "
import json
items = json.loads('$DIGEST_ITEMS')
print(json.dumps({'action': 'digest', 'items': items, 'period': 'daily'}))
")

            if run_plugin "forge-voice" "$DIGEST_INPUT" "daily-digest"; then
                log_ok "Daily digest generated"

                # Extract and save as markdown too
                DIGEST_FILE="$RESULTS_TODAY/daily-digest.json"
                if [ -f "$DIGEST_FILE" ]; then
                    python3 -c "
import json
with open('$DIGEST_FILE') as f:
    d = json.load(f)
content = d.get('content', '')
if content:
    with open('$RESULTS_TODAY/daily-digest.md', 'w') as f:
        f.write(content)
" 2>/dev/null && log_ok "Markdown digest saved"
                fi
            fi
        else
            log_info "No items to digest"
        fi
    fi
else
    if [ "$TOTAL_RESULTS" -eq 0 ]; then
        log_info "No results to digest"
    elif ! $GATEKEEPER_OK; then
        log_warn "Skipping digest (gatekeeper not available)"
    fi
fi

log ""

# ---------------------------------------------------------------------------
# Phase 6: Git Commit
# ---------------------------------------------------------------------------
log "--- Phase 5: Git Operations ---"

if $DRY_RUN; then
    log_info "[DRY RUN] Would commit and push output changes"
else
    # Check if there are changes to commit
    cd "$PROJECT_DIR"

    # Add output files
    if [ -d "$RESULTS_TODAY" ] && [ "$(ls -A "$RESULTS_TODAY" 2>/dev/null)" ]; then
        # Only commit if output is tracked (not gitignored)
        # If output/ is gitignored (default), we skip the git commit
        if git check-ignore -q output/ 2>/dev/null; then
            log_info "output/ is gitignored - skipping git commit of results"
            log_info "Results are saved locally in: $RESULTS_TODAY"
        else
            git add output/ 2>/dev/null || true

            if git diff --cached --quiet 2>/dev/null; then
                log_info "No new changes to commit"
            else
                DATE_STR=$(date '+%Y-%m-%d')
                git commit -m "daily fire: $DATE_STR scan results

Automated daily cycle: $SCAN_RESULTS legislative scans, $SPENDING_RESULTS spending queries.
Generated by scripts/daily-fire.sh" 2>/dev/null

                log_ok "Committed daily results"

                # Push to remote
                if git remote get-url origin &>/dev/null; then
                    if git push origin HEAD 2>/dev/null; then
                        log_ok "Pushed to remote"
                    else
                        log_warn "Push failed (will retry next cycle)"
                    fi
                else
                    log_info "No remote configured - skipping push"
                fi
            fi
        fi
    else
        log_info "No output files generated today"
    fi

    # Also check for any other uncommitted work
    DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$DIRTY" -gt 0 ]; then
        log_info "Note: $DIRTY uncommitted changes in working tree"
    fi
fi

log ""

# ---------------------------------------------------------------------------
# Phase 7: Summary
# ---------------------------------------------------------------------------
log "========================================"
log "DAILY CYCLE COMPLETE"
log "========================================"
log "Legislative scans: $SCAN_RESULTS/3"
log "Spending queries:  $SPENDING_RESULTS/3"
log "Gatekeeper:        $(if $GATEKEEPER_OK; then echo 'running'; else echo 'down'; fi)"
log "Ollama:            $(if $OLLAMA_OK; then echo 'running'; else echo 'down'; fi)"
log "Output:            $RESULTS_TODAY"
log "Log:               $RUN_LOG"
log "Duration:          ${SECONDS}s"
log ""
log "The fire burns whether or not anyone watches."
log "========================================"
