#!/usr/bin/env python3
"""
Cleansing Fire - Task Scheduler & Event System

The autonomous operation loop for Cleansing Fire nodes. Manages:
1. Cron-like scheduled tasks (via internal scheduling, not system cron)
2. Event-driven tasks (file watchers, webhooks, HTTP API polls)
3. Plugin-based task execution (JSON stdin/stdout protocol)
4. Claude Code CLI tasks (autonomous AI agent invocations)
5. Integration with the Gatekeeper for local LLM tasks
6. Integration with the Worker Orchestrator for code tasks
7. Integration with FireWire federation daemon for inter-node tasks
8. Status API on port 7802 for monitoring

The SENSE -> ANALYZE -> CREATE -> DISTRIBUTE -> IMPROVE -> REPEAT cycle.
Tasks are defined in scheduler/tasks.json with categories mapping to cycle phases.

Runs as a daemon. Designed for single-node with federation support.
"""

import argparse
import http.server
import json
import logging
import os
import shutil
import signal
import socketserver
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("scheduler")

PROJECT_DIR = Path(__file__).resolve().parent.parent
TASKS_FILE = PROJECT_DIR / "scheduler" / "tasks.json"
PLUGINS_DIR = PROJECT_DIR / "plugins"
LOG_DIR = Path("/tmp/cleansing-fire-scheduler")
LOG_DIR.mkdir(exist_ok=True)
STATUS_PORT = 7802
MAX_CONCURRENT_CLAUDE = 2  # Limit concurrent Claude Code invocations


# ---------------------------------------------------------------------------
# Cron expression parser (simplified: minute hour day_of_month month day_of_week)
# Supports: *, */N, N, N-M
# ---------------------------------------------------------------------------

def cron_match(expr: str, now: datetime) -> bool:
    """Check if a cron expression matches the current time."""
    parts = expr.strip().split()
    if len(parts) != 5:
        return False

    fields = [
        (now.minute, 0, 59),
        (now.hour, 0, 23),
        (now.day, 1, 31),
        (now.month, 1, 12),
        (now.weekday(), 0, 6),  # Monday=0
    ]

    for pattern, (current, lo, hi) in zip(parts, fields):
        if not _field_match(pattern, current, lo, hi):
            return False
    return True


def _field_match(pattern: str, value: int, lo: int, hi: int) -> bool:
    if pattern == "*":
        return True
    if pattern.startswith("*/"):
        step = int(pattern[2:])
        return value % step == 0
    if "-" in pattern:
        a, b = pattern.split("-", 1)
        return int(a) <= value <= int(b)
    if "," in pattern:
        return value in [int(x) for x in pattern.split(",")]
    return value == int(pattern)


# ---------------------------------------------------------------------------
# Task executors
# ---------------------------------------------------------------------------

def exec_shell(task: dict) -> dict:
    """Execute a shell command."""
    cmd = task["command"]
    timeout = task.get("timeout", 120)
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True,
            timeout=timeout, cwd=str(PROJECT_DIR),
        )
        return {
            "success": result.returncode == 0,
            "stdout": result.stdout[-2000:],  # truncate
            "stderr": result.stderr[-1000:],
            "returncode": result.returncode,
        }
    except subprocess.TimeoutExpired:
        return {"success": False, "error": f"Timeout after {timeout}s"}


def exec_gatekeeper(task: dict) -> dict:
    """Submit a prompt to the Ollama gatekeeper."""
    port = task.get("gatekeeper_port", 7800)
    payload = {
        "prompt": task["prompt"],
        "system": task.get("system", ""),
        "model": task.get("model", ""),
        "caller": f"scheduler:{task.get('name', 'unknown')}",
        "temperature": task.get("temperature", 0.7),
        "max_tokens": task.get("max_tokens", 4096),
        "timeout": task.get("timeout", 300),
    }
    data = json.dumps(payload).encode("utf-8")
    endpoint = "submit-sync" if task.get("sync", True) else "submit"
    req = urllib.request.Request(
        f"http://127.0.0.1:{port}/{endpoint}",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, timeout=payload["timeout"] + 10) as resp:
            body = json.loads(resp.read().decode("utf-8"))
            return {
                "success": body.get("status") == "completed",
                "result": body.get("result", ""),
                "task_id": body.get("id", ""),
            }
    except Exception as e:
        return {"success": False, "error": str(e)}


def exec_orchestrator(task: dict) -> dict:
    """Launch a worker via the orchestrator."""
    action = task.get("action", "implement")
    args = task.get("args", [])
    cmd = [str(PROJECT_DIR / "workers" / "orchestrator.sh"), action] + args
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=30,
        )
        return {
            "success": result.returncode == 0,
            "output": result.stdout.strip(),
            "error": result.stderr.strip() if result.returncode != 0 else "",
        }
    except Exception as e:
        return {"success": False, "error": str(e)}


def exec_plugin(task: dict) -> dict:
    """Execute a plugin script from the plugins directory."""
    plugin_name = task["plugin"]
    plugin_path = PLUGINS_DIR / plugin_name
    if not plugin_path.exists():
        return {"success": False, "error": f"Plugin not found: {plugin_name}"}

    plugin_input = json.dumps(task.get("input", {}))
    try:
        result = subprocess.run(
            [str(plugin_path)],
            input=plugin_input, capture_output=True, text=True,
            timeout=task.get("timeout", 120), cwd=str(PROJECT_DIR),
            env={**os.environ, "CF_PROJECT_DIR": str(PROJECT_DIR)},
        )
        try:
            output = json.loads(result.stdout)
        except json.JSONDecodeError:
            output = {"raw": result.stdout[-2000:]}

        return {
            "success": result.returncode == 0,
            "output": output,
            "stderr": result.stderr[-1000:] if result.returncode != 0 else "",
        }
    except subprocess.TimeoutExpired:
        return {"success": False, "error": f"Plugin timeout"}
    except Exception as e:
        return {"success": False, "error": str(e)}


def exec_claude(task: dict) -> dict:
    """Execute a task via Claude Code CLI.

    This is the core of autonomous operation — invoking Claude Opus 4.6
    to perform investigations, research, content generation, and self-improvement.
    Uses --dangerously-skip-permissions for autonomous operation.
    """
    prompt = task.get("prompt", "")
    if not prompt:
        return {"success": False, "error": "No prompt provided for claude task"}

    timeout = task.get("timeout", 600)
    model = task.get("model", "")  # empty = default (Opus 4.6)

    # Check if claude CLI is available
    claude_path = shutil.which("claude")
    if not claude_path:
        return {"success": False, "error": "Claude Code CLI not found in PATH"}

    # Build command
    cmd = [claude_path, "--dangerously-skip-permissions", "-p", prompt]
    if model:
        cmd.extend(["--model", model])

    log.info("Claude task: %.100s...", prompt.replace("\n", " "))

    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True,
            timeout=timeout, cwd=str(PROJECT_DIR),
            env={**os.environ, "CF_PROJECT_DIR": str(PROJECT_DIR)},
        )
        output = result.stdout[-4000:]  # Claude can produce long output
        return {
            "success": result.returncode == 0,
            "stdout": output,
            "stderr": result.stderr[-1000:] if result.returncode != 0 else "",
            "returncode": result.returncode,
        }
    except subprocess.TimeoutExpired:
        return {"success": False, "error": f"Claude task timeout after {timeout}s"}
    except Exception as e:
        return {"success": False, "error": str(e)}


# Semaphore to limit concurrent Claude invocations
_claude_semaphore = threading.Semaphore(MAX_CONCURRENT_CLAUDE)


def exec_claude_limited(task: dict) -> dict:
    """Execute Claude task with concurrency limiting."""
    acquired = _claude_semaphore.acquire(timeout=10)
    if not acquired:
        return {"success": False, "error": "Too many concurrent Claude tasks"}
    try:
        return exec_claude(task)
    finally:
        _claude_semaphore.release()


EXECUTORS = {
    "shell": exec_shell,
    "gatekeeper": exec_gatekeeper,
    "orchestrator": exec_orchestrator,
    "plugin": exec_plugin,
    "claude": exec_claude_limited,
}


# ---------------------------------------------------------------------------
# Event sources
# ---------------------------------------------------------------------------

class EventSource:
    """Base class for event sources that trigger tasks."""
    def check(self) -> list[dict]:
        """Return list of events (dicts) if triggered, empty list otherwise."""
        return []


class FileWatcherEvent(EventSource):
    """Trigger when files matching a glob pattern change."""
    def __init__(self, config: dict):
        self.pattern = config["pattern"]
        self.last_check = {}

    def check(self) -> list[dict]:
        events = []
        for path in PROJECT_DIR.glob(self.pattern):
            mtime = path.stat().st_mtime
            if str(path) in self.last_check and mtime > self.last_check[str(path)]:
                events.append({"type": "file_changed", "path": str(path)})
            self.last_check[str(path)] = mtime
        return events


class HttpPollEvent(EventSource):
    """Trigger when an HTTP endpoint returns new data.

    Used for polling FireWire peers, external APIs, and webhooks.
    """
    def __init__(self, config: dict):
        self.url = config["url"]
        self.interval = config.get("interval", 60)  # seconds
        self.last_poll = 0
        self.last_hash = ""
        self.headers = config.get("headers", {})

    def check(self) -> list[dict]:
        now = time.time()
        if now - self.last_poll < self.interval:
            return []
        self.last_poll = now

        try:
            req = urllib.request.Request(self.url, headers=self.headers)
            with urllib.request.urlopen(req, timeout=15) as resp:
                data = resp.read()
                import hashlib
                data_hash = hashlib.sha256(data).hexdigest()[:16]
                if data_hash != self.last_hash and self.last_hash:
                    self.last_hash = data_hash
                    try:
                        payload = json.loads(data.decode("utf-8"))
                    except (json.JSONDecodeError, UnicodeDecodeError):
                        payload = {"raw_length": len(data)}
                    return [{"type": "http_poll_changed", "url": self.url, "data": payload}]
                self.last_hash = data_hash
        except Exception as e:
            log.debug("HTTP poll %s failed: %s", self.url, e)
        return []


EVENT_SOURCES = {
    "file_watcher": FileWatcherEvent,
    "http_poll": HttpPollEvent,
}


# ---------------------------------------------------------------------------
# Scheduler
# ---------------------------------------------------------------------------

class Scheduler:
    def __init__(self, tasks_file: Path):
        self.tasks_file = tasks_file
        self.tasks = []
        self.events = []
        self.running = True
        self.last_run = {}  # task_name -> last run minute
        self.start_time = datetime.now()
        self.stats = {
            "tasks_executed": 0,
            "tasks_succeeded": 0,
            "tasks_failed": 0,
            "by_category": {},
            "by_type": {},
            "active_tasks": [],
        }
        self._stats_lock = threading.Lock()
        self.load_tasks()

    def load_tasks(self):
        if not self.tasks_file.exists():
            log.warning("No tasks file found at %s, creating default", self.tasks_file)
            self._create_default_tasks()

        with open(self.tasks_file) as f:
            config = json.load(f)

        self.tasks = config.get("scheduled_tasks", [])
        self.events = []
        for evt_config in config.get("event_tasks", []):
            source_type = evt_config.get("source_type")
            if source_type in EVENT_SOURCES:
                source = EVENT_SOURCES[source_type](evt_config.get("source_config", {}))
                self.events.append((source, evt_config))

        # Count tasks by category
        categories = {}
        for t in self.tasks:
            cat = t.get("category", "uncategorized")
            categories[cat] = categories.get(cat, 0) + 1

        log.info("Loaded %d scheduled tasks, %d event sources", len(self.tasks), len(self.events))
        log.info("Task categories: %s", ", ".join(f"{k}={v}" for k, v in sorted(categories.items())))

    def _create_default_tasks(self):
        default = {
            "scheduled_tasks": [
                {
                    "name": "health-check",
                    "schedule": "*/5 * * * *",
                    "type": "shell",
                    "command": "curl -sf http://127.0.0.1:7800/health > /dev/null && echo ok || echo gatekeeper-down",
                    "enabled": True,
                },
                {
                    "name": "git-status-report",
                    "schedule": "0 */6 * * *",
                    "type": "shell",
                    "command": "git status --porcelain && git log --oneline -5",
                    "enabled": True,
                },
            ],
            "event_tasks": [],
        }
        with open(self.tasks_file, "w") as f:
            json.dump(default, f, indent=2)

    def run(self):
        log.info("Scheduler started")
        while self.running:
            now = datetime.now()
            minute_key = now.strftime("%Y%m%d%H%M")

            # Check scheduled tasks
            for task in self.tasks:
                if not task.get("enabled", True):
                    continue
                name = task.get("name", "unnamed")
                if self.last_run.get(name) == minute_key:
                    continue  # already ran this minute
                if cron_match(task.get("schedule", ""), now):
                    self.last_run[name] = minute_key
                    threading.Thread(
                        target=self._execute_task, args=(task,), daemon=True,
                    ).start()

            # Check event sources
            for source, evt_task in self.events:
                try:
                    events = source.check()
                    for event in events:
                        merged = {**evt_task, "event_data": event}
                        threading.Thread(
                            target=self._execute_task, args=(merged,), daemon=True,
                        ).start()
                except Exception as e:
                    log.error("Event source error: %s", e)

            time.sleep(15)  # check every 15 seconds

    def _execute_task(self, task: dict):
        name = task.get("name", "unnamed")
        task_type = task.get("type", "shell")
        category = task.get("category", "uncategorized")
        executor = EXECUTORS.get(task_type)
        if not executor:
            log.error("Unknown task type '%s' for task '%s'", task_type, name)
            return

        log.info("Executing task: %s (type=%s, category=%s)", name, task_type, category)

        # Track active task
        with self._stats_lock:
            self.stats["active_tasks"].append({"name": name, "started": datetime.now().isoformat()})

        start = time.time()
        try:
            result = executor(task)
            duration = round(time.time() - start, 2)
            success = result.get("success", False)
            log.info("Task %s %s (%.1fs)", name, "OK" if success else "FAILED", duration)

            # Update stats
            with self._stats_lock:
                self.stats["tasks_executed"] += 1
                if success:
                    self.stats["tasks_succeeded"] += 1
                else:
                    self.stats["tasks_failed"] += 1
                self.stats["by_category"][category] = self.stats["by_category"].get(category, 0) + 1
                self.stats["by_type"][task_type] = self.stats["by_type"].get(task_type, 0) + 1
                self.stats["active_tasks"] = [
                    t for t in self.stats["active_tasks"] if t["name"] != name
                ]

            # Log result
            log_entry = {
                "task": name,
                "type": task_type,
                "category": category,
                "success": success,
                "duration": duration,
                "timestamp": datetime.now().isoformat(),
                "result": result,
            }
            log_file = LOG_DIR / "task-results.jsonl"
            with open(log_file, "a") as f:
                f.write(json.dumps(log_entry) + "\n")

            # Execute on_success / on_failure hooks
            if success and "on_success" in task:
                self._execute_task(task["on_success"])
            elif not success and "on_failure" in task:
                self._execute_task(task["on_failure"])

        except Exception as e:
            log.error("Task %s exception: %s", name, e)
            with self._stats_lock:
                self.stats["tasks_failed"] += 1
                self.stats["active_tasks"] = [
                    t for t in self.stats["active_tasks"] if t["name"] != name
                ]

    def shutdown(self):
        self.running = False


# ---------------------------------------------------------------------------
# Status API server (port 7802)
# ---------------------------------------------------------------------------

class StatusHandler(http.server.BaseHTTPRequestHandler):
    """HTTP handler for scheduler status and control API."""

    scheduler = None  # Set by main()

    def log_message(self, format, *args):
        pass  # Suppress default logging

    def _json_response(self, data: dict, status: int = 200):
        body = json.dumps(data, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            self._json_response({
                "status": "running",
                "uptime_seconds": (datetime.now() - self.scheduler.start_time).total_seconds(),
            })
        elif self.path == "/status":
            sched = self.scheduler
            enabled = [t for t in sched.tasks if t.get("enabled", True)]
            categories = {}
            for t in enabled:
                cat = t.get("category", "uncategorized")
                categories[cat] = categories.get(cat, 0) + 1

            self._json_response({
                "status": "running",
                "uptime_seconds": round((datetime.now() - sched.start_time).total_seconds()),
                "total_tasks": len(sched.tasks),
                "enabled_tasks": len(enabled),
                "event_sources": len(sched.events),
                "categories": categories,
                "stats": sched.stats,
                "cycle_phases": {
                    "sense": "News scanning, legislative monitoring, spending watchdog, issue checks",
                    "analyze": "Investigations, cross-referencing, deep research",
                    "create": "Social content, threads, visualizations, reports",
                    "distribute": "FireWire federation, peer sharing, heartbeats",
                    "improve": "Self-update, self-assessment, issue creation",
                    "system": "Health checks, git status, file monitoring",
                },
            })
        elif self.path == "/tasks":
            tasks = []
            for t in self.scheduler.tasks:
                tasks.append({
                    "name": t.get("name"),
                    "schedule": t.get("schedule"),
                    "type": t.get("type"),
                    "category": t.get("category", "uncategorized"),
                    "enabled": t.get("enabled", True),
                    "description": t.get("description", ""),
                })
            self._json_response({"tasks": tasks, "count": len(tasks)})
        elif self.path == "/results":
            # Return last 50 task results
            results_file = LOG_DIR / "task-results.jsonl"
            results = []
            if results_file.exists():
                with open(results_file) as f:
                    lines = f.readlines()
                for line in lines[-50:]:
                    try:
                        results.append(json.loads(line.strip()))
                    except json.JSONDecodeError:
                        pass
            self._json_response({"results": results, "count": len(results)})
        else:
            self._json_response({"error": "Not found", "endpoints": [
                "/health", "/status", "/tasks", "/results", "POST /reload",
            ]}, 404)

    def do_POST(self):
        if self.path == "/reload":
            self.scheduler.load_tasks()
            self._json_response({"status": "reloaded", "tasks": len(self.scheduler.tasks)})
        else:
            self._json_response({"error": "Not found"}, 404)


def start_status_server(scheduler, port=STATUS_PORT):
    """Start the status API server in a background thread."""
    StatusHandler.scheduler = scheduler

    class ReuseServer(socketserver.TCPServer):
        allow_reuse_address = True

    try:
        server = ReuseServer(("127.0.0.1", port), StatusHandler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        log.info("Status API running on http://127.0.0.1:%d", port)
        return server
    except OSError as e:
        log.warning("Could not start status API on port %d: %s", port, e)
        return None


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Cleansing Fire Scheduler")
    parser.add_argument("--tasks", type=str, default=str(TASKS_FILE), help="Tasks JSON file")
    parser.add_argument("--port", type=int, default=STATUS_PORT, help="Status API port")
    args = parser.parse_args()

    scheduler = Scheduler(Path(args.tasks))

    # Start status API
    status_server = start_status_server(scheduler, args.port)

    def shutdown_handler(signum, frame):
        scheduler.shutdown()
        if status_server:
            status_server.shutdown()

    signal.signal(signal.SIGTERM, shutdown_handler)
    signal.signal(signal.SIGINT, shutdown_handler)

    # Reload tasks on SIGHUP
    def reload_handler(signum, frame):
        log.info("SIGHUP received, reloading tasks...")
        scheduler.load_tasks()

    signal.signal(signal.SIGHUP, reload_handler)

    try:
        scheduler.run()
    except KeyboardInterrupt:
        pass
    finally:
        if status_server:
            status_server.shutdown()
        log.info("Scheduler stopped.")


if __name__ == "__main__":
    main()
