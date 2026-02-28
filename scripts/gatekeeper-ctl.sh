#!/usr/bin/env bash
# gatekeeper-ctl.sh - Control the Cleansing Fire Gatekeeper daemon
set -euo pipefail

PLIST_NAME="com.cleansingfire.gatekeeper"
PLIST_SRC="$(cd "$(dirname "$0")/.." && pwd)/daemon/${PLIST_NAME}.plist"
PLIST_DST="$HOME/Library/LaunchAgents/${PLIST_NAME}.plist"

usage() {
    echo "Usage: $0 {install|uninstall|start|stop|restart|status|logs}"
    exit 1
}

cmd_install() {
    echo "Installing gatekeeper daemon..."
    cp "$PLIST_SRC" "$PLIST_DST"
    # Update working directory to actual project path
    PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
    sed -i '' "s|/Users/bedwards/vibe/cleansing-fire|${PROJECT_DIR}|g" "$PLIST_DST"
    launchctl load "$PLIST_DST"
    echo "Installed and started. Check: $0 status"
}

cmd_uninstall() {
    echo "Uninstalling gatekeeper daemon..."
    launchctl unload "$PLIST_DST" 2>/dev/null || true
    rm -f "$PLIST_DST"
    echo "Uninstalled."
}

cmd_start() {
    launchctl load "$PLIST_DST" 2>/dev/null || launchctl start "$PLIST_NAME"
    echo "Started."
}

cmd_stop() {
    launchctl stop "$PLIST_NAME" 2>/dev/null || true
    launchctl unload "$PLIST_DST" 2>/dev/null || true
    echo "Stopped."
}

cmd_restart() {
    cmd_stop
    sleep 1
    cmd_start
}

cmd_status() {
    echo "=== Daemon Status ==="
    launchctl list "$PLIST_NAME" 2>/dev/null || echo "Not loaded"
    echo ""
    echo "=== Gatekeeper Health ==="
    curl -s http://127.0.0.1:7800/health 2>/dev/null | python3 -m json.tool || echo "Not responding"
}

cmd_logs() {
    echo "=== stdout ==="
    tail -20 /tmp/cleansing-fire-gatekeeper.stdout.log 2>/dev/null || echo "(no output)"
    echo ""
    echo "=== stderr ==="
    tail -20 /tmp/cleansing-fire-gatekeeper.stderr.log 2>/dev/null || echo "(no errors)"
}

case "${1:-}" in
    install)   cmd_install ;;
    uninstall) cmd_uninstall ;;
    start)     cmd_start ;;
    stop)      cmd_stop ;;
    restart)   cmd_restart ;;
    status)    cmd_status ;;
    logs)      cmd_logs ;;
    *)         usage ;;
esac
