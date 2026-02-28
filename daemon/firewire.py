#!/usr/bin/env python3
"""
Cleansing Fire - FireWire Federation Daemon

Inter-node communication protocol for the Cleansing Fire network.
A lightweight HTTP server that implements the FireWire federation protocol:
gossip-based intelligence sharing, peer discovery, signed append-only logs,
and distributed task coordination.

Architecture:
  - HTTP API on localhost:7801
  - Ed25519 identity from ~/.cleansing-fire/node.key (openssl format)
  - Signed append-only log of all events
  - Gossip protocol: share intelligence with peers who share with their peers
  - Peer connection management (5-10 active peers)
  - Background gossip thread for periodic intelligence propagation

Endpoints:
  POST /message         - receive a signed message from a peer
  GET  /peers           - list known peers
  POST /peers/announce  - announce this node to a peer
  GET  /log             - get this node's append-only log (paginated)
  GET  /health          - health check
  POST /intelligence    - share civic intelligence
  GET  /tasks           - get available coordination tasks
  POST /tasks/claim     - claim a coordination task

Protocol specification: docs/federation-protocol.md

Usage:
  python3 daemon/firewire.py [--port 7801] [--data-dir ~/.cleansing-fire]
"""

import argparse
import base64
import hashlib
import http.server
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
import uuid
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

DEFAULT_PORT = 7801
DEFAULT_DATA_DIR = os.path.expanduser("~/.cleansing-fire")
PROTOCOL_VERSION = 1
MAX_PEERS = 10
MIN_PEERS = 5
GOSSIP_INTERVAL = 60  # seconds between gossip rounds
PEER_TIMEOUT = 300  # seconds before a peer is considered stale
LOG_PAGE_SIZE = 50  # default entries per page for log endpoint
MAX_INTELLIGENCE = 1000  # max intelligence objects in memory
MAX_TASKS = 200  # max tasks in memory
MESSAGE_TTL = 3600  # default message TTL in seconds
SEEN_MESSAGE_LIMIT = 5000  # dedup cache size

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger("firewire")


# ---------------------------------------------------------------------------
# Cryptographic identity
# ---------------------------------------------------------------------------

class NodeIdentity:
    """Ed25519 identity loaded from ~/.cleansing-fire/node.key (openssl PEM)."""

    def __init__(self, data_dir: str):
        self.data_dir = Path(data_dir)
        self.key_path = self.data_dir / "node.key"
        self.pub_path = self.data_dir / "node.pub"
        self.id_path = self.data_dir / "node.id"
        self.node_id = ""
        self.pub_key_der = b""
        self._loaded = False

    def load(self) -> bool:
        """Load node identity from disk. Returns True if successful."""
        if not self.key_path.exists():
            log.error("Node key not found at %s. Run bootstrap/setup-node.sh first.", self.key_path)
            return False
        if not self.pub_path.exists():
            log.error("Node public key not found at %s. Run bootstrap/setup-node.sh first.", self.pub_path)
            return False

        # Load node ID
        if self.id_path.exists():
            self.node_id = self.id_path.read_text().strip()
        else:
            # Generate node ID from public key hash (same method as setup-node.sh)
            self.pub_key_der = self._load_pub_der()
            key_hash = hashlib.sha256(self.pub_key_der).hexdigest()[:16]
            self.node_id = f"fire-{key_hash}"

        # Load public key DER for verification
        if not self.pub_key_der:
            self.pub_key_der = self._load_pub_der()

        self._loaded = True
        log.info("Node identity loaded: %s", self.node_id)
        return True

    def _load_pub_der(self) -> bytes:
        """Extract raw public key bytes from PEM using openssl."""
        try:
            result = subprocess.run(
                ["openssl", "pkey", "-in", str(self.key_path), "-pubout", "-outform", "DER"],
                capture_output=True, timeout=10,
            )
            if result.returncode == 0:
                return result.stdout
        except Exception as e:
            log.warning("Could not extract public key DER: %s", e)
        return b""

    def sign(self, data: bytes) -> str:
        """Sign data with the node's Ed25519 private key. Returns base64 signature."""
        if not self._loaded:
            return ""
        try:
            # Write data to temp file, sign with openssl
            tmp_data = self.data_dir / ".sign_tmp"
            tmp_sig = self.data_dir / ".sig_tmp"
            try:
                tmp_data.write_bytes(data)
                result = subprocess.run(
                    ["openssl", "pkeyutl", "-sign",
                     "-inkey", str(self.key_path),
                     "-in", str(tmp_data),
                     "-out", str(tmp_sig)],
                    capture_output=True, timeout=10,
                )
                if result.returncode == 0 and tmp_sig.exists():
                    sig_bytes = tmp_sig.read_bytes()
                    return base64.b64encode(sig_bytes).decode("ascii")
                else:
                    log.warning("openssl sign failed: %s", result.stderr.decode())
                    return ""
            finally:
                tmp_data.unlink(missing_ok=True)
                tmp_sig.unlink(missing_ok=True)
        except Exception as e:
            log.warning("Signing failed: %s", e)
            return ""

    def verify(self, data: bytes, signature_b64: str, pub_key_pem_path: Optional[str] = None) -> bool:
        """Verify an Ed25519 signature. Uses own public key if no path given."""
        pub_key = pub_key_pem_path or str(self.pub_path)
        if not Path(pub_key).exists():
            return False
        try:
            sig_bytes = base64.b64decode(signature_b64)
            tmp_data = self.data_dir / ".verify_data_tmp"
            tmp_sig = self.data_dir / ".verify_sig_tmp"
            try:
                tmp_data.write_bytes(data)
                tmp_sig.write_bytes(sig_bytes)
                result = subprocess.run(
                    ["openssl", "pkeyutl", "-verify",
                     "-pubin", "-inkey", pub_key,
                     "-in", str(tmp_data),
                     "-sigfile", str(tmp_sig)],
                    capture_output=True, timeout=10,
                )
                return result.returncode == 0
            finally:
                tmp_data.unlink(missing_ok=True)
                tmp_sig.unlink(missing_ok=True)
        except Exception:
            return False


# ---------------------------------------------------------------------------
# Message construction
# ---------------------------------------------------------------------------

def now_iso() -> str:
    """Current UTC timestamp in ISO 8601 format."""
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def canonical_json(obj: dict) -> bytes:
    """Deterministic JSON serialization for signing."""
    return json.dumps(obj, sort_keys=True, separators=(",", ":")).encode("utf-8")


def build_message(identity: NodeIdentity, msg_type: str, payload: dict,
                  to: Optional[str] = None, ttl: int = MESSAGE_TTL,
                  sequence: int = 0) -> dict:
    """Build a signed FireWire protocol message."""
    msg = {
        "v": PROTOCOL_VERSION,
        "id": str(uuid.uuid4()),
        "type": msg_type,
        "from": identity.node_id,
        "to": to,
        "timestamp": now_iso(),
        "sequence": sequence,
        "ttl": ttl,
        "payload": payload,
    }
    # Sign everything except the signature field
    sig = identity.sign(canonical_json(msg))
    msg["signature"] = sig
    return msg


# ---------------------------------------------------------------------------
# Peer management
# ---------------------------------------------------------------------------

@dataclass
class Peer:
    node_id: str
    address: str  # http://host:port
    last_seen: float = field(default_factory=time.time)
    announced_at: float = field(default_factory=time.time)
    capabilities: list = field(default_factory=list)
    trust_score: float = 0.5

    def is_stale(self) -> bool:
        return (time.time() - self.last_seen) > PEER_TIMEOUT

    def to_dict(self) -> dict:
        return {
            "node_id": self.node_id,
            "address": self.address,
            "last_seen": self.last_seen,
            "last_seen_iso": datetime.fromtimestamp(self.last_seen, tz=timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "announced_at": self.announced_at,
            "capabilities": self.capabilities,
            "trust_score": self.trust_score,
            "stale": self.is_stale(),
        }


# ---------------------------------------------------------------------------
# Append-only log
# ---------------------------------------------------------------------------

@dataclass
class LogEntry:
    sequence: int
    timestamp: str
    msg_type: str
    message_id: str
    payload_hash: str
    signature: str

    def to_dict(self) -> dict:
        return {
            "sequence": self.sequence,
            "timestamp": self.timestamp,
            "type": self.msg_type,
            "message_id": self.message_id,
            "payload_hash": self.payload_hash,
            "signature": self.signature,
        }


# ---------------------------------------------------------------------------
# FireWire core
# ---------------------------------------------------------------------------

class FireWire:
    """Core FireWire federation daemon state and logic."""

    def __init__(self, identity: NodeIdentity, port: int):
        self.identity = identity
        self.port = port
        self.running = True
        self.started_at = time.time()

        # Peer table
        self.peers: dict[str, Peer] = {}  # node_id -> Peer
        self.peers_lock = threading.Lock()

        # Append-only log
        self.log_entries: list[LogEntry] = []
        self.log_lock = threading.Lock()
        self.sequence = 0

        # Intelligence store
        self.intelligence: list[dict] = []
        self.intel_lock = threading.Lock()

        # Task store
        self.tasks: dict[str, dict] = {}  # task_id -> task
        self.tasks_lock = threading.Lock()

        # Message deduplication
        self.seen_messages: set[str] = set()
        self.seen_lock = threading.Lock()

        # Persistence paths
        self.data_dir = Path(identity.data_dir)
        self.peers_file = self.data_dir / "firewire-peers.json"
        self.log_file = self.data_dir / "firewire-log.jsonl"
        self.intel_file = self.data_dir / "firewire-intel.jsonl"
        self.tasks_file = self.data_dir / "firewire-tasks.json"

        # Load persisted state
        self._load_peers()
        self._load_log()
        self._load_intelligence()
        self._load_tasks()

        # Start background gossip thread
        self.gossip_thread = threading.Thread(
            target=self._gossip_loop, daemon=True, name="firewire-gossip"
        )
        self.gossip_thread.start()

        log.info(
            "FireWire started: node=%s, port=%d, peers=%d, log_entries=%d",
            identity.node_id, port, len(self.peers), len(self.log_entries),
        )

    # -- Persistence --------------------------------------------------------

    def _load_peers(self):
        if self.peers_file.exists():
            try:
                with open(self.peers_file) as f:
                    data = json.load(f)
                for p in data.get("peers", []):
                    peer = Peer(
                        node_id=p["node_id"],
                        address=p["address"],
                        last_seen=p.get("last_seen", 0),
                        announced_at=p.get("announced_at", 0),
                        capabilities=p.get("capabilities", []),
                        trust_score=p.get("trust_score", 0.5),
                    )
                    self.peers[peer.node_id] = peer
                log.info("Loaded %d peers from disk", len(self.peers))
            except (json.JSONDecodeError, KeyError) as e:
                log.warning("Could not load peers file: %s", e)

    def _save_peers(self):
        try:
            with self.peers_lock:
                data = {"peers": [p.to_dict() for p in self.peers.values()]}
            with open(self.peers_file, "w") as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            log.warning("Could not save peers: %s", e)

    def _load_log(self):
        if self.log_file.exists():
            try:
                with open(self.log_file) as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue
                        entry_data = json.loads(line)
                        entry = LogEntry(
                            sequence=entry_data["sequence"],
                            timestamp=entry_data["timestamp"],
                            msg_type=entry_data["type"],
                            message_id=entry_data["message_id"],
                            payload_hash=entry_data["payload_hash"],
                            signature=entry_data["signature"],
                        )
                        self.log_entries.append(entry)
                if self.log_entries:
                    self.sequence = self.log_entries[-1].sequence
                log.info("Loaded %d log entries from disk", len(self.log_entries))
            except (json.JSONDecodeError, KeyError) as e:
                log.warning("Could not load log file: %s", e)

    def _append_log(self, msg: dict):
        """Append a message to the local signed log."""
        with self.log_lock:
            self.sequence += 1
            payload_hash = hashlib.sha256(
                canonical_json(msg.get("payload", {}))
            ).hexdigest()
            entry = LogEntry(
                sequence=self.sequence,
                timestamp=msg.get("timestamp", now_iso()),
                msg_type=msg.get("type", "unknown"),
                message_id=msg.get("id", ""),
                payload_hash=payload_hash,
                signature=msg.get("signature", ""),
            )
            self.log_entries.append(entry)
            # Persist to disk
            try:
                with open(self.log_file, "a") as f:
                    f.write(json.dumps(entry.to_dict()) + "\n")
            except Exception as e:
                log.warning("Could not persist log entry: %s", e)

    def _load_intelligence(self):
        if self.intel_file.exists():
            try:
                with open(self.intel_file) as f:
                    for line in f:
                        line = line.strip()
                        if not line:
                            continue
                        self.intelligence.append(json.loads(line))
                log.info("Loaded %d intelligence objects from disk", len(self.intelligence))
            except (json.JSONDecodeError, KeyError) as e:
                log.warning("Could not load intelligence file: %s", e)

    def _save_intelligence_entry(self, intel: dict):
        try:
            with open(self.intel_file, "a") as f:
                f.write(json.dumps(intel) + "\n")
        except Exception as e:
            log.warning("Could not persist intelligence: %s", e)

    def _load_tasks(self):
        if self.tasks_file.exists():
            try:
                with open(self.tasks_file) as f:
                    self.tasks = json.load(f)
                log.info("Loaded %d tasks from disk", len(self.tasks))
            except (json.JSONDecodeError, KeyError) as e:
                log.warning("Could not load tasks file: %s", e)

    def _save_tasks(self):
        try:
            with self.tasks_lock:
                data = dict(self.tasks)
            with open(self.tasks_file, "w") as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            log.warning("Could not save tasks: %s", e)

    # -- Message handling ---------------------------------------------------

    def _is_seen(self, message_id: str) -> bool:
        """Check if we have already processed this message."""
        with self.seen_lock:
            if message_id in self.seen_messages:
                return True
            self.seen_messages.add(message_id)
            # Prune cache if too large
            if len(self.seen_messages) > SEEN_MESSAGE_LIMIT:
                # Remove oldest half (sets are unordered, so this is approximate)
                to_remove = list(self.seen_messages)[:SEEN_MESSAGE_LIMIT // 2]
                for mid in to_remove:
                    self.seen_messages.discard(mid)
            return False

    def handle_message(self, msg: dict) -> dict:
        """Process an incoming signed message from a peer."""
        msg_id = msg.get("id", "")
        msg_type = msg.get("type", "")
        sender = msg.get("from", "")

        if not msg_id or not msg_type or not sender:
            return {"error": "Missing required fields: id, type, from", "status": "rejected"}

        # Deduplication
        if self._is_seen(msg_id):
            return {"status": "already_seen", "id": msg_id}

        # Check TTL
        ttl = msg.get("ttl", MESSAGE_TTL)
        try:
            msg_time = datetime.fromisoformat(msg.get("timestamp", "").replace("Z", "+00:00"))
            age = (datetime.now(timezone.utc) - msg_time).total_seconds()
            if age > ttl:
                return {"status": "expired", "id": msg_id, "age": age, "ttl": ttl}
        except (ValueError, TypeError):
            pass  # Accept messages with unparseable timestamps

        # Log the message
        self._append_log(msg)

        # Update peer last_seen if we know the sender
        with self.peers_lock:
            if sender in self.peers:
                self.peers[sender].last_seen = time.time()

        # Route by message type
        if msg_type in ("intelligence", "firewire/intel/publish"):
            return self._handle_intelligence(msg)
        elif msg_type in ("announcement", "firewire/identity/announce"):
            return self._handle_announcement(msg)
        elif msg_type in ("task", "firewire/task/propose"):
            return self._handle_task(msg)
        elif msg_type == "heartbeat":
            return {"status": "ack", "id": msg_id}
        else:
            # Accept unknown types for forward compatibility
            log.info("Received message type '%s' from %s", msg_type, sender)
            return {"status": "accepted", "id": msg_id, "type": msg_type}

    def _handle_intelligence(self, msg: dict) -> dict:
        """Process incoming intelligence."""
        payload = msg.get("payload", {})
        intel_obj = {
            "id": msg.get("id", str(uuid.uuid4())),
            "from": msg.get("from", ""),
            "timestamp": msg.get("timestamp", now_iso()),
            "title": payload.get("title", ""),
            "domain": payload.get("domain", []),
            "classification": payload.get("classification", "raw"),
            "confidence": payload.get("confidence", 0.5),
            "content": payload.get("content", ""),
            "evidence": payload.get("evidence", []),
            "signature": msg.get("signature", ""),
        }

        with self.intel_lock:
            self.intelligence.append(intel_obj)
            # Prune if over limit
            if len(self.intelligence) > MAX_INTELLIGENCE:
                self.intelligence = self.intelligence[-MAX_INTELLIGENCE:]

        self._save_intelligence_entry(intel_obj)

        # Gossip: forward to peers (decrement TTL)
        self._gossip_forward(msg)

        log.info("Intelligence received from %s: %s", msg.get("from", "?"), intel_obj.get("title", "(untitled)"))
        return {"status": "accepted", "id": msg.get("id", ""), "type": "intelligence"}

    def _handle_announcement(self, msg: dict) -> dict:
        """Process a node announcement."""
        payload = msg.get("payload", {})
        node_id = msg.get("from", "")
        address = payload.get("address", "")

        if not node_id or not address:
            return {"error": "Announcement must include from and payload.address", "status": "rejected"}

        peer = Peer(
            node_id=node_id,
            address=address,
            last_seen=time.time(),
            announced_at=time.time(),
            capabilities=payload.get("capabilities", []),
            trust_score=0.5,
        )

        with self.peers_lock:
            self.peers[node_id] = peer

        self._save_peers()

        # Gossip: forward announcement to other peers
        self._gossip_forward(msg)

        log.info("Peer announced: %s at %s", node_id, address)
        return {"status": "accepted", "id": msg.get("id", ""), "node_id": self.identity.node_id}

    def _handle_task(self, msg: dict) -> dict:
        """Process a task proposal."""
        payload = msg.get("payload", {})
        task_id = payload.get("id", msg.get("id", str(uuid.uuid4())))

        task = {
            "id": task_id,
            "from": msg.get("from", ""),
            "timestamp": msg.get("timestamp", now_iso()),
            "title": payload.get("title", ""),
            "description": payload.get("description", ""),
            "domain": payload.get("domain", []),
            "roles": payload.get("roles", []),
            "status": "open",
            "claimed_by": None,
            "claimed_at": None,
        }

        with self.tasks_lock:
            self.tasks[task_id] = task
            # Prune if over limit
            if len(self.tasks) > MAX_TASKS:
                # Remove oldest completed tasks
                completed = [
                    tid for tid, t in self.tasks.items()
                    if t.get("status") in ("completed", "aborted")
                ]
                for tid in completed[:len(self.tasks) - MAX_TASKS]:
                    del self.tasks[tid]

        self._save_tasks()

        # Gossip: forward task to peers
        self._gossip_forward(msg)

        log.info("Task received from %s: %s", msg.get("from", "?"), task.get("title", "(untitled)"))
        return {"status": "accepted", "id": msg.get("id", ""), "task_id": task_id}

    # -- Peer operations ----------------------------------------------------

    def add_peer(self, node_id: str, address: str, capabilities: list = None) -> Peer:
        """Register a peer in the peer table."""
        peer = Peer(
            node_id=node_id,
            address=address,
            capabilities=capabilities or [],
        )
        with self.peers_lock:
            self.peers[node_id] = peer
        self._save_peers()
        return peer

    def get_active_peers(self) -> list[Peer]:
        """Return list of non-stale peers."""
        with self.peers_lock:
            return [p for p in self.peers.values() if not p.is_stale()]

    def announce_to_peer(self, peer_address: str) -> dict:
        """Announce this node to a remote peer."""
        msg = build_message(
            self.identity,
            msg_type="firewire/identity/announce",
            payload={
                "address": f"http://127.0.0.1:{self.port}",
                "capabilities": [],
                "node_type": "hybrid",
            },
            sequence=self.sequence + 1,
        )
        return self._send_to_peer(peer_address, "/peers/announce", msg)

    def _send_to_peer(self, peer_address: str, endpoint: str, data: dict) -> dict:
        """Send a JSON POST to a peer endpoint."""
        url = f"{peer_address.rstrip('/')}{endpoint}"
        payload = json.dumps(data).encode("utf-8")
        req = urllib.request.Request(
            url, data=payload,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            return {"error": f"HTTP {e.code}", "peer": peer_address}
        except urllib.error.URLError as e:
            return {"error": f"Connection failed: {e.reason}", "peer": peer_address}
        except Exception as e:
            return {"error": str(e), "peer": peer_address}

    # -- Gossip protocol ----------------------------------------------------

    def _gossip_forward(self, msg: dict):
        """Forward a message to connected peers (gossip propagation)."""
        msg_id = msg.get("id", "")
        sender = msg.get("from", "")
        ttl = msg.get("ttl", MESSAGE_TTL)

        # Decrement TTL
        if ttl <= 0:
            return

        forwarded = dict(msg)
        forwarded["ttl"] = ttl - (GOSSIP_INTERVAL * 2)  # decay TTL
        if forwarded["ttl"] <= 0:
            return

        active_peers = self.get_active_peers()
        for peer in active_peers:
            # Do not send back to the sender
            if peer.node_id == sender:
                continue
            # Do not send to self
            if peer.node_id == self.identity.node_id:
                continue
            threading.Thread(
                target=self._send_to_peer,
                args=(peer.address, "/message", forwarded),
                daemon=True,
            ).start()

    def _gossip_loop(self):
        """Background thread: periodically share state with peers."""
        # Wait a bit before first gossip round
        time.sleep(10)
        while self.running:
            try:
                self._gossip_round()
            except Exception as e:
                log.error("Gossip round error: %s", e)
            time.sleep(GOSSIP_INTERVAL)

    def _gossip_round(self):
        """One round of gossip: exchange peer lists and heartbeats."""
        active_peers = self.get_active_peers()
        if not active_peers:
            return

        log.info("Gossip round: %d active peers", len(active_peers))

        # Build peer exchange list
        with self.peers_lock:
            peer_list = [
                {"node_id": p.node_id, "address": p.address, "last_seen": p.last_seen}
                for p in self.peers.values()
                if not p.is_stale()
            ]

        # Send heartbeat + peer list to each active peer
        heartbeat = build_message(
            self.identity,
            msg_type="heartbeat",
            payload={
                "peers": peer_list[:50],
                "log_length": len(self.log_entries),
                "intel_count": len(self.intelligence),
            },
            ttl=GOSSIP_INTERVAL * 2,
            sequence=self.sequence,
        )

        for peer in active_peers:
            if peer.node_id == self.identity.node_id:
                continue
            result = self._send_to_peer(peer.address, "/message", heartbeat)
            if "error" in result:
                log.debug("Gossip to %s failed: %s", peer.node_id[:12], result["error"])
            else:
                # Process any peer list from response
                resp_peers = result.get("peers", [])
                for rp in resp_peers:
                    rp_id = rp.get("node_id", "")
                    rp_addr = rp.get("address", "")
                    if rp_id and rp_addr and rp_id != self.identity.node_id:
                        with self.peers_lock:
                            if rp_id not in self.peers:
                                self.peers[rp_id] = Peer(
                                    node_id=rp_id,
                                    address=rp_addr,
                                    last_seen=rp.get("last_seen", time.time()),
                                )

        # Prune stale peers (keep at least MIN_PEERS even if stale)
        with self.peers_lock:
            stale = [pid for pid, p in self.peers.items() if p.is_stale()]
            if len(self.peers) - len(stale) >= MIN_PEERS:
                for pid in stale:
                    del self.peers[pid]
                    log.info("Pruned stale peer: %s", pid[:12])

        self._save_peers()

    # -- Intelligence operations --------------------------------------------

    def publish_intelligence(self, title: str, content: str, domain: list = None,
                              classification: str = "analysis", confidence: float = 0.5,
                              evidence: list = None) -> dict:
        """Create and broadcast an intelligence object."""
        msg = build_message(
            self.identity,
            msg_type="firewire/intel/publish",
            payload={
                "title": title,
                "content": content,
                "domain": domain or [],
                "classification": classification,
                "confidence": confidence,
                "evidence": evidence or [],
            },
            sequence=self.sequence + 1,
        )

        # Store locally
        self._handle_intelligence(msg)

        # Broadcast to all peers
        active_peers = self.get_active_peers()
        results = []
        for peer in active_peers:
            if peer.node_id == self.identity.node_id:
                continue
            result = self._send_to_peer(peer.address, "/intelligence", msg)
            results.append({"peer": peer.node_id, "result": result})

        return {
            "status": "published",
            "id": msg["id"],
            "broadcast_to": len(results),
            "results": results,
        }

    # -- Task operations ----------------------------------------------------

    def claim_task(self, task_id: str, role_id: str = "") -> dict:
        """Claim an open task."""
        with self.tasks_lock:
            task = self.tasks.get(task_id)
            if not task:
                return {"error": "Task not found", "task_id": task_id}
            if task.get("status") != "open":
                return {"error": f"Task is not open (status: {task.get('status')})", "task_id": task_id}

            task["status"] = "claimed"
            task["claimed_by"] = self.identity.node_id
            task["claimed_at"] = now_iso()
            if role_id:
                task["claimed_role"] = role_id

        self._save_tasks()

        # Announce claim to peers
        msg = build_message(
            self.identity,
            msg_type="firewire/task/accept",
            payload={
                "task_id": task_id,
                "role_id": role_id,
            },
            sequence=self.sequence + 1,
        )
        self._append_log(msg)

        log.info("Claimed task %s (role: %s)", task_id[:12], role_id or "any")
        return {"status": "claimed", "task_id": task_id, "claimed_by": self.identity.node_id}

    # -- Status -------------------------------------------------------------

    def get_health(self) -> dict:
        """Health check data."""
        uptime = time.time() - self.started_at
        with self.peers_lock:
            active = sum(1 for p in self.peers.values() if not p.is_stale())
            total = len(self.peers)
        return {
            "service": "cleansing-fire-firewire",
            "version": "0.1.0",
            "protocol_version": PROTOCOL_VERSION,
            "node_id": self.identity.node_id,
            "port": self.port,
            "running": self.running,
            "uptime_seconds": round(uptime, 1),
            "peers_active": active,
            "peers_total": total,
            "log_entries": len(self.log_entries),
            "intelligence_count": len(self.intelligence),
            "tasks_count": len(self.tasks),
            "sequence": self.sequence,
        }

    def shutdown(self):
        """Graceful shutdown."""
        log.info("Shutting down FireWire daemon...")
        self.running = False
        self._save_peers()
        self._save_tasks()
        self.gossip_thread.join(timeout=5)


# ---------------------------------------------------------------------------
# HTTP Handler
# ---------------------------------------------------------------------------

class FireWireHandler(http.server.BaseHTTPRequestHandler):
    firewire: FireWire  # set by server setup

    def log_message(self, fmt, *args):
        log.debug(fmt, *args)

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

    def _parse_query(self) -> dict:
        """Parse query string parameters from the URL."""
        params = {}
        if "?" in self.path:
            query_string = self.path.split("?", 1)[1]
            for pair in query_string.split("&"):
                if "=" in pair:
                    key, val = pair.split("=", 1)
                    params[key] = val
        return params

    # -- GET endpoints ------------------------------------------------------

    def do_GET(self):
        path = self.path.split("?")[0]  # strip query string

        if path == "/health":
            self._json_response(self.firewire.get_health())

        elif path == "/peers":
            with self.firewire.peers_lock:
                peers = [p.to_dict() for p in self.firewire.peers.values()]
            self._json_response({
                "node_id": self.firewire.identity.node_id,
                "peers": peers,
                "total": len(peers),
                "active": sum(1 for p in peers if not p["stale"]),
            })

        elif path == "/log":
            params = self._parse_query()
            page = int(params.get("page", "1"))
            size = int(params.get("size", str(LOG_PAGE_SIZE)))
            size = min(size, 200)  # cap page size

            with self.firewire.log_lock:
                total = len(self.firewire.log_entries)
                start = max(0, (page - 1) * size)
                end = min(total, start + size)
                entries = [e.to_dict() for e in self.firewire.log_entries[start:end]]

            self._json_response({
                "node_id": self.firewire.identity.node_id,
                "page": page,
                "size": size,
                "total": total,
                "total_pages": (total + size - 1) // size if size > 0 else 0,
                "entries": entries,
            })

        elif path == "/tasks":
            params = self._parse_query()
            status_filter = params.get("status", "")
            with self.firewire.tasks_lock:
                tasks = list(self.firewire.tasks.values())
            if status_filter:
                tasks = [t for t in tasks if t.get("status") == status_filter]
            self._json_response({
                "node_id": self.firewire.identity.node_id,
                "tasks": tasks,
                "total": len(tasks),
            })

        elif path == "/":
            self._json_response({
                "service": "cleansing-fire-firewire",
                "version": "0.1.0",
                "protocol": "FireWire Federation Protocol",
                "node_id": self.firewire.identity.node_id,
                "endpoints": {
                    "POST /message": "Receive a signed message from a peer",
                    "GET  /peers": "List known peers",
                    "POST /peers/announce": "Announce this node to a peer",
                    "GET  /log": "Get this node's append-only log (paginated: ?page=1&size=50)",
                    "GET  /health": "Health check",
                    "POST /intelligence": "Share civic intelligence",
                    "GET  /tasks": "Get available coordination tasks (?status=open)",
                    "POST /tasks/claim": "Claim a coordination task",
                },
            })

        else:
            self._json_response({"error": "Not found"}, 404)

    # -- POST endpoints -----------------------------------------------------

    def do_POST(self):
        path = self.path.split("?")[0]

        if path == "/message":
            try:
                body = self._read_body()
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response({"error": f"Invalid JSON: {e}"}, 400)
                return

            result = self.firewire.handle_message(body)
            status_code = 200 if result.get("status") != "rejected" else 400
            self._json_response(result, status_code)

        elif path == "/peers/announce":
            try:
                body = self._read_body()
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response({"error": f"Invalid JSON: {e}"}, 400)
                return

            # Accept both raw announce and wrapped message
            if "type" in body and "from" in body:
                # It is a full protocol message
                result = self.firewire.handle_message(body)
            else:
                # Simple announce: {node_id, address, capabilities}
                node_id = body.get("node_id", body.get("from", ""))
                address = body.get("address", "")
                if not node_id or not address:
                    self._json_response({"error": "Missing node_id and address"}, 400)
                    return
                self.firewire.add_peer(
                    node_id=node_id,
                    address=address,
                    capabilities=body.get("capabilities", []),
                )
                result = {
                    "status": "accepted",
                    "node_id": self.firewire.identity.node_id,
                    "address": f"http://127.0.0.1:{self.firewire.port}",
                }

            self._json_response(result)

        elif path == "/intelligence":
            try:
                body = self._read_body()
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response({"error": f"Invalid JSON: {e}"}, 400)
                return

            # Accept both wrapped messages and direct intelligence posts
            if "type" in body and body.get("type") in ("intelligence", "firewire/intel/publish"):
                result = self.firewire.handle_message(body)
            else:
                # Direct post: create intelligence from body
                result = self.firewire.publish_intelligence(
                    title=body.get("title", ""),
                    content=body.get("content", ""),
                    domain=body.get("domain", []),
                    classification=body.get("classification", "analysis"),
                    confidence=body.get("confidence", 0.5),
                    evidence=body.get("evidence", []),
                )

            status_code = 200 if "error" not in result else 400
            self._json_response(result, status_code)

        elif path == "/tasks/claim":
            try:
                body = self._read_body()
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response({"error": f"Invalid JSON: {e}"}, 400)
                return

            task_id = body.get("task_id", "")
            if not task_id:
                self._json_response({"error": "Missing required field: task_id"}, 400)
                return

            result = self.firewire.claim_task(
                task_id=task_id,
                role_id=body.get("role_id", ""),
            )
            status_code = 200 if "error" not in result else 404
            self._json_response(result, status_code)

        else:
            self._json_response({"error": "Not found"}, 404)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Cleansing Fire FireWire Federation Daemon")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT,
                        help=f"Port (default: {DEFAULT_PORT})")
    parser.add_argument("--data-dir", type=str, default=DEFAULT_DATA_DIR,
                        help=f"Data directory (default: {DEFAULT_DATA_DIR})")
    parser.add_argument("--pid-file", type=str, default="",
                        help="Write PID to file")
    args = parser.parse_args()

    # Load node identity
    identity = NodeIdentity(args.data_dir)
    if not identity.load():
        log.error("Cannot start without node identity. Run bootstrap/setup-node.sh first.")
        sys.exit(1)

    # Create FireWire daemon
    firewire = FireWire(identity=identity, port=args.port)
    FireWireHandler.firewire = firewire

    # Start HTTP server
    server = http.server.HTTPServer(("127.0.0.1", args.port), FireWireHandler)

    if args.pid_file:
        with open(args.pid_file, "w") as f:
            f.write(str(os.getpid()))

    def shutdown_handler(signum, frame):
        firewire.shutdown()
        server.shutdown()

    signal.signal(signal.SIGTERM, shutdown_handler)
    signal.signal(signal.SIGINT, shutdown_handler)

    log.info("FireWire listening on http://127.0.0.1:%d (node: %s)", args.port, identity.node_id)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        firewire.shutdown()
        if args.pid_file and os.path.exists(args.pid_file):
            os.remove(args.pid_file)
        log.info("FireWire stopped.")


if __name__ == "__main__":
    main()
