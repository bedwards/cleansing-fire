#!/bin/bash
# node-status.sh - Show comprehensive status of a Cleansing Fire node
#
# Displays git status, gatekeeper health, Ollama models, scheduled tasks,
# output directory, disk usage, and network connectivity in one view.
#
# Usage:
#   scripts/node-status.sh
#   scripts/node-status.sh --json
#   scripts/node-status.sh --help
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
${FIRE}CLEANSING FIRE${RESET} - Node Status

Usage: $0 [OPTIONS]

Options:
  --json    Output machine-readable JSON
  --help    Show this message

Shows:
  - Git repository status and recent commits
  - Gatekeeper daemon health
  - Ollama status and available models
  - Scheduled tasks status
  - Output directory contents
  - Disk usage
  - Network connectivity to key services

${DIM}Know the state of the fire before you feed it.${RESET}
EOF
    exit 0
}

JSON_MODE=false

for arg in "$@"; do
    case "$arg" in
        --help|-h)  usage ;;
        --json)     JSON_MODE=true ;;
        *)          echo "Unknown option: $arg"; usage ;;
    esac
done

section() {
    if $JSON_MODE; then return; fi
    echo ""
    echo "${BOLD}${EMBER}=== $* ===${RESET}"
}

status_line() {
    local label="$1"
    local value="$2"
    local color="${3:-}"
    if $JSON_MODE; then return; fi
    case "$color" in
        green)  printf "  %-24s ${GREEN}%s${RESET}\n" "$label" "$value" ;;
        red)    printf "  %-24s ${RED}%s${RESET}\n" "$label" "$value" ;;
        yellow) printf "  %-24s ${YELLOW}%s${RESET}\n" "$label" "$value" ;;
        *)      printf "  %-24s %s\n" "$label" "$value" ;;
    esac
}

# ---------------------------------------------------------------------------
# Collect all status data
# ---------------------------------------------------------------------------
declare -A STATUS

# --- Banner ---
if ! $JSON_MODE; then
    echo ""
    echo "${FIRE}  CLEANSING FIRE - Node Status${RESET}"
    echo "${DIM}  $(date '+%Y-%m-%d %H:%M:%S %Z')${RESET}"
    echo "${DIM}  ${PROJECT_DIR}${RESET}"
fi

# ---------------------------------------------------------------------------
# Git Status
# ---------------------------------------------------------------------------
section "Git Repository"

if git rev-parse --git-dir &>/dev/null; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
    LAST_COMMIT=$(git log -1 --format='%h %s' 2>/dev/null || echo "none")
    LAST_COMMIT_AGE=$(git log -1 --format='%cr' 2>/dev/null || echo "unknown")
    DIRTY_COUNT=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    UNTRACKED=$(git status --porcelain 2>/dev/null | grep '^??' | wc -l | tr -d ' ')
    REMOTE=$(git remote get-url origin 2>/dev/null || echo "none")
    AHEAD_BEHIND=$(git rev-list --left-right --count HEAD...origin/"$BRANCH" 2>/dev/null || echo "? ?")
    AHEAD=$(echo "$AHEAD_BEHIND" | awk '{print $1}')
    BEHIND=$(echo "$AHEAD_BEHIND" | awk '{print $2}')

    status_line "Branch:" "$BRANCH" "green"
    status_line "Last commit:" "$LAST_COMMIT"
    status_line "Commit age:" "$LAST_COMMIT_AGE"
    if [ "$DIRTY_COUNT" -gt 0 ]; then
        status_line "Uncommitted:" "$DIRTY_COUNT files" "yellow"
    else
        status_line "Working tree:" "clean" "green"
    fi
    [ "$UNTRACKED" -gt 0 ] && status_line "Untracked:" "$UNTRACKED files" "yellow"
    status_line "Remote:" "$REMOTE"
    if [ "$AHEAD" != "?" ]; then
        [ "$AHEAD" -gt 0 ] && status_line "Ahead:" "$AHEAD commits" "yellow"
        [ "$BEHIND" -gt 0 ] && status_line "Behind:" "$BEHIND commits" "red"
        [ "$AHEAD" -eq 0 ] && [ "$BEHIND" -eq 0 ] && status_line "Sync:" "up to date" "green"
    fi

    if ! $JSON_MODE; then
        echo ""
        echo "  ${DIM}Recent commits:${RESET}"
        git log --oneline -5 2>/dev/null | while read -r line; do
            echo "    $line"
        done
    fi

    STATUS[git]="ok"
    STATUS[git_branch]="$BRANCH"
    STATUS[git_dirty]="$DIRTY_COUNT"
else
    status_line "Git:" "NOT A REPOSITORY" "red"
    STATUS[git]="error"
fi

# ---------------------------------------------------------------------------
# Gatekeeper
# ---------------------------------------------------------------------------
section "Gatekeeper Daemon"

GATEKEEPER_URL="http://127.0.0.1:7800"
if HEALTH=$(curl -sf "${GATEKEEPER_URL}/health" 2>/dev/null); then
    GK_QUEUE=$(python3 -c "import json; d=json.loads('$HEALTH'); print(f'{d[\"queue_depth\"]}/{d[\"queue_capacity\"]}')" 2>/dev/null || echo "?/?")
    GK_MODEL=$(python3 -c "import json; d=json.loads('$HEALTH'); print(d['default_model'])" 2>/dev/null || echo "unknown")
    GK_RUNNING=$(python3 -c "import json; d=json.loads('$HEALTH'); print('yes' if d['running'] else 'no')" 2>/dev/null || echo "?")
    GK_COMPLETED=$(python3 -c "import json; d=json.loads('$HEALTH'); print(d['total_completed'])" 2>/dev/null || echo "?")
    GK_FAILED=$(python3 -c "import json; d=json.loads('$HEALTH'); print(d['total_failed'])" 2>/dev/null || echo "?")
    GK_REJECTED=$(python3 -c "import json; d=json.loads('$HEALTH'); print(d['total_rejected'])" 2>/dev/null || echo "?")
    GK_CURRENT=$(python3 -c "import json; d=json.loads('$HEALTH'); print(d.get('current_task') or 'idle')" 2>/dev/null || echo "?")

    status_line "Status:" "RUNNING" "green"
    status_line "Queue:" "$GK_QUEUE"
    status_line "Default model:" "$GK_MODEL"
    status_line "Current task:" "$GK_CURRENT"
    status_line "Completed:" "$GK_COMPLETED"
    status_line "Failed:" "$GK_FAILED"
    status_line "Rejected:" "$GK_REJECTED"

    STATUS[gatekeeper]="running"
else
    status_line "Status:" "NOT RUNNING" "red"
    status_line "Start with:" "python3 daemon/gatekeeper.py"
    STATUS[gatekeeper]="down"
fi

# ---------------------------------------------------------------------------
# Ollama
# ---------------------------------------------------------------------------
section "Ollama"

if TAGS=$(curl -sf http://localhost:11434/api/tags 2>/dev/null); then
    status_line "Status:" "RUNNING" "green"

    MODELS=$(python3 -c "
import json
data = json.loads('$(echo "$TAGS" | tr "'" '"')')
models = data.get('models', [])
for m in models:
    name = m['name']
    size_gb = m.get('size', 0) / (1024**3)
    print(f'{name} ({size_gb:.1f}GB)')
" 2>/dev/null || echo "")

    MODEL_COUNT=$(echo "$MODELS" | grep -c . || echo "0")
    status_line "Models:" "$MODEL_COUNT available"

    if [ -n "$MODELS" ]; then
        echo "$MODELS" | while read -r model; do
            echo "    $model"
        done
    fi

    # Check for recommended model
    if echo "$MODELS" | grep -q "mistral-large"; then
        status_line "Recommended:" "mistral-large present" "green"
    else
        status_line "Recommended:" "mistral-large NOT found" "yellow"
    fi

    STATUS[ollama]="running"
    STATUS[ollama_models]="$MODEL_COUNT"
else
    if command -v ollama &>/dev/null; then
        status_line "Status:" "INSTALLED BUT NOT RUNNING" "yellow"
        status_line "Start with:" "ollama serve"
    else
        status_line "Status:" "NOT INSTALLED" "red"
        status_line "Install:" "https://ollama.com"
    fi
    STATUS[ollama]="down"
fi

# ---------------------------------------------------------------------------
# Scheduled Tasks
# ---------------------------------------------------------------------------
section "Scheduled Tasks"

TASKS_FILE="$PROJECT_DIR/scheduler/tasks.json"
if [ -f "$TASKS_FILE" ]; then
    python3 - "$TASKS_FILE" <<'PYEOF'
import json, sys

with open(sys.argv[1]) as f:
    data = json.load(f)

scheduled = data.get("scheduled_tasks", [])
events = data.get("event_tasks", [])

enabled = sum(1 for t in scheduled if t.get("enabled"))
disabled = sum(1 for t in scheduled if not t.get("enabled"))

print(f"  Scheduled tasks:        {len(scheduled)} ({enabled} enabled, {disabled} disabled)")

for t in scheduled:
    state = "\033[32menabled\033[0m" if t.get("enabled") else "\033[33mdisabled\033[0m"
    print(f"    {t['name']:30s} {t['schedule']:15s} [{state}]")

if events:
    evt_enabled = sum(1 for t in events if t.get("enabled"))
    print(f"  Event tasks:            {len(events)} ({evt_enabled} enabled)")
    for t in events:
        state = "\033[32menabled\033[0m" if t.get("enabled") else "\033[33mdisabled\033[0m"
        print(f"    {t['name']:30s} {t['source_type']:15s} [{state}]")
PYEOF
    STATUS[tasks]="ok"
else
    status_line "Tasks file:" "NOT FOUND" "red"
    STATUS[tasks]="missing"
fi

# ---------------------------------------------------------------------------
# Workers
# ---------------------------------------------------------------------------
section "Workers"

WORKER_LOG_DIR="/tmp/cleansing-fire-workers"
if [ -d "$WORKER_LOG_DIR" ]; then
    RUNNING=0
    STOPPED=0
    for pidfile in "$WORKER_LOG_DIR"/*.pid; do
        [ -f "$pidfile" ] || continue
        PID=$(cat "$pidfile")
        NAME=$(basename "$pidfile" .pid)
        if kill -0 "$PID" 2>/dev/null; then
            status_line "RUNNING:" "$NAME (PID $PID)" "green"
            RUNNING=$((RUNNING + 1))
        else
            status_line "STOPPED:" "$NAME (PID $PID)" "yellow"
            STOPPED=$((STOPPED + 1))
        fi
    done
    [ $RUNNING -eq 0 ] && [ $STOPPED -eq 0 ] && status_line "Workers:" "none active"
    STATUS[workers_running]="$RUNNING"
else
    status_line "Workers:" "no worker log directory"
    STATUS[workers_running]="0"
fi

# ---------------------------------------------------------------------------
# Output Directory
# ---------------------------------------------------------------------------
section "Output"

if [ -d "$PROJECT_DIR/output" ]; then
    FILE_COUNT=$(find "$PROJECT_DIR/output" -type f 2>/dev/null | wc -l | tr -d ' ')
    DIR_SIZE=$(du -sh "$PROJECT_DIR/output" 2>/dev/null | cut -f1 || echo "?")
    LATEST=$(find "$PROJECT_DIR/output" -type f -newer "$PROJECT_DIR/output" 2>/dev/null | head -1 || echo "none")

    status_line "Files:" "$FILE_COUNT"
    status_line "Total size:" "$DIR_SIZE"

    # Count by type
    SVG_COUNT=$(find "$PROJECT_DIR/output" -name "*.svg" 2>/dev/null | wc -l | tr -d ' ')
    JSON_COUNT=$(find "$PROJECT_DIR/output" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
    MD_COUNT=$(find "$PROJECT_DIR/output" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    TXT_COUNT=$(find "$PROJECT_DIR/output" -name "*.txt" 2>/dev/null | wc -l | tr -d ' ')

    status_line "By type:" "SVG:$SVG_COUNT JSON:$JSON_COUNT MD:$MD_COUNT TXT:$TXT_COUNT"

    # Recent files
    if ! $JSON_MODE && [ "$FILE_COUNT" -gt 0 ]; then
        echo ""
        echo "  ${DIM}Recent output:${RESET}"
        find "$PROJECT_DIR/output" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -5 | while read -r _ path; do
            local_name="${path#$PROJECT_DIR/}"
            echo "    $local_name"
        done 2>/dev/null || \
        # macOS fallback (no -printf)
        find "$PROJECT_DIR/output" -type f 2>/dev/null | xargs ls -lt 2>/dev/null | head -5 | awk '{print "    " $NF}'
    fi

    STATUS[output_files]="$FILE_COUNT"
else
    status_line "Output:" "directory not created yet"
    status_line "Run:" "scripts/bootstrap.sh"
    STATUS[output_files]="0"
fi

# ---------------------------------------------------------------------------
# Disk Usage
# ---------------------------------------------------------------------------
section "System"

DISK_INFO=$(df -h "$PROJECT_DIR" 2>/dev/null | tail -1)
DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
DISK_AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
DISK_PCT=$(echo "$DISK_INFO" | awk '{print $5}')
PROJECT_SIZE=$(du -sh "$PROJECT_DIR" 2>/dev/null | cut -f1 || echo "?")

status_line "Project size:" "$PROJECT_SIZE"
status_line "Disk used:" "$DISK_USED"
status_line "Disk available:" "$DISK_AVAIL"

# Warn if disk is getting full
PCT_NUM=$(echo "$DISK_PCT" | tr -d '%')
if [ "$PCT_NUM" -gt 90 ] 2>/dev/null; then
    status_line "Disk usage:" "${DISK_PCT} -- CRITICAL" "red"
elif [ "$PCT_NUM" -gt 75 ] 2>/dev/null; then
    status_line "Disk usage:" "${DISK_PCT} -- getting full" "yellow"
else
    status_line "Disk usage:" "$DISK_PCT" "green"
fi

# ---------------------------------------------------------------------------
# Network (quick checks)
# ---------------------------------------------------------------------------
section "Network Connectivity"

check_url() {
    local name="$1"
    local url="$2"
    if curl -sf --max-time 5 "$url" &>/dev/null; then
        status_line "$name:" "reachable" "green"
    else
        status_line "$name:" "unreachable" "red"
    fi
}

check_url "GitHub" "https://api.github.com"
check_url "LegiScan" "https://api.legiscan.com"
check_url "USAspending" "https://api.usaspending.gov"
check_url "FEC" "https://api.open.fec.gov"

# ---------------------------------------------------------------------------
# Plugins
# ---------------------------------------------------------------------------
section "Plugins"

if [ -d "$PROJECT_DIR/plugins" ]; then
    for plugin in "$PROJECT_DIR/plugins"/*; do
        [ -f "$plugin" ] || continue
        name=$(basename "$plugin")
        [ "$name" = "README" ] && continue
        if [ -x "$plugin" ]; then
            status_line "$name:" "executable" "green"
        else
            status_line "$name:" "NOT executable" "red"
        fi
    done
fi

# ---------------------------------------------------------------------------
# Tools
# ---------------------------------------------------------------------------
section "CLI Tools"

for tool in python3 git curl ollama claude gh jq; do
    if command -v "$tool" &>/dev/null; then
        ver=$("$tool" --version 2>&1 | head -1 || echo "?")
        status_line "$tool:" "$ver" "green"
    else
        status_line "$tool:" "not installed" "yellow"
    fi
done

# ---------------------------------------------------------------------------
# JSON output mode
# ---------------------------------------------------------------------------
if $JSON_MODE; then
    python3 -c "
import json, subprocess, os

status = {
    'timestamp': '$(date -u '+%Y-%m-%dT%H:%M:%SZ')',
    'project_dir': '$PROJECT_DIR',
    'git': {
        'status': '${STATUS[git]:-unknown}',
        'branch': '${STATUS[git_branch]:-unknown}',
        'dirty_files': ${STATUS[git_dirty]:-0},
    },
    'gatekeeper': '${STATUS[gatekeeper]:-unknown}',
    'ollama': {
        'status': '${STATUS[ollama]:-unknown}',
        'model_count': '${STATUS[ollama_models]:-0}',
    },
    'tasks': '${STATUS[tasks]:-unknown}',
    'workers_running': ${STATUS[workers_running]:-0},
    'output_files': ${STATUS[output_files]:-0},
}
print(json.dumps(status, indent=2))
"
    exit 0
fi

# ---------------------------------------------------------------------------
# Footer
# ---------------------------------------------------------------------------
echo ""
echo "${FIRE}  The fire reveals the state of things.${RESET}"
echo "${DIM}  What you do with this knowledge is yours to decide.${RESET}"
echo ""
