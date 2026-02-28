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
- **CLI Client** (`bin/fire-ask`) - Command-line interface to gatekeeper
- **Scheduler** (`scheduler/scheduler.py`) - Cron-like task scheduling + event-driven tasks
- **Worker Orchestrator** (`workers/orchestrator.sh`) - Launches Claude Code workers in git worktrees
- **Plugin System** (`plugins/`) - Executable scripts that accept JSON stdin, produce JSON stdout

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
1. Install Claude Code CLI
2. Clone this repo
3. Run `claude` in the project directory
4. Claude reads this file and bootstraps the system
5. Tell Claude what you want to investigate, build, or learn
6. Claude handles infrastructure, plugins, agents, coordination

### For AI Agents
1. Claude Code (Opus) is the orchestrator brain in interactive sessions
2. Background workers are Claude Code instances in isolated git worktrees
3. Implementation and review are ALWAYS in separate workers
4. Every piece of work has a GitHub issue assigned before starting
5. Workers create PRs that reference their issues
6. The gatekeeper manages all local LLM tasks (GPU contention)
7. Commit and push often — continuous delivery to GitHub Pages

### Key Models
- **Claude Opus 4.6** - orchestration, research, planning, writing, implementation, review
- **Ollama local models** - lightweight text tasks via gatekeeper (mistral-large:123b default)

## Development Conventions

### Git Workflow
- `main` branch is always stable (and is GitHub Pages source)
- Feature branches: `cf/<issue-number>-<short-description>`
- All work goes through PRs
- Separate implementation and review workers
- **Commit and push often**

### Code Standards
- Python 3.9+ (stdlib only where possible, minimize dependencies)
- Shell scripts use `set -euo pipefail`
- Plugins are self-contained executables
- All services are pure stdlib Python (no frameworks)

### File Structure
```
cleansing-fire/
├── CLAUDE.md          # This file - project conventions for Claude
├── philosophy.md      # Pyrrhic Lucidity framework
├── daemon/            # Gatekeeper daemon
├── scheduler/         # Task scheduling system
├── workers/           # Worker orchestration
├── plugins/           # Plugin executables (JSON stdin/stdout)
│   ├── civic-*        # Government/civic data plugins
│   ├── forge-*        # Content generation plugins
│   └── pipeline-*     # Multi-plugin pipelines
├── scripts/           # Management and automation scripts
├── bin/               # CLI tools
├── docs/              # Human documentation + GitHub Pages
│   ├── index.html     # Main site
│   └── *.md           # Research documents
└── specs/             # AI-readable specifications
    ├── project-graph.yaml
    ├── plugin-schema.json
    ├── agent-capabilities.yaml
    └── goals.yaml
```

### Running Services
```bash
# Start gatekeeper daemon
scripts/gatekeeper-ctl.sh install  # or:
python3 daemon/gatekeeper.py

# Test gatekeeper
bin/fire-ask --status
bin/fire-ask --sync "test prompt"

# Start scheduler
python3 scheduler/scheduler.py

# Launch implementation worker
workers/orchestrator.sh implement "Task title" "Description"

# Launch review worker
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

## Key Research Documents
- `philosophy.md` - Pyrrhic Lucidity (956 lines)
- `docs/economics.md` - The Ember Economy (1675 lines)
- `docs/historical-research.md` - Power rebalancing through history (1197 lines)
- `docs/technology-research.md` - Tech landscape (773 lines)
- `docs/decentralized-systems.md` - Network/biological/governance systems
- `docs/literary-arsenal.md` - Mottos, poems, slogans, manifestos, songs
- `docs/corporate-power-map.md` - Where power actually lives
- `docs/intelligence-and-osint.md` - OSINT and exposure infrastructure
- `docs/humor-and-satire.md` - Satire as weapon
- `docs/dual-documentation.md` - Human + AI documentation architecture
