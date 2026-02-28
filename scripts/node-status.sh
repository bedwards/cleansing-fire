#!/bin/bash
# node-status.sh - Comprehensive dashboard for a running Cleansing Fire node
#
# Shows the complete status of an autonomous node: identity, daemons,
# federation, scheduler, content pipeline, system resources, and more.
#
# Usage:
#   scripts/node-status.sh          Interactive terminal dashboard
#   scripts/node-status.sh --json   Machine-readable JSON output
#   scripts/node-status.sh --help   Show usage
set -euo pipefail

# ---------------------------------------------------------------------------
# Project root & config
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

FIRE_CONFIG="$HOME/.cleansing-fire"
GATEKEEPER_URL="http://127.0.0.1:7800"
FIREWIRE_URL="http://127.0.0.1:7801"
SCHEDULER_URL="http://127.0.0.1:7802"
RESULTS_FILE="/tmp/cleansing-fire-scheduler/task-results.jsonl"

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

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
${FIRE}CLEANSING FIRE${RESET} - Node Status Dashboard

Usage: $0 [OPTIONS]

Options:
  --json    Output machine-readable JSON
  --help    Show this message

Sections: Node Identity, Daemons, Federation, Scheduler, Recent Activity,
          System Resources, Repository, Edge Infrastructure, Content Pipeline

${DIM}Know the state of the fire before you feed it.${RESET}
EOF
    exit 0
}

JSON_MODE=false
for arg in "$@"; do
    case "$arg" in
        --help|-h) usage ;;
        --json)    JSON_MODE=true ;;
        *)         echo "Unknown option: $arg"; usage ;;
    esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
section() { $JSON_MODE && return; printf "\n${BOLD}${YELLOW}=== %s ===${RESET}\n" "$*"; }

status_line() {
    local label="$1" value="$2" color="${3:-}"
    $JSON_MODE && return
    case "$color" in
        green)  printf "  %-26s ${GREEN}%s${RESET}\n" "$label" "$value" ;;
        red)    printf "  %-26s ${RED}%s${RESET}\n" "$label" "$value" ;;
        yellow) printf "  %-26s ${YELLOW}%s${RESET}\n" "$label" "$value" ;;
        cyan)   printf "  %-26s ${CYAN}%s${RESET}\n" "$label" "$value" ;;
        *)      printf "  %-26s %s\n" "$label" "$value" ;;
    esac
}

format_uptime() {
    local secs="${1%.*}"
    [ -z "$secs" ] && echo "unknown" && return
    local days=$((secs / 86400)) hours=$(( (secs % 86400) / 3600 )) mins=$(( (secs % 3600) / 60 ))
    if [ "$days" -gt 0 ]; then echo "${days}d ${hours}h ${mins}m"
    elif [ "$hours" -gt 0 ]; then echo "${hours}h ${mins}m"
    else echo "${mins}m"; fi
}

probe() { curl -sf --max-time 3 "$1" 2>/dev/null; }

jf() {
    local json="$1" field="$2"
    python3 -c "import json; d=json.loads(r'''$json'''); print(d.get('$field',''))" 2>/dev/null || echo ""
}

jn() {
    local json="$1" expr="$2"
    python3 -c "import json; d=json.loads(r'''$json'''); print($expr)" 2>/dev/null || echo ""
}

# JSON output accumulator (simple vars, macOS bash 3 compatible)
J_NODE_ID="" J_KEY_FP="" J_GK="unknown" J_FW="unknown" J_SC="unknown"
J_FP_ACTIVE="0" J_FP_TOTAL="0" J_FP_INTEL="0"
J_SE="0" J_SS="0" J_SF="0" J_SA="0"
J_DISK_AVAIL="" J_DISK_PCT="" J_PYTHON="" J_CLAUDE="" J_OLLAMA="" J_OLLAMA_N="0"
J_GIT_BR="" J_GIT_DIRTY="0" J_GIT_REMOTE=""
J_WRANGLER="" J_WORKERS="0" J_CONTENT="0"

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
if ! $JSON_MODE; then
    echo ""
    echo "${FIRE}  CLEANSING FIRE${RESET} ${DIM}- Node Status Dashboard${RESET}"
    echo "${DIM}  $(date '+%Y-%m-%d %H:%M:%S %Z')${RESET}"
    echo "${DIM}  ${PROJECT_DIR}${RESET}"
fi

# =========================================================================
# 1. NODE IDENTITY
# =========================================================================
section "Node Identity"

if [ -f "$FIRE_CONFIG/node.id" ]; then
    J_NODE_ID=$(cat "$FIRE_CONFIG/node.id" 2>/dev/null | tr -d '\n')
    status_line "Node ID:" "$J_NODE_ID" "cyan"
else
    status_line "Node ID:" "not configured" "yellow"
    status_line "Setup:" "bootstrap/setup-node.sh"
fi

if [ -f "$FIRE_CONFIG/node.pub" ]; then
    J_KEY_FP=$(openssl pkey -pubin -in "$FIRE_CONFIG/node.pub" -outform DER 2>/dev/null \
        | openssl dgst -sha256 2>/dev/null | awk '{print $NF}' | head -c 32)
    [ -n "$J_KEY_FP" ] && status_line "Key fingerprint:" "${J_KEY_FP}..." "cyan"
elif [ -f "$FIRE_CONFIG/node.key" ]; then
    J_KEY_FP=$(openssl pkey -in "$FIRE_CONFIG/node.key" -pubout -outform DER 2>/dev/null \
        | openssl dgst -sha256 2>/dev/null | awk '{print $NF}' | head -c 32)
    [ -n "$J_KEY_FP" ] && status_line "Key fingerprint:" "${J_KEY_FP}..." "cyan"
else
    status_line "Key:" "no key material found" "yellow"
fi

status_line "Config dir:" "$FIRE_CONFIG"

# =========================================================================
# 2. DAEMON STATUS
# =========================================================================
section "Daemon Status"

check_daemon() {
    local name="$1" url="$2" port="$3" var="$4"
    local health
    if health=$(probe "$url/health"); then
        local up_s up_fmt
        up_s=$(jf "$health" "uptime_seconds")
        up_fmt=$(format_uptime "$up_s")
        status_line "$name (:$port):" "RUNNING  (up $up_fmt)" "green"
        eval "$var=running"
    else
        status_line "$name (:$port):" "DOWN" "red"
        eval "$var=down"
    fi
}

check_daemon "Gatekeeper" "$GATEKEEPER_URL" "7800" "J_GK"
check_daemon "FireWire"   "$FIREWIRE_URL"   "7801" "J_FW"
check_daemon "Scheduler"  "$SCHEDULER_URL"  "7802" "J_SC"

# =========================================================================
# 3. FEDERATION NETWORK
# =========================================================================
section "Federation Network"

FW_HEALTH=$(probe "$FIREWIRE_URL/health" || echo "")
if [ -n "$FW_HEALTH" ]; then
    J_FP_ACTIVE=$(jf "$FW_HEALTH" "peers_active")
    J_FP_TOTAL=$(jf "$FW_HEALTH" "peers_total")
    J_FP_INTEL=$(jf "$FW_HEALTH" "intelligence_count")
    FW_LOG=$(jf "$FW_HEALTH" "log_entries")
    FW_SEQ=$(jf "$FW_HEALTH" "sequence")

    if [ "${J_FP_ACTIVE:-0}" -gt 0 ] 2>/dev/null; then
        status_line "Connected peers:" "${J_FP_ACTIVE} active / ${J_FP_TOTAL} total" "green"
    else
        status_line "Connected peers:" "${J_FP_ACTIVE:-0} active / ${J_FP_TOTAL:-0} total" "yellow"
    fi
    status_line "Intelligence items:" "${J_FP_INTEL:-0}" "cyan"
    status_line "Log entries:" "${FW_LOG:-0}"
    status_line "Message sequence:" "${FW_SEQ:-0}"

    # Last heartbeat from peers
    FW_PEERS_DATA=$(probe "$FIREWIRE_URL/peers" || echo "")
    if [ -n "$FW_PEERS_DATA" ]; then
        LAST_SEEN=$(jn "$FW_PEERS_DATA" "max((p.get('last_seen','') for p in d.get('peers',[])), default='none')")
        [ -n "$LAST_SEEN" ] && [ "$LAST_SEEN" != "none" ] && status_line "Last heartbeat:" "$LAST_SEEN"
    fi
else
    status_line "FireWire:" "offline - federation unavailable" "red"
fi

# =========================================================================
# 4. SCHEDULER STATS
# =========================================================================
section "Scheduler Stats"

SCHED_STATUS=$(probe "$SCHEDULER_URL/status" || echo "")
if [ -n "$SCHED_STATUS" ]; then
    J_SE=$(jn "$SCHED_STATUS" "d.get('stats',{}).get('tasks_executed',0)")
    J_SS=$(jn "$SCHED_STATUS" "d.get('stats',{}).get('tasks_succeeded',0)")
    J_SF=$(jn "$SCHED_STATUS" "d.get('stats',{}).get('tasks_failed',0)")
    J_SA=$(jn "$SCHED_STATUS" "len(d.get('stats',{}).get('active_tasks',[]))")
    S_TOTAL=$(jf "$SCHED_STATUS" "total_tasks")
    S_ENABLED=$(jf "$SCHED_STATUS" "enabled_tasks")

    status_line "Configured tasks:" "${S_TOTAL} total, ${S_ENABLED} enabled"
    status_line "Executed:" "$J_SE" "cyan"
    [ "${J_SS:-0}" -gt 0 ] 2>/dev/null \
        && status_line "Succeeded:" "$J_SS" "green" \
        || status_line "Succeeded:" "${J_SS:-0}"
    [ "${J_SF:-0}" -gt 0 ] 2>/dev/null \
        && status_line "Failed:" "$J_SF" "red" \
        || status_line "Failed:" "${J_SF:-0}" "green"

    if [ "${J_SA:-0}" -gt 0 ] 2>/dev/null; then
        status_line "Active now:" "$J_SA" "green"
        if ! $JSON_MODE; then
            jn "$SCHED_STATUS" "
for t in d.get('stats',{}).get('active_tasks',[]):
    print('    -> ' + t.get('name','?') + ' (since ' + t.get('started','?')[:19] + ')')
" 2>/dev/null || true
        fi
    else
        status_line "Active now:" "idle"
    fi

    CATS=$(jn "$SCHED_STATUS" "', '.join(f'{c}:{n}' for c,n in sorted(d.get('categories',{}).items()))")
    [ -n "$CATS" ] && status_line "Categories:" "$CATS"
else
    status_line "Scheduler:" "offline" "red"
fi

# =========================================================================
# 5. RECENT ACTIVITY
# =========================================================================
section "Recent Activity"

RENDER_RESULTS='
import json, sys
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        r = json.loads(line)
        ok = r.get("success", False)
        m = "\033[32m" if ok else "\033[31m"
        t = "OK" if ok else "FAIL"
        print(f"  {m}[{t:4s}]\033[0m {r.get(\"task\",\"?\")[:32]:32s} {r.get(\"duration\",0):6.1f}s  {r.get(\"category\",\"-\")[:12]:12s}  {r.get(\"timestamp\",\"\")[:19]}")
    except: pass
'

if [ -f "$RESULTS_FILE" ]; then
    LINES=$(tail -5 "$RESULTS_FILE" 2>/dev/null || echo "")
    if [ -n "$LINES" ]; then
        $JSON_MODE || echo "$LINES" | python3 -c "$RENDER_RESULTS" 2>/dev/null
    else
        status_line "Results:" "no results yet" "yellow"
    fi
elif SCHED_RESULTS=$(probe "$SCHEDULER_URL/results") && [ -n "$SCHED_RESULTS" ]; then
    $JSON_MODE || jn "$SCHED_RESULTS" "
import sys
for r in d.get('results',[])[-5:]:
    ok = r.get('success', False)
    m = '\033[32m' if ok else '\033[31m'
    t = 'OK' if ok else 'FAIL'
    print(f'  {m}[{t:4s}]\033[0m {r.get(\"task\",\"?\")[:32]:32s} {r.get(\"duration\",0):6.1f}s  {r.get(\"category\",\"-\")[:12]:12s}  {r.get(\"timestamp\",\"\")[:19]}')
" 2>/dev/null || true
else
    status_line "Results:" "no results file or API" "yellow"
fi

# =========================================================================
# 6. SYSTEM RESOURCES
# =========================================================================
section "System Resources"

DISK_INFO=$(df -h "$PROJECT_DIR" 2>/dev/null | tail -1)
J_DISK_AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
J_DISK_PCT=$(echo "$DISK_INFO" | awk '{print $5}')
PCT_NUM=$(echo "$J_DISK_PCT" | tr -d '%')

if [ "${PCT_NUM:-0}" -gt 90 ] 2>/dev/null; then
    status_line "Disk:" "${J_DISK_AVAIL} free (${J_DISK_PCT} used) -- CRITICAL" "red"
elif [ "${PCT_NUM:-0}" -gt 75 ] 2>/dev/null; then
    status_line "Disk:" "${J_DISK_AVAIL} free (${J_DISK_PCT} used)" "yellow"
else
    status_line "Disk:" "${J_DISK_AVAIL} free (${J_DISK_PCT} used)" "green"
fi

PROJECT_SIZE=$(du -sh "$PROJECT_DIR" 2>/dev/null | cut -f1 || echo "?")
status_line "Project size:" "$PROJECT_SIZE"

if command -v python3 &>/dev/null; then
    J_PYTHON=$(python3 --version 2>&1)
    status_line "Python:" "$J_PYTHON" "green"
else
    status_line "Python:" "not found" "red"; J_PYTHON="missing"
fi

if command -v claude &>/dev/null; then
    J_CLAUDE=$(claude --version 2>&1 | head -1 || echo "installed")
    status_line "Claude Code:" "$J_CLAUDE" "green"
else
    status_line "Claude Code:" "not installed" "yellow"; J_CLAUDE="missing"
fi

if OLLAMA_TAGS=$(probe "http://localhost:11434/api/tags"); then
    J_OLLAMA="running"
    J_OLLAMA_N=$(jn "$OLLAMA_TAGS" "len(d.get('models',[]))")
    NAMES=$(jn "$OLLAMA_TAGS" "', '.join(m['name'] for m in d.get('models',[])[:5])")
    status_line "Ollama:" "running (${J_OLLAMA_N} models)" "green"
    [ -n "$NAMES" ] && status_line "Models:" "$NAMES"
elif command -v ollama &>/dev/null; then
    status_line "Ollama:" "installed but not running" "yellow"; J_OLLAMA="stopped"
else
    status_line "Ollama:" "not installed" "red"; J_OLLAMA="missing"
fi

# =========================================================================
# 7. REPOSITORY STATUS
# =========================================================================
section "Repository Status"

if git rev-parse --git-dir &>/dev/null; then
    J_GIT_BR=$(git branch --show-current 2>/dev/null || echo "detached")
    LAST_COMMIT=$(git log -1 --format='%h %s' 2>/dev/null || echo "none")
    COMMIT_AGE=$(git log -1 --format='%cr' 2>/dev/null || echo "unknown")
    J_GIT_DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    J_GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "none")

    status_line "Branch:" "$J_GIT_BR" "green"
    status_line "Last commit:" "$LAST_COMMIT"
    status_line "Commit age:" "$COMMIT_AGE"

    if [ "$J_GIT_DIRTY" -gt 0 ]; then
        status_line "Uncommitted:" "$J_GIT_DIRTY files" "yellow"
    else
        status_line "Working tree:" "clean" "green"
    fi

    AB=$(git rev-list --left-right --count HEAD...origin/"$J_GIT_BR" 2>/dev/null || echo "")
    if [ -n "$AB" ]; then
        AHEAD=$(echo "$AB" | awk '{print $1}'); BEHIND=$(echo "$AB" | awk '{print $2}')
        if [ "${AHEAD:-0}" -eq 0 ] && [ "${BEHIND:-0}" -eq 0 ]; then
            status_line "Remote sync:" "up to date" "green"
        else
            [ "${AHEAD:-0}" -gt 0 ] && status_line "Ahead:" "$AHEAD commits" "yellow"
            [ "${BEHIND:-0}" -gt 0 ] && status_line "Behind:" "$BEHIND commits" "red"
        fi
    fi
else
    status_line "Git:" "not a repository" "red"
fi

# =========================================================================
# 8. EDGE INFRASTRUCTURE
# =========================================================================
section "Edge Infrastructure"

WORKERS_FOUND=0
for wd in "$PROJECT_DIR"/edge/*/; do
    [ -d "$wd" ] || continue
    wn=$(basename "$wd")
    if [ -f "$wd/wrangler.toml" ] || [ -f "$wd/wrangler.jsonc" ]; then
        WORKERS_FOUND=$((WORKERS_FOUND + 1))
    fi
done
J_WORKERS="$WORKERS_FOUND"

if command -v wrangler &>/dev/null; then
    J_WRANGLER=$(wrangler --version 2>&1 | head -1 || echo "installed")
    status_line "Wrangler:" "$J_WRANGLER" "green"
    for wd in "$PROJECT_DIR"/edge/*/; do
        [ -d "$wd" ] || continue
        wn=$(basename "$wd")
        [ -f "$wd/wrangler.toml" ] || [ -f "$wd/wrangler.jsonc" ] || continue
        status_line "  $wn:" "configured" "cyan"
    done
else
    status_line "Wrangler:" "not installed" "yellow"
    J_WRANGLER="missing"
    [ "$WORKERS_FOUND" -gt 0 ] && status_line "Workers found:" "$WORKERS_FOUND (deploy needs wrangler)" "yellow"
fi

if command -v gh &>/dev/null; then
    DS=$(gh run list --workflow=deploy-workers.yml --limit 1 --json status,conclusion,createdAt 2>/dev/null || echo "")
    if [ -n "$DS" ] && [ "$DS" != "[]" ]; then
        DC=$(jn "$DS" "d[0].get('conclusion','') if d else ''")
        DD=$(jn "$DS" "d[0].get('createdAt','')[:19] if d else ''")
        if [ "$DC" = "success" ]; then
            status_line "Last deploy:" "success ($DD)" "green"
        elif [ -n "$DC" ]; then
            status_line "Last deploy:" "$DC ($DD)" "red"
        fi
    fi
fi

# =========================================================================
# 9. CONTENT PIPELINE
# =========================================================================
section "Content Pipeline"

if [ -d "$PROJECT_DIR/output" ]; then
    TOTAL=$(find "$PROJECT_DIR/output" -type f 2>/dev/null | wc -l | tr -d ' ')
    SVG_N=$(find "$PROJECT_DIR/output" -name "*.svg" -type f 2>/dev/null | wc -l | tr -d ' ')
    JSON_N=$(find "$PROJECT_DIR/output" -name "*.json" -type f 2>/dev/null | wc -l | tr -d ' ')
    MD_N=$(find "$PROJECT_DIR/output" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    OUT_SZ=$(du -sh "$PROJECT_DIR/output" 2>/dev/null | cut -f1 || echo "?")

    status_line "Output files:" "$TOTAL ($OUT_SZ)"
    status_line "By type:" "SVG:$SVG_N  JSON:$JSON_N  MD:$MD_N"
    J_CONTENT="$TOTAL"

    if ! $JSON_MODE && [ "$TOTAL" -gt 0 ]; then
        echo "  ${DIM}Recent output:${RESET}"
        find "$PROJECT_DIR/output" -type f 2>/dev/null \
            | xargs ls -lt 2>/dev/null | head -5 \
            | awk -v p="$PROJECT_DIR/" '{sub(p, "", $NF); print "    " $NF}'
    fi
else
    status_line "Output:" "directory not created" "yellow"
fi

if [ -n "$FW_HEALTH" ]; then
    IC=$(jf "$FW_HEALTH" "intelligence_count")
    [ "${IC:-0}" -gt 0 ] 2>/dev/null \
        && status_line "Intelligence shared:" "$IC items" "green" \
        || status_line "Intelligence shared:" "0 items"
fi

if [ -n "${SCHED_STATUS:-}" ]; then
    for phase in sense create distribute; do
        PC=$(jn "$SCHED_STATUS" "d.get('categories',{}).get('$phase',0)")
        [ "${PC:-0}" -gt 0 ] 2>/dev/null && status_line "${phase^} tasks:" "$PC active"
    done
fi

# =========================================================================
# JSON output
# =========================================================================
if $JSON_MODE; then
    python3 -c "
import json
data = {
    'timestamp': '$(date -u '+%Y-%m-%dT%H:%M:%SZ')',
    'project_dir': '$PROJECT_DIR',
    'node': {'id': '$J_NODE_ID', 'key_fingerprint': '$J_KEY_FP', 'config_dir': '$FIRE_CONFIG'},
    'daemons': {'gatekeeper': '$J_GK', 'firewire': '$J_FW', 'scheduler': '$J_SC'},
    'federation': {
        'peers_active': int('${J_FP_ACTIVE:-0}' or 0),
        'peers_total': int('${J_FP_TOTAL:-0}' or 0),
        'intelligence_items': int('${J_FP_INTEL:-0}' or 0),
    },
    'scheduler': {
        'tasks_executed': int('${J_SE:-0}' or 0),
        'tasks_succeeded': int('${J_SS:-0}' or 0),
        'tasks_failed': int('${J_SF:-0}' or 0),
        'active_tasks': int('${J_SA:-0}' or 0),
    },
    'system': {
        'disk_available': '$J_DISK_AVAIL', 'disk_percent': '$J_DISK_PCT',
        'python': '$J_PYTHON', 'claude_code': '$J_CLAUDE',
        'ollama': '$J_OLLAMA', 'ollama_models': int('${J_OLLAMA_N:-0}' or 0),
    },
    'git': {'branch': '$J_GIT_BR', 'dirty_files': int('${J_GIT_DIRTY:-0}' or 0), 'remote': '$J_GIT_REMOTE'},
    'edge': {'wrangler': '$J_WRANGLER', 'workers': int('${J_WORKERS:-0}' or 0)},
    'content': {'output_files': int('${J_CONTENT:-0}' or 0)},
}
print(json.dumps(data, indent=2))
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
