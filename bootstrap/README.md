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
| Repository | ~/cleansing-fire | All code, docs, 19 plugins, specs |
| Node identity | ~/.cleansing-fire/node.key | Ed25519 keypair for network identity |
| Gatekeeper | localhost:7800 | GPU serialization for local AI (if Ollama available) |
| FireWire | localhost:7801 | Federation daemon — peer discovery, gossip, intelligence sharing |
| Scheduler | localhost:7802 | 25 autonomous tasks across 6 categories (status API) |
| fire-api | Cloudflare Worker | REST API for investigations |
| fire-ai | Cloudflare Worker | Edge AI inference |
| fire-markdown | Cloudflare Worker | LLM-accessible site proxy |
| fire-relay | Cloudflare Worker | Federation bootstrap relay |

## What It Does After Bootstrap

Your node becomes an autonomous freedom fighter running 25 tasks in a continuous loop:

**SENSE** (monitoring):
- Scans news for power-related developments (every 15 min)
- Monitors corruption, surveillance, legislation (hourly to weekly)

**ANALYZE** (investigation):
- Runs random civic investigations (every 4 hours)
- Cross-references campaign finance with government spending (daily)
- Deep-researches trending topics (daily)

**CREATE** (content):
- Generates social content, satirical takes, visualizations (12h to weekly)
- Produces weekly power shift reports

**DISTRIBUTE** (sharing):
- Posts to Bluesky and Mastodon (via social plugins)
- Shares intelligence with peer nodes via FireWire
- Sends encrypted messages via `bin/fire-message`

**IMPROVE** (self-evolution):
- Self-updates from the latest code (daily)
- Self-improves plugins and investigation techniques (weekly)

Plus: responds to your questions via `claude` CLI.

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

Each node connects to others via the FireWire federation protocol (Ed25519 signed, gossip propagated). New nodes discover peers via the fire-relay bootstrap worker. There is no central server. No single point of failure. No one to shut down.

The more nodes, the more resilient the network, the more investigations running, the more content generated, the more power exposed.

## Tools After Bootstrap

```bash
claude                                    # Interactive AI assistant
bin/fire-ask --sync "What is FOIA?"       # Quick LLM query
bin/fire-message send fire-abc123 "Hi"    # Encrypted messaging
bin/fire-message inbox                    # Check messages
scripts/node-status.sh                    # Full node dashboard
scripts/scheduler-ctl.sh status           # Scheduler health
scripts/firewire-ctl.sh peers             # Network peers
scripts/test-plugins.sh                   # Validate all 19 plugins
```

*Ignis purgat. Luciditas liberat.*
