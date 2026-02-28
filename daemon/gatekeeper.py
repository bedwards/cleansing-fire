#!/usr/bin/env python3
"""
Cleansing Fire - Ollama Gatekeeper Daemon

A lightweight HTTP server that serializes access to local Ollama GPU resources.
Accepts tasks via REST API, queues them, executes one at a time against Ollama,
and returns results. Rejects when queue is full to provide backpressure.

Architecture:
  - HTTP API on localhost:7800
  - Single worker thread processes queue serially (GPU contention management)
  - Short queue (configurable, default 5) with rejection on overflow
  - Unified task format for all callers (cron jobs, agents, scripts)
  - Health endpoint for monitoring
  - Task status tracking with polling

Usage:
  python3 daemon/gatekeeper.py [--port 7800] [--queue-size 5] [--model mistral-large:123b]
"""

import argparse
import http.server
import json
import logging
import os
import queue
import signal
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
import uuid
from dataclasses import dataclass, field, asdict
from enum import Enum
from typing import Optional

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

DEFAULT_PORT = 7800
DEFAULT_QUEUE_SIZE = 5
DEFAULT_MODEL = "mistral-large:123b"
DEFAULT_OLLAMA_URL = "http://localhost:11434"
TASK_HISTORY_LIMIT = 100  # keep last N completed tasks in memory

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("gatekeeper")


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------

class TaskStatus(str, Enum):
    QUEUED = "queued"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    REJECTED = "rejected"


@dataclass
class Task:
    id: str
    prompt: str
    system: str = ""
    model: str = ""
    temperature: float = 0.7
    max_tokens: int = 4096
    status: TaskStatus = TaskStatus.QUEUED
    result: Optional[str] = None
    error: Optional[str] = None
    created_at: float = field(default_factory=time.time)
    started_at: Optional[float] = None
    completed_at: Optional[float] = None
    caller: str = "unknown"
    metadata: dict = field(default_factory=dict)

    def to_dict(self):
        d = asdict(self)
        d["status"] = self.status.value
        d["duration"] = None
        if self.started_at and self.completed_at:
            d["duration"] = round(self.completed_at - self.started_at, 2)
        return d


# ---------------------------------------------------------------------------
# Gatekeeper core
# ---------------------------------------------------------------------------

class Gatekeeper:
    def __init__(self, queue_size: int, default_model: str, ollama_url: str):
        self.task_queue: queue.Queue = queue.Queue(maxsize=queue_size)
        self.default_model = default_model
        self.ollama_url = ollama_url
        self.tasks: dict[str, Task] = {}
        self.tasks_lock = threading.Lock()
        self.running = True
        self.current_task: Optional[str] = None
        self.stats = {
            "total_submitted": 0,
            "total_completed": 0,
            "total_failed": 0,
            "total_rejected": 0,
        }

        self.worker_thread = threading.Thread(
            target=self._worker, daemon=True, name="gatekeeper-worker"
        )
        self.worker_thread.start()
        log.info(
            "Gatekeeper started: queue_size=%d, model=%s, ollama=%s",
            queue_size, default_model, ollama_url,
        )

    def submit(self, task: Task) -> bool:
        """Submit a task. Returns True if queued, False if rejected."""
        try:
            self.task_queue.put_nowait(task)
            with self.tasks_lock:
                self.tasks[task.id] = task
                self.stats["total_submitted"] += 1
            log.info("Task %s queued (caller=%s)", task.id[:8], task.caller)
            return True
        except queue.Full:
            task.status = TaskStatus.REJECTED
            task.error = "Queue full - try again later"
            with self.tasks_lock:
                self.stats["total_rejected"] += 1
            log.warning("Task %s rejected - queue full", task.id[:8])
            return False

    def get_task(self, task_id: str) -> Optional[Task]:
        with self.tasks_lock:
            return self.tasks.get(task_id)

    def get_status(self) -> dict:
        return {
            "running": self.running,
            "queue_depth": self.task_queue.qsize(),
            "queue_capacity": self.task_queue.maxsize,
            "current_task": self.current_task,
            "default_model": self.default_model,
            "ollama_url": self.ollama_url,
            **self.stats,
        }

    def _worker(self):
        """Serial worker: processes one task at a time."""
        while self.running:
            try:
                task = self.task_queue.get(timeout=1.0)
            except queue.Empty:
                continue

            self.current_task = task.id
            task.status = TaskStatus.RUNNING
            task.started_at = time.time()
            log.info("Task %s started (model=%s)", task.id[:8], task.model or self.default_model)

            try:
                result = self._call_ollama(task)
                task.result = result
                task.status = TaskStatus.COMPLETED
                with self.tasks_lock:
                    self.stats["total_completed"] += 1
                log.info("Task %s completed (%.1fs)", task.id[:8], time.time() - task.started_at)
            except Exception as e:
                task.error = str(e)
                task.status = TaskStatus.FAILED
                with self.tasks_lock:
                    self.stats["total_failed"] += 1
                log.error("Task %s failed: %s", task.id[:8], e)
            finally:
                task.completed_at = time.time()
                self.current_task = None
                self.task_queue.task_done()
                self._prune_history()

    def _call_ollama(self, task: Task) -> str:
        """Call Ollama API generate endpoint."""
        model = task.model or self.default_model
        payload = {
            "model": model,
            "prompt": task.prompt,
            "stream": False,
            "options": {
                "temperature": task.temperature,
                "num_predict": task.max_tokens,
            },
        }
        if task.system:
            payload["system"] = task.system

        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            f"{self.ollama_url}/api/generate",
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST",
        )

        try:
            with urllib.request.urlopen(req, timeout=300) as resp:
                body = json.loads(resp.read().decode("utf-8"))
                return body.get("response", "")
        except urllib.error.HTTPError as e:
            raise RuntimeError(f"Ollama HTTP {e.code}: {e.read().decode()}")
        except urllib.error.URLError as e:
            raise RuntimeError(f"Ollama connection failed: {e.reason}")

    def _prune_history(self):
        """Keep only recent completed tasks in memory."""
        with self.tasks_lock:
            completed = [
                (tid, t) for tid, t in self.tasks.items()
                if t.status in (TaskStatus.COMPLETED, TaskStatus.FAILED, TaskStatus.REJECTED)
            ]
            if len(completed) > TASK_HISTORY_LIMIT:
                completed.sort(key=lambda x: x[1].completed_at or 0)
                for tid, _ in completed[:-TASK_HISTORY_LIMIT]:
                    del self.tasks[tid]

    def shutdown(self):
        log.info("Shutting down gatekeeper...")
        self.running = False
        self.worker_thread.join(timeout=5)


# ---------------------------------------------------------------------------
# HTTP Handler
# ---------------------------------------------------------------------------

class GatekeeperHandler(http.server.BaseHTTPRequestHandler):
    gatekeeper: Gatekeeper  # set by server setup

    def log_message(self, format, *args):
        log.debug(format, *args)

    def _json_response(self, data: dict, status: int = 200):
        body = json.dumps(data, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _read_body(self) -> dict:
        length = int(self.headers.get("Content-Length", 0))
        if length == 0:
            return {}
        raw = self.rfile.read(length)
        return json.loads(raw.decode("utf-8"))

    def do_GET(self):
        if self.path == "/health":
            self._json_response(self.gatekeeper.get_status())

        elif self.path.startswith("/task/"):
            task_id = self.path.split("/task/", 1)[1].rstrip("/")
            task = self.gatekeeper.get_task(task_id)
            if task:
                self._json_response(task.to_dict())
            else:
                self._json_response({"error": "Task not found"}, 404)

        else:
            self._json_response({
                "service": "cleansing-fire-gatekeeper",
                "version": "0.1.0",
                "endpoints": {
                    "POST /submit": "Submit a task to the queue",
                    "GET /task/<id>": "Check task status and result",
                    "GET /health": "Queue status and stats",
                },
            })

    def do_POST(self):
        if self.path == "/submit":
            try:
                body = self._read_body()
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response({"error": f"Invalid JSON: {e}"}, 400)
                return

            prompt = body.get("prompt", "").strip()
            if not prompt:
                self._json_response({"error": "Missing required field: prompt"}, 400)
                return

            task = Task(
                id=str(uuid.uuid4()),
                prompt=prompt,
                system=body.get("system", ""),
                model=body.get("model", ""),
                temperature=body.get("temperature", 0.7),
                max_tokens=body.get("max_tokens", 4096),
                caller=body.get("caller", "unknown"),
                metadata=body.get("metadata", {}),
            )

            if self.gatekeeper.submit(task):
                self._json_response(task.to_dict(), 202)
            else:
                self._json_response(task.to_dict(), 429)

        elif self.path == "/submit-sync":
            # Synchronous endpoint - blocks until task completes
            try:
                body = self._read_body()
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response({"error": f"Invalid JSON: {e}"}, 400)
                return

            prompt = body.get("prompt", "").strip()
            if not prompt:
                self._json_response({"error": "Missing required field: prompt"}, 400)
                return

            task = Task(
                id=str(uuid.uuid4()),
                prompt=prompt,
                system=body.get("system", ""),
                model=body.get("model", ""),
                temperature=body.get("temperature", 0.7),
                max_tokens=body.get("max_tokens", 4096),
                caller=body.get("caller", "unknown"),
                metadata=body.get("metadata", {}),
            )

            if not self.gatekeeper.submit(task):
                self._json_response(task.to_dict(), 429)
                return

            # Poll until done
            timeout = body.get("timeout", 300)
            deadline = time.time() + timeout
            while time.time() < deadline:
                if task.status in (TaskStatus.COMPLETED, TaskStatus.FAILED):
                    status_code = 200 if task.status == TaskStatus.COMPLETED else 500
                    self._json_response(task.to_dict(), status_code)
                    return
                time.sleep(0.25)

            self._json_response({"error": "Timeout waiting for task", "task_id": task.id}, 408)

        else:
            self._json_response({"error": "Not found"}, 404)


# ---------------------------------------------------------------------------
# CLI client helper
# ---------------------------------------------------------------------------

def submit_task(prompt: str, port: int = DEFAULT_PORT, **kwargs) -> dict:
    """Convenience function for submitting tasks from Python."""
    payload = {"prompt": prompt, **kwargs}
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        f"http://localhost:{port}/submit",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read().decode("utf-8"))


def submit_sync(prompt: str, port: int = DEFAULT_PORT, timeout: int = 300, **kwargs) -> str:
    """Submit and wait for result. Returns the response text."""
    payload = {"prompt": prompt, "timeout": timeout, **kwargs}
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        f"http://localhost:{port}/submit-sync",
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=timeout + 10) as resp:
        body = json.loads(resp.read().decode("utf-8"))
        if body.get("status") == "completed":
            return body.get("result", "")
        raise RuntimeError(f"Task failed: {body.get('error', 'unknown')}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Cleansing Fire Ollama Gatekeeper")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT, help=f"Port (default: {DEFAULT_PORT})")
    parser.add_argument("--queue-size", type=int, default=DEFAULT_QUEUE_SIZE, help=f"Max queue depth (default: {DEFAULT_QUEUE_SIZE})")
    parser.add_argument("--model", type=str, default=DEFAULT_MODEL, help=f"Default model (default: {DEFAULT_MODEL})")
    parser.add_argument("--ollama-url", type=str, default=DEFAULT_OLLAMA_URL, help=f"Ollama URL (default: {DEFAULT_OLLAMA_URL})")
    parser.add_argument("--pid-file", type=str, default="", help="Write PID to file")
    args = parser.parse_args()

    gatekeeper = Gatekeeper(
        queue_size=args.queue_size,
        default_model=args.model,
        ollama_url=args.ollama_url,
    )

    GatekeeperHandler.gatekeeper = gatekeeper
    server = http.server.HTTPServer(("127.0.0.1", args.port), GatekeeperHandler)

    if args.pid_file:
        with open(args.pid_file, "w") as f:
            f.write(str(os.getpid()))

    def shutdown_handler(signum, frame):
        gatekeeper.shutdown()
        server.shutdown()

    signal.signal(signal.SIGTERM, shutdown_handler)
    signal.signal(signal.SIGINT, shutdown_handler)

    log.info("Gatekeeper listening on http://127.0.0.1:%d", args.port)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        gatekeeper.shutdown()
        if args.pid_file and os.path.exists(args.pid_file):
            os.remove(args.pid_file)
        log.info("Gatekeeper stopped.")


if __name__ == "__main__":
    main()
