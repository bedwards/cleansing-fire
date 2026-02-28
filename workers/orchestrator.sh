#!/usr/bin/env bash
# orchestrator.sh - Launch Claude Code background workers with git worktrees
#
# This script is the bridge between the scheduling/event system and Claude Code.
# It creates GitHub issues, launches workers in isolated worktrees, and manages
# the implementation -> review -> merge pipeline.
#
# Usage:
#   ./workers/orchestrator.sh implement "Add feature X" "Detailed description..."
#   ./workers/orchestrator.sh review <pr-number>
#   ./workers/orchestrator.sh status
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

WORKTREE_BASE=".claude/worktrees"
LOG_DIR="/tmp/cleansing-fire-workers"
mkdir -p "$LOG_DIR"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log() { echo "[$(date '+%H:%M:%S')] $*" >&2; }

create_issue() {
    local title="$1"
    local body="$2"
    gh issue create --title "$title" --body "$body" 2>/dev/null
}

get_issue_number() {
    # Extract issue number from gh issue create output
    echo "$1" | grep -oE '[0-9]+$'
}

# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

cmd_implement() {
    local title="${1:?Usage: orchestrator.sh implement <title> <description>}"
    local description="${2:-$title}"
    local labels="${3:-enhancement}"

    log "Creating GitHub issue: $title"
    local issue_url
    issue_url=$(gh issue create \
        --title "$title" \
        --body "$(cat <<EOF
## Description
$description

## Acceptance Criteria
- [ ] Implementation complete
- [ ] Tests pass (if applicable)
- [ ] PR created and ready for review

---
*Created by Cleansing Fire orchestrator*
EOF
)" \
        --label "$labels" 2>/dev/null || echo "")

    local issue_num=""
    if [ -n "$issue_url" ]; then
        issue_num=$(echo "$issue_url" | grep -oE '[0-9]+$')
        log "Created issue #$issue_num"
    else
        log "Warning: Could not create GitHub issue, proceeding without"
    fi

    # Generate a branch name
    local branch_name="cf/$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | head -c 40)"
    if [ -n "$issue_num" ]; then
        branch_name="cf/${issue_num}-$(echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | head -c 30)"
    fi

    local prompt="You are a Cleansing Fire implementation worker.

## Task
$title

## Description
$description

## Instructions
1. Read CLAUDE.md and understand the project conventions
2. Implement the requested changes
3. Write clean, well-tested code
4. Create a git commit with a descriptive message
5. Push your branch
6. Create a pull request$([ -n "$issue_num" ] && echo " that closes #$issue_num")

## Constraints
- Stay focused on THIS task only
- Do not modify unrelated files
- Follow existing code patterns
- Keep changes minimal and focused"

    local log_file="$LOG_DIR/implement-${branch_name//\//-}.log"

    log "Launching implementation worker on branch: $branch_name"
    log "Log: $log_file"

    # Launch Claude Code in headless mode with worktree isolation
    claude -p "$prompt" \
        --permission-mode acceptEdits \
        --worktree "$branch_name" \
        > "$log_file" 2>&1 &

    local worker_pid=$!
    echo "$worker_pid" > "$LOG_DIR/implement-${branch_name//\//-}.pid"
    log "Worker PID: $worker_pid"

    echo "{\"pid\": $worker_pid, \"branch\": \"$branch_name\", \"issue\": \"${issue_num:-none}\", \"log\": \"$log_file\"}"
}

cmd_review() {
    local pr_number="${1:?Usage: orchestrator.sh review <pr-number>}"

    log "Launching review worker for PR #$pr_number"

    local prompt="You are a Cleansing Fire code review worker.

## Task
Review pull request #$pr_number

## Instructions
1. Read the PR description and understand the intent
2. Review ALL changed files carefully
3. Check for:
   - Correctness: Does the code do what it claims?
   - Security: Any vulnerabilities introduced?
   - Quality: Is the code clean, readable, well-structured?
   - Tests: Are there adequate tests?
   - Consistency: Does it follow project conventions?
4. Leave a detailed review on the PR using gh CLI
5. Approve if good, request changes if issues found

## IMPORTANT
- Do NOT fix anything yourself
- Do NOT push any code changes
- ONLY leave review comments on the PR
- Be constructive and specific in feedback"

    local log_file="$LOG_DIR/review-pr-${pr_number}.log"

    claude -p "$prompt" \
        --permission-mode plan \
        > "$log_file" 2>&1 &

    local worker_pid=$!
    echo "$worker_pid" > "$LOG_DIR/review-pr-${pr_number}.pid"
    log "Review worker PID: $worker_pid (log: $log_file)"

    echo "{\"pid\": $worker_pid, \"pr\": $pr_number, \"log\": \"$log_file\"}"
}

cmd_status() {
    echo "=== Active Workers ==="
    for pidfile in "$LOG_DIR"/*.pid; do
        [ -f "$pidfile" ] || continue
        local pid=$(cat "$pidfile")
        local name=$(basename "$pidfile" .pid)
        if kill -0 "$pid" 2>/dev/null; then
            echo "  RUNNING  $name (PID $pid)"
        else
            echo "  STOPPED  $name (PID $pid)"
            rm -f "$pidfile"
        fi
    done

    echo ""
    echo "=== Recent Logs ==="
    for logfile in "$LOG_DIR"/*.log; do
        [ -f "$logfile" ] || continue
        local name=$(basename "$logfile" .log)
        local lines=$(wc -l < "$logfile" 2>/dev/null || echo 0)
        local size=$(du -h "$logfile" 2>/dev/null | cut -f1)
        echo "  $name: $lines lines ($size)"
    done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

case "${1:-}" in
    implement) shift; cmd_implement "$@" ;;
    review)    shift; cmd_review "$@" ;;
    status)    cmd_status ;;
    *)
        echo "Usage: $0 {implement|review|status}"
        echo ""
        echo "  implement <title> [description] [labels]  - Create issue + launch worker"
        echo "  review <pr-number>                         - Launch review worker"
        echo "  status                                     - Show active workers"
        exit 1
        ;;
esac
