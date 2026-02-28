# Claude Code CLI Features for Cleansing Fire

## Research Date: February 28, 2026

This document inventories every Claude Code CLI feature we can leverage for the Cleansing Fire project -- decentralized technology for civic accountability. Claude Code is THE human interface to this system.

---

## Table of Contents

1. [Platform Overview](#1-platform-overview)
2. [Plans and Pricing](#2-plans-and-pricing)
3. [Context Management (CLAUDE.md)](#3-context-management)
4. [Settings and Configuration](#4-settings-and-configuration)
5. [Permissions System](#5-permissions-system)
6. [Hooks System](#6-hooks-system)
7. [Skills (Custom Slash Commands)](#7-skills-custom-slash-commands)
8. [Subagents](#8-subagents)
9. [Agent Teams (Swarm Orchestration)](#9-agent-teams-swarm-orchestration)
10. [Task System](#10-task-system)
11. [Git Worktree Support](#11-git-worktree-support)
12. [MCP (Model Context Protocol) Servers](#12-mcp-servers)
13. [Headless Mode and Automation](#13-headless-mode-and-automation)
14. [Claude Code GitHub Action](#14-github-action)
15. [Agent SDK](#15-agent-sdk)
16. [Worker Patterns for Cleansing Fire](#16-worker-patterns)
17. [Cost Optimization](#17-cost-optimization)
18. [Recommended MCP Servers](#18-recommended-mcp-servers)
19. [Recommended Hooks](#19-recommended-hooks)
20. [Implementation Roadmap](#20-implementation-roadmap)

---

## 1. Platform Overview

Claude Code is an agentic coding tool that lives in the terminal. It reads codebases, executes commands, edits files, manages git workflows, and orchestrates multi-agent work -- all through natural language.

**Current version**: 2.1.x (February 2026)
**Latest model**: Claude Opus 4.6 (`claude-opus-4-6`)
**Key 2026 additions**: Agent teams, git worktree isolation, skills system, persistent memory, task DAGs, automatic memories, SKILL.md, session forking, ConfigChange hooks, `--worktree` flag, background agents, `--from-pr` flag

### How It Maps to Cleansing Fire

The CLAUDE.md file already describes Claude Code as "the human interface to this system." Every feature below maps directly to the project's architecture:

- **Humans** type `claude` in the terminal and describe what they want
- **Claude Opus 4.6** reads CLAUDE.md, understands the project, and orchestrates
- **Workers** run in git worktrees (implementation, review, fix cycle)
- **Plugins** are standalone executables with JSON stdin/stdout
- **The Gatekeeper** serializes GPU access for local Ollama
- **GitHub Actions** automate PR review and CI/CD

---

## 2. Plans and Pricing

### Claude Max Plan (Recommended)

The CLAUDE.md already recommends the $200/month Max plan. Here is the full breakdown:

| Plan | Price | Messages/5hr | Claude Code | Extended Thinking |
|------|-------|-------------|-------------|-------------------|
| Free | $0 | Limited | No | No |
| Pro | $20/mo | ~45 | Yes | Yes |
| Max 5x | $100/mo | ~225 | Yes | Yes |
| Max 20x | $200/mo | ~900 | Yes | Yes |

**Why Max 20x**: The Cleansing Fire development loop (implement -> review -> fix -> merge) burns through messages fast. At 900 messages per 5-hour window, a single developer can run multiple parallel agent workflows without hitting limits. The Max plan combines Claude desktop, mobile, and Claude Code in one subscription.

**Weekly limits**: Max plans have two weekly usage limits -- one across all models and another for Sonnet only. Both reset seven days after your session starts.

### API Pricing (for GitHub Actions and Headless)

For CI/CD automation via `claude-code-action` or headless mode, you pay per-token via the API:

| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|-------|----------------------|------------------------|
| Opus 4.6 | $15.00 | $75.00 |
| Sonnet 4.6 | $3.00 | $15.00 |
| Haiku | $0.25 | $1.25 |

**Cost optimization**: Use Sonnet for automated PR reviews in GitHub Actions (the default). Reserve Opus for implementation workers and complex orchestration. Use Haiku for exploration subagents.

---

## 3. Context Management

### CLAUDE.md Files

CLAUDE.md is the project's constitution -- Claude reads it at session start and follows its instructions. The Cleansing Fire CLAUDE.md is already well-structured at 190 lines.

**File locations and precedence** (lowest to highest):

| Location | Purpose | Shared? |
|----------|---------|---------|
| `~/.claude/CLAUDE.md` | Global preferences | No |
| `CLAUDE.md` (repo root) | Project conventions (ours) | Yes, committed |
| `.claude/CLAUDE.md` | Project conventions (alternative) | Yes, committed |
| `CLAUDE.local.md` | Personal overrides | No, gitignored |
| Parent directories | Monorepo support | Yes |

**Best practices**:
- Keep under 300 lines (ours is 190, good)
- No code snippets (they go stale) -- use file:line references
- Include architecture, workflow, and conventions
- The 7 Principles of Pyrrhic Lucidity belong here as the constitution

### Automatic Memories

New in January 2026: Claude automatically saves useful context to auto-memory. Manage with `/memory`. Claude records and recalls memories as it works, building institutional knowledge across sessions.

**How we should use this**:
- Let Claude learn codebase patterns, plugin APIs, and deployment quirks
- Review auto-memories periodically with `/memory`
- For subagents, enable persistent memory scoped to `project` for shared knowledge

### .claude/ Directory Structure

```
.claude/
  settings.json          # Project settings (committed)
  settings.local.json    # Personal settings (gitignored)
  CLAUDE.md             # Alternative location for project context
  skills/               # Custom skills (committed)
    review-pr/
      SKILL.md
    implement-issue/
      SKILL.md
    investigate/
      SKILL.md
  agents/               # Custom subagents (committed)
    implementation-worker.md
    review-worker.md
    fix-worker.md
    osint-researcher.md
  commands/             # Legacy slash commands (still works)
  hooks/                # Hook scripts
    block-destructive.sh
    lint-python.sh
    verify-integrity.sh
  agent-memory/         # Subagent persistent memory (project scope)
```

---

## 4. Settings and Configuration

### Settings Files

Settings are JSON with hierarchical scope:

| Scope | File | Purpose |
|-------|------|---------|
| Managed (highest) | `/Library/Application Support/ClaudeCode/managed-settings.json` | Org-wide enforcement |
| CLI args | `--model`, `--allowedTools`, etc. | Session overrides |
| Local | `.claude/settings.local.json` | Personal project config |
| Project | `.claude/settings.json` | Team project config (committed) |
| User (lowest) | `~/.claude/settings.json` | Global personal config |

Array settings (permissions, hooks) **merge and deduplicate** across scopes.

### Key Settings for Cleansing Fire

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-opus-4-6",
  "permissions": { ... },
  "hooks": { ... },
  "env": { ... },
  "attribution": {
    "commit": "Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>",
    "pr": "Generated with Claude Code for Cleansing Fire"
  }
}
```

### Environment Variables (Key Ones)

| Variable | Purpose | Recommended Value |
|----------|---------|-------------------|
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Max output tokens | `64000` |
| `BASH_DEFAULT_TIMEOUT_MS` | Shell command timeout | `120000` |
| `CLAUDE_CODE_ENABLE_TASKS` | Task tracking system | `true` (default) |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Agent teams | `1` (when ready) |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents | Leave default (inherit) |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory | Do NOT set (we want memories) |
| `CLAUDE_CODE_AUTOCOMPACT_PCT_OVERRIDE` | Compaction trigger | `80` (compact earlier to preserve quality) |

---

## 5. Permissions System

### Permission Rule Format

Rules follow `Tool` or `Tool(specifier)` syntax. Evaluated in order: **deny -> ask -> allow** (first match wins).

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(python3 *)",
      "Bash(npm run *)",
      "Bash(gh *)",
      "Read",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Bash(rm -rf *)",
      "Bash(curl * | sh)",
      "Bash(sudo *)"
    ]
  }
}
```

### Wildcard Support (New in 2026)

`Bash(*-h*)` -- wildcard matching for tool permissions. Useful for allowing help flags across tools.

### Permission Modes

| Mode | Use Case |
|------|----------|
| `default` | Standard prompting |
| `acceptEdits` | Auto-accept file edits (good for implementation workers) |
| `dontAsk` | Auto-deny unknown tools (good for review workers) |
| `bypassPermissions` | Skip all checks (use with extreme caution) |
| `plan` | Read-only exploration |

---

## 6. Hooks System

Hooks are user-defined commands that execute at lifecycle points. This is one of the most powerful features for Cleansing Fire.

### Hook Events (All 16)

| Event | When | Matcher | Key Use |
|-------|------|---------|---------|
| `SessionStart` | Session begins/resumes | startup, resume, clear, compact | Environment setup |
| `UserPromptSubmit` | Before processing prompt | (none) | Prompt validation |
| `PreToolUse` | Before tool call | Tool name (regex) | Block dangerous ops |
| `PermissionRequest` | Permission dialog | Tool name | Custom approval logic |
| `PostToolUse` | After tool succeeds | Tool name | Linting, formatting |
| `PostToolUseFailure` | After tool fails | Tool name | Error reporting |
| `Notification` | Notification sent | Notification type | Alerting |
| `SubagentStart` | Subagent spawned | Agent type | Setup resources |
| `SubagentStop` | Subagent finishes | Agent type | Cleanup resources |
| `Stop` | Claude finishes | (none) | Final validation |
| `TeammateIdle` | Agent team idle | (none) | Task redistribution |
| `TaskCompleted` | Task completed | (none) | Verification |
| `ConfigChange` | Config file changes | Config source | Reload settings |
| `WorktreeCreate` | Worktree created | (none) | Custom VCS isolation |
| `WorktreeRemove` | Worktree removed | (none) | Cleanup |
| `PreCompact` | Before compaction | manual, auto | Context preservation |
| `SessionEnd` | Session terminates | Exit reason | Cleanup, logging |

### Hook Handler Types

1. **Command** (`type: "command"`) -- shell script, receives JSON stdin, controls via exit codes
2. **HTTP** (`type: "http"`) -- POST to URL, response body controls behavior
3. **Prompt** (`type: "prompt"`) -- sends to Claude model for yes/no evaluation
4. **Agent** (`type: "agent"`) -- spawns subagent with Read/Grep/Glob for deep verification

### Exit Code Semantics

| Code | Meaning |
|------|---------|
| 0 | Success, allow the operation |
| 1 | Error (non-blocking) |
| 2 | Block/deny the operation |

### Hook Configuration Format

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/block-destructive.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/lint-python.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Cleansing Fire session started' >> ~/.claude/session.log"
          }
        ]
      }
    ]
  }
}
```

### How This Maps to Cleansing Fire

| Need | Hook Event | Implementation |
|------|-----------|----------------|
| Block `rm -rf`, `sudo`, dangerous commands | PreToolUse (Bash) | Shell script checks command |
| Auto-lint Python after edits | PostToolUse (Edit\|Write) | Run `python3 -m py_compile` |
| Verify integrity manifest after changes | PostToolUse (Write) | Check `integrity-manifest.json` |
| Log all operations for accountability | PostToolUse (*) | Append to audit log |
| Block reading .env files | PreToolUse (Read) | Check file path |
| Validate plugin outputs | PostToolUse (Bash) | Verify JSON stdout format |
| Notify on task completion | Stop | Send notification |

---

## 7. Skills (Custom Slash Commands)

Skills replace the old `.claude/commands/` system (which still works). They are the primary way to create reusable workflows.

### SKILL.md Format

```yaml
---
name: skill-name
description: When to use this skill
disable-model-invocation: true    # Only manual /skill-name
allowed-tools: Read, Grep, Glob   # Tool restrictions
context: fork                      # Run in subagent
agent: Explore                     # Which subagent type
model: opus                        # Model override
---

Your instructions in markdown...
Use $ARGUMENTS for user input.
Use $0, $1, $2 for positional args.
Use !`shell command` for dynamic context injection.
```

### Skills We Should Create for Cleansing Fire

#### /investigate -- OSINT Research Skill

```yaml
---
name: investigate
description: Investigate a person, company, or topic using OSINT techniques
disable-model-invocation: true
context: fork
allowed-tools: Bash(gh *), Read, Grep, Glob, WebFetch, WebSearch
---

Investigate $ARGUMENTS using OSINT methodology:

1. Search public records, SEC filings, corporate registrations
2. Cross-reference data sources
3. Map relationships and ownership chains
4. Document findings with sources
5. Generate a report in docs/ format

Reference: docs/intelligence-and-osint.md for methodology
Reference: docs/corporate-power-map.md for existing mappings
```

#### /implement -- Implementation Worker Skill

```yaml
---
name: implement
description: Implement a GitHub issue as an implementation worker
disable-model-invocation: true
context: fork
agent: general-purpose
---

Implementation Worker Protocol:

1. Read GitHub issue $ARGUMENTS
2. Create feature branch: cf/$ARGUMENTS-description
3. Implement in isolated worktree
4. Write tests
5. Create a Pull Request referencing the issue
6. Push often

Rules from CLAUDE.md:
- Always Claude Opus 4.6
- Always git worktrees for isolation
- Implementation, review, and fix are separate workers
- Commit and push often
```

#### /review -- Review Worker Skill

```yaml
---
name: review
description: Review a pull request as a review worker
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob, Bash(gh *), Bash(git *)
---

Review Worker Protocol:

1. Check out PR $ARGUMENTS
2. Review thoroughly:
   - Code quality, readability
   - Security issues (secrets, injection, etc.)
   - Alignment with CLAUDE.md conventions
   - Test coverage
   - Plugin JSON stdin/stdout contract
3. Post review comments on the PR
4. NEVER fix code -- only review and comment

Reference: CLAUDE.md "Key Rules" section
```

#### /fix -- Fix Worker Skill

```yaml
---
name: fix
description: Fix issues found in a PR review
disable-model-invocation: true
context: fork
---

Fix Worker Protocol:

1. Read review comments on PR $ARGUMENTS
2. Address each review comment
3. Make fixes on the feature branch
4. Push updates
5. Iterate until review worker approves
```

#### /forge -- Content Generation Skill

```yaml
---
name: forge
description: Generate content using the Forge system
disable-model-invocation: true
---

Use the Forge content generation system to create $ARGUMENTS.

Available forge plugins:
- forge-vision: SVG, ASCII art, Mermaid diagrams, image prompts
- forge-voice: Social posts, threads, newsletters, poetry, agitprop, satire
- Satire Engine: Parody, doublespeak translator, memes
- pipeline-data-to-fire: data -> analysis -> visualization -> narrative -> distribution
```

### Skill Directory Structure

```
.claude/skills/
  investigate/
    SKILL.md
    reference/
      osint-methodology.md
  implement/
    SKILL.md
  review/
    SKILL.md
  fix/
    SKILL.md
  forge/
    SKILL.md
  deploy/
    SKILL.md
```

---

## 8. Subagents

Subagents are specialized AI assistants that run in their own context window with custom system prompts, tool restrictions, and permissions.

### Built-in Subagents

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| Explore | Haiku | Read-only | Fast codebase search |
| Plan | Inherit | Read-only | Research for planning |
| general-purpose | Inherit | All | Complex multi-step tasks |
| Bash | Inherit | Terminal | Shell commands in separate context |

### Subagent Configuration Format

Subagents are Markdown files in `.claude/agents/`:

```markdown
---
name: implementation-worker
description: Implement GitHub issues. Use proactively when code changes are needed.
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus
permissionMode: acceptEdits
isolation: worktree
memory: project
---

You are an implementation worker for the Cleansing Fire project.
Follow the development loop from CLAUDE.md exactly.
Create feature branch cf/<issue>-<description>.
Implement in isolated worktree.
Commit and push often.
```

### Key Subagent Features

| Feature | How It Works |
|---------|-------------|
| `isolation: worktree` | Runs in its own git worktree (NEW Feb 2026) |
| `memory: project` | Persistent memory in `.claude/agent-memory/<name>/` |
| `background: true` | Runs concurrently while you continue working |
| `maxTurns` | Limits agent loop iterations |
| `skills` | Preloads skill content into agent context |
| `hooks` | Lifecycle hooks scoped to this agent |
| `mcpServers` | MCP servers available to this agent |

### Subagents We Should Create

1. **implementation-worker** -- implements issues, creates PRs, uses worktree isolation
2. **review-worker** -- reviews PRs, read-only, posts comments, NEVER fixes code
3. **fix-worker** -- reads review comments, makes fixes, pushes updates
4. **osint-researcher** -- investigates targets using OSINT plugins
5. **content-forger** -- generates content using forge plugins
6. **data-analyst** -- processes civic data, SEC filings, FEC records

---

## 9. Agent Teams (Swarm Orchestration)

**Status**: Experimental (January 2026). Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

Agent teams let multiple Claude Code sessions coordinate as a team:
- One session acts as **team lead** coordinating work
- **Teammates** work independently in their own context windows
- They communicate directly through **inbox-based messaging**
- Uses **tmux split panes** for visual monitoring
- Git worktree isolation handles code conflicts

### TeammateTool Operations (13 total)

The TeammateTool provides enterprise-grade agent orchestration including inbox-based communication, task assignment, and status monitoring.

### How This Maps to Cleansing Fire

The agent teams feature is essentially the worker orchestration pattern from CLAUDE.md, but built into Claude Code natively:

| CLAUDE.md Pattern | Agent Teams Equivalent |
|-------------------|----------------------|
| Orchestrator | Team lead session |
| Implementation Worker | Teammate with worktree |
| Review Worker | Teammate (read-only) |
| Fix Worker | Teammate spawned on review findings |

**When to use**: Large batched changes, code migrations, parallel OSINT investigations, simultaneous content generation across multiple topics.

---

## 10. Task System

Released January 22, 2026. Replaces the old Todos with a sophisticated DAG-based orchestration layer.

### Task Operations

| Operation | Purpose |
|-----------|---------|
| `TaskCreate` | Create task with subject and description |
| `TaskUpdate` | Update status, add dependencies |
| `addBlockedBy` | Task X cannot start until task Y completes |
| `addBlocks` | Task X blocks task Y from starting |

### Task DAGs

Tasks form directed acyclic graphs. Example:

```
Task 1: Build API       ─┐
                          ├─ Task 3: Run Tests ── Task 4: Deploy
Task 2: Configure Auth  ─┘
```

Task 3 cannot start until both Task 1 and Task 2 complete.

### Task Storage

Tasks are stored on the local filesystem at `~/.claude/tasks`. Share task lists across sessions with `CLAUDE_CODE_TASK_LIST_ID`.

### How This Maps to Cleansing Fire

The GitHub issue -> implement -> review -> fix -> merge cycle maps directly to task DAGs:

```
TaskCreate: "Implement #42"  ─── TaskCreate: "Review PR #43" ─── TaskCreate: "Fix review issues" ─── TaskCreate: "Merge"
```

---

## 11. Git Worktree Support

**Released**: February 21, 2026. Built-in to CLI.

### Usage Methods

```bash
# Start Claude in isolated worktree
claude --worktree
claude -w

# Named worktree
claude --worktree my-feature

# Subagent with worktree isolation
# In agent definition:
# isolation: worktree
```

### How It Works

- Creates separate working directory under `.claude/worktrees/`
- Each worktree has its own files and branch
- Shares repository history and remote connections
- Automatically cleaned up if subagent makes no changes
- On session exit, prompted to keep or remove

### Non-Git Systems

For Mercurial, Perforce, SVN, define custom `WorktreeCreate` and `WorktreeRemove` hooks.

### How This Maps to Cleansing Fire

The CLAUDE.md already mandates worktrees: "Workers ALWAYS use git worktrees for isolation." The built-in `--worktree` flag and `isolation: worktree` in subagent definitions make this native instead of requiring manual worktree management via `workers/orchestrator.sh`.

**Migration path**: Replace `workers/orchestrator.sh` worktree management with native Claude Code worktree support via subagent `isolation: worktree`.

---

## 12. MCP Servers

MCP (Model Context Protocol) connects Claude to external tools and data sources. Over 200 servers available as of February 2026.

### Configuration

MCP servers are configured in two locations:
- User-level: `~/.claude.json`
- Project-level: `.mcp.json`

```bash
# Add MCP server
claude mcp add <name> --scope user -- <command> [args...]

# Example: Add GitHub MCP
claude mcp add github --scope user -- npx -y @modelcontextprotocol/server-github

# Pass environment variables securely
claude mcp add github --scope user -e GITHUB_TOKEN -- npx -y @modelcontextprotocol/server-github
```

### MCP Tool Search (Performance)

When MCP tool descriptions exceed 10% of context window, Claude Code automatically activates tool search -- reducing context consumption by up to 85% by loading tools on-demand.

Control with `ENABLE_TOOL_SEARCH`:
- `auto` -- auto-enable at 10% context (default)
- `auto:5` -- auto-enable at 5%
- `true` -- always enabled
- `false` -- disabled

### Recommended MCP Servers for Cleansing Fire

See [Section 18](#18-recommended-mcp-servers) for detailed recommendations.

---

## 13. Headless Mode and Automation

### The `-p` Flag

```bash
# Run single prompt, get result on stdout
claude -p "Generate unit tests for daemon/gatekeeper.py"

# With tool permissions
claude -p "Fix lint errors" --allowedTools "Bash(npm run lint)" "Edit"

# JSON output
claude -p "List all plugins" --output-format json

# Streaming output
claude -p "Analyze codebase" --output-format stream-json

# Max turns limit
claude -p "Implement feature X" --max-turns 20

# Specific model
claude -p "Review code" --model claude-sonnet-4-6
```

### Multi-Turn Sessions

Chain prompts while preserving conversation history:

```bash
# Start session
SESSION=$(claude -p "Start analyzing the plugin system" --output-format json | jq -r '.session_id')

# Continue with context
claude -p "Now look at the forge plugins specifically" --session $SESSION
```

### Automation Patterns for Cleansing Fire

#### Cron-Based Data Collection

```bash
# In scheduler/scheduler.py or system crontab
# Daily SEC EDGAR check
0 6 * * * claude -p "Run civic-sec-edgar plugin for latest filings, save results to output/" \
  --allowedTools "Bash(python3 plugins/*)" "Write" "Read" \
  --max-turns 10

# Weekly OSINT refresh
0 0 * * 0 claude -p "Refresh all OSINT data sources, update corporate-power-map.md" \
  --allowedTools "Bash" "Read" "Write" "Edit" "WebFetch" \
  --max-turns 30
```

#### CI/CD Pipeline Integration

```bash
# Verify integrity after build
claude -p "Verify integrity-manifest.json matches all tracked files" \
  --allowedTools "Read" "Bash(sha256sum *)" \
  --max-turns 5
```

#### Batch Processing

```bash
# Process multiple targets
for target in "company-a" "company-b" "company-c"; do
  claude -p "Investigate $target using OSINT methodology" \
    --allowedTools "Bash" "Read" "Write" "WebFetch" "WebSearch" \
    --max-turns 20 &
done
wait
```

---

## 14. GitHub Action

### claude-code-action v1

The official GitHub Action for integrating Claude Code into PR/issue workflows.

### Setup

Quickest method:
```bash
claude
# then run:
/install-github-app
```

Or manual setup:
1. Install Claude GitHub app: https://github.com/apps/claude
2. Add `ANTHROPIC_API_KEY` to repository secrets
3. Copy workflow file to `.github/workflows/`

### Workflow Files for Cleansing Fire

#### PR Review (Automated on Every PR)

```yaml
name: Claude Code PR Review
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  claude-review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
      issues: write
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: "/review"
          claude_args: "--max-turns 10 --model claude-sonnet-4-6"
```

#### Interactive @claude Mentions

```yaml
name: Claude Code Interactive
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned]

jobs:
  claude:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'issues' && contains(github.event.issue.body, '@claude'))
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

#### Scheduled Automation

```yaml
name: Daily OSINT Refresh
on:
  schedule:
    - cron: "0 9 * * *"  # 9 AM UTC daily

jobs:
  osint-refresh:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Check for new SEC filings, FEC data, and public records
            for entities tracked in docs/corporate-power-map.md.
            If new data found, update the relevant docs and create a PR.
          claude_args: "--max-turns 20 --model claude-sonnet-4-6"
```

#### Issue-to-PR Implementation

```yaml
name: Claude Implement Issue
on:
  issues:
    types: [assigned]

jobs:
  implement:
    if: contains(github.event.issue.labels.*.name, 'claude-implement')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: write
    steps:
      - uses: actions/checkout@v4

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Implement the feature described in this issue.
            Follow CLAUDE.md conventions exactly.
            Create a PR when done.
          claude_args: "--max-turns 30 --model claude-opus-4-6"
```

### Action Parameters

| Parameter | Description | Required |
|-----------|-------------|----------|
| `prompt` | Instructions or skill name (e.g., `/review`) | No |
| `claude_args` | CLI arguments | No |
| `anthropic_api_key` | API key | Yes (for direct API) |
| `github_token` | GitHub token | No |
| `trigger_phrase` | Custom trigger (default: `@claude`) | No |
| `use_bedrock` | Use AWS Bedrock | No |
| `use_vertex` | Use Google Vertex AI | No |

### Cost Control for GitHub Actions

- Use `--max-turns` to prevent runaway jobs
- Set workflow-level timeouts
- Use concurrency controls to limit parallel runs
- Default to Sonnet for reviews (cheaper than Opus)
- Reserve Opus for implementation tasks

---

## 15. Agent SDK

The Claude Code SDK has been renamed to **Claude Agent SDK**. It provides the same agent harness that powers Claude Code, programmable in Python and TypeScript.

### Installation

```bash
# Python
pip install claude-agent-sdk
# or
uv pip install claude-agent-sdk

# TypeScript/Node
npm install @anthropic-ai/claude-agent-sdk
```

### Use Cases for Cleansing Fire

- **Custom automation scripts** that use Claude's full tool ecosystem
- **Integration with existing Python infrastructure** (gatekeeper, scheduler, plugins)
- **Programmatic agent orchestration** beyond what the CLI provides
- **Building the scheduler integration** -- trigger Claude agents from Python

### Example: Programmatic Worker Launch

```python
from claude_agent_sdk import Agent

agent = Agent(
    model="claude-opus-4-6",
    system_prompt="You are an implementation worker for Cleansing Fire...",
    tools=["Read", "Write", "Edit", "Bash", "Grep", "Glob"],
    working_directory="/path/to/worktree"
)

result = agent.run("Implement GitHub issue #42")
```

---

## 16. Worker Patterns for Cleansing Fire

### The Definitive Development Loop (Enhanced with Claude Code Features)

The CLAUDE.md defines the implement -> review -> fix -> merge cycle. Here is how to implement it using native Claude Code features:

#### Option A: Skills-Based (Simplest)

```bash
# Human triggers each step manually
claude
> /implement 42
# ... Claude implements in worktree, creates PR ...

claude
> /review 43
# ... Claude reviews PR, posts comments ...

claude
> /fix 43
# ... Claude reads comments, makes fixes ...
```

#### Option B: Subagent-Based (Automated)

Define subagents in `.claude/agents/`:

```markdown
# .claude/agents/implementation-worker.md
---
name: implementation-worker
description: Implement GitHub issues in isolated worktrees
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus
permissionMode: acceptEdits
isolation: worktree
memory: project
hooks:
  Stop:
    - hooks:
        - type: command
          command: "echo 'Implementation worker completed' >> ~/.claude/worker.log"
---

You are an implementation worker for Cleansing Fire.
[Full worker instructions from CLAUDE.md]
```

Then Claude automatically delegates: "Implement issue #42" -> spawns implementation-worker in worktree.

#### Option C: Agent Teams (Full Swarm)

Enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` and have the team lead orchestrate:

```
Team Lead: "We need to implement issues #42, #43, and #44"
-> Spawns 3 implementation workers in parallel worktrees
-> Each creates a PR
-> Spawns 3 review workers
-> Fix workers spawned as needed
-> Team lead merges approved PRs
```

#### Option D: Headless CI/CD (GitHub Actions)

```yaml
# Label issue with 'claude-implement' -> triggers workflow
# Claude implements, creates PR
# PR triggers review workflow
# Review comments trigger fix workflow
# All checks pass -> ready to merge
```

### Recommended Approach: Progressive Enhancement

1. **Start with Skills** (Option A) -- works today, simple, human in the loop
2. **Add Subagents** (Option B) -- when comfortable, enables delegation
3. **Enable Agent Teams** (Option C) -- for parallel work at scale
4. **Add GitHub Actions** (Option D) -- for fully automated CI/CD

---

## 17. Cost Optimization

### Max Plan Strategy

At $200/month for Max 20x:
- ~900 messages per 5-hour window
- Use for all interactive development
- Extended thinking included

### API Cost Strategy (for GitHub Actions)

| Task | Model | Reason |
|------|-------|--------|
| PR review | Sonnet 4.6 | Fast, cheap, good enough for reviews |
| Implementation | Opus 4.6 | Complex reasoning needed |
| Exploration | Haiku | Fast codebase search |
| OSINT data collection | Sonnet 4.6 | Structured data extraction |
| Content generation | Opus 4.6 | Creative quality matters |

### Context Management

- Set `CLAUDE_CODE_AUTOCOMPACT_PCT_OVERRIDE=80` to compact context earlier
- Use subagents for verbose operations (keeps main context clean)
- Use skills with `context: fork` for isolated work
- MCP Tool Search reduces context by up to 85% with many tools

### Reducing Unnecessary API Calls

- `--max-turns` limits in GitHub Actions
- Workflow-level timeouts
- Concurrency controls
- Specific `@claude` commands instead of broad instructions
- `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1` for lean operation

---

## 18. Recommended MCP Servers

### Tier 1: Core (Install Immediately)

#### GitHub MCP Server

```bash
claude mcp add github --scope user -e GITHUB_TOKEN -- npx -y @modelcontextprotocol/server-github
```

**Why**: 15 tools covering issues, PRs, files, search. 92% of Claude Code MCP users activate this first. Essential for the implement -> review -> fix cycle.

**Tools provided**: create_issue, list_issues, get_pull_request, create_pull_request, search_repositories, get_file_contents, and more.

#### Memory MCP Server

```bash
claude mcp add memory --scope user -- npx -y @modelcontextprotocol/server-memory
```

**Why**: Persistent memory across sessions. Store investigation findings, entity relationships, corporate ownership chains.

#### Git MCP Server

```bash
claude mcp add git --scope user -- npx -y @modelcontextprotocol/server-git
```

**Why**: Read, search, and manipulate Git repositories. Supplements built-in git support.

### Tier 2: Investigation & Research

#### Brave Search MCP Server

```bash
claude mcp add brave-search --scope user -e BRAVE_API_KEY -- npx -y @modelcontextprotocol/server-brave-search
```

**Why**: Privacy-focused web search. Essential for OSINT. Includes local business search, image search, news search, and AI-powered summarization.

#### Filesystem MCP Server

```bash
claude mcp add filesystem --scope user -- npx -y @modelcontextprotocol/server-filesystem ~/Documents ~/Projects
```

**Why**: Secure file operations with configurable access controls. Access files outside the project directory.

### Tier 3: Data & Integration

#### PostgreSQL MCP Server

```bash
claude mcp add postgres --scope project -- npx -y @modelcontextprotocol/server-postgres postgresql://localhost/cleansing_fire
```

**Why**: If/when we add a database for storing investigation data, entity maps, or civic records.

#### Fetch MCP Server

```bash
claude mcp add fetch --scope user -- npx -y @modelcontextprotocol/server-fetch
```

**Why**: Enhanced web fetching with fewer restrictions than built-in WebFetch. Good for scraping public records.

### MCP Configuration File (.mcp.json)

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    }
  }
}
```

---

## 19. Recommended Hooks

### block-destructive.sh

Prevents dangerous shell commands from executing.

```bash
#!/bin/bash
# .claude/hooks/block-destructive.sh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Block destructive commands
if echo "$COMMAND" | grep -qE 'rm -rf /|sudo |curl.*\| ?sh|wget.*\| ?sh'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive or dangerous command blocked by Cleansing Fire safety hook"
    }
  }'
else
  exit 0
fi
```

### lint-python.sh

Auto-checks Python syntax after edits.

```bash
#!/bin/bash
# .claude/hooks/lint-python.sh
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" == *.py ]]; then
  python3 -m py_compile "$FILE_PATH" 2>&1 || true
fi
exit 0
```

### verify-integrity.sh

Checks integrity manifest after file writes.

```bash
#!/bin/bash
# .claude/hooks/verify-integrity.sh
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check if integrity-manifest.json exists
if [ -f "$CLAUDE_PROJECT_DIR/integrity-manifest.json" ]; then
  # Log the file change for integrity tracking
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) CHANGED: $FILE_PATH" >> "$CLAUDE_PROJECT_DIR/.claude/change.log"
fi
exit 0
```

### protect-env.sh

Prevents reading environment files.

```bash
#!/bin/bash
# .claude/hooks/protect-env.sh
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if echo "$FILE_PATH" | grep -qE '\.env($|\.)'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Reading .env files is blocked for security"
    }
  }'
else
  exit 0
fi
```

---

## 20. Implementation Roadmap

### Phase 1: Foundation (Do Now)

- [ ] Create `.claude/settings.json` with permissions, hooks, and model config
- [ ] Create `.mcp.json` with GitHub MCP server
- [ ] Create `.claude/hooks/` scripts (block-destructive, lint-python, protect-env)
- [ ] Install GitHub MCP server: `claude mcp add github --scope user -e GITHUB_TOKEN`
- [ ] Install Memory MCP server: `claude mcp add memory --scope user`
- [ ] Set up GitHub Actions workflow for PR review

### Phase 2: Skills & Agents (Next Week)

- [ ] Create skills: `/implement`, `/review`, `/fix`, `/investigate`, `/forge`
- [ ] Create subagents: implementation-worker, review-worker, fix-worker
- [ ] Test the implement -> review -> fix cycle with skills
- [ ] Add `isolation: worktree` to implementation and fix workers
- [ ] Enable persistent memory for workers

### Phase 3: Automation (Next Month)

- [ ] Set up GitHub Actions for automated PR review on every PR
- [ ] Set up `@claude` interactive mentions in issues/PRs
- [ ] Set up scheduled OSINT refresh workflow
- [ ] Set up issue-to-PR implementation workflow
- [ ] Integrate with scheduler/scheduler.py for local automation

### Phase 4: Swarm (When Ready)

- [ ] Enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- [ ] Test agent team orchestration for parallel implementation
- [ ] Build swarm patterns for large-scale OSINT investigations
- [ ] Implement parallel content generation across topics

---

## Sources

- [Claude Code Overview](https://code.claude.com/docs/en/overview)
- [Claude Code Settings](https://code.claude.com/docs/en/settings)
- [Hooks Reference](https://code.claude.com/docs/en/hooks)
- [Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Skills Documentation](https://code.claude.com/docs/en/skills)
- [Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [MCP Documentation](https://code.claude.com/docs/en/mcp)
- [Headless Mode](https://code.claude.com/docs/en/headless)
- [GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [Claude Code GitHub Action](https://github.com/anthropics/claude-code-action)
- [Claude Code Repository](https://github.com/anthropics/claude-code)
- [Claude Max Plan](https://claude.com/pricing/max)
- [Agent SDK Overview](https://platform.claude.com/docs/en/agent-sdk/overview)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [Claude Code Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
