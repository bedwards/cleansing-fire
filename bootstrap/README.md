# Bootstrap: Zero-Touch Node Deployment

One command. Zero human intervention after that. A complete autonomous civic intelligence node.

## For Humans

```bash
# Step 1: Install Claude Code CLI
curl -fsSL https://cli.claude.ai/install.sh | sh

# Step 2: Ignite
claude --dangerously-skip-permissions -p "$(curl -sL https://raw.githubusercontent.com/bedwards/cleansing-fire/main/bootstrap/ignite.md)"
```

That's it. Claude reads the ignite prompt, clones the repo, sets up your machine, deploys edge infrastructure, connects to the network, and begins autonomous operation.

## What Gets Installed

| Component | Where | What It Does |
|-----------|-------|-------------|
| Repository | ~/cleansing-fire | All code, docs, plugins, specs |
| Node identity | ~/.cleansing-fire/node.key | Ed25519 keypair for network identity |
| Gatekeeper | localhost:7800 | GPU serialization for local AI (if Ollama available) |
| Scheduler | ~/.cleansing-fire/ | Cron + event-triggered autonomous tasks |
| fire-api | Cloudflare Worker | REST API for investigations |
| fire-ai | Cloudflare Worker | Edge AI inference |
| fire-markdown | Cloudflare Worker | LLM-accessible site proxy |

## What It Does After Bootstrap

Your node becomes an autonomous freedom fighter:
- Monitors news for power-related developments (every 15 min)
- Runs random civic investigations (every 4 hours)
- Generates and distributes content (every 12 hours)
- Deep-researches trending topics (daily)
- Self-updates from the latest code (daily)
- Generates weekly power shift reports
- Responds to your questions via `claude` CLI
- Communicates with other nodes in the network

## Files

| File | Purpose |
|------|---------|
| `ignite.md` | The initial prompt that Claude Code reads to start bootstrap |
| `setup-node.sh` | Shell script that handles the actual installation |
| `README.md` | This file |

## Requirements

- **Claude Code CLI** with an Anthropic API key ($200/mo Max plan recommended)
- **macOS or Linux** (personal hardware)
- **Internet connection**
- Optional: Ollama (for local GPU inference)
- Optional: Cloudflare account (for edge deployment)
- Optional: GitHub account (for development workflow participation)

## Cost

| Component | Cost | Required |
|-----------|------|----------|
| Claude Code Max | $200/mo | Recommended (API works too) |
| Cloudflare Workers | $0-5/mo | Optional (free tier covers most) |
| Personal hardware | $0 | Whatever you already have |

## The Network

Each node connects to others via the FireWire federation protocol. There is no central server. No single point of failure. No one to shut down. The more nodes, the more resilient the network, the more investigations running, the more content generated, the more power exposed.

*Ignis purgat. Luciditas liberat.*
