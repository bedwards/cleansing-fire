#!/usr/bin/env bash
# firewire-ctl.sh - Control the Cleansing Fire FireWire federation daemon
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FIREWIRE_PORT="${FIREWIRE_PORT:-7801}"
FIREWIRE_URL="http://127.0.0.1:${FIREWIRE_PORT}"
PID_FILE="/tmp/cleansing-fire-firewire.pid"
LOG_FILE="/tmp/cleansing-fire-firewire.log"

usage() {
    cat <<EOF
Usage: $0 {start|stop|restart|status|peers|announce|health|log}

Commands:
  start              Start the FireWire federation daemon
  stop               Stop the FireWire daemon
  restart            Restart the FireWire daemon
  status             Show daemon status and health
  peers              List known peers
  announce <address> Announce this node to a peer (e.g., http://host:7801)
  health             Show health check output
  log [page]         Show append-only log (optional page number)
EOF
    exit 1
}

cmd_start() {
    if curl -sf "${FIREWIRE_URL}/health" >/dev/null 2>&1; then
        echo "FireWire daemon already running on port ${FIREWIRE_PORT}"
        return 0
    fi

    echo "Starting FireWire daemon on port ${FIREWIRE_PORT}..."
    nohup python3 "${PROJECT_DIR}/daemon/firewire.py" \
        --port "${FIREWIRE_PORT}" \
        --pid-file "${PID_FILE}" \
        >> "${LOG_FILE}" 2>&1 &

    # Wait for startup
    for i in 1 2 3 4 5; do
        sleep 1
        if curl -sf "${FIREWIRE_URL}/health" >/dev/null 2>&1; then
            echo "FireWire daemon started."
            cmd_health
            return 0
        fi
    done

    echo "Warning: daemon may not have started. Check ${LOG_FILE}"
    return 1
}

cmd_stop() {
    if [ -f "${PID_FILE}" ]; then
        PID=$(cat "${PID_FILE}")
        if kill -0 "${PID}" 2>/dev/null; then
            echo "Stopping FireWire daemon (PID ${PID})..."
            kill "${PID}"
            sleep 1
            if kill -0 "${PID}" 2>/dev/null; then
                kill -9 "${PID}" 2>/dev/null || true
            fi
            rm -f "${PID_FILE}"
            echo "Stopped."
            return 0
        fi
        rm -f "${PID_FILE}"
    fi

    # Try to find by port
    PID=$(lsof -ti :"${FIREWIRE_PORT}" 2>/dev/null || true)
    if [ -n "${PID}" ]; then
        echo "Stopping FireWire daemon (PID ${PID})..."
        kill "${PID}" 2>/dev/null || true
        sleep 1
        echo "Stopped."
    else
        echo "FireWire daemon is not running."
    fi
}

cmd_restart() {
    cmd_stop
    sleep 1
    cmd_start
}

cmd_status() {
    echo "=== FireWire Daemon Status ==="
    if [ -f "${PID_FILE}" ]; then
        PID=$(cat "${PID_FILE}")
        if kill -0 "${PID}" 2>/dev/null; then
            echo "PID: ${PID} (running)"
        else
            echo "PID file exists but process not running"
        fi
    else
        echo "No PID file"
    fi
    echo ""
    cmd_health
}

cmd_health() {
    echo "=== FireWire Health ==="
    curl -s "${FIREWIRE_URL}/health" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "Not responding on ${FIREWIRE_URL}"
}

cmd_peers() {
    echo "=== FireWire Peers ==="
    curl -s "${FIREWIRE_URL}/peers" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "Not responding on ${FIREWIRE_URL}"
}

cmd_announce() {
    local peer_address="${1:-}"
    if [ -z "${peer_address}" ]; then
        echo "Usage: $0 announce <peer-address>"
        echo "Example: $0 announce http://192.168.1.100:7801"
        exit 1
    fi
    echo "Announcing to ${peer_address}..."
    echo "{\"action\": \"announce\", \"peer_address\": \"${peer_address}\"}" \
        | python3 "${PROJECT_DIR}/plugins/firewire-relay" \
        | python3 -m json.tool
}

cmd_log() {
    local page="${1:-1}"
    echo "=== FireWire Log (page ${page}) ==="
    curl -s "${FIREWIRE_URL}/log?page=${page}" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo "Not responding on ${FIREWIRE_URL}"
}

case "${1:-}" in
    start)     cmd_start ;;
    stop)      cmd_stop ;;
    restart)   cmd_restart ;;
    status)    cmd_status ;;
    peers)     cmd_peers ;;
    announce)  cmd_announce "${2:-}" ;;
    health)    cmd_health ;;
    log)       cmd_log "${2:-1}" ;;
    *)         usage ;;
esac
