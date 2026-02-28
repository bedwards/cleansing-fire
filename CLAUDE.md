# Cleansing Fire

## Project Philosophy: Pyrrhic Lucidity

A philosophy of contested liberation for the age of systemic capture. See `philosophy.md` for the full framework. Key principles:

1. **Lucidity Before Liberation** - see clearly before acting, including your own distortions
2. **Relational Agency** - the unit of action is relationship patterns, not sovereign individuals
3. **Transparent Mechanism** - legitimacy requires visible, comprehensible, alterable mechanisms
4. **Adversarial Collaboration** - groups that cannot tolerate structured dissent are already captured
5. **Minimum Viable Coercion** - necessary sometimes, always corrupting, faces continuous minimization
6. **Recursive Accountability** - liberators face accountability at least as rigorous as what they impose
7. **Differential Solidarity** - weight toward the most exposed without essentializing identity

## Project Mission

Build decentralized, autonomous technology that shifts power from corrupt concentrated authority toward the people. Not a platform — a protocol. Not a movement — an infrastructure. Designed for massive scale adoption worldwide, agent-first but human-accessible.

**Power lives outside government now.** The primary targets are corporate power, private equity, tech platforms, media conglomerates, dark money networks, and the opacity mechanisms that protect them. Government is one vector, not the main one.

## The Human Interface: Claude Code CLI

Claude Code CLI is the human interface to this system. Humans learn to use Claude Code, and Claude handles the complexity from there — setting up infrastructure, running investigations, generating content, coordinating agents. The system teaches humans as they use it.

- Humans interact through `claude` CLI (Claude Code)
- Claude Opus 4.6 is the orchestrator brain
- The system bootstraps itself: `claude` reads CLAUDE.md, understands the project, guides the human
- Other Claude instances can extend and fork — but the core must be protected from corruption

## Architecture

### Core Infrastructure
- **Gatekeeper Daemon** (`daemon/gatekeeper.py`) - HTTP server on port 7800 that serializes GPU access to local Ollama. Short queue (5), rejects on overflow. Endpoints: POST /submit, POST /submit-sync, GET /task/{id}, GET /health
- **FireWire Daemon** (`daemon/firewire.py`, 1124 lines) - Federation protocol daemon on port 7801. Ed25519 message signing, gossip propagation, append-only log, intelligence sharing, task coordination, peer discovery. Pure stdlib Python.
- **Scheduler** (`scheduler/scheduler.py`, 533 lines) - Autonomous operation loop: 25 tasks across 6 categories (sense/analyze/create/distribute/improve/system). Claude Code executor, HTTP poll events, status API on port 7802. The SENSE->ANALYZE->CREATE->DISTRIBUTE->IMPROVE->REPEAT cycle.
- **CLI Client** (`bin/fire-ask`) - Command-line interface to gatekeeper
- **Encrypted Messaging** (`bin/fire-message`, 823 lines) - Node-to-node encrypted messaging CLI. Ed25519 signing, AES-256-CBC encryption, send/inbox/read/peers/broadcast/threads. Relays via FireWire.
- **Worker Orchestrator** (`workers/orchestrator.sh`) - Launches Claude Code workers in git worktrees
- **Plugin System** (`plugins/`, 17 plugins) - Executable scripts that accept JSON stdin, produce JSON stdout

### Intelligence & Exposure
- **OSINT Pipeline** - Automated open-source intelligence collection
- **Corporate Power Mapping** - SEC EDGAR, OpenCorporates, LittleSis, beneficial ownership chains
- **Civic Data Pipeline** - LegiScan, FEC, USAspending, cross-referencing corruption detector
- **Whistleblower Infrastructure** - SecureDrop-style secure submission (planned)

### The Forge (Content Generation)
- **forge-vision** - SVG visualizations, ASCII art, Mermaid diagrams, image prompts
- **forge-voice** - Social posts, threads, newsletters, poetry, agitprop, satire
- **Satire Engine** - Parody generator, corporate doublespeak translator, meme generation
- **pipeline-data-to-fire** - Full pipeline: data → analysis → visualization → narrative → distribution

### Dual Documentation
- **Human docs** (`docs/`) - Narrative, philosophical, motivational, visual (GitHub Pages)
- **AI docs** (`specs/`) - Machine-parseable specs, schemas, decision trees, goal hierarchies
- Both must be maintained — never let one drift from the other

### Economics
- **The Ember Economy** (`docs/economics.md`) - Decentralized economic model with demurrage currency at 3 scales, commons protocol, production mesh, structural redistribution cycles

## Workflow

### For Humans
1. Install Claude Code CLI (`curl -fsSL https://cli.claude.ai/install.sh | sh`)
2. Get Anthropic API key — **$200/month Max plan recommended** for Claude Opus 4.6 throughput
3. Clone this repo: `git clone https://github.com/bedwards/cleansing-fire.git`
4. Run `claude` in the project directory — it reads this file and bootstraps
5. Tell Claude what you want to investigate, build, or learn
6. Claude handles infrastructure, plugins, agents, coordination

### For AI Agents — The Definitive Development Loop

**All work follows this exact cycle:**

1. **GitHub Issue** — every piece of work starts as an issue with labels
2. **Implementation Worker** (Claude Opus 4.6, git worktree)
   - Creates feature branch: `cf/<issue>-<description>`
   - Implements the work in isolated worktree
   - Creates a Pull Request referencing the issue
3. **Review Worker** (separate Opus 4.6 instance, own worktree)
   - Reviews the PR thoroughly
   - **NEVER fixes code** — only reviews and comments
4. **Fix Worker** (separate instance, if review finds issues)
   - Reads review comments, makes fixes on the feature branch
   - Pushes updates, iterates until review worker approves
5. **Orchestrator verifies**
   - Resolves merge conflicts
   - Merges PR to main
   - Verifies main branch is clean
   - Verifies all deployments are green (GitHub Pages + Cloudflare Workers)
6. **Close the issue**

### Key Rules
- Workers are **ALWAYS Claude Opus 4.6** (`claude-opus-4-6`)
- Workers **ALWAYS use git worktrees** for isolation
- Implementation, review, and fix are **ALWAYS separate workers**
- Review workers **NEVER fix code**
- Only the orchestrator merges to main
- **Commit and push often**

### Key Models
- **Claude Opus 4.6** — all workers, orchestration, research, planning, writing, review
- **Ollama local models** — lightweight text tasks via gatekeeper (mistral-large:123b default)

### Deployments
- **GitHub Pages** (docs/ folder on main branch) — the public website
- **Cloudflare Workers** (workers/ via GitHub Actions + wrangler) — API, AI inference, search, federation relay
- Both must be verified green after every merge

## Development Conventions

### Git Workflow
- `main` branch is always stable (GitHub Pages source + deployment trigger)
- Feature branches: `cf/<issue-number>-<short-description>`
- All work goes through PRs with the review/fix cycle
- **Commit and push often**

### Code Standards
- Python 3.9+ (stdlib only where possible, minimize dependencies)
- Shell scripts use `set -euo pipefail`
- Plugins are self-contained executables
- All services are pure stdlib Python (no frameworks)

### File Structure
```
cleansing-fire/
├── CLAUDE.md              # This file - project constitution for Claude
├── LICENSE                # AGPL-3.0
├── philosophy.md          # Pyrrhic Lucidity framework (956 lines)
├── integrity-manifest.json # SHA-256 hashes of protected files
├── .claude/               # Claude Code configuration
│   ├── settings.json      # Project settings + permissions
│   └── hooks/             # Safety hooks (block-destructive, protect-env, etc.)
├── .github/workflows/     # GitHub Actions (Cloudflare deployment)
├── daemon/                # Gatekeeper (7800), FireWire (7801), launchd plists
├── scheduler/             # Autonomous operation loop (25 tasks, status API on 7802)
├── workers/               # Worker orchestration
├── plugins/               # Plugin executables (JSON stdin/stdout)
│   ├── civic-*            # Government/civic data plugins
│   ├── forge-*            # Content generation plugins
│   └── pipeline-*         # Multi-plugin pipelines
├── scripts/               # Management and automation scripts (12 scripts)
├── bin/                   # CLI tools (fire-ask, fire-message)
├── edge/                  # Cloudflare Workers
│   ├── fire-api/          # REST API gateway
│   └── fire-ai/           # Workers AI inference
├── docs/                  # Human documentation + GitHub Pages
│   ├── index.html         # Split landing page (human + AI)
│   ├── humans.html        # Human portal (chat, TTS, accessibility)
│   ├── agents.html        # AI agent portal (bootstrap, specs, workflow)
│   └── *.md               # 26 research documents
└── specs/                 # AI-readable specifications
    ├── project-graph.yaml
    ├── plugin-schema.json
    ├── agent-capabilities.yaml
    └── goals.yaml
```

### Running Services
```bash
# Start all daemons
scripts/gatekeeper-ctl.sh start    # Ollama gatekeeper on :7800
scripts/firewire-ctl.sh start     # Federation daemon on :7801
scripts/scheduler-ctl.sh start    # Autonomous scheduler on :7802

# Or bootstrap everything at once
bootstrap/setup-node.sh

# Scheduler control
scripts/scheduler-ctl.sh status   # Show stats and active tasks
scripts/scheduler-ctl.sh tasks    # List all 25 configured tasks
scripts/scheduler-ctl.sh results  # Recent task execution results
scripts/scheduler-ctl.sh reload   # Reload tasks.json without restart

# FireWire control
scripts/firewire-ctl.sh peers     # Show connected peers
scripts/firewire-ctl.sh announce <address>  # Connect to a peer

# Test gatekeeper
bin/fire-ask --status
bin/fire-ask --sync "test prompt"

# Encrypted messaging
bin/fire-message send fire-abc123 "Hello from the network"
bin/fire-message inbox
bin/fire-message peers
bin/fire-message broadcast "Network alert: new intelligence available"

# Launch workers
workers/orchestrator.sh implement "Task title" "Description"
workers/orchestrator.sh review <pr-number>
```

## Fork Protection

This project is designed to be forked and extended by other Claude instances and human contributors. But the core philosophical framework and ethical constraints must not be corrupted:

- **Integrity checks**: The 7 Principles of Pyrrhic Lucidity are the constitution
- **Recursive accountability**: Any fork that exempts itself from scrutiny has already failed
- **Transparency requirement**: No fork can be legitimate if it operates in opacity
- **The cost heuristic**: If a change costs nothing to the actor, it is structurally suspect

## The Cost Heuristic (from Pyrrhic Lucidity)

When evaluating any action, feature, or decision: if it costs nothing to the actor, it is structurally suspect. Genuine alignment with this project's values will be uncomfortable, will challenge assumptions, and will impose real costs. If it's easy, it's probably not real.

## Edge Infrastructure (Cloudflare Workers)

Separate from GitHub Pages — these handle compute, API, and AI inference at the edge.

- **fire-api** (`edge/fire-api/`) - REST gateway for investigations, queries (D1, KV, R2, Queue bindings)
- **fire-ai** (`edge/fire-ai/`) - Workers AI inference: analysis, embeddings, summarization, classification
- **fire-markdown** (`edge/fire-markdown/`) - LLM-accessible markdown proxy (Accept: text/markdown header)
- **fire-relay** (`edge/fire-relay/`) - Federation bootstrap relay: node registration, peer discovery, intelligence relay. KV + D1.
- Deployed via `.github/workflows/deploy-workers.yml` using wrangler (4 workers)
- See `docs/cloudflare-implementation.md` for full architecture and cost analysis

## Key Research Documents
- `philosophy.md` - Pyrrhic Lucidity (956 lines)
- `docs/justified-resistance.md` - The Calculus of Necessary Transgression (2305 lines)
- `docs/economics.md` - The Ember Economy (1675 lines)
- `docs/federation-protocol.md` - FireWire federation protocol (1829 lines)
- `docs/intelligence-and-osint.md` - OSINT and exposure infrastructure (1803 lines)
- `docs/global-architecture.md` - Planetary-scale deployment (2491 lines)
- `docs/claude-code-features.md` - CLI features inventory (1322 lines)
- `docs/historical-research.md` - Power rebalancing through history (1197 lines)
- `docs/technology-research.md` - Tech landscape (773 lines)
- `docs/corporate-power-map.md` - Where power actually lives (25+ data sources)
- `docs/game-theory.md` - Decay functions, trust calculus, anti-capture mechanisms
- `docs/humor-and-satire.md` - Satire engine, comedy as weapon
- `docs/decentralized-systems.md` - Network/biological/governance systems
- `docs/literary-arsenal.md` - Mottos, poems, slogans, manifestos, songs
- `docs/art-and-media.md` - Revolutionary art, visual identity, media theory
- `docs/future-capabilities.md` - AI futures, $50 civic agent
- `docs/blue-sky-vision.md` - 10-year aspirational roadmap
- `docs/cloudflare-implementation.md` - 5 workers, cost analysis, 5-phase rollout
- `docs/dual-documentation.md` - Human + AI documentation architecture
- `docs/fork-protection.md` - Integrity verification, web of trust
- `docs/movement-strategy.md` - Movement building strategy (1945 lines)
- `docs/disinformation-defense.md` - Disinformation detection and counter-strategies (835 lines)
- `docs/zero-touch-bootstrap.md` - THE CENTRAL PIECE: one-command node deployment (1992 lines)
- `docs/adversarial-resilience.md` - War manual: threat modeling, takedown case studies, anti-fragile design, incident response (928 lines)
- `docs/chaos-research.md` - Serendipity methodology, random research angles (1246 lines)
- `docs/digital-rights-law.md` - CFAA, whistleblower protections, FOIA, legal survival guide (818 lines)
- `docs/multimedia-tools.md` - Media generation tools research
- `docs/getting-started.md` - Human onboarding guide
- `docs/claude-code-tutorial.md` - CLI tutorial for beginners

## Coherence Principle

**Never bolt on. Always integrate.** Before adding anything new, read the existing work it connects to. We value what we've built — never destroy, never regress. Add in a fashion that keeps the whole project coherent. Cross-reference. Interweave. Every addition should strengthen the existing structure, not just sit beside it.
