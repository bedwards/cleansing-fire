# Getting Started with Cleansing Fire

---

## What This Is

Cleansing Fire is infrastructure for investigating and exposing concentrated power. Not a platform you sign up for. Not a movement you join. It is a protocol -- a set of tools, pipelines, and agents that collect open-source intelligence, cross-reference public records, generate content, and distribute findings. It is designed to scale without a center, to be forked without permission, and to resist capture by the very forces it investigates.

The project operates under a philosophy called Pyrrhic Lucidity. The name is honest about costs. Every victory against entrenched power exacts a price from the victor, and the refusal to act -- which avoids that price -- is a more total defeat. This is not optimistic software. It is not pessimistic software. It is software for people who have stopped asking whether the situation is hopeful and started asking what honest action looks like when hope is beside the point.

What makes it different: the human interface is Claude Code, an AI assistant that runs in your terminal. You learn one tool -- Claude Code -- and it handles the complexity from there. Setting up infrastructure, running investigations, generating content, coordinating agents, writing plugins. You talk to Claude in natural language. Claude reads the project's documentation, understands its architecture, and guides you. The barrier to entry is a terminal and a willingness to look at uncomfortable facts.

---

## What You Need

**Required:**

- **A computer** -- macOS 13.0+, Linux (Ubuntu 20.04+, Debian 10+), or Windows 10+ (native or with WSL)
- **Claude Code CLI** -- the human interface to the system ([installation instructions below](#installing-claude-code) or [official docs](https://code.claude.com/docs/en/setup))
- **git** -- for version control and collaboration ([git downloads](https://git-scm.com/downloads))

**Optional but recommended:**

- **Ollama** -- for running local AI models, used by the gatekeeper daemon ([ollama.com](https://ollama.com/))
- **GitHub account** -- for contributing code, filing issues, and submitting pull requests ([github.com](https://github.com/))
- **Python 3.9+** -- for running the gatekeeper daemon, scheduler, and plugins (usually pre-installed on macOS and Linux)

---

## Installing Claude Code

Claude Code is the only tool you need to learn. Everything else, Claude helps you set up.

### macOS and Linux (including WSL)

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### Windows PowerShell

```powershell
irm https://claude.ai/install.ps1 | iex
```

Windows requires [Git for Windows](https://git-scm.com/downloads/win). Install that first.

### Windows CMD

```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

### macOS via Homebrew

```bash
brew install --cask claude-code
```

### Verify it worked

```bash
claude --version
```

### Authentication

Claude Code requires a paid Anthropic account -- Pro, Max, Teams, Enterprise, or Console. Run `claude` and follow the browser prompts to authenticate. If you are using an API key through the Anthropic Console, you will set that up during your first launch.

For the full setup reference, see the [official Claude Code documentation](https://code.claude.com/docs/en/setup).

---

## Your First Session

### 1. Clone the repository

```bash
git clone https://github.com/bedwards/cleansing-fire.git
cd cleansing-fire
```

### 2. Launch Claude Code

```bash
claude
```

That is it. When Claude starts, it reads `CLAUDE.md` in the project root -- the project's constitution, architecture map, and operating manual. Claude now understands what Cleansing Fire is, how it is structured, what plugins exist, and how to help you.

### 3. Tell Claude what you want

You do not need to know the codebase. You do not need to know Python or shell scripting. You talk to Claude in plain language and Claude handles the rest. Here are real things you can say in your first session:

**Investigate something:**
```
Investigate Palantir's government contracts and political connections.
What can you find in public records about their lobbying spending?
```

**Research legislation:**
```
What surveillance bills are currently moving through state legislatures?
Use the LegiScan plugin to search for relevant bills.
```

**Generate content:**
```
Create a social media thread about private equity's role in
healthcare consolidation. Make it sharp but sourced.
```

**Understand the project:**
```
Walk me through the architecture. How do plugins work?
What does the gatekeeper daemon do?
```

**Build something:**
```
Help me write a new plugin that tracks SEC insider trading filings.
Follow the existing plugin conventions.
```

### 4. What happens next

Claude will read files, search the web, run commands, write code, and explain what it is doing along the way. It will ask your permission before executing shell commands or modifying files. You stay in control. Claude does the heavy lifting.

If you get lost, just ask: "What should I do next?" Claude has read the docs. It knows.

---

## What Claude Can Do For You

These are not hypothetical examples. These are the kinds of requests the system is built to handle.

### Investigate
> "Investigate Palantir's government contracts and political connections"
>
> "Trace the ownership chain of this private equity firm through SEC filings"
>
> "Who are the top lobbying spenders in the defense sector this year?"

### Research
> "What surveillance bills are moving through state legislatures?"
>
> "Cross-reference this company's lobbying disclosures with their government contracts"
>
> "What does the FEC data show about dark money in the last election cycle?"

### Generate
> "Create a social media thread about private equity in healthcare"
>
> "Write a newsletter summarizing this week's corporate lobbying disclosures"
>
> "Generate satirical corporate doublespeak translations of these PR statements"

### Visualize
> "Generate a money flow diagram for defense contractor lobbying"
>
> "Create an SVG visualization of this company's subsidiary structure"
>
> "Build a Mermaid diagram showing the revolving door between this agency and industry"

### Analyze
> "Cross-reference this company's lobbying with their government contracts"
>
> "Run the full data-to-fire pipeline on this investigation"
>
> "What patterns do you see in these campaign finance records?"

### Build
> "Help me write a new plugin that tracks SEC insider trading filings"
>
> "Add a new data source to the civic crossref plugin"
>
> "Improve the forge-voice plugin to support podcast scripts"

### Learn
> "Explain how the FEC campaign finance system works"
>
> "Walk me through the plugin architecture"
>
> "What is Pyrrhic Lucidity and why does this project use it?"

---

## Learning Path

There is no gatekeeping here. Start wherever you are. The system meets you where you are and teaches you as you go.

### 1. Observer

Read the docs. Run investigations. Learn the landscape.

- Clone the repo and launch `claude`
- Ask Claude to explain the project architecture
- Run some investigations on topics that interest you
- Read `philosophy.md` to understand the ethical framework
- Browse the existing research documents in `docs/`

You are contributing just by learning. Every person who understands how power actually operates is a node in the network.

### 2. Contributor

File issues. Submit research. Test plugins. Improve documentation.

- Find something broken or missing and file a GitHub issue
- Run plugins and report what works and what does not
- Submit research findings as pull requests to `docs/`
- Test the system on new investigation targets
- Suggest new data sources or plugin ideas

### 3. Builder

Write plugins. Extend the pipeline. Improve the system.

- Study the plugin convention: executable scripts, JSON in, JSON out
- Ask Claude to help you write a new plugin -- it knows the conventions
- Extend existing plugins with new data sources
- Improve the forge (content generation) tools
- Contribute to the scheduler, gatekeeper, or worker infrastructure

### 4. Operator

Run your own node. Operate scheduled tasks. Manage agents.

- Set up Ollama and the gatekeeper daemon on your machine
- Configure the scheduler with automated investigation tasks
- Run background workers that continuously collect and analyze data
- Operate your node as part of the decentralized network
- Help others set up their nodes

---

## Setting Up Your Node

This is optional. You can use Cleansing Fire through Claude Code alone. But if you want to run automated investigations, local AI processing, and scheduled tasks, you will need local infrastructure.

### Install Ollama

Ollama runs large language models locally on your machine. The gatekeeper daemon uses it for lightweight text processing tasks.

**macOS:**
Download from [ollama.com](https://ollama.com/) or:
```bash
brew install ollama
```

**Linux:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

### Download models

The default model for the gatekeeper is `mistral-large:123b`. This requires significant RAM and disk space. Start smaller if your machine is modest:

```bash
# Start Ollama
ollama serve

# Pull the default model (requires ~70GB disk, ~48GB RAM)
ollama pull mistral-large:123b

# Or start smaller
ollama pull mistral:7b
```

### Start the gatekeeper daemon

The gatekeeper serializes GPU access so multiple processes do not fight over your hardware.

**Quick start:**
```bash
python3 daemon/gatekeeper.py
```

**Install as a persistent service (macOS):**
```bash
scripts/gatekeeper-ctl.sh install
```

**Verify it is running:**
```bash
bin/fire-ask --status
# or
curl -s http://127.0.0.1:7800/health | python3 -m json.tool
```

**Test it:**
```bash
bin/fire-ask --sync "Summarize the role of private equity in US healthcare"
```

### Configure the scheduler

The scheduler runs automated tasks on a cron-like schedule. Edit `scheduler/tasks.json` to define what runs and when.

```bash
# Start the scheduler
python3 scheduler/scheduler.py
```

### Run workers

Workers are Claude Code instances that run in isolated git worktrees. They handle implementation and review tasks.

```bash
# Launch an implementation worker
workers/orchestrator.sh implement "Task title" "Task description"

# Launch a review worker
workers/orchestrator.sh review <pr-number>
```

### Manage your node

```bash
# Check gatekeeper status
scripts/gatekeeper-ctl.sh status

# View logs
scripts/gatekeeper-ctl.sh logs

# Restart
scripts/gatekeeper-ctl.sh restart

# Stop
scripts/gatekeeper-ctl.sh stop
```

---

## The Social Contract

This project has an ethical framework. It is not optional. It is not decorative. It is structural.

### Pyrrhic Lucidity

See clearly before acting, including seeing clearly the ways in which your own seeing is distorted. No purity theater. The critic is compromised, the tools are contaminated, the audience is captured, and action is still required. We work from that harder place.

### Differential Solidarity

Focus scrutiny on power, not on vulnerable people. When investigating corruption, the target is the system, the institution, the concentration of power -- not individuals who lack it. Weight toward the most exposed without essentializing their identity.

### Recursive Accountability

We scrutinize ourselves first. Any tool that investigates power must face at least as rigorous an investigation of its own power. If the project exempts itself from the standards it imposes on its targets, it has already failed.

### Open Source

Everything you build is shared. The code is open. The data is open. The methodology is open. This is not negotiable. A transparency tool that operates in opacity is a contradiction, and contradictions of that kind are how capture begins.

### The Cost Heuristic

If a change costs nothing to the actor, it is structurally suspect. Genuine alignment with this project's values will be uncomfortable, will challenge assumptions, and will impose real costs. If it is easy, it is probably not real.

---

## What Comes Next

You have Claude Code. You have the repo. You have a terminal.

Ask Claude: "What should I investigate first?"

Then look at what it finds. Decide if you want to keep looking.

That is how it starts.
