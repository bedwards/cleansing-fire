#!/usr/bin/env python3
"""
Cleansing Fire - Task Scheduler & Event System

A lightweight scheduler that manages:
1. Cron-like scheduled tasks (via internal scheduling, not system cron)
2. Event-driven tasks (file watchers, webhooks, RSS feeds, API polls)
3. Plugin-based task execution
4. Integration with the Gatekeeper for LLM tasks
5. Integration with the Worker Orchestrator for code tasks

Runs as a daemon. Tasks are defined in scheduler/tasks.json.

Architecture:
  - Main loop checks scheduled tasks and event sources
  - Tasks execute via plugins (shell, python, gatekeeper, orchestrator)
  - Results logged and optionally forwarded
  - Designed for single-node but federation-ready
"""

import argparse
import json
import logging
import os
import signal
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Callable

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


EXECUTORS = {
    "shell": exec_shell,
    "gatekeeper": exec_gatekeeper,
    "orchestrator": exec_orchestrator,
    "plugin": exec_plugin,
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


class WebhookEvent(EventSource):
    """Placeholder for incoming webhook handling."""
    pass


EVENT_SOURCES = {
    "file_watcher": FileWatcherEvent,
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

        log.info("Loaded %d scheduled tasks, %d event sources", len(self.tasks), len(self.events))

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
        executor = EXECUTORS.get(task_type)
        if not executor:
            log.error("Unknown task type '%s' for task '%s'", task_type, name)
            return

        log.info("Executing task: %s (type=%s)", name, task_type)
        start = time.time()
        try:
            result = executor(task)
            duration = round(time.time() - start, 2)
            success = result.get("success", False)
            log.info("Task %s %s (%.1fs)", name, "OK" if success else "FAILED", duration)

            # Log result
            log_entry = {
                "task": name,
                "type": task_type,
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

    def shutdown(self):
        self.running = False


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Cleansing Fire Scheduler")
    parser.add_argument("--tasks", type=str, default=str(TASKS_FILE), help="Tasks JSON file")
    args = parser.parse_args()

    scheduler = Scheduler(Path(args.tasks))

    def shutdown_handler(signum, frame):
        scheduler.shutdown()

    signal.signal(signal.SIGTERM, shutdown_handler)
    signal.signal(signal.SIGINT, shutdown_handler)

    try:
        scheduler.run()
    except KeyboardInterrupt:
        pass
    finally:
        log.info("Scheduler stopped.")


if __name__ == "__main__":
    main()
