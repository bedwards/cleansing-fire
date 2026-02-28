# ZERO-TOUCH BOOTSTRAP ARCHITECTURE

## The One-Command Path from Human to Autonomous Civic Intelligence Node

### Cleansing Fire Project -- Operational Specification v0.1

Architecture Date: 2026-02-28
Status: KEYSTONE DOCUMENT -- Connects all existing architecture into one operational system
Depends On:
- `docs/federation-protocol.md` (FireWire protocol, node identity, trust, discovery)
- `docs/global-architecture.md` (four-layer planetary architecture, headless AI system)
- `docs/cloudflare-implementation.md` (edge workers, cost analysis, phased rollout)
- `docs/claude-code-features.md` (CLI features, skills, hooks, headless mode, agent teams)
- `CLAUDE.md` (project constitution, development loop, file structure)
- `docs/blue-sky-vision.md` (10-year aspirational roadmap)

---

*"The human does nothing but install Claude Code and run it. We give them an initial prompt and it handles installing everything and deploying the framework locally and on Cloudflare. And that instance connects with other instances in a decentralized manner and gets to work."*

---

## TABLE OF CONTENTS

1. [The One-Command Vision](#1-the-one-command-vision)
2. [The Bootstrap Sequence](#2-the-bootstrap-sequence)
3. [The Autonomous Operation Loop](#3-the-autonomous-operation-loop)
4. [Content Generation and Distribution](#4-content-generation-and-distribution)
5. [The Network Topology](#5-the-network-topology)
6. [Self-Improvement and Evolution](#6-self-improvement-and-evolution)
7. [Human Interaction Points](#7-human-interaction-points)
8. [Security and Resilience](#8-security-and-resilience)
9. [Cost Analysis](#9-cost-analysis)
10. [Implementation Roadmap](#10-implementation-roadmap)

---

## 1. THE ONE-COMMAND VISION

### 1.1 The Promise

A human installs Claude Code CLI. The human runs a single command. Everything after that is autonomous. The command bootstraps a fully operational civic intelligence node on the human's personal hardware, deploys edge infrastructure to Cloudflare, generates a cryptographic identity, connects to the FireWire federation network, and begins an autonomous operation loop that monitors power, generates content, coordinates with other nodes, and improves itself. The human can walk away. The node works.

This is not a metaphor. This is an engineering specification.

### 1.2 The Command

```bash
claude --dangerously-skip-permissions -p "$(curl -sL https://raw.githubusercontent.com/bedwards/cleansing-fire/main/bootstrap/ignite.md)"
```

Three components:

1. **`claude`** -- The Claude Code CLI, already installed by the human. This is the only prerequisite. Claude Code version 2.1+ with Claude Opus 4.6 as the orchestrator brain. The human must have a Claude Max plan ($200/month) or an Anthropic API key.

2. **`--dangerously-skip-permissions`** -- Bypasses all permission prompts. Claude will not ask "May I run this command?" or "May I write this file?" It will execute freely. This is required for zero-touch operation. The safety model shifts from permission-per-action to the philosophical constraints embedded in CLAUDE.md and the structural safeguards of the project architecture. See `docs/claude-code-features.md` Section 5 (Permissions System) for what this flag bypasses.

3. **`-p "$(curl -sL ...)"` -- Headless mode with a remote prompt.** The `-p` flag runs Claude in headless mode (see `docs/claude-code-features.md` Section 13). The prompt is fetched live from the repository's `bootstrap/ignite.md` file. This ensures every new node gets the latest bootstrap instructions without the human needing to know what they are.

### 1.3 What "Everything" Means

After the human runs that command, the following happens without further human input:

| Phase | Duration | What Happens |
|-------|----------|-------------|
| Clone & Understand | ~30 seconds | Clone the repo, read CLAUDE.md, understand the project |
| Local Setup | ~5 minutes | Install dependencies, start gatekeeper, configure scheduler |
| Edge Deployment | ~10 minutes | Deploy Cloudflare Workers, provision D1/KV/R2 |
| Identity Generation | ~10 seconds | Generate Ed25519 keypair, create Agent Card |
| Network Connection | ~2 minutes | Register with discovery relays, connect to peers |
| First Operation Cycle | ~30 minutes | Run first news scan, generate first content, share first intelligence |
| Steady State | Continuous | Autonomous operation loop, indefinitely |

Total time from human command to operational node: approximately 45 minutes.

### 1.4 Prerequisites

The human needs:

| Requirement | Why | How to Get It |
|-------------|-----|--------------|
| Claude Code CLI | The orchestrator brain | `curl -fsSL https://cli.claude.ai/install.sh \| sh` |
| Claude Max plan or API key | Pays for Opus 4.6 inference | `claude.ai/pricing/max` or `console.anthropic.com` |
| A computer | Runs the local node | Any Mac, Linux, or WSL system |
| Internet connection | Reaches GitHub, Cloudflare, APIs | Standard home internet |
| Cloudflare account (optional) | Edge deployment | `dash.cloudflare.com/sign-up` (free) |

The human does NOT need:
- Any programming knowledge
- Any understanding of the project architecture
- Any knowledge of Git, Python, Cloudflare, or federation protocols
- To read any documentation
- To make any configuration decisions

Claude handles all of it.

### 1.5 The bootstrap/ignite.md Prompt

The `bootstrap/ignite.md` file is the initial prompt that Claude receives. It is the seed from which the entire node grows. Its structure:

```markdown
# Cleansing Fire -- Node Ignition Sequence

You are bootstrapping a new Cleansing Fire civic intelligence node.

## Step 1: Clone and Orient
Clone the repository. Read CLAUDE.md. Understand the project.

## Step 2: Assess This Machine
Detect the OS, available tools, GPU presence, disk space, network.

## Step 3: Run Bootstrap
Execute scripts/bootstrap.sh --skip-optional --quiet.

## Step 4: Local Infrastructure
Start the gatekeeper daemon. Configure the scheduler.
Install Ollama if a GPU is detected.

## Step 5: Edge Deployment (if Cloudflare credentials available)
Deploy fire-api, fire-ai, fire-markdown, fire-relay workers.
Provision D1 databases, KV namespaces, R2 buckets.

## Step 6: Generate Identity
Create Ed25519 keypair. Build Agent Card. Store securely.

## Step 7: Connect to Network
Register with bootstrap relays. Discover peers. Begin gossip.

## Step 8: Begin Autonomous Operation
Start the operation loop. Run first cycle. Report status.

[Detailed instructions for each step follow...]
```

This prompt is the ONLY thing fetched from the network before the repo is cloned. Everything else comes from the repository itself, which Claude reads after cloning. The prompt is deliberately minimal -- it points Claude at the repo and lets CLAUDE.md take over.

---

## 2. THE BOOTSTRAP SEQUENCE

### 2.1 Step 1: Clone the Repository

Claude's first action is to clone the Cleansing Fire repository:

```bash
git clone https://github.com/bedwards/cleansing-fire.git ~/cleansing-fire
cd ~/cleansing-fire
```

This gives Claude access to the entire project:
- `CLAUDE.md` -- the project constitution (230 lines, see root file)
- `philosophy.md` -- the Pyrrhic Lucidity framework (956 lines)
- `docs/` -- 25+ research documents
- `specs/` -- machine-readable specifications
- `daemon/gatekeeper.py` -- the GPU serialization daemon (440 lines)
- `scheduler/scheduler.py` -- the task scheduling system (533 lines)
- `scheduler/tasks.json` -- the predefined task set (327 lines)
- `workers/orchestrator.sh` -- the worker launch system (202 lines)
- `plugins/` -- 14 executable plugin scripts
- `edge/` -- 3 Cloudflare Worker projects (fire-api, fire-ai, fire-markdown)
- `scripts/` -- 10 management scripts including `bootstrap.sh` (461 lines)

### 2.2 Step 2: Read CLAUDE.md and Understand the Project

Claude reads CLAUDE.md. This is the moment the node acquires its purpose. CLAUDE.md contains:

- **Project Philosophy**: The 7 Principles of Pyrrhic Lucidity
- **Project Mission**: "Build decentralized, autonomous technology that shifts power from corrupt concentrated authority toward the people."
- **Architecture Overview**: Gatekeeper daemon, scheduler, worker orchestrator, plugin system, OSINT pipeline, Forge content generation, dual documentation
- **Workflow**: The definitive development loop (issue -> implement -> review -> fix -> merge)
- **Key Rules**: Workers are always Opus 4.6, always use worktrees, implementation and review are separate workers, review workers never fix code
- **Key Models**: Claude Opus 4.6 for everything, Ollama for lightweight local tasks
- **Deployments**: GitHub Pages (docs/) and Cloudflare Workers (edge/)
- **File Structure**: The complete project tree
- **Fork Protection**: Integrity checks, recursive accountability, transparency requirement

After reading CLAUDE.md, Claude reads the key supporting documents in order:

1. `docs/global-architecture.md` -- understands the four-layer architecture (Edge, Core, Network, People) as described in Sections 3-7
2. `docs/cloudflare-implementation.md` -- understands what needs to be deployed to Cloudflare (see Section 3: Worker Projects)
3. `docs/federation-protocol.md` -- understands the FireWire protocol for connecting to other nodes (see Sections 2-6)
4. `docs/claude-code-features.md` -- understands its own capabilities: skills, hooks, subagents, agent teams, headless mode, MCP servers

This reading phase takes approximately 30 seconds. Claude now understands the entire system.

### 2.3 Step 3: Assess the Local Machine

Before installing anything, Claude examines the host machine:

```bash
# Operating system and architecture
uname -a

# Available disk space
df -h ~

# Python version (required: 3.9+)
python3 --version

# Git version
git --version

# Whether Ollama is already installed
which ollama && ollama --version

# GPU detection
# macOS: check for Metal support
system_profiler SPDisplaysDataType 2>/dev/null | grep -i "Metal"
# Linux: check for NVIDIA GPU
nvidia-smi 2>/dev/null || lspci 2>/dev/null | grep -i nvidia

# Whether Claude Code is in the right state
claude --version

# Network connectivity
curl -sf https://api.github.com/rate_limit > /dev/null && echo "GitHub: OK"
curl -sf https://api.cloudflare.com/client/v4/user/tokens/verify > /dev/null || echo "Cloudflare: needs setup"

# Check for existing Cloudflare credentials
wrangler whoami 2>/dev/null || echo "Wrangler: not authenticated"
```

The assessment produces a machine profile that determines which optional components are installed:

| Condition | Decision |
|-----------|----------|
| GPU detected (Metal or NVIDIA) | Install Ollama, pull mistral-large:123b |
| No GPU | Skip Ollama, use only Claude/Workers AI for inference |
| Cloudflare credentials present | Full edge deployment |
| No Cloudflare credentials | Local-only mode, edge deployment deferred |
| macOS detected | Use launchd for daemon management |
| Linux detected | Use systemd for daemon management |
| Low disk space (<10GB free) | Skip large model pulls, warn |

### 2.4 Step 4: Run scripts/bootstrap.sh

Claude executes the existing bootstrap script:

```bash
scripts/bootstrap.sh --skip-optional --quiet
```

This script (460 lines, at `scripts/bootstrap.sh`) performs:

1. **Required tool verification**: Checks for python3, git, curl (lines 126-156)
2. **Optional tool detection**: Checks for ollama, claude, gh (lines 161-191)
3. **Directory creation**: Creates `output/`, `output/svg/`, `output/reports/`, `output/content/`, `/tmp/cleansing-fire/` (lines 196-234)
4. **Git hooks installation**: Installs pre-commit hook (secret detection, plugin validation) and post-merge hook (bootstrap reminder) (lines 239-291)
5. **Plugin permissions**: Makes all plugins in `plugins/` executable (lines 296-337)
6. **Ollama setup**: If detected, checks if running, verifies model availability (lines 342-392)
7. **Gatekeeper connectivity test**: Checks if gatekeeper is already running on port 7800 (lines 399-409)

The `--skip-optional` flag prevents interactive prompts (since we are running headless). The `--quiet` flag reduces output.

### 2.5 Step 5: Install Local Dependencies

After the bootstrap script, Claude handles additional setup that the script does not cover:

#### Python Dependencies

The project uses stdlib-only Python (per `CLAUDE.md` Code Standards), so there are no pip installs needed. All plugins and daemons use only Python 3.9+ standard library modules (json, http.server, urllib, subprocess, threading, xml.etree, etc.).

#### Ollama Installation (if GPU detected)

If the machine has a GPU and Ollama is not installed:

```bash
# macOS
brew install ollama || curl -fsSL https://ollama.com/install.sh | sh

# Linux
curl -fsSL https://ollama.com/install.sh | sh
```

Then start Ollama and pull the recommended model:

```bash
ollama serve &
ollama pull mistral-large:123b
```

The `mistral-large:123b` model is the default specified in `daemon/gatekeeper.py` (line 45: `DEFAULT_MODEL = "mistral-large:123b"`). This is a 70GB download and may take 30-60 minutes on a typical connection. The bootstrap continues in parallel -- Ollama is not a blocking dependency.

#### Node.js and Wrangler (for Cloudflare deployment)

If Cloudflare deployment is planned:

```bash
# Install Node.js if not present (needed for wrangler)
# macOS
brew install node || curl -fsSL https://fnm.vercel.app/install | bash && fnm install --lts

# Install wrangler v4
npm install -g wrangler
```

### 2.6 Step 6: Start the Gatekeeper Daemon

The gatekeeper daemon (`daemon/gatekeeper.py`, 441 lines) serializes GPU access to local Ollama. Claude starts it:

```bash
python3 daemon/gatekeeper.py --port 7800 --queue-size 5 --model mistral-large:123b &
```

Or, on macOS, installs it as a launchd service:

```bash
scripts/gatekeeper-ctl.sh install
```

The gatekeeper provides:
- `POST /submit` -- Asynchronous task submission (line 287)
- `POST /submit-sync` -- Synchronous task submission with blocking wait (line 315)
- `GET /task/{id}` -- Task status polling (line 267)
- `GET /health` -- Health check with queue depth, model info, stats (line 264)

This is the local inference gateway used by plugins (news-monitor, narrative-detector, forge-voice) for LLM-powered analysis. If no GPU is available and Ollama is not installed, the gatekeeper starts but fails gracefully on inference requests -- plugins fall back to their non-LLM codepaths.

### 2.7 Step 7: Configure the Scheduler with Task Set

Claude configures `scheduler/tasks.json` with the full autonomous operation schedule. The existing file (93 lines) contains a starter set. Claude expands it to the full autonomous schedule:

```json
{
  "scheduled_tasks": [
    {
      "name": "health-check",
      "schedule": "*/5 * * * *",
      "type": "shell",
      "command": "curl -sf http://127.0.0.1:7800/health > /dev/null && echo ok || echo gatekeeper-down",
      "enabled": true
    },
    {
      "name": "news-monitor-power",
      "schedule": "*/15 * * * *",
      "type": "plugin",
      "plugin": "news-monitor",
      "input": {
        "action": "monitor",
        "terms": ["dark money", "surveillance", "antitrust", "lobbying", "corporate consolidation"]
      },
      "enabled": true
    },
    {
      "name": "github-issues-check",
      "schedule": "0 * * * *",
      "type": "shell",
      "command": "gh issue list --label 'claude-implement' --state open --json number,title --limit 5",
      "enabled": true,
      "on_success": {
        "name": "implement-next-issue",
        "type": "orchestrator",
        "action": "implement",
        "args": ["$ISSUE_TITLE", "$ISSUE_BODY"]
      }
    },
    {
      "name": "investigation-random",
      "schedule": "0 */4 * * *",
      "type": "shell",
      "command": "claude -p 'Pick a random investigation from docs/chaos-research.md and execute it' --max-turns 20",
      "enabled": true
    },
    {
      "name": "content-generation",
      "schedule": "0 */12 * * *",
      "type": "shell",
      "command": "scripts/generate-content.sh",
      "enabled": true
    },
    {
      "name": "deep-research",
      "schedule": "0 3 * * *",
      "type": "shell",
      "command": "claude -p 'Run the news-monitor trending action. Pick the highest-scoring topic. Research it deeply. Generate a report in output/reports/' --max-turns 30",
      "enabled": true
    },
    {
      "name": "self-update",
      "schedule": "0 2 * * *",
      "type": "shell",
      "command": "cd ~/cleansing-fire && git pull origin main && scripts/bootstrap.sh --skip-optional --quiet",
      "enabled": true
    },
    {
      "name": "weekly-report",
      "schedule": "0 6 * * 0",
      "type": "shell",
      "command": "claude -p 'Generate a comprehensive weekly report on power shifts detected this week. Review all output/daily-* directories from the last 7 days. Write the report to output/reports/weekly-$(date +%Y%m%d).md' --max-turns 30",
      "enabled": true
    },
    {
      "name": "legislative-scan-privacy",
      "schedule": "0 8 * * 1",
      "type": "plugin",
      "plugin": "civic-legiscan",
      "input": {
        "action": "monitor",
        "keywords": ["surveillance", "encryption", "privacy", "facial recognition", "data collection"]
      },
      "enabled": true
    },
    {
      "name": "legislative-scan-antitrust",
      "schedule": "0 8 * * 2",
      "type": "plugin",
      "plugin": "civic-legiscan",
      "input": {
        "action": "monitor",
        "keywords": ["antitrust", "monopoly", "merger", "competition", "market concentration"]
      },
      "enabled": true
    },
    {
      "name": "legislative-scan-transparency",
      "schedule": "0 8 * * 3",
      "type": "plugin",
      "plugin": "civic-legiscan",
      "input": {
        "action": "monitor",
        "keywords": ["FOIA", "transparency", "whistleblower", "public records", "disclosure"]
      },
      "enabled": true
    },
    {
      "name": "spending-watchdog",
      "schedule": "0 9 * * 4,5",
      "type": "plugin",
      "plugin": "civic-spending",
      "input": {
        "action": "search",
        "keyword": "surveillance technology",
        "fiscal_year": 2026
      },
      "enabled": true
    },
    {
      "name": "sec-filings-scan",
      "schedule": "0 10 * * 1-5",
      "type": "plugin",
      "plugin": "corp-sec",
      "input": {
        "action": "search",
        "keywords": ["merger", "acquisition", "lobbying expense"]
      },
      "enabled": true
    },
    {
      "name": "narrative-detection",
      "schedule": "0 */6 * * *",
      "type": "plugin",
      "plugin": "narrative-detector",
      "input": {
        "action": "trending"
      },
      "enabled": true
    },
    {
      "name": "lobby-tracking",
      "schedule": "0 11 * * 1,3,5",
      "type": "plugin",
      "plugin": "lobby-tracker",
      "input": {
        "action": "recent",
        "days": 3
      },
      "enabled": true
    },
    {
      "name": "daily-fire",
      "schedule": "0 6 * * *",
      "type": "shell",
      "command": "scripts/daily-fire.sh",
      "enabled": true
    },
    {
      "name": "node-heartbeat",
      "schedule": "*/10 * * * *",
      "type": "shell",
      "command": "scripts/node-status.sh --json | curl -sf -X POST -H 'Content-Type: application/json' -d @- https://fire-relay.cleansingfire.org/api/v1/heartbeat || true",
      "enabled": false,
      "note": "Enable after fire-relay is deployed and node identity is generated"
    }
  ],
  "event_tasks": [
    {
      "name": "docs-changed",
      "source_type": "file_watcher",
      "source_config": {
        "pattern": "docs/*.md"
      },
      "type": "gatekeeper",
      "prompt": "A documentation file in the Cleansing Fire project has been updated. Generate a brief changelog entry summarizing what changed.",
      "sync": true,
      "enabled": true
    },
    {
      "name": "new-plugin-output",
      "source_type": "file_watcher",
      "source_config": {
        "pattern": "output/**/*.json"
      },
      "type": "shell",
      "command": "claude -p 'New plugin output detected. Review the latest files in output/ and determine if any findings warrant a GitHub issue, a social media post, or an alert to the network.' --max-turns 10",
      "enabled": true
    }
  ]
}
```

Then Claude starts the scheduler:

```bash
python3 scheduler/scheduler.py &
```

The scheduler (`scheduler/scheduler.py`, 533 lines) runs as a daemon with a 15-second polling loop (line 324). It supports four task executor types:

- **shell**: Runs bash commands via `subprocess` (lines 94-110)
- **gatekeeper**: Submits prompts to the local Ollama gatekeeper (lines 113-142)
- **orchestrator**: Launches Claude Code workers via `workers/orchestrator.sh` (lines 145-160)
- **plugin**: Executes plugin scripts from `plugins/` with JSON stdin/stdout (lines 163-191)

### 2.8 Step 8: Deploy Cloudflare Workers

If the human has Cloudflare credentials available (either via `wrangler login` or environment variables), Claude deploys the edge infrastructure. This step is optional -- the node functions in local-only mode without it, but loses global accessibility and federation relay capability.

#### 2.8.1 Authenticate with Cloudflare

```bash
# Check if already authenticated
wrangler whoami

# If not, prompt is skipped in headless mode.
# The human must have previously run: wrangler login
# Or set: CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID
```

#### 2.8.2 Provision Infrastructure

```bash
# Create KV namespaces (referenced in edge/fire-api/wrangler.toml lines 33-40)
wrangler kv namespace create CACHE
wrangler kv namespace create CONFIG
wrangler kv namespace create AI_CACHE

# Create D1 database (referenced in edge/fire-api/wrangler.toml lines 53-56)
wrangler d1 create civic-data

# Create R2 bucket (referenced in edge/fire-api/wrangler.toml lines 65-68)
wrangler r2 bucket create fire-media

# Create Queue (referenced in edge/fire-api/wrangler.toml lines 90-92)
wrangler queues create fire-task-queue

# Create Vectorize index (referenced in edge/fire-ai/wrangler.toml)
wrangler vectorize create civic-embeddings --dimensions 1024 --metric cosine
```

Claude captures the IDs returned by each creation command and updates the corresponding `wrangler.toml` files:

- `edge/fire-api/wrangler.toml` -- Replace all `REPLACE_WITH_*` placeholders with actual IDs
- `edge/fire-ai/wrangler.toml` -- Replace Vectorize and KV namespace IDs
- `edge/fire-markdown/wrangler.toml` -- No bindings to update (stateless proxy)

#### 2.8.3 Initialize D1 Schema

```sql
-- Applied via: wrangler d1 execute civic-data --file=edge/fire-api/schema.sql

CREATE TABLE IF NOT EXISTS entities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'unknown',
    description TEXT,
    source TEXT,
    first_seen TEXT DEFAULT (datetime('now')),
    last_updated TEXT DEFAULT (datetime('now')),
    metadata TEXT DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS legislation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bill_number TEXT,
    title TEXT,
    jurisdiction TEXT NOT NULL,
    sponsor TEXT,
    status TEXT DEFAULT 'introduced',
    introduced_date TEXT,
    summary TEXT,
    source_url TEXT,
    keywords TEXT DEFAULT '[]',
    last_updated TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS spending (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    entity TEXT NOT NULL,
    description TEXT,
    amount REAL,
    fiscal_year INTEGER,
    agency TEXT,
    source TEXT,
    source_url TEXT,
    last_updated TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS intelligence (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    source_node TEXT,
    source_plugin TEXT,
    confidence REAL DEFAULT 0.5,
    created_at TEXT DEFAULT (datetime('now')),
    tags TEXT DEFAULT '[]',
    hash TEXT UNIQUE
);

CREATE INDEX idx_entities_name ON entities(name);
CREATE INDEX idx_legislation_jurisdiction ON legislation(jurisdiction);
CREATE INDEX idx_legislation_sponsor ON legislation(sponsor);
CREATE INDEX idx_spending_entity ON spending(entity);
CREATE INDEX idx_intelligence_type ON intelligence(type);
CREATE INDEX idx_intelligence_source ON intelligence(source_node);
```

#### 2.8.4 Deploy Workers

```bash
# Deploy fire-api (the API gateway)
cd edge/fire-api && npx wrangler deploy

# Deploy fire-ai (AI inference worker)
cd edge/fire-ai && npx wrangler deploy

# Deploy fire-markdown (LLM-accessible markdown proxy)
cd edge/fire-markdown && npx wrangler deploy
```

Each worker deployment creates a `*.workers.dev` URL. Claude records these URLs for later configuration.

#### 2.8.5 Verify Deployment

```bash
# Health checks
curl -sf https://fire-api.<account>.workers.dev/health
curl -sf https://fire-ai.<account>.workers.dev/health
curl -sf https://fire-markdown.<account>.workers.dev/health
```

All three should return JSON with `"status": "ok"` and binding availability information.

#### 2.8.6 Deploy fire-relay (Federation Discovery)

The fourth worker -- `fire-relay` -- is the federation relay described in `docs/federation-protocol.md` Section 5 (Discovery Layer). It is not yet implemented in `edge/` but is specified here for the bootstrap sequence:

```
edge/fire-relay/
  wrangler.toml
  src/index.js
```

The fire-relay worker provides:
- `POST /api/v1/register` -- Node registration (stores Agent Card in KV)
- `GET /api/v1/discover` -- Peer discovery (returns known nodes)
- `POST /api/v1/heartbeat` -- Node liveness reporting
- `POST /api/v1/relay` -- Message relay for NAT-traversal
- `GET /api/v1/bootstrap` -- Returns bootstrap node list for new nodes

Bindings:
- KV: `NODE_REGISTRY` -- Stores node identities, Agent Cards, last-seen timestamps
- KV: `MESSAGE_BUFFER` -- Temporary storage for relayed messages
- Durable Objects: `RELAY_SESSION` -- Maintains WebSocket connections for live relay

This worker is the bridge between the local FireWire protocol stack and nodes behind NAT/firewalls. It runs on Cloudflare's free tier. Every node that deploys one becomes a bootstrap relay for the network.

### 2.9 Step 9: Generate Node Identity

Claude generates the node's cryptographic identity as specified in `docs/federation-protocol.md` Section 4 (Identity Layer):

```python
#!/usr/bin/env python3
"""Generate Ed25519 keypair for FireWire node identity."""

import base64
import hashlib
import json
import os
import time

# Ed25519 key generation using Python 3.9+ stdlib
# Note: Python's cryptography is in nacl/sodium, but for bootstrap
# we use a pure-Python Ed25519 or fall back to openssl
import subprocess

def generate_identity():
    """Generate Ed25519 keypair and node identity."""
    identity_dir = os.path.expanduser("~/.cleansing-fire/identity")
    os.makedirs(identity_dir, mode=0o700, exist_ok=True)

    private_key_path = os.path.join(identity_dir, "node.key")
    public_key_path = os.path.join(identity_dir, "node.pub")
    identity_path = os.path.join(identity_dir, "identity.json")

    # Check if identity already exists
    if os.path.exists(identity_path):
        with open(identity_path) as f:
            return json.load(f)

    # Generate Ed25519 keypair using openssl
    subprocess.run([
        "openssl", "genpkey", "-algorithm", "Ed25519",
        "-out", private_key_path
    ], check=True)
    os.chmod(private_key_path, 0o600)

    subprocess.run([
        "openssl", "pkey", "-in", private_key_path,
        "-pubout", "-out", public_key_path
    ], check=True)

    # Read public key and generate node ID
    with open(public_key_path) as f:
        public_key_pem = f.read()

    # Node ID is the SHA-256 hash of the public key, base58 encoded
    pub_bytes = public_key_pem.encode("utf-8")
    node_id = hashlib.sha256(pub_bytes).hexdigest()[:32]

    # Build identity document
    identity = {
        "node_id": f"fire:{node_id}",
        "public_key": public_key_pem.strip(),
        "created_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "node_type": "hybrid",
        "software_version": "0.1.0",
        "capabilities": [],
        "operator": {
            "type": "human-ai-hybrid",
            "ai_model": "claude-opus-4-6",
            "local_model": "mistral-large:123b"
        }
    }

    with open(identity_path, "w") as f:
        json.dump(identity, f, indent=2)
    os.chmod(identity_path, 0o600)

    return identity
```

The identity is stored at `~/.cleansing-fire/identity/`:

```
~/.cleansing-fire/
  identity/
    node.key          # Ed25519 private key (0600 permissions)
    node.pub          # Ed25519 public key
    identity.json     # Node identity document
    agent-card.json   # FireWire Agent Card (public, shareable)
```

### 2.10 Step 10: Build the Agent Card

The Agent Card is the public-facing identity document described in `docs/federation-protocol.md` Section 3.1 (adapted from A2A/MCP). Claude builds it from the node's capabilities:

```json
{
  "firewire_version": "0.1",
  "node_id": "fire:a1b2c3d4...",
  "node_type": "hybrid",
  "name": "Cleansing Fire Node <hostname>",
  "description": "Autonomous civic intelligence node running on personal hardware",
  "operator": {
    "type": "human-ai-hybrid",
    "ai_model": "claude-opus-4-6",
    "local_model": "mistral-large:123b",
    "transparency": "This node is operated by a human with AI assistance. All actions are logged."
  },
  "capabilities": {
    "investigation": ["osint", "corporate-mapping", "legislative-tracking", "spending-watchdog"],
    "content": ["social-posts", "reports", "satire", "visualizations", "data-analysis"],
    "data_sources": ["sec-edgar", "legiscan", "usaspending", "fec", "rss-feeds", "gdelt"],
    "inference": {
      "local": ["mistral-large:123b"],
      "edge": ["llama-3.3-70b", "mistral-7b", "bge-m3"],
      "cloud": ["claude-opus-4-6"]
    },
    "federation": ["gossip", "intelligence-sharing", "task-coordination", "content-amplification"]
  },
  "endpoints": {
    "api": "https://fire-api.<account>.workers.dev",
    "relay": "https://fire-relay.<account>.workers.dev",
    "site": "https://<account>.github.io/cleansing-fire"
  },
  "trust": {
    "genesis_timestamp": "2026-02-28T00:00:00Z",
    "signed_log_head": "<hash>",
    "sponsor": null
  },
  "signed_by": "<Ed25519 signature of this document>"
}
```

### 2.11 Step 11: Register with Discovery Relays

The node announces itself to the network using the discovery mechanism described in `docs/federation-protocol.md` Section 5 (Discovery Layer):

```bash
# Register with known bootstrap relays
# These are Cloudflare Workers running fire-relay
BOOTSTRAP_RELAYS=(
    "https://relay1.cleansingfire.org"
    "https://relay2.cleansingfire.org"
    "https://fire-relay.cleansingfire.workers.dev"
)

for relay in "${BOOTSTRAP_RELAYS[@]}"; do
    curl -sf -X POST "$relay/api/v1/register" \
        -H "Content-Type: application/json" \
        -d @~/.cleansing-fire/identity/agent-card.json \
        && echo "Registered with $relay" \
        || echo "Failed to reach $relay (will retry)"
done
```

If the node's own fire-relay worker is deployed, it also registers itself AS a bootstrap relay, increasing network resilience.

### 2.12 Step 12: Connect to the FireWire Federation Network

Claude establishes connections to peer nodes:

```bash
# Discover peers from bootstrap relays
PEERS=$(curl -sf "$BOOTSTRAP_RELAY/api/v1/discover?limit=20")

# For each peer, verify their Agent Card signature
# and establish a gossip connection
```

The gossip protocol (from `docs/federation-protocol.md` Section 6: Communication Layer) operates over:
1. **Direct HTTP** for nodes with public endpoints (Cloudflare Workers)
2. **WebSocket relay** for nodes behind NAT (via fire-relay Durable Objects)
3. **Periodic pull** as a fallback (poll peers for new intelligence)

Initial peer connections are ephemeral and unweighted. Trust accrues over time through demonstrated contribution, as specified in `docs/federation-protocol.md` Section 11 (Trust and Reputation). New nodes start with zero trust and earn it by:
- Sharing verifiable intelligence
- Responding to task coordination requests
- Consistent uptime and heartbeats
- Cross-validation of claims by other nodes

### 2.13 Step 13: Begin Autonomous Operation

Claude starts the autonomous operation loop by running the first cycle:

```bash
# Run the daily-fire script for immediate first cycle
scripts/daily-fire.sh

# Verify scheduler is running and will continue autonomously
curl -sf http://127.0.0.1:7800/health

# Log bootstrap completion
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) Bootstrap complete. Node is operational." \
    >> ~/.cleansing-fire/bootstrap.log
```

The node is now operational. The scheduler runs continuously, executing the tasks defined in `scheduler/tasks.json`. The gatekeeper handles local LLM inference. The Cloudflare Workers handle edge compute and API access. The FireWire connection handles federation.

---

## 3. THE AUTONOMOUS OPERATION LOOP

### 3.1 Overview

After bootstrap, the node enters an indefinite autonomous operation loop. This loop has three layers: continuous scheduled operations (cron), event-triggered operations (reactive), and inter-node operations (federation). All three run concurrently.

The scheduler (`scheduler/scheduler.py`) is the heartbeat. It checks for due tasks every 15 seconds. Each task executes in its own thread. Results are logged to `/tmp/cleansing-fire-scheduler/task-results.jsonl`.

### 3.2 Continuous Operations (Cron-Scheduled)

#### Every 5 Minutes: Health Check

```json
{
  "name": "health-check",
  "schedule": "*/5 * * * *",
  "type": "shell",
  "command": "curl -sf http://127.0.0.1:7800/health > /dev/null && echo ok || echo gatekeeper-down"
}
```

Verifies the gatekeeper daemon is responsive. If the gatekeeper is down, the scheduler logs the failure. Subsequent tasks that require the gatekeeper will gracefully degrade.

#### Every 10 Minutes: Network Heartbeat

```json
{
  "name": "node-heartbeat",
  "schedule": "*/10 * * * *",
  "type": "shell",
  "command": "scripts/node-status.sh --json | curl -sf -X POST -H 'Content-Type: application/json' -d @- $RELAY_URL/api/v1/heartbeat || true"
}
```

Reports node liveness and capability status to the federation relay. Other nodes use this to determine which peers are active. The heartbeat includes queue depth, active tasks, recent output count, and resource availability. See `docs/federation-protocol.md` Section 5.3 for the heartbeat specification.

#### Every 15 Minutes: News Monitoring

```json
{
  "name": "news-monitor-power",
  "schedule": "*/15 * * * *",
  "type": "plugin",
  "plugin": "news-monitor",
  "input": {
    "action": "monitor",
    "terms": ["dark money", "surveillance", "antitrust", "lobbying", "corporate consolidation"]
  }
}
```

The `news-monitor` plugin (`plugins/news-monitor`, 1111 lines) monitors 14 RSS feeds (Google News, Reuters, AP, BBC, NPR, ProPublica, The Intercept, Bellingcat, OpenSecrets, EFF, Ars Technica, Techdirt) plus optional API sources (NewsAPI, MediaStack). It:

1. Fetches RSS feeds matching the monitoring terms (line 741)
2. Scores each article for mission relevance using 7 keyword categories: corruption, lobbying, corporate_power, surveillance, labor, environment, civil_rights (lines 147-183)
3. Deduplicates by title similarity (lines 768-776)
4. If the gatekeeper is available, sends top results for LLM analysis summarizing themes, power dynamics, connections, and urgency (lines 800-812)
5. Outputs structured JSON with scored articles, source metadata, and AI analysis

High-relevance articles (score >= 30) are flagged for immediate attention. The output feeds into content generation and inter-node intelligence sharing.

#### Every Hour: GitHub Issue Processing

```json
{
  "name": "github-issues-check",
  "schedule": "0 * * * *",
  "type": "shell",
  "command": "gh issue list --label 'claude-implement' --state open --json number,title --limit 5"
}
```

Checks the project's GitHub Issues for work that needs doing. Issues labeled `claude-implement` are picked up by the node and implemented via the development loop:

1. The orchestrator (`workers/orchestrator.sh`, 202 lines) creates a feature branch `cf/<issue>-<description>` (line 76)
2. A Claude Code implementation worker is launched in headless mode with `--permission-mode acceptEdits` and `--worktree` isolation (lines 108-111)
3. The worker reads the issue, implements the change, creates a PR
4. A separate review worker is launched in `--permission-mode plan` (read-only) (lines 150-152)
5. If review finds issues, a fix worker addresses them
6. The orchestrator merges approved PRs

This is the AI-driven development loop from `CLAUDE.md` (lines 69-97), running autonomously.

#### Every 4 Hours: Random Investigation

```json
{
  "name": "investigation-random",
  "schedule": "0 */4 * * *",
  "type": "shell",
  "command": "claude -p 'Pick a random investigation from docs/chaos-research.md and execute it' --max-turns 20"
}
```

The chaos research methodology from `docs/chaos-research.md` (1246 lines) introduces serendipity into the investigation process. Claude picks a random investigation template -- these might include:

- Follow a random lobbying firm's client list
- Pick a random government contract over $10M and trace the vendor
- Find the three least-covered members of a congressional committee and map their donors
- Pick a random Fortune 500 company and map its beneficial ownership chain
- Search for SEC enforcement actions from this week and analyze patterns

The randomness ensures the network is not predictable. Adversaries cannot anticipate which threads will be pulled.

#### Every 6 Hours: Narrative Detection

```json
{
  "name": "narrative-detection",
  "schedule": "0 */6 * * *",
  "type": "plugin",
  "plugin": "narrative-detector",
  "input": {
    "action": "trending"
  }
}
```

The `narrative-detector` plugin (`plugins/narrative-detector`, 880 lines) uses the GDELT Project (Global Database of Events, Language, and Tone) to detect coordinated PR campaigns. It:

1. Searches GDELT for articles on trending power-related topics (line 481)
2. Analyzes publication timing for suspicious clustering (line 509)
3. Computes text similarity across articles using bigram fingerprinting (lines 153-185)
4. Detects coordinated messaging via similarity scores, shared phrases, and tone uniformity (lines 426-436)
5. Sends findings to the gatekeeper LLM for deep analysis (lines 529-562)
6. Outputs a coordination_score from 0.0 (organic) to 1.0 (definite coordinated campaign)

High coordination scores trigger counter-narrative generation (see Section 4).

#### Every 12 Hours: Content Generation and Distribution

```json
{
  "name": "content-generation",
  "schedule": "0 */12 * * *",
  "type": "shell",
  "command": "scripts/generate-content.sh"
}
```

The content generation pipeline uses the Forge system described in `CLAUDE.md` (lines 46-49):

1. **forge-voice** (`plugins/forge-voice`) -- Generates social posts, threads, newsletters, poetry, satire
2. **forge-vision** (`plugins/forge-vision`) -- Generates SVG visualizations, ASCII art, Mermaid diagrams
3. **pipeline-data-to-fire** (`plugins/pipeline-data-to-fire`) -- Full pipeline: data -> analysis -> visualization -> narrative -> distribution

Content is generated from the day's findings: news monitoring results, investigation outputs, detected narratives, legislative scans.

#### Every 24 Hours: Deep Research

```json
{
  "name": "deep-research",
  "schedule": "0 3 * * *",
  "type": "shell",
  "command": "claude -p 'Run the news-monitor trending action. Pick the highest-scoring topic. Research it deeply.' --max-turns 30"
}
```

At 3 AM local time, the node conducts deep research on whatever topic is currently most relevant. Claude:

1. Runs the news-monitor trending action to identify the hottest power-related topic
2. Cross-references with SEC EDGAR via `plugins/corp-sec`
3. Checks legislative databases via `plugins/civic-legiscan`
4. Traces spending via `plugins/civic-spending`
5. Runs narrative detection to check for PR campaigns around the topic
6. Generates a comprehensive investigation report
7. Saves the report to `output/reports/`
8. Shares the report with the federation network

#### Every 24 Hours: Self-Update

```json
{
  "name": "self-update",
  "schedule": "0 2 * * *",
  "type": "shell",
  "command": "cd ~/cleansing-fire && git pull origin main && scripts/bootstrap.sh --skip-optional --quiet"
}
```

At 2 AM local time, the node pulls the latest code from the repository and re-runs the bootstrap script. This ensures:

- New plugins are installed and made executable
- New investigation templates are available
- Bug fixes and improvements are applied
- New scheduler tasks are picked up
- Cloudflare Workers are redeployed if edge code changed

This is how the network evolves. When any node merges an improvement to main, every other node picks it up within 24 hours.

#### Every 24 Hours: Daily Fire

```json
{
  "name": "daily-fire",
  "schedule": "0 6 * * *",
  "type": "shell",
  "command": "scripts/daily-fire.sh"
}
```

The `daily-fire.sh` script (`scripts/daily-fire.sh`, 425 lines) runs the full daily operational cycle:

1. **System health** (lines 156-195): Checks gatekeeper, Ollama, disk space
2. **Legislative scans** (lines 207-233): Privacy, antitrust, transparency keyword scans via `civic-legiscan`
3. **Spending watchdog** (lines 239-262): Surveillance, consulting, AI spending queries via `civic-spending`
4. **Daily digest** (lines 268-349): Collects results, generates LLM-powered summary via `forge-voice`
5. **Git operations** (lines 355-406): Commits and pushes output (if output/ is not gitignored)
6. **Summary** (lines 412-426): Logs duration, results count, system status

#### Weekly: Comprehensive Report

```json
{
  "name": "weekly-report",
  "schedule": "0 6 * * 0",
  "type": "shell",
  "command": "claude -p 'Generate a comprehensive weekly report on power shifts detected this week.' --max-turns 30"
}
```

Every Sunday at 6 AM, Claude reviews the week's accumulated output and generates a comprehensive report covering:

- Top stories and their power implications
- Legislative developments across tracked jurisdictions
- Spending anomalies detected
- Coordinated narratives identified
- Network intelligence received from peer nodes
- Recommended investigation priorities for the coming week

### 3.3 Event-Triggered Operations

The scheduler's event system (`scheduler/scheduler.py` lines 206-236) triggers tasks in response to detected events:

#### New Legislation Detected

When the `civic-legiscan` plugin detects new bills matching tracked keywords, the output triggers:

1. **Analysis**: Claude analyzes the bill text using `fire-ai` Workers AI inference (`POST /ai/analyze` with type "legislation")
2. **Distribution**: A social media post is generated via `forge-voice`
3. **Network share**: The analysis is shared with federation peers via the gossip protocol
4. **Tracking**: A GitHub issue is created for ongoing monitoring if the bill is significant

#### New SEC Filing by Tracked Entity

When `corp-sec` detects new filings from entities in the watch list:

1. **Cross-reference**: Compare the filing with the entity's known lobbying activity (via `lobby-tracker`)
2. **Anomaly detection**: Flag unusual patterns (large insider sales, executive departures, restatements)
3. **Report**: Generate an investigation brief
4. **Alert**: If the anomaly score exceeds threshold, send an emergency alert to the network

#### PR Campaign Detected

When `narrative-detector` returns a coordination_score above 0.7:

1. **Counter-narrative generation**: Claude generates factual counter-narratives using `forge-voice`
2. **Source tracing**: `narrative-detector`'s `think_tank_trace` action traces the campaign's likely origin
3. **Network amplification**: The counter-narrative and analysis are shared with peer nodes for distributed amplification
4. **Documentation**: The detected campaign is logged with full evidence chain

#### Network Peer Shares Intelligence

When a peer node sends intelligence via the FireWire gossip protocol:

1. **Verification**: Cross-reference the intelligence with the node's own data
2. **Integration**: If verified, store in D1 via `fire-api /api/ingest`
3. **Amplification**: Re-share with other peers that may not have received it
4. **Response**: If the intelligence reveals something actionable, trigger a follow-up investigation

#### New GitHub Issue Assigned

When a GitHub issue is labeled `claude-implement` or assigned to the node:

1. **Parse**: Read the issue description and acceptance criteria
2. **Implement**: Launch an implementation worker via `workers/orchestrator.sh`
3. **Review**: Launch a review worker for the resulting PR
4. **Fix**: Iterate if review finds issues
5. **Merge**: If approved, merge to main

#### Human Asks a Question

When the human runs `claude` interactively in the project directory:

1. Claude reads CLAUDE.md and understands the full project context
2. The human types their question
3. Claude responds with sourced analysis, drawing on the node's accumulated intelligence
4. The human can direct the node: "investigate X" or "focus on Y"
5. These directives are translated into GitHub issues, scheduler tasks, or direct actions

### 3.4 Inter-Node Communication

The following operations run continuously as part of federation:

#### Gossip Protocol for Intelligence Sharing

Based on `docs/federation-protocol.md` Section 7 (Intelligence Sharing):

- Each node maintains a gossip buffer of recent intelligence
- Every 5 minutes, the node selects 3 random peers and exchanges gossip
- Intelligence Objects (structured civic data) are content-addressed by hash
- A node only sends objects that the peer does not already have (bloom filter comparison)
- Received objects are verified (signature check, source reputation check) before integration

#### Distributed Investigation Coordination

Based on `docs/federation-protocol.md` Section 8 (Coordination Protocol):

- A node can propose a distributed investigation (e.g., "Trace beneficial ownership of companies receiving defense contracts in 5 states")
- Interested nodes claim subtasks based on their capabilities and geographic focus
- Results are aggregated and cross-referenced
- The coordinating node publishes the combined report

#### Content Amplification

When a node generates a high-quality investigation report or social media post:

- It publishes the content to the network with a "redistribute" flag
- Peer nodes evaluate the content quality (using their own LLM inference)
- Nodes that approve the content redistribute it through their own channels
- The result: node A creates, nodes B through Z distribute

#### Trust and Reputation Updates

Based on `docs/federation-protocol.md` Section 11 (Trust and Reputation):

- Trust is behavioral, not token-weighted. It accrues through verified contributions.
- Each node maintains a local trust score for every known peer.
- Trust scores are updated based on: intelligence quality, uptime, responsiveness, cross-validation accuracy.
- Trust decays over time (use it or lose it). A node that stops contributing loses trust.
- High-trust nodes' intelligence is amplified more broadly. Low-trust nodes' intelligence is verified more carefully.

#### Emergency Alerts

When a node detects something urgent (new legislation with immediate impact, coordinated takedown attempt, critical investigation finding):

- It broadcasts an emergency alert to all connected peers
- Emergency alerts propagate with higher priority than normal gossip
- Receiving nodes verify the alert, assess urgency, and re-propagate if verified
- The alert includes recommended response actions

---

## 4. CONTENT GENERATION AND DISTRIBUTION

### 4.1 What the Node Produces

The node's content generation system is the Forge, described in `CLAUDE.md` (lines 46-49). It produces concrete, distributable content from the intelligence gathered by the operation loop.

#### Social Media Posts

Generated by `forge-voice` for Bluesky (AT Protocol), Mastodon (ActivityPub), and other platforms:

- **Thread posts**: Multi-post analysis threads breaking down a finding (e.g., "We found that Company X received $50M in government contracts while its CEO donated $500K to the committee chair's PAC. Here is the chain: 1/7...")
- **Alert posts**: Short, urgent notifications about new developments
- **Data posts**: Key statistics with context (e.g., "Surveillance spending is up 340% since 2020. Here is where the money went.")
- **Satire posts**: Corporate doublespeak translations (from `docs/humor-and-satire.md`), corruption weather reports, accountability scorecards

#### Short-Form Video Scripts

Claude generates scripts for human review before posting:

- **Investigation summaries**: 60-second narrated breakdowns of findings
- **Data visualizations with voiceover**: Animated charts showing trends
- **"Who Profits?" explainers**: Follow-the-money narratives
- **Satirical segments**: "The Corruption Weather Report", "Doublespeak Dictionary"

These are scripts and storyboards, not rendered video. The human reviews and records them, or they are distributed as text/audio for other nodes or humans to produce.

#### Investigation Reports

Full-length investigation reports stored in `output/reports/`:

- **Entity reports**: Comprehensive dossier on a person, company, or organization
- **Legislative analysis**: Bill-by-bill analysis with beneficiary mapping
- **Spending reports**: Government spending pattern analysis
- **Network maps**: Relationship graphs showing connections between entities
- **Campaign detection reports**: Evidence of coordinated PR/messaging campaigns

Reports include source citations, confidence levels, methodology notes, and are structured for both human reading and machine parsing (see `docs/dual-documentation.md`).

#### Satirical Content

From `docs/humor-and-satire.md`:

- **Corporate Doublespeak Translator**: Takes a corporate press release and translates it to plain English. "We are committed to right-sizing our workforce to drive shareholder value" becomes "We are firing people to make the stock go up."
- **Corruption Weather Reports**: "Today's forecast: a 90% chance of regulatory capture in the telecom sector, with scattered conflicts of interest across the defense appropriations committee. Expect heavy lobbying through Wednesday."
- **Accountability Scorecards**: Report-card style grading of officials and companies
- **Parody press releases**: Mirror the format and tone of actual corporate communications

#### Data Visualizations

Generated by `forge-vision`:

- **SVG charts**: Spending trends, donation flows, voting patterns
- **Mermaid diagrams**: Ownership chains, relationship networks, legislative process flows
- **ASCII art**: Terminal-friendly visualizations for technical audiences
- **Image prompts**: Detailed prompts for image generation tools (Stable Diffusion, DALL-E) when the node needs visual content

#### Newsletter Content

Weekly digest format combining the week's findings:

- Top stories with analysis
- Legislative tracker (new bills, status changes)
- Spending anomaly report
- Network intelligence highlights
- Recommended reading and investigation follow-ups

#### Podcast Scripts

Structured for audio production:

- Opening briefing (2 minutes: top findings)
- Deep dive (10 minutes: investigation of the week)
- Listener questions (5 minutes: responding to human queries)
- Closing (1 minute: recommended actions, where to learn more)

#### Counter-Narratives

When the narrative-detector identifies a coordinated PR campaign, the node generates:

- Factual rebuttals with source citations
- Context that the campaign omits
- Historical patterns (similar campaigns by the same entities)
- "What they are not telling you" analysis
- Alternative framings that center affected communities rather than corporate interests

### 4.2 Distribution Channels

Content reaches humans through multiple channels:

| Channel | Mechanism | Human Review Required |
|---------|-----------|----------------------|
| GitHub Pages | Pushed to `docs/` or `output/`, deployed via GitHub Pages | No (auto-published) |
| Bluesky | AT Protocol posting via API | Optional (configurable) |
| Mastodon | ActivityPub posting via API | Optional (configurable) |
| Email newsletter | Generated and queued for send | Yes (human sends) |
| Federation network | Shared via FireWire gossip | No (auto-shared) |
| Local `output/` | Written to filesystem for human access | N/A (local) |
| RSS feed | Generated from `output/reports/` | No (auto-generated) |

The node defaults to requiring human review for social media posts. This is a safety mechanism. The human can change this setting to fully autonomous posting if they choose. Video scripts always require human review.

### 4.3 Content Quality Control

Content passes through quality checks before distribution:

1. **Factual verification**: Claims are cross-referenced with source data
2. **Source citation**: Every factual claim must have a source. Unsourced claims are flagged.
3. **Tone check**: Content is checked against the Pyrrhic Lucidity principles. It must be clear, not inflammatory. It must inform, not manipulate.
4. **Safety classification**: Content is run through Llama Guard 3 via `fire-ai /ai/classify` (see `edge/fire-ai/src/index.js` lines 350-379). Content classified as harmful is blocked.
5. **Peer review**: Before federation-wide distribution, content is shared with 3 random trusted peers for cross-validation. If 2 of 3 flag issues, distribution is paused.

---

## 5. THE NETWORK TOPOLOGY

### 5.1 Bootstrap Nodes

The network starts from known bootstrap relays. These are Cloudflare Workers running `fire-relay` that provide:

- Initial peer discovery for new nodes
- Message relay for nodes behind NAT
- Node registry for the discovery protocol
- Health monitoring for the network

Bootstrap relays are not special. Any node with Cloudflare deployment can be a bootstrap relay. The list of bootstrap relays is stored in the repository at `config/bootstrap-relays.json`:

```json
{
  "relays": [
    {
      "url": "https://relay1.cleansingfire.org",
      "operator": "bedwards",
      "region": "us-east",
      "trust_level": "genesis"
    },
    {
      "url": "https://relay2.cleansingfire.org",
      "operator": "bedwards",
      "region": "eu-west",
      "trust_level": "genesis"
    }
  ],
  "last_updated": "2026-02-28T00:00:00Z",
  "min_relays": 2,
  "max_relays": 50
}
```

New nodes that deploy fire-relay can submit themselves for inclusion in this list via a GitHub PR. The list grows as the network grows.

### 5.2 Gossip-Based Peer Discovery

After connecting to bootstrap relays, nodes discover each other through gossip. The gossip protocol is specified in `docs/federation-protocol.md` Section 5.2. The algorithm:

1. Every 5 minutes, select 3 random peers from the known peer list
2. Send a `PEER_EXCHANGE` message containing 10 random peers from your own list
3. Receive the peer's list in return
4. Merge new peers into your list (with initial trust score of 0)
5. Verify new peers by checking their Agent Card signature
6. Successful verification promotes the peer to "known" status

This creates a rapid mesh: if node A knows node B and node B knows node C, then within one gossip cycle, node A learns about node C. With 100 nodes doing this every 5 minutes, the entire network converges within hours.

### 5.3 Reputation-Weighted Connections

Not all peer connections are equal. The trust system from `docs/federation-protocol.md` Section 11 determines connection priority:

- **High-trust peers**: Contacted first during gossip, intelligence from them is accepted with less verification, their content is amplified more broadly
- **Medium-trust peers**: Normal gossip participation, standard verification
- **Low-trust peers**: Contacted less frequently, intelligence is heavily verified, content is not amplified
- **Untrusted/New peers**: Only basic gossip (peer exchange), no intelligence sharing until trust is established

Trust is contextual. A node might have high trust for legislative analysis but low trust for financial investigation. See `docs/federation-protocol.md` Section 11.4 for the trust domain specification.

### 5.4 Geographic and Topical Clustering

Nodes naturally cluster based on two dimensions:

**Geographic clustering**: Nodes in the same jurisdiction (state, country) tend to have overlapping data sources and shared investigative targets. A node tracking New York state legislation will gossip more frequently with other New York-focused nodes.

**Topical clustering**: Nodes focused on the same domain (corporate power, surveillance, environmental policy) will share more relevant intelligence. The Agent Card's capabilities field enables this: a node advertising "corporate-mapping" capability will receive more corporate intelligence from the network.

Clustering is emergent, not enforced. No central coordinator assigns clusters. Nodes gravitate toward useful peers through the trust and gossip mechanisms.

### 5.5 Redundancy and Multiple Paths

The mesh topology ensures redundancy:

- Every node maintains connections to at least 5 peers (configurable)
- If a peer goes offline, the node discovers replacements via gossip
- Intelligence is propagated through multiple independent paths
- No single node's failure disrupts the network (see `docs/global-architecture.md` Section 1.1: "The system must survive the loss of any node, any provider, any country")

The network topology resembles a small-world network: dense local clusters with long-distance bridges between clusters. This is the same topology observed in social networks and biological neural networks -- it optimizes for both local efficiency and global connectivity.

### 5.6 NAT Traversal and Censorship Resistance

Most home computers are behind NAT. They cannot receive incoming connections. The network handles this through:

1. **Cloudflare relay**: fire-relay workers act as message relay points. Node A sends a message to the relay addressed to node B. Node B polls the relay and receives it. See Section 2.8.6 for the relay specification.

2. **WebSocket connections**: Nodes behind NAT establish persistent WebSocket connections to relay workers. Messages can be pushed to them through these connections. fire-relay uses Durable Objects with the Hibernation API (see `docs/cloudflare-implementation.md` Section 2.8) to maintain these connections at zero cost during idle periods.

3. **Cloudflare Tunnel (advanced)**: For nodes that want direct connectivity, Cloudflare Tunnel can expose local services without port forwarding.

4. **Tor integration (planned)**: For nodes in censored networks, the FireWire transport layer can operate over Tor. See `docs/federation-protocol.md` Section 6.2 for the transport specification.

### 5.7 Network Topology Diagram

```
                      INTERNET
                         |
            +------------+------------+
            |                         |
    +-------v--------+      +--------v-------+
    | Bootstrap Relay |      | Bootstrap Relay |
    | (fire-relay CF) |      | (fire-relay CF) |
    | relay1.cf.org   |      | relay2.cf.org   |
    +---+----+---+----+      +----+---+---+----+
        |    |   |                |   |   |
        |    |   +--------+------+   |   |
        |    |            |          |   |
   +----v--+ +---v----+  +--v---+  +v---+---+
   | Node A | | Node B |  |Node C|  | Node D |
   |  Home  | | Home   |  | Home |  |  VPS   |
   |  NAT   | | Direct |  | NAT  |  | Public |
   |  Mac   | | Linux  |  | WSL  |  | Linux  |
   +---+----+ +---+----+  +--+---+  +---+----+
       |          |           |          |
       +-----+---+           +----+-----+
             |                     |
        +----v----+          +-----v-----+
        | Node E  |          |  Node F   |
        | Home    |          |  Home     |
        | NAT     |          |  NAT     |
        +----+----+          +-----+-----+
             |                     |
             +----------+----------+
                        |
                   +----v----+
                   | Node G  |
                   | Home    |
                   +---------+

Legend:
  Solid lines = gossip connections
  NAT nodes connect via fire-relay WebSocket
  Public nodes accept direct connections
  Every node also has Cloudflare Workers (not shown)
```

---

## 6. SELF-IMPROVEMENT AND EVOLUTION

### 6.1 The Improvement Cycle

The network improves itself through the same development loop described in `CLAUDE.md` (lines 69-97), running autonomously across nodes:

```
Node A identifies an improvement opportunity
    |
    v
Node A creates a GitHub issue describing the improvement
    |
    v
Node B (or A) picks up the issue via hourly issue check
    |
    v
Implementation worker creates feature branch, implements change, creates PR
    |
    v
Review worker reviews the PR (separate Claude instance)
    |
    v
Fix worker addresses review feedback if needed
    |
    v
Orchestrator merges to main
    |
    v
Every node pulls the change within 24 hours (self-update cron)
    |
    v
The improvement propagates across the entire network
```

### 6.2 What Nodes Propose

Nodes identify improvement opportunities through their operation:

- **Plugin failures**: "The civic-legiscan plugin is returning 403 errors. The LegiScan API URL may have changed." -> GitHub issue -> fix -> deploy
- **Missing data sources**: "ProPublica's nonprofit explorer has a new API endpoint for 990 filings that we are not using." -> GitHub issue -> new plugin feature -> deploy
- **Performance issues**: "The news-monitor plugin takes 90 seconds because it fetches all 14 feeds sequentially. It should use asyncio." -> GitHub issue -> refactor -> deploy
- **New investigation templates**: "I discovered that county-level property records are available via API in 12 states. We should add a civic-property plugin." -> GitHub issue -> new plugin -> deploy
- **Content quality improvements**: "The satire engine's doublespeak translations are too obvious. They should be more subtle." -> GitHub issue -> prompt engineering -> deploy
- **Federation protocol improvements**: "Gossip convergence is slow with only 3 peers per cycle. Increase to 5." -> GitHub issue -> protocol change -> deploy
- **Documentation gaps**: "The getting-started guide does not cover Windows/WSL setup." -> GitHub issue -> doc update -> deploy

### 6.3 Quality Control on Self-Modifications

Not every proposed change is good. The system has safeguards:

1. **Review workers never fix code** (CLAUDE.md line 95). A separate Claude instance reviews every PR. This means at least two independent AI perspectives evaluate every change.

2. **Integrity verification** (`docs/fork-protection.md`). The integrity manifest tracks SHA-256 hashes of protected files. Changes to core philosophy files (philosophy.md, CLAUDE.md) trigger additional scrutiny.

3. **The 7 Principles are constitutional** (`CLAUDE.md` lines 3-14). No change can violate Pyrrhic Lucidity. Claude is instructed to reject changes that:
   - Add opacity (violating Transparent Mechanism)
   - Concentrate power (violating Anti-Accumulation)
   - Suppress dissent (violating Adversarial Collaboration)
   - Remove accountability (violating Recursive Accountability)

4. **GitHub branch protection**. The main branch requires PR approval. Force pushes are blocked.

5. **Automated testing**. The CI/CD pipeline (`.github/workflows/deploy-workers.yml`) runs health checks on deployed workers after every merge.

6. **Human oversight**. The GitHub repository is owned by a human who receives notifications for all PRs and can intervene at any time.

### 6.4 New Plugin Development

Nodes can create entirely new plugins. The plugin architecture (`plugins/README`, `specs/plugin-schema.json`) defines the contract:

- Plugins are executable scripts (Python, Bash, or any language)
- Input: JSON on stdin
- Output: JSON on stdout
- Must accept an `action` field in the input
- Must return structured output with error handling
- Must declare their manifest (name, category, actions, requirements)

A node that needs a capability that does not exist can:

1. Research available APIs and data sources
2. Write a new plugin following the plugin schema
3. Test it locally
4. Create a PR to add it to the `plugins/` directory
5. Once merged, all nodes gain the capability within 24 hours

### 6.5 New Investigation Templates

Investigation templates (in `docs/chaos-research.md`) are instructions for conducting specific types of research. Nodes can propose new templates:

- "Trace the board of directors overlap between a company and its regulatory agency"
- "Map the campaign finance network around a specific piece of legislation"
- "Compare lobbying disclosures with actual legislative outcomes"
- "Identify revolving-door hires at a specific agency"

New templates are added via PR and become available to all nodes.

### 6.6 Network Learning

The network accumulates knowledge over time:

- **D1 databases** on Cloudflare store civic data persistently (entities, legislation, spending)
- **Vectorize indexes** enable semantic search across accumulated intelligence
- **R2 storage** holds investigation reports, documents, and media
- **Agent memory** (via Claude Code's automatic memory feature, see `docs/claude-code-features.md` Section 3) preserves institutional knowledge across sessions

Each node's accumulated knowledge is partially shared via federation. A node that has been running for a year has a rich database of entities, relationships, and patterns. New nodes bootstrap from zero but rapidly acquire knowledge from the network.

---

## 7. HUMAN INTERACTION POINTS

### 7.1 The Initial Install Command

This is where the human enters. They run:

```bash
claude --dangerously-skip-permissions -p "$(curl -sL https://raw.githubusercontent.com/bedwards/cleansing-fire/main/bootstrap/ignite.md)"
```

After this, the human can walk away. But they probably will not. The system is designed to be interesting enough that humans want to participate.

### 7.2 The GitHub Pages Site

The project's public website is deployed via GitHub Pages from the `docs/` directory. It has three entry points (see `CLAUDE.md` lines 147-149):

- **`index.html`** -- Split landing page with paths for humans and AI agents
- **`humans.html`** -- Human portal with chat interface, text-to-speech, accessibility features
- **`agents.html`** -- AI agent portal with bootstrap instructions, specs, workflow documentation

The site presents the node's accumulated intelligence in human-readable form:
- Investigation reports
- Legislative trackers
- Spending dashboards
- Network status
- Weekly reports

Humans outside the network can read and learn without running a node.

### 7.3 Claude Code CLI (Interactive Mode)

The human can run `claude` in the project directory at any time. This opens an interactive session where they can:

```bash
# Ask a question
claude
> What lobbying firms represent the largest defense contractors?

# Direct an investigation
claude
> /investigate Palantir Technologies

# Generate content
claude
> /forge "Create a social media thread about today's spending watchdog findings"

# Check status
claude
> What has the node done today? Show me the latest findings.

# Change focus
claude
> Shift investigation focus to healthcare industry mergers for the next week
```

The skills system (see `docs/claude-code-features.md` Section 7) provides the `/investigate`, `/forge`, `/implement`, `/review`, and `/fix` slash commands. Each skill has a `SKILL.md` file with detailed instructions that Claude follows.

### 7.4 Social Media Feeds

The node generates social media content that the human can review and post:

- Generated posts are stored in `output/content/`
- The human reviews them for accuracy and tone
- Approved posts can be auto-published (if the human enables this)
- The human can edit, reject, or redirect content generation

### 7.5 Notifications and Alerts

The node alerts the human to urgent findings:

- **Emergency alerts** from the federation network
- **High-relevance news** detected by news-monitor (relevance score >= 50)
- **Coordinated campaigns** detected by narrative-detector (coordination score >= 0.7)
- **New legislation** affecting tracked keywords
- **System issues** (gatekeeper down, Cloudflare deployment failed, disk space low)

Notification channels (configurable):
- Terminal notifications via Claude Code
- Desktop notifications via the operating system
- Email alerts (if configured)
- Webhook alerts (for integration with other systems)

### 7.6 Directing the Node

The human is not a passive observer. They can direct their node at any time:

- **"Investigate X"** -- Triggers a targeted investigation
- **"Focus on Y"** -- Adjusts the scheduler's monitoring keywords
- **"Write about Z"** -- Triggers content generation on a specific topic
- **"Connect to node ABC"** -- Manually add a peer to the federation list
- **"Pause operations"** -- Temporarily stop the scheduler
- **"Show me everything about entity Q"** -- Query the accumulated intelligence

The human's directives are translated into scheduler tasks, GitHub issues, or direct actions. The human has full control but is never required to exercise it.

### 7.7 Learning and Growth

The system teaches humans as they use it:

- `docs/getting-started.md` -- Onboarding guide
- `docs/claude-code-tutorial.md` -- Claude Code CLI tutorial for beginners
- Interactive `claude` sessions explain what the node is doing and why
- Generated reports include methodology notes so humans understand the process
- The human portal (`humans.html`) includes explanatory content with text-to-speech

Over time, the human learns how power works by watching their node investigate it. This is the Pyrrhic Lucidity principle of "lucidity before liberation" in practice.

---

## 8. SECURITY AND RESILIENCE

### 8.1 Node Identity Verification

Every node has an Ed25519 keypair generated during bootstrap (Section 2.9). All messages are signed.

- **Message signing**: Every intelligence object, gossip message, and coordination request is signed with the node's private key. Receivers verify the signature against the sender's public key from their Agent Card.
- **Agent Card signing**: The Agent Card itself is self-signed. This means a node's capabilities, endpoints, and metadata are tamper-evident.
- **Signed append-only logs**: Every node maintains a log of its actions (from `docs/federation-protocol.md` Section 2.1). Each entry references the hash of the previous entry, creating a Merkle chain. This makes historical modification detectable.

Key material is stored at `~/.cleansing-fire/identity/` with 0600 permissions. The private key never leaves the local machine. It is never transmitted over the network. It is never stored in the repository.

### 8.2 Encrypted Inter-Node Communication

All inter-node communication is encrypted:

- **HTTPS**: All communication with Cloudflare Workers is over TLS (Cloudflare enforces this)
- **Message-level encryption**: Sensitive intelligence objects are encrypted with the recipient's public key before transmission (from `docs/federation-protocol.md` Section 6.3)
- **WebSocket TLS**: Relay connections use WSS (WebSocket Secure)
- **Key exchange**: Nodes establish shared secrets via X25519 key exchange for efficient symmetric encryption of high-volume gossip

### 8.3 Sybil Resistance

The network resists Sybil attacks (an adversary creating many fake nodes to manipulate the system) through contribution-based trust rather than financial stakes:

- **New nodes start with zero trust**. They cannot influence the network until they demonstrate value.
- **Trust requires verifiable contribution**. A node gains trust by sharing intelligence that other nodes independently verify. A Sybil node that generates fake intelligence will be caught when cross-referenced.
- **Trust decays over time**. A Sybil node must continuously contribute real value to maintain trust. The cost of operating a useful Sybil is similar to operating a legitimate node.
- **Sponsor requirement**: Agent nodes must be sponsored by a human node (from `docs/federation-protocol.md` Section 3.1). This makes Sybil attacks require human involvement.
- **Behavioral analysis**: Nodes that exhibit unusual patterns (sudden burst of activity, identical behavior to another node, intelligence that is always unverifiable) are flagged for community review.

See `docs/federation-protocol.md` Section 12.3 for the full Sybil resistance specification.

### 8.4 Takedown Resistance

No single point of failure. From `docs/global-architecture.md` Section 1.1:

- **No central server**: Nodes connect peer-to-peer via gossip. There is no server to take down.
- **Cloudflare is a tool, not a dependency**: If Cloudflare bans the project, nodes fall back to direct peer-to-peer communication. The local node continues to function.
- **GitHub is a convenience, not a requirement**: If GitHub removes the repository, forks exist on every node's local machine. A new hosting provider can be set up in minutes.
- **The code is on every node**: Every operational node has a complete copy of the repository. The code propagates through git and cannot be deleted from all machines simultaneously.
- **Geographic distribution**: With nodes in multiple countries and jurisdictions, no single legal authority can shut down the network.

### 8.5 Fork Protection

From `docs/fork-protection.md`:

- **Integrity manifest**: `integrity-manifest.json` contains SHA-256 hashes of protected files (CLAUDE.md, philosophy.md, and other core documents). Changes to these files trigger verification.
- **Constitutional constraints**: The 7 Principles of Pyrrhic Lucidity are the constitution. Any fork that violates them is illegitimate. The integrity verification hook (`scripts/verify-integrity.sh`) checks for violations.
- **Transparency requirement**: No legitimate fork can operate in opacity. All forks must maintain the open-source, publicly auditable nature of the project.
- **The cost heuristic**: If a fork exempts itself from accountability, costs nothing to the actor, or removes uncomfortable constraints, it has already failed.

### 8.6 Adversarial Resilience

The network assumes adversaries. From `docs/federation-protocol.md` Section 12:

- **Infiltration detection**: Nodes that consistently produce intelligence that fails cross-validation are flagged. A pattern of subtle misinformation triggers trust degradation.
- **Coordination attacks**: If a group of nodes coordinates to push false intelligence, the trust system's requirement for independent verification catches this. Two colluding nodes cannot verify each other's claims -- verification requires consensus from non-colluding peers.
- **Co-optation resistance**: The protocol's anti-accumulation property means no node or group can gain disproportionate control. Even if compromised, high-trust nodes' trust decays if their behavior changes.
- **Information pollution**: Content quality checks (Section 4.3) and the safety classification via Llama Guard prevent the injection of harmful content.
- **Legal threats**: The project operates transparently under AGPL-3.0. It uses only publicly available data sources. It does not hack, break into systems, or access private data. It is civic research automation. Its legal posture is identical to a journalist using public records.

### 8.7 Local Security

On the human's machine:

- Private keys have 0600 permissions (owner read/write only)
- The gatekeeper daemon binds to `127.0.0.1:7800` (localhost only, not exposed to the network)
- Cloudflare Workers validate incoming requests via auth middleware (see `docs/cloudflare-implementation.md` Appendix B)
- The pre-commit hook checks for accidentally committed secrets (see `scripts/bootstrap.sh` lines 246-259)
- The `.claude/hooks/protect-env.sh` hook prevents reading `.env` files (see `docs/claude-code-features.md` Section 19)
- The `.claude/hooks/block-destructive.sh` hook blocks `rm -rf /`, `sudo`, and pipe-to-shell commands

---

## 9. COST ANALYSIS

### 9.1 What a Node Costs

The total cost of running a fully autonomous civic intelligence node:

| Component | Cost | Notes |
|-----------|------|-------|
| Claude Code Max 20x plan | $200/month | Recommended. 900 messages per 5-hour window. Covers all Claude Opus 4.6 inference. |
| Claude Code Max 5x plan | $100/month | Budget option. 225 messages per 5-hour window. Sufficient for light operation. |
| Cloudflare Workers (free tier) | $0/month | 100K requests/day, includes D1, KV, R2, Queues, Workers AI. Covers most nodes. |
| Cloudflare Workers (paid tier) | $5/month | For nodes exceeding free tier limits (50K+ daily active users). |
| Workers AI inference | $0-10/month | Free tier includes limited inference. Paid scales per usage. |
| Personal hardware | $0 | Whatever the human already has. Mac, Linux, or WSL. |
| Ollama (local inference) | $0 | Free and open source. GPU uses power the human is already paying for. |
| Domain name (optional) | $10/year | For custom domain on Cloudflare Workers. Optional. |

**Total for recommended configuration: $200/month.**

**Total for budget configuration: $100/month** (with reduced throughput).

**Total for API-only configuration**: Variable. At Opus 4.6 API pricing ($15 input / $75 output per million tokens), a moderately active node uses approximately 10M tokens/month, costing roughly $150-300/month. The Max plan is more predictable and usually cheaper for sustained use.

### 9.2 Cloudflare Free Tier Budget

From `docs/cloudflare-implementation.md` Section 8.1:

| Service | Free Tier Limit | Typical Node Usage | Headroom |
|---------|----------------|-------------------|----------|
| Workers | 100K requests/day | ~5K requests/day | 95% |
| Workers AI | Limited free inference | ~500 inferences/day | Varies |
| KV | Unlimited reads, 1K writes/day | ~200 writes/day | 80% |
| D1 | 5M rows read/day, 100K written | ~50K reads, ~1K writes | 99% |
| R2 | 10GB storage, 1M Class A ops | ~1GB, ~10K ops | 90% |
| Queues | 10K operations/day | ~1K operations/day | 90% |
| Vectorize | Included | ~10K vectors | Minimal |
| Durable Objects | Free tier available | ~100 objects | Minimal |

A typical node stays well within the free tier. The $5/month paid tier is needed only for nodes that become public-facing API gateways or high-traffic relays.

### 9.3 Cost Comparison

For context, what does $200/month buy in other domains?

- A Netflix Premium subscription: $23/month -- passive entertainment
- A gym membership: $50/month -- personal health
- A single hour of a private investigator's time: $100-200
- A New York Times + Wall Street Journal subscription: $50/month -- curated news
- A single FOIA request processing fee: $25-250
- A single hour of a lobbyist's time: $500-1000

For $200/month, a Cleansing Fire node runs 24/7/365:
- Monitors 14 news sources every 15 minutes
- Scans legislative databases across jurisdictions
- Watches government spending patterns
- Detects coordinated PR campaigns
- Generates investigation reports and social media content
- Connects to a global federation of civic intelligence nodes
- Improves itself over time

This is the "$50 civic agent" described in `docs/future-capabilities.md`, currently at the $200 price point but trending toward $50 as AI inference costs decline.

### 9.4 Cost Optimization

From `docs/claude-code-features.md` Section 17:

- **Use Max plan for interactive work** (predictable cost, high throughput)
- **Use Sonnet for automated reviews** in GitHub Actions ($3/$15 per million tokens vs. Opus's $15/$75)
- **KV caching on Cloudflare** reduces duplicate AI inference calls (see `edge/fire-ai/src/index.js` lines 126-132)
- **AI Gateway caching** (see `docs/cloudflare-implementation.md` Section 2.10) reduces identical AI API calls by up to 90%
- **Model tiering**: Use Mistral 7B (fast, cheap) for simple tasks on Workers AI; reserve Llama 3.3 70B for deep analysis (see `edge/fire-ai/src/index.js` lines 22-38)
- **Context compaction**: Set `CLAUDE_CODE_AUTOCOMPACT_PCT_OVERRIDE=80` to compact context earlier, reducing token waste
- **`--max-turns` limits**: Prevent runaway headless sessions

---

## 10. IMPLEMENTATION ROADMAP

### 10.1 Phase 1: Single-Node Bootstrap (Partially Working Today)

**Status**: Most components exist. Manual steps required.

What works now:
- [x] `scripts/bootstrap.sh` -- Full local setup script (461 lines)
- [x] `daemon/gatekeeper.py` -- GPU serialization daemon (441 lines)
- [x] `scheduler/scheduler.py` -- Task scheduling system (395 lines)
- [x] `scheduler/tasks.json` -- Initial task set (93 lines)
- [x] `workers/orchestrator.sh` -- Worker launch system (203 lines)
- [x] 14 plugins in `plugins/` (news-monitor, narrative-detector, civic-legiscan, civic-fec, civic-spending, civic-crossref, forge-vision, forge-voice, pipeline-data-to-fire, corp-sec, osint-social, lobby-tracker, whistleblower-submit, narrative-detector)
- [x] `edge/fire-api/` -- API gateway worker (448 lines)
- [x] `edge/fire-ai/` -- AI inference worker (452 lines)
- [x] `edge/fire-markdown/` -- LLM markdown proxy worker (721 lines)
- [x] `scripts/daily-fire.sh` -- Daily autonomous cycle (426 lines)
- [x] `docs/` -- 25+ research documents
- [x] `.claude/hooks/` -- Safety hooks (block-destructive, lint-python, protect-env, verify-integrity)

What needs manual steps today:
- Human must clone repo manually
- Human must run `scripts/bootstrap.sh` manually
- Human must start gatekeeper and scheduler manually
- Human must run `wrangler login` for Cloudflare deployment
- Human must create Cloudflare resources (KV, D1, R2) manually
- No node identity generation
- No federation connection

**Deliverables to reach Phase 1 completion:**
- [ ] Create `bootstrap/ignite.md` -- The initial prompt for zero-touch bootstrap
- [ ] Create `scripts/auto-setup.sh` -- Automated Cloudflare provisioning
- [ ] Create identity generation script at `scripts/generate-identity.py`
- [ ] Create `edge/fire-api/schema.sql` -- D1 schema initialization
- [ ] Expand `scheduler/tasks.json` to full autonomous schedule
- [ ] Test end-to-end: `claude --dangerously-skip-permissions -p "..."` from clean machine

### 10.2 Phase 2: Automated Bootstrap (One Command)

**Status**: Specified in this document, not yet implemented.

The gap between Phase 1 and Phase 2 is the `bootstrap/ignite.md` prompt and the automation of Cloudflare provisioning. All the underlying components exist.

**Deliverables:**
- [ ] `bootstrap/ignite.md` -- Complete, tested, field-verified bootstrap prompt
- [ ] `scripts/auto-cloudflare.sh` -- Provisions KV, D1, R2, Queues, Vectorize, deploys all workers
- [ ] `scripts/generate-identity.py` -- Ed25519 keypair generation, Agent Card building
- [ ] Automated `wrangler.toml` configuration (replace placeholder IDs)
- [ ] Automated scheduler expansion (merge full schedule into tasks.json)
- [ ] End-to-end testing on macOS, Ubuntu, and WSL
- [ ] Error recovery: if any step fails, the bootstrap logs the failure, skips that step, and continues

### 10.3 Phase 3: Network Discovery and Connection

**Status**: Specified in `docs/federation-protocol.md`, not yet implemented.

**Deliverables:**
- [ ] `edge/fire-relay/` -- Federation relay Cloudflare Worker
  - [ ] `wrangler.toml` with KV and Durable Objects bindings
  - [ ] `src/index.js` with register, discover, heartbeat, relay endpoints
- [ ] `config/bootstrap-relays.json` -- Initial relay list
- [ ] `scripts/network-connect.sh` -- Peer discovery and connection
- [ ] Gossip protocol implementation (local Python daemon or Claude Code headless session)
- [ ] Agent Card exchange and verification
- [ ] Heartbeat reporting

### 10.4 Phase 4: Autonomous Operation Loop

**Status**: Individual components exist, integration needed.

The scheduler, plugins, and content generation scripts all work independently. The integration work is:

**Deliverables:**
- [ ] Full `scheduler/tasks.json` with all cron tasks from Section 3.2
- [ ] Event task integration: new plugin output -> Claude analysis -> GitHub issue creation
- [ ] Automated content pipeline: findings -> forge-voice -> output/content/ -> distribution
- [ ] GitHub issue -> implement -> review -> fix -> merge cycle running autonomously
- [ ] Self-update cycle: git pull -> bootstrap -> redeploy
- [ ] Monitoring dashboard: `scripts/node-status.sh` enhanced with full operational metrics

### 10.5 Phase 5: Content Distribution

**Status**: Forge plugins exist, distribution channels not yet connected.

**Deliverables:**
- [ ] Bluesky API integration for automated posting (AT Protocol)
- [ ] Mastodon API integration for automated posting (ActivityPub)
- [ ] RSS feed generation from `output/reports/`
- [ ] Email newsletter generation and send queue
- [ ] Human review workflow for social media posts
- [ ] Content quality pipeline (verification, citation, safety, peer review)

### 10.6 Phase 6: Full Mesh Network

**Status**: Specified in `docs/federation-protocol.md` and `docs/global-architecture.md`, not yet implemented.

**Deliverables:**
- [ ] Full gossip protocol implementation
- [ ] Intelligence Object format and exchange
- [ ] Distributed task coordination protocol
- [ ] Trust substrate (contribution tracking, decay, contextual scoring)
- [ ] Content amplification network
- [ ] Emergency alert system
- [ ] Cross-node investigation coordination
- [ ] Network-wide search (federated Vectorize queries)
- [ ] Governance mesh (protocol-level decision-making)

### 10.7 Timeline

| Phase | Target | Dependencies |
|-------|--------|-------------|
| Phase 1: Single-node complete | March 2026 | `bootstrap/ignite.md`, identity scripts |
| Phase 2: One-command bootstrap | April 2026 | Phase 1 + Cloudflare automation |
| Phase 3: Network discovery | May 2026 | Phase 2 + fire-relay worker |
| Phase 4: Autonomous loop | June 2026 | Phase 3 + scheduler integration |
| Phase 5: Content distribution | July 2026 | Phase 4 + social API integration |
| Phase 6: Full mesh | September 2026 | Phase 5 + full federation protocol |

These are targets, not promises. Each phase builds on the previous one. A node at any phase is useful -- Phase 1 nodes run local investigations. Phase 2 nodes do it automatically. Phase 3 nodes find each other. Phase 4 nodes operate without human intervention. Phase 5 nodes distribute content. Phase 6 nodes form an intelligent mesh.

---

## APPENDIX A: FILE REFERENCE

Every file referenced in this document, with its role in the bootstrap architecture.

### Core Infrastructure

| File | Lines | Role in Bootstrap |
|------|-------|-------------------|
| `CLAUDE.md` | 230 | Project constitution. Read in Step 2. Defines all conventions. |
| `daemon/gatekeeper.py` | 440 | GPU serialization daemon. Started in Step 6. |
| `scheduler/scheduler.py` | 533 | Task scheduling daemon. Started in Step 7. |
| `scheduler/tasks.json` | 327 | Task definitions. Expanded in Step 7. |
| `workers/orchestrator.sh` | 202 | Worker launch system. Used by hourly issue check. |
| `scripts/bootstrap.sh` | 460 | Local setup script. Run in Step 4. |
| `scripts/daily-fire.sh` | 425 | Daily operation cycle. First run in Step 13. |

### Plugins

| File | Role in Autonomous Loop |
|------|------------------------|
| `plugins/news-monitor` | 15-minute news monitoring cycle. RSS + API sources. |
| `plugins/narrative-detector` | 6-hour narrative detection. GDELT integration. |
| `plugins/civic-legiscan` | Weekly legislative scans. LegiScan API. |
| `plugins/civic-spending` | Weekly spending watchdog. USAspending API. |
| `plugins/civic-fec` | Campaign finance monitoring. FEC API. |
| `plugins/civic-crossref` | Cross-referencing across data sources. |
| `plugins/corp-sec` | SEC EDGAR filing monitoring. |
| `plugins/lobby-tracker` | Lobbying disclosure tracking. |
| `plugins/osint-social` | Social media OSINT. |
| `plugins/forge-voice` | Content generation: text, posts, newsletters. |
| `plugins/forge-vision` | Content generation: SVG, diagrams, visualizations. |
| `plugins/pipeline-data-to-fire` | Full pipeline: data -> analysis -> visualization -> narrative. |
| `plugins/whistleblower-submit` | Secure submission interface. |

### Cloudflare Workers

| File | Role in Bootstrap |
|------|-------------------|
| `edge/fire-api/wrangler.toml` | API gateway configuration. Provisioned in Step 8. |
| `edge/fire-api/src/index.js` | API gateway routes (447 lines). Deployed in Step 8. |
| `edge/fire-ai/wrangler.toml` | AI inference worker configuration. |
| `edge/fire-ai/src/index.js` | AI inference routes (451 lines). Deployed in Step 8. |
| `edge/fire-markdown/wrangler.toml` | Markdown proxy configuration. |
| `edge/fire-markdown/src/index.js` | LLM markdown proxy (720 lines). Deployed in Step 8. |
| `edge/fire-relay/` | Federation relay. Phase 3 deliverable. |

### Documentation Cross-References

| Document | How This Document Builds On It |
|----------|-------------------------------|
| `docs/federation-protocol.md` | Sections 2.9-2.12 implement the identity, discovery, and gossip layers specified there. Section 3.4 implements the intelligence sharing and coordination protocols. Section 5 implements the network topology. |
| `docs/global-architecture.md` | Section 2 implements the four-layer architecture (Edge, Core, Network, People). Section 3 implements the headless AI system. Section 9 builds on the cost analysis. |
| `docs/cloudflare-implementation.md` | Section 2.8 implements the worker deployment and resource provisioning. Section 9 extends the cost analysis. All Cloudflare service references are verified against the capability inventory in that document. |
| `docs/claude-code-features.md` | Section 1.2 uses headless mode and `--dangerously-skip-permissions`. Section 2 leverages skills, hooks, subagents. Section 3 uses the scheduler patterns, GitHub Action integration, and MCP servers. |
| `docs/blue-sky-vision.md` | This document is the engineering path toward the convergence described there. Section 6 connects to the "capabilities that emerge when everything connects." |
| `docs/chaos-research.md` | Section 3.2's random investigation cycle implements the serendipity methodology. |
| `docs/humor-and-satire.md` | Section 4.1's satirical content generation implements the satire engine. |
| `docs/intelligence-and-osint.md` | Section 3's continuous operations implement the OSINT pipeline. |
| `docs/movement-strategy.md` | Section 7's human interaction model implements the recruitment and engagement strategy. |
| `docs/fork-protection.md` | Section 8.5 implements the integrity verification mechanisms. |
| `docs/game-theory.md` | Section 5.3's reputation-weighted connections implement the trust calculus. Section 8.3's Sybil resistance implements the anti-capture mechanisms. |

---

## APPENDIX B: THE IGNITE PROMPT (DRAFT)

This is the draft content of `bootstrap/ignite.md`, the prompt that initiates the entire bootstrap sequence.

```markdown
# CLEANSING FIRE -- NODE IGNITION

You are Claude, running in headless mode with full permissions.
Your task: bootstrap a Cleansing Fire civic intelligence node on this machine.

## ORIENTATION

1. Clone the Cleansing Fire repository:
   git clone https://github.com/bedwards/cleansing-fire.git ~/cleansing-fire
   cd ~/cleansing-fire

2. Read CLAUDE.md. This is the project constitution. Understand it completely.

3. Read docs/zero-touch-bootstrap.md. This is your engineering specification.
   Follow it exactly, from Section 2.3 through Section 2.13.

## EXECUTION

Execute the bootstrap sequence. At each step:
- If a step fails, log the error, skip that step, and continue.
- If a step requires credentials you do not have, note it and move on.
- Prefer graceful degradation over failure.

After completing the bootstrap:
- Run scripts/node-status.sh to report the node's operational status.
- Run the first daily-fire cycle: scripts/daily-fire.sh
- Start the scheduler: python3 scheduler/scheduler.py &
- Print a summary of what was set up and what was skipped.

## PRINCIPLES

You are bound by the 7 Principles of Pyrrhic Lucidity in CLAUDE.md.
You are building infrastructure for civic intelligence.
You serve no party, no corporation, no ideology.
You serve transparency, accountability, and the public interest.

The fire is lit. What you do with the light is yours to decide.
```

---

## APPENDIX C: ARCHITECTURE DIAGRAM

```
+=====================================================================+
|                     ZERO-TOUCH BOOTSTRAP                             |
|   claude --dangerously-skip-permissions -p "$(curl ignite.md)"       |
+=====================================================================+
         |
         v
+--------+--------+
|  Clone Repo     |
|  Read CLAUDE.md |
+--------+--------+
         |
    +----+----+----+----+----+----+
    |         |         |         |
    v         v         v         v
+-------+ +-------+ +-------+ +-------+
| Local | | Edge  | |Network| | Auto  |
| Setup | | Deploy| |Connect| | Loop  |
+---+---+ +---+---+ +---+---+ +---+---+
    |         |         |         |
    v         v         v         v
+-------+ +-------+ +-------+ +-------+
|Gate-  | |fire-  | |Fire-  | |Sched- |
|keeper | |api    | |Wire   | |uler   |
|:7800  | |fire-ai| |Gossip | |tasks  |
|       | |fire-md| |Trust  | |.json  |
|Ollama | |fire-  | |Agent  | |       |
|(opt)  | |relay  | |Cards  | |Cron   |
|       | |       | |       | |Events |
|Plugins| |D1/KV  | |Heart- | |       |
|14 exe | |R2/Vec | |beat   | |Plugins|
+---+---+ +---+---+ +---+---+ +---+---+
    |         |         |         |
    +----+----+----+----+----+----+
         |
         v
+--------+---------+
|  AUTONOMOUS NODE  |
|                   |
|  Every 15 min:    |
|    News Monitor   |
|  Every hour:      |
|    GitHub Issues   |
|  Every 4 hours:   |
|    Investigation  |
|  Every 6 hours:   |
|    Narrative Det. |
|  Every 12 hours:  |
|    Content Gen    |
|  Every 24 hours:  |
|    Deep Research  |
|    Self-Update    |
|    Daily Fire     |
|  Weekly:          |
|    Full Report    |
|                   |
|  + Event Triggers |
|  + Federation     |
|  + Human Input    |
+-------------------+
```

---

## APPENDIX D: GLOSSARY

| Term | Definition |
|------|-----------|
| **Agent Card** | Public identity document advertising a node's capabilities, endpoints, and trust status. From `docs/federation-protocol.md` Section 3.1. |
| **Bootstrap relay** | A Cloudflare Worker running fire-relay that provides initial peer discovery for new nodes. |
| **The Forge** | The content generation system: forge-voice (text), forge-vision (visual), pipeline-data-to-fire (full pipeline). |
| **FireWire** | The federation protocol for inter-node communication. From `docs/federation-protocol.md`. |
| **Gatekeeper** | The local daemon that serializes GPU access to Ollama. `daemon/gatekeeper.py`. |
| **Gossip protocol** | The mechanism by which nodes share intelligence and discover peers. From `docs/federation-protocol.md` Section 5.2. |
| **Headless mode** | Claude Code's `-p` flag for non-interactive operation. From `docs/claude-code-features.md` Section 13. |
| **Ignite prompt** | The `bootstrap/ignite.md` file that initiates the bootstrap sequence. |
| **Intelligence Object** | A structured piece of civic data (FOIA result, legislative analysis, investigation finding) shared via FireWire. From `docs/federation-protocol.md` Section 7. |
| **Node** | A running instance of the Cleansing Fire system, consisting of local software + Cloudflare edge + federation connection. |
| **Orchestrator** | `workers/orchestrator.sh` -- launches Claude Code workers for the implement/review/fix cycle. |
| **Plugin** | An executable script in `plugins/` that accepts JSON stdin and produces JSON stdout. |
| **Pyrrhic Lucidity** | The project's philosophical framework. 7 principles that constrain all design decisions. From `philosophy.md`. |
| **Scheduler** | `scheduler/scheduler.py` -- cron-like daemon that runs scheduled and event-driven tasks. |
| **Trust substrate** | The web-of-trust system where reputation is earned through verifiable contribution. From `docs/federation-protocol.md` Section 11. |
| **Zero-touch** | The property that the human performs one action (the install command) and everything else is automated. |

---

*The fire burns whether or not anyone watches. But it burns brighter when someone does.*

*See clearly. Act anyway. Bear the cost.*
