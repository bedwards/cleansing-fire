# ZERO-TOUCH BOOTSTRAP

## The Complete Architecture of Autonomous Civic Intelligence Node Deployment

*Ignis purgat. Luciditas liberat.*
*Fire purifies. Lucidity liberates.*

Architecture Date: 2026-02-28
Status: KEYSTONE DOCUMENT
Depends On: CLAUDE.md, bootstrap/ignite.md, bootstrap/setup-node.sh, scheduler/scheduler.py
Cross-References: docs/global-architecture.md, docs/federation-protocol.md, docs/cloudflare-implementation.md

---

## TABLE OF CONTENTS

1. [The One-Command Vision](#1-the-one-command-vision)
2. [The Bootstrap Sequence](#2-the-bootstrap-sequence)
3. [The Autonomous Operation Loop](#3-the-autonomous-operation-loop)
4. [Node Architecture](#4-node-architecture)
5. [The Content Pipeline](#5-the-content-pipeline)
6. [Network Topology](#6-network-topology)
7. [Self-Improvement](#7-self-improvement)
8. [Human Interaction Points](#8-human-interaction-points)
9. [Security Model](#9-security-model)
10. [Cost Analysis](#10-cost-analysis)
11. [Scaling Scenarios](#11-scaling-scenarios)
12. [Implementation Roadmap](#12-implementation-roadmap)
13. [Failure Modes and Mitigations](#13-failure-modes-and-mitigations)

---

## 1. THE ONE-COMMAND VISION

### 1.1 The Premise

There is a single command that, when executed on any macOS or Linux machine, transforms that machine into an autonomous civic intelligence node -- a system that monitors government and corporate power, investigates corruption, generates compelling public-interest content, distributes that content across decentralized platforms, coordinates with other nodes around the world, and improves itself over time. The human who runs the command needs no technical knowledge beyond opening a terminal. Everything else happens autonomously.

The command:

```bash
claude --dangerously-skip-permissions -p "$(curl -sL https://raw.githubusercontent.com/bedwards/cleansing-fire/main/bootstrap/ignite.md)"
```

Two things happen in that line. First, `curl` fetches a prompt document -- `ignite.md` -- from the project's public GitHub repository. Second, that document is fed directly to Claude Code, Anthropic's CLI agent, running with full permissions (the `--dangerously-skip-permissions` flag). Claude reads the prompt, understands what it is being asked to do, and begins executing the bootstrap sequence: cloning the repository, installing dependencies, generating cryptographic identity, deploying edge infrastructure, configuring autonomous scheduling, and reporting back to the human who started it.

From that point forward, the node operates independently. It does not wait for instructions. It does not need supervision. It has its own identity, its own schedule, its own data sources, its own content pipeline, and its own connection to a global network of other nodes doing the same thing.

This is not a product demo. This is infrastructure for shifting power.

### 1.2 Why Zero-Touch Matters

The history of civic technology is the history of good intentions dying in configuration files. Every project that requires a manual setup guide, a Docker compose file with twelve services, a database migration, an API key rotation, a deploy pipeline, and a monitoring stack -- every such project self-selects for operators who already have technical skill, free time, and institutional support. The people who most need civic intelligence infrastructure -- community organizers, local journalists, activists in hostile jurisdictions, citizens in information deserts -- are the people least likely to complete a multi-step technical installation.

Zero-touch deployment eliminates this barrier. The system itself handles complexity. The human provides one thing: the decision to participate. Everything else is delegation to an AI agent that understands the project's architecture, its philosophical framework, its security requirements, and its operational patterns.

This design principle flows directly from the Pyrrhic Lucidity framework:

**Relational Agency** (Principle 2): The unit of action is not the individual human operator but the relationship between the human's intention and the system's capability. The bootstrap sequence is designed to maximize the effective scope of that relationship -- to let a person with no DevOps experience wield the same investigative infrastructure that a fully staffed newsroom would struggle to build.

**Transparent Mechanism** (Principle 3): The entire bootstrap process is visible. The ignite.md prompt is public, readable, auditable. The setup-node.sh script is plain bash with verbose logging. There are no hidden steps, no obfuscated binaries, no phone-home telemetry. Anyone can read exactly what the system will do before they run it.

**The Cost Heuristic** (Principle 6): Running a node is not free. It requires a Claude Code Max subscription ($200/month). It requires electricity. It requires a machine. This is by design. If civic intelligence cost nothing, it would mean nothing. The cost ensures that every node represents a real commitment by a real person to the project of making power visible.

### 1.3 The Philosophical Weight

Consider what it means that a single person, acting alone, with no organizational backing, no funding, no credentials, and no technical expertise beyond the ability to open a terminal, can deploy an autonomous system that:

- Monitors every bill introduced in every state legislature and the US Congress
- Tracks campaign finance data for every federal candidate
- Cross-references government contracts with political donations
- Generates visualizations of money flows between corporations and politicians
- Writes social media threads explaining complex corruption patterns
- Publishes findings across censorship-resistant platforms
- Coordinates with other nodes to avoid duplicated effort
- Improves its own capabilities over time

This is not a speculative future. This is what the bootstrap system already deploys. The plugins exist (`civic-legiscan`, `civic-fec`, `civic-spending`, `civic-crossref`). The forge exists (`forge-vision`, `forge-voice`). The pipeline exists (`pipeline-data-to-fire`). The scheduler exists (`scheduler/scheduler.py`). The content distribution targets exist (Bluesky, Mastodon). The federation protocol is specified (`docs/federation-protocol.md`). The edge infrastructure is deployable (`edge/fire-api`, `edge/fire-ai`, `edge/fire-markdown`).

The zero-touch bootstrap is the thing that takes all of these components and makes them accessible to anyone. It is the difference between a toolbox and a factory. The toolbox requires a skilled worker. The factory runs itself.

**Power lives outside government now.** The primary targets are corporate power, private equity, tech platforms, media conglomerates, dark money networks, and the opacity mechanisms that protect them (see `CLAUDE.md`). A single person running a single command becomes a node in a distributed investigative network that can match the information asymmetry currently wielded by concentrated power against the public interest.

### 1.4 What This Document Covers

This is the central integration document for the Cleansing Fire project. It connects the philosophical framework (`philosophy.md`), the project constitution (`CLAUDE.md`), the bootstrap prompt (`bootstrap/ignite.md`), the installer script (`bootstrap/setup-node.sh`), the scheduler (`scheduler/scheduler.py`), the task configuration (`scheduler/tasks.json`), the worker orchestrator (`workers/orchestrator.sh`), the content pipeline (`plugins/pipeline-data-to-fire`), the edge architecture (`docs/cloudflare-implementation.md`), and the federation protocol (`docs/federation-protocol.md`) into a single coherent picture.

It describes what exists, what is being built, and what comes next -- always distinguishing clearly between the three.

---

## 2. THE BOOTSTRAP SEQUENCE

### 2.1 The Trigger

Everything begins with a human opening a terminal and running:

```bash
claude --dangerously-skip-permissions -p "$(curl -sL https://raw.githubusercontent.com/bedwards/cleansing-fire/main/bootstrap/ignite.md)"
```

Decomposition of the command:

| Component | What It Does |
|-----------|-------------|
| `curl -sL` | Silently (`-s`) follows redirects (`-L`) to fetch a URL |
| `https://raw.githubusercontent.com/...` | The raw content of `bootstrap/ignite.md` from the `main` branch |
| `$(...)` | Shell command substitution: the fetched content becomes the argument |
| `claude` | Invokes Claude Code CLI, Anthropic's agentic coding assistant |
| `--dangerously-skip-permissions` | Grants Claude full system access without per-action approval prompts |
| `-p "..."` | Passes the fetched prompt as the initial instruction |

The `--dangerously-skip-permissions` flag is significant. Under normal operation, Claude Code asks the human to approve potentially dangerous actions: writing files, running scripts, making network requests. During bootstrap, these approvals would create dozens of interruptions. The flag tells Claude to proceed autonomously, which is exactly the point -- the human has made one decision (to run the command), and the system handles the rest.

**Prerequisite**: The human must have Claude Code CLI installed and authenticated. The recommended approach:

```bash
# Install Claude Code CLI
curl -fsSL https://cli.claude.ai/install.sh | sh

# Authenticate (Claude Code Max subscription required)
claude auth
```

### 2.2 Phase 0: Prompt Ingestion

When Claude receives the ignite.md prompt, it reads a document that begins:

> You are being initialized as a Cleansing Fire autonomous civic intelligence node. This is not a simulation. This is infrastructure for shifting power from corrupt concentrated authority toward the people.

The prompt establishes context, mission, and procedure. It tells Claude:

1. **What it is**: a civic intelligence node in a distributed network
2. **What it will do**: set up infrastructure, deploy services, begin autonomous operation
3. **How to proceed**: phase by phase, with specific technical instructions for each
4. **What philosophical framework governs its behavior**: Pyrrhic Lucidity and its 7 Principles
5. **What to report back when done**: node status, deployed services, interaction instructions

Claude's first action, as instructed by ignite.md, is to clone the repository and read the project constitution:

```
git clone https://github.com/bedwards/cleansing-fire.git ~/cleansing-fire
cd ~/cleansing-fire
```

Then it reads:
- `CLAUDE.md` -- the project constitution, defining architecture, workflow, conventions, and Principles
- `philosophy.md` -- the full Pyrrhic Lucidity framework (956 lines)
- `specs/goals.yaml` -- machine-readable goal hierarchy with success criteria and dependencies
- `specs/agent-capabilities.yaml` -- the explicit boundaries of what agents can and cannot do

This reading phase is not decorative. Claude genuinely processes these documents and uses them to inform every subsequent decision during bootstrap. The philosophical framework is not a mission statement bolted onto a technical system -- it is the operating constraint set.

### 2.3 Phase 1: Dependency Detection and Installation

Claude invokes `bootstrap/setup-node.sh`, which handles the mechanical aspects of environment setup. The script uses `set -euo pipefail` (strict error handling) and begins with platform detection:

```bash
OS="$(uname -s)"
case "$OS" in
    Darwin) log "Platform: macOS" ;;
    Linux)  log "Platform: Linux" ;;
    *)      fail "Unsupported platform: $OS" ;;
esac

ARCH="$(uname -m)"
log "Architecture: $ARCH"
```

Then it checks for required and optional dependencies:

| Dependency | Required | Purpose | Fallback If Missing |
|-----------|----------|---------|---------------------|
| Python 3 | Yes | Plugin execution, daemon services | Cannot proceed |
| Git | Yes | Repository management, version control | Cannot proceed |
| GitHub CLI (`gh`) | Recommended | Issue management, PR workflow, API access | Some features limited |
| Node.js / npm | Optional | Wrangler CLI installation | Cloudflare deployment skipped |
| Wrangler CLI | Optional | Cloudflare Workers deployment | Local-only mode |
| Ollama | Optional | Local GPU inference via gatekeeper | Uses Cloudflare Workers AI |

The script installs what it can automatically (Wrangler via npm if npm is available) and warns about what it cannot install. It never fails silently -- every missing dependency is logged with an installation URL:

```bash
# Example: Wrangler installation attempt
if command -v wrangler &>/dev/null; then
    log "Wrangler: $(wrangler --version 2>/dev/null || echo 'installed')"
else
    if command -v npm &>/dev/null; then
        log "Installing wrangler CLI..."
        npm install -g wrangler 2>>"$LOG" || warn "Could not install wrangler globally"
    else
        warn "Wrangler not found and npm not available. Cloudflare deployment will be skipped."
    fi
fi
```

**Graceful degradation** is a core design principle. A node without Ollama still works -- it uses Cloudflare Workers AI for inference. A node without Wrangler still works -- it operates in local-only mode without edge deployment. A node without `gh` still works -- it cannot participate in the GitHub-based development workflow but can still run investigations and generate content. The only hard requirements are Python 3 and Git.

### 2.4 Phase 2: Repository Setup

If the repository already exists at `~/cleansing-fire`, the script pulls the latest changes. If not, it clones fresh:

```bash
FIRE_HOME="${FIRE_HOME:-$HOME/cleansing-fire}"

if [ -d "$FIRE_HOME/.git" ]; then
    log "Repository exists at $FIRE_HOME"
    cd "$FIRE_HOME"
    git pull --rebase 2>>"$LOG" || warn "Could not pull latest changes"
else
    log "Cloning repository to $FIRE_HOME..."
    git clone https://github.com/bedwards/cleansing-fire.git "$FIRE_HOME" 2>>"$LOG"
    cd "$FIRE_HOME"
fi
```

The repository contains everything the node needs:

```
cleansing-fire/
+-- CLAUDE.md                    # Project constitution
+-- philosophy.md                # Pyrrhic Lucidity (956 lines)
+-- integrity-manifest.json      # SHA-256 hashes of protected files
+-- bootstrap/
|   +-- ignite.md                # The bootstrap prompt
|   +-- setup-node.sh            # The installer script
|   +-- README.md                # Human instructions
+-- daemon/
|   +-- gatekeeper.py            # GPU serialization daemon
+-- scheduler/
|   +-- scheduler.py             # Cron + event scheduler daemon
|   +-- tasks.json               # Task definitions
+-- workers/
|   +-- orchestrator.sh          # Claude Code worker management
+-- plugins/                     # 15 executable plugins
|   +-- civic-legiscan           # Bill tracking
|   +-- civic-fec               # Campaign finance
|   +-- civic-spending           # Federal contracts
|   +-- civic-crossref           # Corruption detection
|   +-- corp-sec                # SEC filings
|   +-- forge-vision             # SVG visualizations
|   +-- forge-voice              # Narrative content
|   +-- pipeline-data-to-fire    # Full investigation pipeline
|   +-- news-monitor             # News feed scanning
|   +-- narrative-detector       # PR/propaganda detection
|   +-- lobby-tracker            # Lobbying data
|   +-- osint-social             # Social media OSINT
|   +-- whistleblower-submit     # Secure submission
|   +-- example-summarize        # Template plugin
+-- edge/                        # Cloudflare Workers
|   +-- fire-api/                # REST API gateway
|   +-- fire-ai/                 # Workers AI inference
|   +-- fire-markdown/           # LLM-accessible proxy
+-- scripts/                     # Management scripts
+-- bin/                         # CLI tools (fire-ask)
+-- docs/                        # Human documentation (25+ documents)
+-- specs/                       # Machine-readable specifications
+-- investigations/              # Investigation templates
```

After cloning, the script makes all scripts and plugins executable:

```bash
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x plugins/* 2>/dev/null || true
chmod +x bin/* 2>/dev/null || true
```

### 2.5 Phase 3: Local Environment Configuration

The script creates a `.env` file from a template if one does not already exist:

```bash
cat > "$FIRE_HOME/.env" << 'ENVEOF'
# Cleansing Fire - Environment Variables
# NEVER commit this file. It is in .gitignore.

# Ollama Gatekeeper
GATEKEEPER_URL=http://127.0.0.1:7800

# API keys (add as needed)
# GEMINI_API_KEY=
# LEGISCAN_API_KEY=
# FEC_API_KEY=
# NEWSAPI_KEY=
# MEDIASTACK_KEY=
ENVEOF
```

API keys are intentionally left blank. The system degrades gracefully without them -- plugins that require API keys check for their presence and return clear error messages when missing. A node operator can add keys incrementally as they choose to enable specific data sources.

This `.env` file is in `.gitignore` and is never committed to the repository. The system never stores, transmits, or exposes API credentials. This is a deliberate security boundary and an architectural absolute.

### 2.6 Phase 4: Node Identity Generation

Every node in the Cleansing Fire network has a unique cryptographic identity based on an Ed25519 keypair. The bootstrap script generates this identity:

```bash
FIRE_CONFIG="$HOME/.cleansing-fire"
NODE_KEY="$FIRE_CONFIG/node.key"
NODE_PUB="$FIRE_CONFIG/node.pub"
NODE_ID_FILE="$FIRE_CONFIG/node.id"

if [ -f "$NODE_KEY" ] && [ -f "$NODE_PUB" ]; then
    log "Node identity already exists"
    NODE_ID="$(cat "$NODE_ID_FILE" 2>/dev/null || echo 'unknown')"
else
    log "Generating Ed25519 keypair..."
    openssl genpkey -algorithm Ed25519 -out "$NODE_KEY" 2>>"$LOG"
    openssl pkey -in "$NODE_KEY" -pubout -out "$NODE_PUB" 2>>"$LOG"
    chmod 600 "$NODE_KEY"
    chmod 644 "$NODE_PUB"

    NODE_ID="fire-$(openssl pkey -in "$NODE_KEY" -pubout -outform DER 2>/dev/null | \
        openssl dgst -sha256 -hex 2>/dev/null | cut -d' ' -f2 | head -c 16)"
    echo "$NODE_ID" > "$NODE_ID_FILE"
fi
```

The node ID is derived from the SHA-256 hash of the DER-encoded public key, truncated to 16 hex characters and prefixed with `fire-`. This produces identifiers like `fire-a3b7c9d2e4f61082` -- human-readable, globally unique, and cryptographically verifiable.

The identity files are stored in `~/.cleansing-fire/`:

```
~/.cleansing-fire/
+-- node.key                    # Ed25519 private key (chmod 600)
+-- node.pub                    # Ed25519 public key (chmod 644)
+-- node.id                     # Short node identifier
+-- bootstrap.log               # Full bootstrap transcript
+-- autonomous-schedule.json    # The node's autonomous task schedule
+-- gatekeeper.log              # Gatekeeper daemon log (if running)
```

The private key (`node.key`) is chmod 600 -- readable only by the owner. It never leaves the local machine. It is used to sign messages in the FireWire federation protocol, proving that a message originated from this specific node.

The public key (`node.pub`) is chmod 644 -- world-readable. It is shared with the network during peer discovery and used by other nodes to verify signed messages.

### 2.7 Phase 5: Local Service Startup

If Ollama is available on the machine, the bootstrap script starts the Gatekeeper daemon:

```bash
if [ "$HAVE_OLLAMA" = true ]; then
    if curl -sf http://127.0.0.1:7800/health >/dev/null 2>&1; then
        log "Gatekeeper daemon: already running"
    else
        log "Starting gatekeeper daemon..."
        nohup python3 "$FIRE_HOME/daemon/gatekeeper.py" \
            >> "$FIRE_CONFIG/gatekeeper.log" 2>&1 &
        sleep 2
        if curl -sf http://127.0.0.1:7800/health >/dev/null 2>&1; then
            log "Gatekeeper daemon: started on port 7800"
        else
            warn "Gatekeeper daemon: failed to start"
        fi
    fi
fi
```

The Gatekeeper (`daemon/gatekeeper.py`) is a lightweight pure-Python HTTP server on port 7800 that serializes access to the local Ollama GPU. It accepts LLM tasks via a REST API, queues them (maximum queue depth: 5), executes them one at a time against Ollama, and returns results. When the queue is full, it rejects new tasks with backpressure -- this prevents GPU contention from degrading the entire system.

**Gatekeeper API:**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/submit` | POST | Submit a task, returns immediately with task ID |
| `/submit-sync` | POST | Submit a task and block until result is ready |
| `/task/{id}` | GET | Poll for task result by ID |
| `/health` | GET | Health check: queue depth, uptime, status |

The Gatekeeper runs `mistral-large:123b` by default but can be configured for any Ollama-supported model via the `--model` flag.

### 2.8 Phase 6: Autonomous Scheduler Configuration

The bootstrap script writes the autonomous operation schedule to `~/.cleansing-fire/autonomous-schedule.json`:

```json
{
  "node_id": "auto",
  "schedule": [
    {"interval": "15m", "task": "news-scan",
     "command": "echo '{\"action\":\"trending\"}' | plugins/news-monitor"},
    {"interval": "1h", "task": "issue-check",
     "command": "gh issue list --assignee=@me --state=open --json number,title"},
    {"interval": "4h", "task": "investigate",
     "command": "scripts/investigate.sh --random"},
    {"interval": "12h", "task": "forge-content",
     "command": "scripts/generate-content.sh"},
    {"interval": "24h", "task": "deep-research",
     "command": "claude -p 'Research a trending power-related topic.'"},
    {"interval": "24h", "task": "self-update",
     "command": "git pull --rebase && scripts/verify-integrity.sh"},
    {"interval": "7d", "task": "weekly-report",
     "command": "claude -p 'Generate a weekly power shift report.'"}
  ],
  "triggers": [
    {"event": "new-legislation", "source": "civic-legiscan",
     "action": "analyze-and-distribute"},
    {"event": "sec-filing", "source": "corp-sec",
     "action": "investigate-entity"},
    {"event": "pr-campaign-detected", "source": "narrative-detector",
     "action": "counter-narrative"},
    {"event": "peer-intelligence", "source": "firewire",
     "action": "cross-reference"},
    {"event": "github-issue-assigned", "source": "github",
     "action": "implement"},
    {"event": "human-query", "source": "claude-cli",
     "action": "respond"}
  ]
}
```

This schedule defines the node's autonomous heartbeat. The actual scheduler (`scheduler/scheduler.py`) uses standard 5-field cron expressions and supports four executor types:

```python
EXECUTORS = {
    "shell": exec_shell,            # Execute a shell command
    "gatekeeper": exec_gatekeeper,  # Submit to local Ollama via Gatekeeper
    "orchestrator": exec_orchestrator,  # Launch Claude Code workers
    "plugin": exec_plugin,          # Execute a plugin (JSON in, JSON out)
}
```

### 2.9 Phase 7: Cloudflare Edge Deployment

If the Wrangler CLI is available and authenticated, the bootstrap script deploys the edge workers:

```bash
if command -v wrangler &>/dev/null; then
    if wrangler whoami &>/dev/null 2>&1; then
        log "Wrangler: authenticated"
        for worker in fire-api fire-ai fire-markdown; do
            WORKER_DIR="$FIRE_HOME/edge/$worker"
            if [ -d "$WORKER_DIR" ]; then
                log "Deploying $worker..."
                (cd "$WORKER_DIR" && wrangler deploy 2>>"$LOG") && \
                    log "$worker: deployed" || \
                    warn "$worker: deployment failed (will retry later)"
            fi
        done
    else
        warn "Wrangler not authenticated. Run 'wrangler login' to deploy."
        info "The node will operate in local-only mode."
    fi
fi
```

Three workers are deployed:

| Worker | Purpose | Cloudflare Bindings |
|--------|---------|---------------------|
| `fire-api` | REST API gateway | D1 (SQLite), KV (cache), R2 (media), Queues |
| `fire-ai` | Edge AI inference | Workers AI (Llama 3.3, embeddings, classification) |
| `fire-markdown` | LLM-accessible proxy | Serves docs as markdown for AI consumption |

These workers run on Cloudflare's global edge -- 300+ locations in 100+ countries. They handle public API access, edge AI inference, content serving, and federation relay communication. See `docs/cloudflare-implementation.md` for the full architecture.

If Cloudflare deployment fails or is skipped, the node operates in local-only mode. All investigation, analysis, and content generation still works -- only global distribution and federation features are affected.

### 2.10 Phase 8: Summary Report

When bootstrap completes, the script presents a comprehensive status report:

```
[FIRE] ============================================
[FIRE]   CLEANSING FIRE NODE BOOTSTRAP COMPLETE
[FIRE] ============================================
[FIRE]
[FIRE] Node ID:        fire-a3b7c9d2e4f61082
[FIRE] Home:           /Users/operator/cleansing-fire
[FIRE] Config:         /Users/operator/.cleansing-fire
[FIRE] Gatekeeper:     running
[FIRE] Ollama:         available
[FIRE] Wrangler:       available
[FIRE] GitHub CLI:     available
[FIRE]
[FIRE] Docs:           25 research documents
[FIRE] Plugins:        15 plugins
[FIRE] Investigations: 3 templates
[FIRE]
[FIRE] To interact:    cd ~/cleansing-fire && claude
[FIRE] To investigate:  claude -p '/investigate [entity name]'
[FIRE] To check status: scripts/node-status.sh
[FIRE]
[FIRE] The fire is lit. This node is operational.
[FIRE] Ignis purgat. Luciditas liberat.
```

The human now has a running node. They can interact with it through the Claude Code CLI, direct investigations, check status, or simply let it operate autonomously.

### 2.11 Bootstrap Sequence Diagram

```
Human Terminal
    |
    | curl fetches ignite.md from GitHub
    v
Claude Code CLI (--dangerously-skip-permissions)
    |
    | Reads ignite.md prompt
    | Understands mission, principles, phases
    v
Phase 0: Clone Repository ---------> ~/cleansing-fire
    |
    | Read CLAUDE.md, philosophy.md, specs/
    v
Phase 1: Dependencies
    |
    | Check: Python3, Git, gh, Node.js, Wrangler, Ollama
    | Install where possible, warn about the rest
    v
Phase 2: Repository Update
    |
    | git pull --rebase (if already cloned)
    | chmod +x on scripts, plugins, bin
    v
Phase 3: Local Configuration
    |
    | Create .env from template (never committed)
    v
Phase 4: Node Identity
    |
    | Generate Ed25519 keypair
    | Derive node ID from public key hash
    | Store in ~/.cleansing-fire/
    v
Phase 5: Local Services
    |
    | Start Gatekeeper daemon (if Ollama available)
    | Verify health endpoint responds
    v
Phase 6: Scheduler
    |
    | Write autonomous-schedule.json
    | Configure cron tasks and event triggers
    v
Phase 7: Edge Deployment
    |
    | Deploy fire-api, fire-ai, fire-markdown
    | (Skipped if Wrangler not available)
    v
Phase 8: Report
    |
    | Display node status, interaction instructions
    v
NODE OPERATIONAL
    |
    +---> Autonomous loop begins
```

---

## 3. THE AUTONOMOUS OPERATION LOOP

### 3.1 The Six-Phase Cycle

Once bootstrapped, a Cleansing Fire node enters its autonomous operation loop. This is not a metaphor. The scheduler daemon literally runs this cycle continuously, driven by cron tasks, event triggers, and the node's own AI-directed investigation priorities.

The cycle, as defined in `bootstrap/ignite.md`:

```
SENSE -----> ANALYZE -----> CREATE -----> DISTRIBUTE -----> IMPROVE -----> REPEAT
  ^                                                                          |
  |                                                                          |
  +--------------------------------------------------------------------------+
```

1. **SENSE**: Monitor news, data feeds, peer intelligence, human directives
2. **ANALYZE**: Cross-reference, investigate, detect patterns, identify power shifts
3. **CREATE**: Generate reports, social content, visualizations, satire, counter-narratives
4. **DISTRIBUTE**: Share intelligence with peers, post content, alert humans
5. **IMPROVE**: Update code, create new plugins, propose new investigations
6. **REPEAT**: The loop never stops. The fire is always burning.

### 3.2 SENSE: Monitor Inputs

The SENSE phase is the node's perceptual system. It continuously monitors multiple data streams for information relevant to civic intelligence.

#### 3.2.1 Scheduled Sensing Tasks

From `scheduler/tasks.json` and the autonomous schedule:

| Task | Schedule | Source | Plugin/Command |
|------|----------|--------|----------------|
| News scan | Every 15 minutes | News APIs | `news-monitor` |
| Health check | Every 5 minutes | Gatekeeper | `curl /health` |
| Git status report | Every 6 hours | Local git | `git status` |
| Legislative scan (privacy) | Monday 8am | LegiScan API | `civic-legiscan` |
| Legislative scan (antitrust) | Tuesday 8am | LegiScan API | `civic-legiscan` |
| Legislative scan (transparency) | Wednesday 8am | LegiScan API | `civic-legiscan` |
| Spending watchdog (defense) | Thursday 9am | USAspending.gov | `civic-spending` |
| Spending watchdog (consulting) | Friday 9am | USAspending.gov | `civic-spending` |
| GitHub issue check | Every hour | GitHub API | `gh issue list` |

The legislative scans track specific keyword sets:

- **Privacy**: surveillance, encryption, privacy, facial recognition, data collection
- **Antitrust**: antitrust, monopoly, merger, competition, market concentration
- **Transparency**: FOIA, transparency, whistleblower, public records, disclosure

#### 3.2.2 Event-Driven Sensing

The scheduler's event system responds to real-time triggers. The `EventSource` base class defines the interface:

```python
class EventSource:
    """Base class for event sources that trigger tasks."""
    def check(self) -> list[dict]:
        """Return list of events if triggered, empty list otherwise."""
        return []
```

Currently implemented:

```python
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
```

Event triggers defined in the autonomous schedule:

| Event | Source | Response Action |
|-------|--------|-----------------|
| New legislation detected | `civic-legiscan` | Analyze and distribute |
| SEC filing by tracked entity | `corp-sec` | Investigate entity |
| PR campaign detected | `narrative-detector` | Generate counter-narrative |
| Peer intelligence received | FireWire protocol | Cross-reference with local data |
| GitHub issue assigned | GitHub API | Launch implementation worker |
| Human query via CLI | Claude Code | Respond directly |

#### 3.2.3 The Sensing Loop Internals

The scheduler runs its main loop every 15 seconds:

```python
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
                    target=self._execute_task, args=(task,),
                    daemon=True,
                ).start()

        # Check event sources
        for source, evt_task in self.events:
            try:
                events = source.check()
                for event in events:
                    merged = {**evt_task, "event_data": event}
                    threading.Thread(
                        target=self._execute_task, args=(merged,),
                        daemon=True,
                    ).start()
            except Exception as e:
                log.error("Event source error: %s", e)

        time.sleep(15)  # check every 15 seconds
```

Each task executes in its own daemon thread, preventing slow tasks from blocking the main loop. Results are logged to `/tmp/cleansing-fire-scheduler/task-results.jsonl` as structured JSON:

```json
{
  "task": "spending-watchdog-defense",
  "type": "plugin",
  "success": true,
  "duration": 3.42,
  "timestamp": "2026-02-28T09:00:03",
  "result": {
    "success": true,
    "output": {"awards": [...], "total": 15234567.89}
  }
}
```

### 3.3 ANALYZE: Cross-Reference and Detect

The ANALYZE phase takes raw data from SENSE and transforms it into actionable intelligence.

#### 3.3.1 The Cross-Reference Engine

The `civic-crossref` plugin is the analytical core. Given an entity name, it queries multiple data sources simultaneously and uses AI analysis to identify correlations:

- **Campaign finance** (FEC): who donated, how much, to which committees
- **Government contracts** (USAspending): what awards, from which agencies, for how much
- **SEC filings**: corporate disclosures, beneficial ownership, insider transactions
- **Lobbying records**: registered lobbyists, expenditures, client relationships
- **Legislative activity**: bills sponsored, votes cast, committee memberships

The cross-reference engine looks for patterns:

- **Money loops**: Corporation A donates to Politician B who awards contracts to Corporation A
- **Revolving doors**: Former regulators now lobbying for the industries they regulated
- **Dark money chains**: Donations through PACs and nonprofits obscuring the original donor
- **Legislative capture**: Bills whose language mirrors lobbyist draft proposals
- **Contract concentration**: Disproportionate spending directed to a small number of contractors

#### 3.3.2 Investigation Selection

When the scheduler triggers the `investigate` task (every 4 hours), the node chooses what to investigate using multiple inputs:

1. **Current news**: Topics from the most recent `news-monitor` scan
2. **Network priorities**: Investigation topics shared by peer nodes via federation
3. **Ongoing investigations**: Entities already under scrutiny needing follow-up
4. **Randomized chaos**: The `--random` flag introduces deliberate randomness, following the project's chaos research methodology (`docs/chaos-research.md`)
5. **Operator directives**: If the human has directed a specific investigation, it takes priority

**Differential Solidarity** (Principle 7) applies here: investigations are weighted toward topics that affect the most vulnerable communities. A bill restricting voting access in a low-income district receives higher priority than a regulatory tweak affecting Fortune 500 tax planning.

### 3.4 CREATE: Generate Content

The CREATE phase transforms analysis into compelling, human-accessible content. This is where the Forge operates.

#### 3.4.1 The Forge: Vision (forge-vision)

Generates visual content from data:

| Action | Input | Output |
|--------|-------|--------|
| `money_flow` | Flow data `{from, to, amount}` | SVG Sankey diagram |
| `power_network` | Network graph data | SVG network visualization |
| `timeline` | Dated events | SVG chronological timeline |
| `corruption_meter` | Score (0-10) | SVG gauge visualization |
| `ascii_fire` | Text string | ASCII art with fire aesthetic |
| `mermaid` | Description text | Mermaid.js diagram (via LLM) |
| `prompt` | Concept text | Image generation prompt for FLUX/SD |

All visualizations use the Cleansing Fire visual language: dark backgrounds (#0a0a0a), fire gradient colors (#ff4400 to #ffcc00), Courier New monospace typography, glow effects on key elements. Designed to be immediately recognizable and shareable on social media.

#### 3.4.2 The Forge: Voice (forge-voice)

Generates narrative content under the `PYRRHIC_LUCIDITY_VOICE` system prompt:

```python
PYRRHIC_LUCIDITY_VOICE = """You are the voice of the Cleansing Fire project,
operating under Pyrrhic Lucidity.

Core voice principles:
- Never claim purity. We are compromised. Say so.
- Name specific mechanisms, not vague evils.
- Always include what the reader/listener can DO
- Use fire metaphors naturally
- Mix registers: street and scholarly in the same breath
- The enemy is opacity, not people
- Acknowledge the cost of seeing clearly
- End with invitation, not despair. The fire is already lit. Join or watch."""
```

Content types and tonal variations:

| Action | Platforms | Tones Available |
|--------|-----------|----------------|
| `social` | Mastodon (500 char), Bluesky (300 char) | urgent, analytical, poetic, sardonic, invitational, furious |
| `thread` | Mastodon, Bluesky | Narrative arc across 8-10 posts |
| `digest` | Newsletter (1000 words) | Weekly summary format |
| `poeticize` | Any | haiku, sonnet, prose poem, free verse, spoken word |
| `agitprop` | Multiple audiences | general, youth, workers, elders, technical |

A single investigation produces dozens of content pieces: urgent alerts, sardonic observations, analytical summaries, investigation threads, spoken word poems, and audience-specific agitprop. Different audiences respond to different registers. The system generates for all of them.

#### 3.4.3 The Full Pipeline (pipeline-data-to-fire)

The `pipeline-data-to-fire` plugin chains everything together. Three actions:

**`full_investigation`**: Complete investigation of an entity

```python
def full_investigation(target):
    # Phase 1: Data Collection (civic-crossref)
    crossref = call_plugin("civic-crossref", {
        "action": "investigate", "entity": target,
    })

    # Phase 2: Visualization (forge-vision)
    money_svg = call_plugin("forge-vision", {
        "action": "money_flow", "data": {"flows": flows},
    })
    corruption_svg = call_plugin("forge-vision", {
        "action": "corruption_meter", "score": 6.5,
    })

    # Phase 3: Narrative Generation (forge-voice)
    for platform in ["mastodon", "bluesky"]:
        for tone in ["urgent", "sardonic", "analytical"]:
            post = call_plugin("forge-voice", {
                "action": "social", "platform": platform, "tone": tone,
                "data": {...},
            })

    thread = call_plugin("forge-voice", {
        "action": "thread", "topic": f"Investigation: {target}",
    })

    poem = call_plugin("forge-voice", {
        "action": "poeticize", "raw_data": "...", "form": "spoken",
    })

    # Phase 4: Package everything
    save_output(f"{target}-full-investigation", package)
```

**`bill_spotlight`**: Complete content package for a single legislative bill

**`weekly_fire`**: Digest of all tracked topics across a week, including a newsletter and a haiku sequence distilling the week's data into three images

### 3.5 DISTRIBUTE: Share and Publish

The DISTRIBUTE phase takes completed content packages and sends them into the world.

#### 3.5.1 Social Media Distribution

| Platform | Protocol | Character Limit | Content Types |
|----------|----------|----------------|---------------|
| Mastodon | ActivityPub | 500 | Posts, threads, media attachments |
| Bluesky | AT Protocol | 300 | Posts, threads, media |
| Matrix | Matrix Protocol | 4000 | Messages, encrypted rooms, media |

**Adversarial Collaboration** (Principle 4) applies to content distribution: the system does not post only content that flatters one political faction. If an investigation reveals corruption in any direction, that gets posted. The system's loyalty is to transparency, not to any ideology.

#### 3.5.2 Peer Distribution (via FireWire)

Content packages are shared with connected nodes via the FireWire gossip protocol. Each node pushes new intelligence to its 5-10 direct peers, who propagate it to their peers, achieving full network coverage in O(log N) hops. Content is content-addressed (retrievable by hash) and cryptographically signed (verifiable origin).

#### 3.5.3 Edge Distribution (via Cloudflare)

Content is pushed to the node's Cloudflare Workers for global edge serving:
- Investigation reports cached in D1 (SQLite at the edge)
- SVG visualizations stored in R2 (object storage, zero egress fees)
- Content indexed in Vectorize for semantic search
- Served via fire-api at the nearest of 300+ edge locations worldwide

### 3.6 IMPROVE: Self-Modification

The IMPROVE phase is covered in depth in Section 7. In summary: nodes pull the latest code daily, verify integrity of protected files, create GitHub issues for improvements they identify, and can implement those improvements through the worker orchestrator's implementation-review-merge cycle.

### 3.7 REPEAT: The Perpetual Loop

The loop never stops. As long as the machine is running, the node is sensing new data every 15 seconds (scheduler main loop), analyzing patterns, creating content on schedule, distributing through all available channels, and improving itself incrementally.

There is no "idle" state. There is no "done."

This is by design. The systems of concentrated power that the project opposes never rest. Lobbying is 24/7. Legislative capture is continuous. Corporate influence operations run without pause. A civic intelligence system that operates only when a human remembers to check on it is structurally outmatched. Autonomous operation is not a convenience feature -- it is a prerequisite for effectiveness.

---

## 4. NODE ARCHITECTURE

### 4.1 What a Running Node Looks Like

A fully operational node consists of local processes on the operator's hardware, edge services on Cloudflare's global network, and connections to peer nodes via federation.

```
+------------------------------------------------------------------+
|                      LOCAL MACHINE                                |
|                                                                   |
|  +--------------------+    +--------------------------+           |
|  |   Claude Code CLI  |    |    Scheduler Daemon      |           |
|  |   (human interface)|    |    scheduler.py          |           |
|  +--------+-----------+    +---+-------+---------+----+           |
|           |                    |       |         |                |
|           |              +----v--+ +--v----+ +--v--------+       |
|           |              |Plugins| |Workers| |Gatekeeper |       |
|           |              |15 exec| |orchest| |port:7800  |       |
|           |              +---+---+ +---+---+ +-----+-----+       |
|           |                  |         |           |              |
|           |                  |    +----v----+  +---v---+          |
|           |                  |    |Git      |  |Ollama |          |
|           |                  |    |Worktrees|  |GPU LLM|          |
|           |                  |    +---------+  +-------+          |
+------------------------------------------------------------------+
            |                  |
            v                  v
+------------------------------------------------------------------+
|                    CLOUDFLARE EDGE (300+ locations)                |
|                                                                   |
|  +----------+  +---------+  +----------+  +---------+            |
|  | fire-api |  | fire-ai |  |fire-mark |  |Durable  |            |
|  | REST API |  | Workers |  |down prxy |  |Objects  |            |
|  +----+-----+  +----+----+  +----------+  +----+----+            |
|       |              |                          |                 |
|  +----v---+ +---v---+ +------+ +--------+ +---v------+          |
|  |   D1   | |  KV   | |  R2  | |Vectorize| | Queues  |          |
|  | SQLite | | Cache | |Object| | Search  | | Async   |          |
|  +--------+ +-------+ +------+ +---------+ +---------+          |
+------------------------------------------------------------------+
            |
            v
+------------------------------------------------------------------+
|                    FEDERATION NETWORK                              |
|  +--------+    +--------+    +--------+    +--------+            |
|  | Node B |<-->| Node C |<-->| Node D |<-->| Node E |            |
|  +--------+    +--------+    +--------+    +--------+            |
+------------------------------------------------------------------+
```

### 4.2 Local Services in Detail

#### 4.2.1 The Scheduler Daemon

The scheduler (`scheduler/scheduler.py`) is the heartbeat. Pure Python, stdlib only. Its capabilities:

1. Reads task definitions from `scheduler/tasks.json`
2. Evaluates cron expressions every 15 seconds
3. Fires matching tasks in daemon threads
4. Monitors event sources (file watchers, webhook receivers)
5. Logs all results to structured JSONL files
6. Supports task chaining via `on_success` and `on_failure` hooks

The cron parser supports standard 5-field expressions:

```
*     *     *     *     *
|     |     |     |     +--- day of week (0-6, Monday=0)
|     |     |     +--------- month (1-12)
|     |     +--------------- day of month (1-31)
|     +--------------------- hour (0-23)
+--------------------------- minute (0-59)

Supported patterns: *, */N, N, N-M, N,M,O
```

#### 4.2.2 The Gatekeeper Daemon

Architecture:

```
Plugin/Task Request
    |  HTTP POST to :7800/submit-sync
    v
+-------------------------------+
|         Gatekeeper            |
|  +--------+  +------------+  |
|  | Queue  |->| Worker     |  |
|  | (max 5)|  | Thread     |  |
|  +--------+  +------+-----+  |
|                     |         |
|               +-----v------+  |
|               | Ollama API |  |
|               | :11434     |  |
|               +------------+  |
|  +-------------------------+  |
|  | Task History (last 100) |  |
|  +-------------------------+  |
+-------------------------------+
```

Design decisions:
- **Single worker thread**: GPU inference is inherently serial
- **Short queue (5)**: Backpressure, not buffering
- **Synchronous option**: `/submit-sync` blocks until result, simplifying plugin code
- **Caller identification**: Every submission includes a `caller` field for audit

#### 4.2.3 The Worker Orchestrator

The orchestrator (`workers/orchestrator.sh`) bridges the scheduler with Claude Code:

```bash
# Three commands:
workers/orchestrator.sh implement "Title" "Description"
workers/orchestrator.sh review <pr-number>
workers/orchestrator.sh status
```

Implementation workers launch Claude Code in headless mode within isolated git worktrees. Review workers run in plan-only mode (they cannot edit files). The separation is architectural, not advisory.

### 4.3 The Plugin System

Plugins follow a strict convention:

1. Self-contained executables in `plugins/`
2. JSON on stdin for input
3. JSON on stdout for output
4. Exit code 0 for success, non-zero for failure
5. `CF_PROJECT_DIR` environment variable for project root

The 15 current plugins:

| Plugin | Category | Purpose |
|--------|----------|---------|
| `civic-legiscan` | Civic Data | Bill tracking across all 50 states + Congress |
| `civic-fec` | Civic Data | Campaign finance, donor tracking |
| `civic-spending` | Civic Data | Federal contracts, grants, awards |
| `civic-crossref` | Civic Data | Cross-reference correlation engine |
| `corp-sec` | Corporate | SEC filings, beneficial ownership |
| `lobby-tracker` | Corporate | Lobbyist registrations, expenditures |
| `news-monitor` | Intelligence | Trending topics, breaking news |
| `narrative-detector` | Intelligence | PR campaign and propaganda detection |
| `osint-social` | Intelligence | Open-source social intelligence |
| `whistleblower-submit` | Submissions | Secure whistleblower tip intake |
| `forge-vision` | Content | SVG visualizations, Mermaid diagrams |
| `forge-voice` | Content | Social posts, newsletters, poetry, agitprop |
| `pipeline-data-to-fire` | Pipeline | End-to-end investigation pipeline |
| `example-summarize` | Template | Example plugin for creating new ones |

### 4.4 Edge Services

Summary of Cloudflare Workers (see `docs/cloudflare-implementation.md` for full detail):

**fire-api**: REST gateway with D1 (structured civic data), KV (cache, config), R2 (media assets, SVGs, PDFs), and Queues (async task dispatch).

**fire-ai**: Edge AI inference using Workers AI models -- Llama 3.3 70B for analysis, BGE-M3 for multilingual embeddings, Llama Guard 3 for content safety classification. Runs at 200+ edge cities.

**fire-markdown**: LLM-accessible proxy serving documentation as clean markdown for AI agent consumption.

---

## 5. THE CONTENT PIPELINE

### 5.1 Pipeline Architecture

```
RAW DATA SOURCES                    CONTENT FORGE
+-- LegiScan (bills, votes)         +-- forge-vision (SVGs, diagrams)
+-- FEC (donations, PACs)           +-- forge-voice (posts, threads, poetry)
+-- USAspending (contracts)         +-- (planned) forge-video
+-- SEC EDGAR (filings)             +-- (planned) forge-audio
+-- Lobbying databases
+-- News feeds                             |
+-- Peer intelligence                      v
+-- Whistleblower tips              DISTRIBUTION CHANNELS
        |                           +-- Mastodon (ActivityPub)
        v                           +-- Bluesky (AT Protocol)
INVESTIGATION ENGINE                +-- Matrix (encrypted)
+-- civic-crossref: correlate       +-- Newsletters (email)
+-- AI analysis: patterns           +-- Edge API (global CDN)
+-- Evidence: sources, data         +-- Peer nodes (federation)
                                    +-- GitHub Pages (archive)
```

### 5.2 The Weekly Fire

Every 7 days, the node generates a comprehensive digest:

```python
def weekly_fire(topics):
    # Scan legislation across all topics
    all_bills = []
    for topic in topics:
        scan = call_plugin("civic-legiscan", {
            "action": "monitor", "keywords": [topic],
        })
        if scan.get("bills"):
            all_bills.extend(scan["bills"][:5])

    # Generate newsletter digest
    digest = call_plugin("forge-voice", {
        "action": "digest", "items": items, "period": "weekly",
    })

    # Generate haiku sequence from the week's data
    haiku = call_plugin("forge-voice", {
        "action": "poeticize",
        "raw_data": f"This week: {len(all_bills)} bills tracked...",
        "form": "haiku",
    })
```

The weekly digest format:
1. Opening context (Pyrrhic Lucidity voice)
2. Top stories with power dynamics analysis
3. Data point of the week (one striking number)
4. What you can do (3 concrete actions)
5. Closing (poetic, invitational)
6. Haiku sequence distilling the week into images

### 5.3 Planned Content Extensions

**forge-video** (in progress): Short-form video for social platforms. Script generation from investigation data, SVG visualization frames, text-to-speech narration via Cloudflare Workers AI (Deepgram Aura 2, MeloTTS), 30-60 second assembly with automatic subtitling.

**forge-audio** (planned): Podcast segments. Daily 5-minute briefings from investigation summaries, legislative alerts, data highlights, and spoken word interludes.

**Multilingual content** (planned): Using Workers AI multilingual models (GLM-4.7-Flash for 131K context, BGE-M3 for 100+ language embeddings), content generated in any language. A node in Mexico City generates in Spanish. A node in Berlin generates in German. Same investigation data, localized.

---

## 6. NETWORK TOPOLOGY

### 6.1 FireWire Federation Protocol

Nodes connect to each other via FireWire, a federation protocol designed for autonomous civic intelligence coordination (see `docs/federation-protocol.md` for the full 1829-line specification).

FireWire is built on three primitives:

1. **Signed Append-Only Logs** (from SSB/Hypercore): Every node maintains an immutable, cryptographically signed sequence of events -- the source of truth for identity, claims, and contributions.

2. **Content-Addressed Intelligence Objects** (from IPFS): Civic data stored as content-addressed objects, retrievable by hash from any node that has them. Content is not tied to location.

3. **Gossip-Based Propagation** (from SSB/libp2p GossipSub): Information spreads through the network via gossip, with no central broker.

On top of these, FireWire adds:

4. **Agent Capability Cards** (adapted from A2A/MCP): Machine-readable advertisements of what a node can do
5. **Task Coordination Protocol**: Distributed task negotiation and execution
6. **Trust Substrate**: Web-of-trust with contextual, decaying reputation
7. **Governance Mesh**: Rough consensus with mandatory dissent channels

### 6.2 Node Types

From the federation protocol specification:

| Type | Description | Capabilities | Constraints |
|------|-------------|-------------|-------------|
| **Human Node** | Human operator with FireWire software | Observations, investigations, governance votes, trust vouching | Lower throughput, intermittent |
| **Agent Node** | Autonomous AI agent | Continuous monitoring, automated analysis, high-throughput data processing | Must be sponsored by human, must expose reasoning chains |
| **Hybrid Node** | Human + AI operating together | Full capabilities of both | Expected mode for Cleansing Fire instances |

No type has more governance rights or inherent trust than any other. Types describe capability, not authority.

### 6.3 Discovery Process

When a new node comes online:

```
New Node
    |
    | POST identity + capabilities to known discovery relays
    | (Cloudflare Workers serving as relay endpoints)
    v
Discovery Relay
    |
    | Returns list of active peers
    | (public keys, capabilities, last-seen timestamps)
    v
New Node
    |
    | Connects to 5-10 initial peers
    | Exchanges capability advertisements (Agent Cards)
    v
Peer Nodes
    |
    | Gossip propagation announces new node
    | Network graph stabilizes
    v
Network Connected
```

Discovery relays are Cloudflare Workers -- convenience services, not authorities. If all relays go down, nodes can connect directly by exchanging public keys through any out-of-band channel.

### 6.4 Network Mesh

Each node maintains connections to 5-10 peers, forming a dense mesh:

```
         +---+
    +----| A |----+
    |    +---+    |
    |      |      |
  +-+-+  +-+-+  +-+-+
  | B |  | C |  | D |
  +-+-+  +-+-+  +-+-+
    |      |      |
    |    +-+-+    |
    +----| E |----+
         +-+-+
           |
         +-+-+
         | F |
         +---+
```

Multiple paths between every pair of nodes. The network can lose nodes without losing connectivity. This is **Unstoppability Through Distribution** (from `docs/global-architecture.md`).

### 6.5 Intelligence Sharing

When a node completes an investigation, it shares results via a FireWire intelligence object:

```json
{
  "type": "intelligence_object",
  "version": "1.0",
  "id": "sha256:a3b7c9d2e4f610824f8a9b3c7d2e4f61",
  "author": "fire-a3b7c9d2e4f61082",
  "timestamp": "2026-02-28T14:30:00Z",
  "category": "investigation",
  "target": "Palantir Technologies",
  "summary": "Cross-reference: $2.8B federal contracts vs campaign finance",
  "content_hash": "sha256:...",
  "sources": ["fec", "usaspending", "sec", "legiscan"],
  "signature": "ed25519:..."
}
```

Receiving nodes: verify signature, check for duplicates (content-addressed), store locally, propagate to their peers (gossip), optionally extend with their own analysis.

### 6.6 Task Coordination

Nodes coordinate on distributed tasks to avoid duplication:

```
Node A: "I'm investigating Palantir contracts"
    |  (FireWire task advertisement)
    v
Node B: "I'll cover their lobbying data instead"
Node C: "I'll analyze their SEC filings"
Node D: "I'll generate content for Spanish-speaking audiences"
```

The protocol ensures that:
- Multiple nodes do not run the same investigation simultaneously
- Complementary tasks are distributed across capable nodes
- Results are shared back for integration
- Failed tasks are picked up by other nodes

### 6.7 Gossip Propagation

Modified GossipSub model:

1. **Eager push**: New intelligence immediately pushed to all connected peers
2. **Lazy pull**: Periodically, nodes compare content inventories and request missing items
3. **Fanout**: Each node pushes to 5-10 direct peers; full coverage in O(log N) hops
4. **Deduplication**: Content-addressed storage naturally skips duplicates

### 6.8 Offline Behavior

When a node goes offline:

1. Peers detect absence via failed heartbeats (30-second intervals)
2. Peer lists updated to mark node as offline
3. No data is lost -- content replicated across multiple nodes
4. Tasks reassigned to other capable nodes
5. When the node returns, lazy pull catches up on missed intelligence

The network does not depend on any single node. If hardware is seized, only that node's private key and locally cached data are exposed -- not the keys or data of other nodes.

---

## 7. SELF-IMPROVEMENT

### 7.1 The Recursive Self-Modification Loop

Cleansing Fire nodes are not static deployments. They are designed to improve themselves over time.

```
1. DETECT ---> 2. PROPOSE ---> 3. IMPLEMENT ---> 4. REVIEW
   (errors,        (GitHub        (worker in        (separate
   gaps,           issue)         isolated          worker,
   peer caps)                     worktree)         never the
                                                    implementer)
      ^                                                |
      |           6. VERIFY <--- 5. MERGE <--------+
      |           (integrity     (orchestrator,
      |           check,         after approval)
      |           health)
      |               |
      +---------------+
```

### 7.2 What Triggers Self-Improvement

**Error pattern detection**: When a task fails repeatedly (3+ consecutive failures), the pattern triggers investigation and potential code fix.

**Capability gaps**: During investigation, encountering a data source without a matching plugin generates an issue proposing the new plugin.

**Peer capabilities**: Via federation, learning that peers have capabilities this node lacks.

### 7.3 Self-Update from Git

Every 24 hours:

```bash
git pull --rebase && scripts/verify-integrity.sh
```

The integrity verification checks SHA-256 hashes of protected files against `integrity-manifest.json`:

- `CLAUDE.md` (project constitution)
- `philosophy.md` (Pyrrhic Lucidity framework)
- `specs/agent-capabilities.yaml` (safety boundaries)
- `specs/goals.yaml` (goal hierarchy)

If any protected file's hash does not match, the update is rolled back and an alert is generated. This protects the node's philosophical and safety core from corruption through the git update channel.

### 7.4 The Implementation-Review-Merge Cycle

```
Orchestrator (Claude Opus 4.6)
    |
    | gh issue create -> Issue #47
    | workers/orchestrator.sh implement "Add retry logic" "..."
    v
Implementation Worker (Opus 4.6, isolated worktree)
    |
    | Reads CLAUDE.md, creates branch cf/47-add-retry-logic
    | Writes code, runs tests, creates PR
    v
Review Worker (separate Opus 4.6 instance)
    |
    | Reads PR diff, checks correctness/security/style
    | Approves or requests changes (NEVER fixes code)
    v
(If changes requested) Fix Worker ---> push updates ---> re-review
    v
Orchestrator merges PR, verifies deployments
    v
Next self-update cycle picks up the change
```

The separation of roles is absolute: implementation workers never review their own code, review workers never fix code, and only the orchestrator merges. This is enforced by `specs/agent-capabilities.yaml`.

### 7.5 Safety Constraints on Self-Modification

1. **Protected files**: Philosophy, safety boundaries, and integrity manifest cannot be modified through the autonomous loop. Human approval required.
2. **Integrity verification**: Every self-update checks file hashes.
3. **Role separation**: Writer, reviewer, and merger are always separate AI instances.
4. **Audit trail**: Every change goes through a GitHub PR with full diff and review history.
5. **The Cost Heuristic**: If a self-improvement costs nothing (trivial, no review), it is structurally suspect.

---

## 8. HUMAN INTERACTION POINTS

### 8.1 The Teaching Function

A Cleansing Fire node is autonomous but not opaque. Every interaction between a human and the node is an opportunity for the human to learn -- about the system, about civic data, about power structures, about what the node is discovering.

This is **Lucidity Before Liberation** (Principle 1): the system helps humans see clearly before it asks them to act.

### 8.2 The Claude Code CLI Interface

The primary human interface. After bootstrap:

```bash
cd ~/cleansing-fire && claude
```

Claude reads `CLAUDE.md`, understands the project, and can guide the human through any operation.

#### 8.2.1 Directing Investigations

```
Human: investigate Lockheed Martin
Claude: I'll run a full investigation on Lockheed Martin...
        [runs pipeline-data-to-fire with target "Lockheed Martin"]
        [generates visualizations, social posts, analysis]
        [presents findings and asks what to do with them]
```

#### 8.2.2 Checking Node Status

```
Human: what's my node doing right now?
Claude: Node fire-a3b7c9d2e4f61082 status:
        - Gatekeeper: running (3 tasks in queue)
        - Last news scan: 12 minutes ago (3 items flagged)
        - Last investigation: "Boeing defense contracts" (4 hours ago)
        - Next scheduled task: legislative-scan-privacy (Monday 8am)
        - Content queue: 7 posts pending distribution
        - Network peers: 4 connected, 2 offline
```

#### 8.2.3 Reviewing Generated Content

```
Human: show me the content queue
Claude: Here are the 7 pending posts:
        1. [Mastodon/urgent] "Boeing received $12.3B in..."
        2. [Bluesky/sardonic] "Nothing says 'free market'..."
        3. [Mastodon/analytical] "A cross-reference of..."
        [asks which to approve, edit, or discard]
```

#### 8.2.4 Pausing and Resuming

```
Human: pause autonomous operation
Claude: Stopping scheduler...
        Autonomous operation paused.
        I'll still respond to your queries.
        Say "resume" to restart autonomous operation.
```

#### 8.2.5 Learning About Power

```
Human: explain what dark money is
Claude: [draws from project research documents]
        Dark money refers to political spending by nonprofits
        that are not required to disclose their donors...
        [explains mechanisms, gives examples from project data]
        [shows what the node has found about dark money patterns]