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

Build decentralized, autonomous technology that shifts power from corrupt concentrated authority toward the people. Not a platform - a protocol. Not a movement - an infrastructure. Designed for massive scale adoption worldwide, agent-first but human-accessible.

## Architecture

### Core Infrastructure
- **Gatekeeper Daemon** (`daemon/gatekeeper.py`) - HTTP server on port 7800 that serializes GPU access to local Ollama. Short queue (5), rejects on overflow. Endpoints: POST /submit, POST /submit-sync, GET /task/{id}, GET /health
- **CLI Client** (`bin/fire-ask`) - Command-line interface to gatekeeper
- **Scheduler** (`scheduler/scheduler.py`) - Cron-like task scheduling + event-driven tasks
- **Worker Orchestrator** (`workers/orchestrator.sh`) - Launches Claude Code workers in git worktrees for implementation and review
- **Plugin System** (`plugins/`) - Executable scripts that accept JSON stdin, produce JSON stdout

### Workflow
1. Claude Code (Opus) is the orchestrator brain in interactive sessions
2. Background workers are Claude Code instances in isolated git worktrees
3. Implementation and review are ALWAYS in separate workers
4. Every piece of work has a GitHub issue assigned before starting
5. Workers create PRs that reference their issues
6. Review workers check PRs but never fix code
7. The gatekeeper manages all local LLM tasks (GPU contention)

### Key Models
- **Claude Opus** - orchestration, research, planning, writing, implementation, review
- **Ollama local models** - lightweight text tasks via gatekeeper (mistral-large:123b default)

## Development Conventions

### Git Workflow
- `main` branch is always stable
- Feature branches: `cf/<issue-number>-<short-description>`
- All work goes through PRs
- Separate implementation and review workers

### Code Standards
- Python 3.9+ (stdlib only where possible, minimize dependencies)
- Shell scripts use `set -euo pipefail`
- Plugins are self-contained executables
- All services are pure stdlib Python (no frameworks)

### File Structure
```
cleansing-fire/
├── CLAUDE.md          # This file - project conventions
├── philosophy.md      # Pyrrhic Lucidity framework
├── daemon/            # Gatekeeper daemon
├── scheduler/         # Task scheduling system
├── workers/           # Worker orchestration
├── plugins/           # Plugin executables
├── scripts/           # Management scripts
├── bin/               # CLI tools
└── docs/              # Research and documentation
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

## The Cost Heuristic (from Pyrrhic Lucidity)

When evaluating any action, feature, or decision: if it costs nothing to the actor, it is structurally suspect. Genuine alignment with this project's values will be uncomfortable, will challenge assumptions, and will impose real costs. If it's easy, it's probably not real.
