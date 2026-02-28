#!/bin/bash
# scheduler-ctl.sh - Control the Cleansing Fire scheduler daemon
#
# The scheduler is the heart of autonomous operation — the cron+event loop
# that drives SENSE -> ANALYZE -> CREATE -> DISTRIBUTE -> IMPROVE -> REPEAT.
#
# Usage:
#   scripts/scheduler-ctl.sh start     Start the scheduler daemon
#   scripts/scheduler-ctl.sh stop      Stop the scheduler daemon
#   scripts/scheduler-ctl.sh restart   Restart the scheduler daemon
#   scripts/scheduler-ctl.sh status    Show scheduler status
#   scripts/scheduler-ctl.sh reload    Reload tasks.json without restart
#   scripts/scheduler-ctl.sh tasks     List all configured tasks
#   scripts/scheduler-ctl.sh results   Show recent task results
#   scripts/scheduler-ctl.sh logs      Tail the scheduler logs
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIRE_CONFIG="$HOME/.cleansing-fire"
PID_FILE="$FIRE_CONFIG/scheduler.pid"
LOG_FILE="/tmp/cleansing-fire-scheduler/scheduler.log"
STATUS_URL="http://127.0.0.1:7802"

mkdir -p "$FIRE_CONFIG" "/tmp/cleansing-fire-scheduler"

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

info()  { echo "${CYAN}[info]${RESET}  $*"; }
ok()    { echo "${GREEN}[  ok]${RESET}  $*"; }
fail()  { echo "${RED}[FAIL]${RESET}  $*"; }
warn()  { echo "${YELLOW}[WARN]${RESET}  $*"; }

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

get_pid() {
    if [ -f "$PID_FILE" ]; then
        cat "$PID_FILE"
    fi
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

cmd_start() {
    if is_running; then
        ok "Scheduler already running (PID $(get_pid))"
        return 0
    fi

    info "Starting scheduler daemon..."
    nohup python3 "$PROJECT_DIR/scheduler/scheduler.py" >> "$LOG_FILE" 2>&1 &
    local pid=$!
    echo "$pid" > "$PID_FILE"

    # Wait for status API
    local retries=10
    while [ $retries -gt 0 ]; do
        if curl -sf "$STATUS_URL/health" > /dev/null 2>&1; then
            ok "Scheduler started (PID $pid, status API on port 7802)"
            return 0
        fi
        sleep 0.5
        retries=$((retries - 1))
    done

    # Check if process is still alive
    if kill -0 "$pid" 2>/dev/null; then
        ok "Scheduler started (PID $pid, status API may take a moment)"
    else
        fail "Scheduler failed to start. Check logs: $LOG_FILE"
        rm -f "$PID_FILE"
        return 1
    fi
}

cmd_stop() {
    if ! is_running; then
        info "Scheduler is not running"
        rm -f "$PID_FILE"
        return 0
    fi

    local pid
    pid=$(get_pid)
    info "Stopping scheduler (PID $pid)..."
    kill "$pid" 2>/dev/null

    # Wait for graceful shutdown
    local retries=20
    while [ $retries -gt 0 ] && kill -0 "$pid" 2>/dev/null; do
        sleep 0.5
        retries=$((retries - 1))
    done

    if kill -0 "$pid" 2>/dev/null; then
        warn "Scheduler did not stop gracefully, sending SIGKILL..."
        kill -9 "$pid" 2>/dev/null || true
    fi

    rm -f "$PID_FILE"
    ok "Scheduler stopped"
}

cmd_restart() {
    cmd_stop
    sleep 1
    cmd_start
}

cmd_status() {
    if ! is_running; then
        info "Scheduler is not running"
        return 1
    fi

    local pid
    pid=$(get_pid)
    ok "Scheduler running (PID $pid)"

    # Try to get detailed status from API
    if curl -sf "$STATUS_URL/status" > /dev/null 2>&1; then
        echo ""
        curl -sf "$STATUS_URL/status" | python3 -c "
import json, sys
d = json.load(sys.stdin)
hours = d.get('uptime_seconds', 0) / 3600
print(f'  Uptime:          {hours:.1f} hours')
print(f'  Total tasks:     {d.get(\"total_tasks\", 0)}')
print(f'  Enabled tasks:   {d.get(\"enabled_tasks\", 0)}')
print(f'  Event sources:   {d.get(\"event_sources\", 0)}')

stats = d.get('stats', {})
print(f'  Executed:        {stats.get(\"tasks_executed\", 0)}')
print(f'  Succeeded:       {stats.get(\"tasks_succeeded\", 0)}')
print(f'  Failed:          {stats.get(\"tasks_failed\", 0)}')

active = stats.get('active_tasks', [])
if active:
    print(f'  Active now:      {len(active)}')
    for t in active:
        print(f'    - {t[\"name\"]} (started {t[\"started\"]})')

categories = d.get('categories', {})
if categories:
    print()
    print('  Categories:')
    for cat, count in sorted(categories.items()):
        phase = d.get('cycle_phases', {}).get(cat, '')
        print(f'    {cat:15s} {count:3d} tasks  {phase[:50]}')
" 2>/dev/null || warn "Could not parse status response"
    else
        warn "Status API not responding"
    fi
}

cmd_reload() {
    if ! is_running; then
        fail "Scheduler is not running"
        return 1
    fi

    # Try API reload first
    if curl -sf -X POST "$STATUS_URL/reload" > /dev/null 2>&1; then
        ok "Tasks reloaded via API"
        return 0
    fi

    # Fall back to SIGHUP
    local pid
    pid=$(get_pid)
    kill -HUP "$pid" 2>/dev/null
    ok "Sent SIGHUP to scheduler (PID $pid)"
}

cmd_tasks() {
    if is_running && curl -sf "$STATUS_URL/tasks" > /dev/null 2>&1; then
        curl -sf "$STATUS_URL/tasks" | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(f'Total tasks: {d[\"count\"]}')
print()
fmt = '  {:<30s} {:<12s} {:<10s} {:<12s} {}'
print(fmt.format('NAME', 'SCHEDULE', 'TYPE', 'CATEGORY', 'ENABLED'))
print('  ' + '-' * 90)
for t in d['tasks']:
    enabled = 'yes' if t['enabled'] else 'no'
    print(fmt.format(
        t['name'][:30],
        t.get('schedule', '-')[:12],
        t['type'][:10],
        t.get('category', '-')[:12],
        enabled,
    ))
" 2>/dev/null
    else
        # Parse directly from file
        python3 -c "
import json
with open('$PROJECT_DIR/scheduler/tasks.json') as f:
    d = json.load(f)
tasks = d.get('scheduled_tasks', [])
print(f'Total tasks: {len(tasks)} (from file)')
print()
fmt = '  {:<30s} {:<12s} {:<10s} {:<12s} {}'
print(fmt.format('NAME', 'SCHEDULE', 'TYPE', 'CATEGORY', 'ENABLED'))
print('  ' + '-' * 90)
for t in tasks:
    enabled = 'yes' if t.get('enabled', True) else 'no'
    print(fmt.format(
        t.get('name', '?')[:30],
        t.get('schedule', '-')[:12],
        t.get('type', '?')[:10],
        t.get('category', '-')[:12],
        enabled,
    ))
" 2>/dev/null
    fi
}

cmd_results() {
    if is_running && curl -sf "$STATUS_URL/results" > /dev/null 2>&1; then
        curl -sf "$STATUS_URL/results" | python3 -c "
import json, sys
d = json.load(sys.stdin)
results = d.get('results', [])[-20:]
if not results:
    print('No results yet.')
    sys.exit(0)
print(f'Last {len(results)} results:')
print()
for r in results:
    status = 'OK' if r.get('success') else 'FAIL'
    mark = '\033[32m' if r.get('success') else '\033[31m'
    reset = '\033[0m'
    print(f'  {mark}[{status:4s}]{reset} {r.get(\"task\", \"?\"):30s} {r.get(\"duration\", 0):6.1f}s  {r.get(\"category\", \"-\"):12s}  {r.get(\"timestamp\", \"\")[:19]}')
" 2>/dev/null
    else
        # Parse from log file
        RESULTS_FILE="/tmp/cleansing-fire-scheduler/task-results.jsonl"
        if [ -f "$RESULTS_FILE" ]; then
            tail -20 "$RESULTS_FILE" | python3 -c "
import json, sys
for line in sys.stdin:
    try:
        r = json.loads(line.strip())
        status = 'OK' if r.get('success') else 'FAIL'
        mark = '\033[32m' if r.get('success') else '\033[31m'
        reset = '\033[0m'
        print(f'  {mark}[{status:4s}]{reset} {r.get(\"task\", \"?\"):30s} {r.get(\"duration\", 0):6.1f}s  {r.get(\"category\", \"-\"):12s}  {r.get(\"timestamp\", \"\")[:19]}')
    except json.JSONDecodeError:
        pass
" 2>/dev/null
        else
            info "No results file found"
        fi
    fi
}

cmd_logs() {
    if [ -f "$LOG_FILE" ]; then
        tail -100 -f "$LOG_FILE"
    else
        info "No log file found at $LOG_FILE"
    fi
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

case "${1:-help}" in
    start)   cmd_start ;;
    stop)    cmd_stop ;;
    restart) cmd_restart ;;
    status)  cmd_status ;;
    reload)  cmd_reload ;;
    tasks)   cmd_tasks ;;
    results) cmd_results ;;
    logs)    cmd_logs ;;
    help|--help|-h)
        echo "${RED}${BOLD}CLEANSING FIRE${RESET} - Scheduler Control"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  start     Start the scheduler daemon"
        echo "  stop      Stop the scheduler daemon"
        echo "  restart   Restart the scheduler daemon"
        echo "  status    Show scheduler status and statistics"
        echo "  reload    Reload tasks.json without restart"
        echo "  tasks     List all configured tasks"
        echo "  results   Show recent task execution results"
        echo "  logs      Tail the scheduler log"
        echo ""
        echo "${DIM}The scheduler drives the autonomous loop:"
        echo "SENSE -> ANALYZE -> CREATE -> DISTRIBUTE -> IMPROVE -> REPEAT${RESET}"
        ;;
    *)
        fail "Unknown command: $1"
        echo "Run $0 --help for usage."
        exit 1
        ;;
esac
