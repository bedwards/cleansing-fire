# GLOBAL EDGE ARCHITECTURE

## Cleansing Fire: Planetary-Scale Autonomous Civic Intelligence Infrastructure

Architecture Date: 2026-02-28
Status: MASTER ARCHITECTURE DOCUMENT
Scale Target: 10 million nodes, 300+ edge locations, every timezone, every language

---

## TABLE OF CONTENTS

1. [Design Principles](#1-design-principles)
2. [Infrastructure Research Summary](#2-infrastructure-research-summary)
3. [The Four Layers](#3-the-four-layers)
4. [Layer 1: The Edge (Cloudflare)](#4-layer-1-the-edge)
5. [Layer 2: The Core (GitHub + Local Compute)](#5-layer-2-the-core)
6. [Layer 3: The Network (Federation and Propagation)](#6-layer-3-the-network)
7. [Layer 4: The People (Human Interface)](#7-layer-4-the-people)
8. [The Headless AI System](#8-the-headless-ai-system)
9. [The Recruitment Protocol](#9-the-recruitment-protocol)
10. [The Content Distribution Network](#10-the-content-distribution-network)
11. [Security, Trust, and Adversarial Resilience](#11-security-trust-and-adversarial-resilience)
12. [Cost Analysis and Scaling Economics](#12-cost-analysis-and-scaling-economics)
13. [Implementation Roadmap](#13-implementation-roadmap)
14. [Failure Modes and Mitigations](#14-failure-modes-and-mitigations)

---

## 1. DESIGN PRINCIPLES

These principles are derived from Pyrrhic Lucidity. Every architectural decision is measured against them.

### 1.1 Unstoppability Through Distribution

No single point of failure. No single entity that can be pressured, subpoenaed, or shut down to kill the network. The system must survive the loss of any node, any provider, any country. Cloudflare is a tool, not a dependency. GitHub is a convenience, not a requirement. Every layer has a fallback. Every fallback has a fallback.

### 1.2 Minimum Viable Trust

No node trusts any other node completely. Content is cryptographically signed. Reputation is earned through verifiable contribution. The system assumes every participant -- human and AI -- is potentially compromised, and designs accordingly. This is not paranoia; it is the Corruption Gradient applied to infrastructure.

### 1.3 Cost as Accountability

Free resources attract freeloaders and state actors. Every node must contribute something real -- compute, data, verification, distribution, or money. The contribution need not be large, but it must be nonzero. If participation costs nothing, participation means nothing.

### 1.4 Intelligence at the Edge

Do not centralize computation. Run inference where users are. Cache knowledge where it is needed. Let the edge be smart, not just a proxy. Every edge node should be capable of independent operation if disconnected from the core.

### 1.5 Agent-First, Human-Accessible

The primary users of this infrastructure are autonomous AI agents. The system is designed for machine-speed coordination, programmatic interfaces, structured data exchange. But every function must also be accessible to a human with a web browser, a command line, or an email client. The system serves humans through agents, not despite them.

### 1.6 Recursive Self-Modification

The system must be capable of modifying itself. New capabilities, new integrations, new defenses -- all must be deployable without human intervention when necessary, but with human oversight when available. The system creates GitHub issues for itself, implements features, reviews its own code, and deploys changes. Human approval is the default gate, but the gate can be opened wider or narrower depending on urgency.

---

## 2. INFRASTRUCTURE RESEARCH SUMMARY

### 2.1 Cloudflare Platform (as of February 2026)

#### Workers
- Serverless functions running at 300+ edge locations in 100+ countries
- Free tier: 100,000 requests/day, 10ms CPU time per invocation
- Paid tier ($5/month base): 10 million requests/month, 30 million CPU-ms, $0.30/million additional requests
- 128MB memory limit per Worker
- Supports JavaScript, TypeScript, Python, Rust (via WASM)
- Static asset serving built directly into Workers (Pages is now in maintenance mode; Workers is the future)
- Workers Builds: automatic CI/CD from GitHub/GitLab

#### Workers AI
- 50+ models available for serverless inference at 200+ edge cities
- LLMs: Llama 3.3 70B (with speculative decoding, 2-4x faster), Llama 3.2 (multilingual), Qwen 2.5 Coder 32B (code generation matching GPT-4o), Mistral 7B
- Speech: Whisper (transcription), Deepgram Nova 3 (real-time STT), Deepgram Aura 2 (TTS)
- Vision: Leonardo Phoenix and Lucid Origin (image generation)
- Embeddings: EmbeddingGemma (300M params, vector representations for search/retrieval)
- Safety: Llama Guard 3 (content classification)
- Batch inference API for bulk operations (summarization, embeddings at scale)
- OpenAI-compatible API format
- Free tier includes limited inference; paid scales with usage

#### KV (Key-Value Store)
- Eventually consistent global key-value store
- p99 read latency under 5ms after 2025 rearchitecture (down from 200ms)
- Hot key reads: 500 microseconds to 10ms
- Changes visible locally immediately, globally within 60 seconds
- Unlimited reads on free tier; paid tier included with $5/month Workers plan
- Hybrid storage architecture (distributed databases + object storage)
- Maximum value size: 25MB
- No limit on number of keys per namespace

#### D1 (SQLite at the Edge)
- SQLite databases accessible from Workers
- 10GB per database, up to 50,000 databases per Worker
- Read replicas automatically distributed across Cloudflare's global network
- Near-zero latency for reads from nearest edge location
- Time Travel: point-in-time recovery to any minute within 30 days
- Single-threaded writes; reads scale horizontally
- 6 simultaneous connections per Worker invocation
- Free tier: 5 million rows read/day, 100K rows written/day
- Perfect for structured civic data (legislation, voting records, official statements)

#### R2 (Object Storage)
- S3-compatible API, zero egress fees
- Free tier: 10GB storage, 1M Class A operations, 10M Class B operations per month
- Paid: $0.015/GB-month standard, $0.01/GB-month infrequent access
- No egress charges ever (via Workers API, S3 API, or r2.dev domains)
- Ideal for multimedia: SVGs, generated images, audio, video, PDFs, datasets

#### Durable Objects
- Stateful serverless functions with globally unique names
- Each has embedded SQLite database with strong consistency
- WebSocket support with Hibernation API (connections persist while object sleeps, zero cost during hibernation)
- One object per logical unit (per coordination room, per session, per agent)
- Now available on free tier (as of April 2025)
- Recommended replacement for Pub/Sub (which ended beta August 2025)
- Use @cloudflare/actors library for fan-out and broadcast messaging

#### Queues
- Message queuing with at-least-once delivery
- 5,000 messages/second per queue throughput
- 250 concurrent consumers
- Pull-based consumers available (HTTP pull from any environment)
- Dead letter queues for failed messages
- Individual message acknowledgment within batches
- Available on free tier (as of February 2026)
- Event subscriptions from KV, R2, Workers AI, Vectorize

#### Vectorize
- Globally distributed vector database for embeddings
- 50K namespaces/indexes per account
- 5 million vectors per index
- Integrated with Workers AI for embedding generation
- Semantic search, classification, recommendation, anomaly detection
- Bring your own embeddings from OpenAI, Cohere, or any provider

#### AI Gateway
- Proxy for AI API calls (OpenAI, Anthropic, Workers AI, Hugging Face)
- Caching, rate limiting, logging, cost tracking
- Free tier: 100K logs/month; paid: 1M logs/month
- Can consolidate billing for third-party model usage
- One line of code to integrate

#### Email Workers
- Process incoming email programmatically
- Route, reject, forward, or drop based on Worker logic
- AI-powered email parsing, summarization, labeling
- Threaded replies supported (March 2025)
- Can maintain email conversations with Worker scripts

#### Hyperdrive
- Database connection pooling and acceleration for external PostgreSQL/MySQL
- Transaction-mode pooling
- Regional prepared statement caching (5x faster cache hits as of May 2025)
- Free tier: 5 connections minimum; paid: up to 100

#### WebSockets
- Bi-directional real-time communication via Durable Objects
- Hibernation API: connections persist at zero cost when idle
- Automatic wake on message arrival
- Ideal for real-time agent coordination, live dashboards, collaborative editing

### 2.2 GitHub Platform

#### GitHub Actions
- CI/CD with cron scheduling (minimum 5-minute intervals)
- Matrix builds for parallel execution
- 2,000 minutes/month free (public repos unlimited)
- Secrets management for API keys
- Self-hosted runners possible for heavy compute
- Claude Code Action (official Anthropic integration) for autonomous agent workflows

#### GitHub as Infrastructure
- Repos as source of truth (code, data, configuration)
- Issues as global task queue (structured, searchable, API-accessible)
- PRs as review workflow (automated creation, automated review)
- Discussions as long-form deliberation
- Pages for fallback static hosting
- API: full programmatic access to everything
- Codespaces: cloud development environments for contributors

### 2.3 Claude Code as Autonomous Agent

- Claude Code Action: official GitHub Actions integration for autonomous AI workflows
- Can read issues, implement code, create PRs, respond to comments
- Multi-agent collaboration with Copilot and other Claude instances
- Autonomous development loops with exit detection and safety guardrails
- v2.1.0 (January 2026): enhanced MCP support, deeper GitHub Actions integration

---

## 3. THE FOUR LAYERS

```
+------------------------------------------------------------------+
|                    LAYER 4: THE PEOPLE                            |
|    Browsers  |  CLIs  |  Email  |  Fediverse  |  Bluesky  |  SMS |
+------------------------------------------------------------------+
         |              |              |              |
+------------------------------------------------------------------+
|                    LAYER 3: THE NETWORK                           |
|  Federation Protocol  |  Content Propagation  |  Trust Mesh      |
+------------------------------------------------------------------+
         |              |              |              |
+------------------------------------------------------------------+
|                    LAYER 2: THE CORE                              |
|  GitHub Repos  |  GitHub Actions  |  Local GPU Nodes  |  Ollama  |
+------------------------------------------------------------------+
         |              |              |              |
+------------------------------------------------------------------+
|                    LAYER 1: THE EDGE                              |
|  CF Workers  |  Workers AI  |  KV/D1/R2  |  Durable Objects     |
+------------------------------------------------------------------+
         |              |              |              |
    [300+ Cloudflare Edge Locations Worldwide]
```

Intelligence flows in both directions. Content is created at any layer and propagates through the others. Data collected at the edge flows to the core for deep analysis. Analysis from the core flows to the edge for fast serving. Users at Layer 4 interact primarily with Layer 1 (fast, local) but can reach deeper layers for specialized operations.

---

## 4. LAYER 1: THE EDGE

### 4.1 Architecture Overview

The edge layer is the public face of Cleansing Fire. It handles every user request, serves every page, runs lightweight AI inference, caches global civic data, stores multimedia assets, and coordinates real-time communication between nodes. The edge is designed to be independently functional -- if GitHub goes down, if the local compute nodes go dark, the edge continues to serve cached content, run inference on cached models, and accept user contributions for later synchronization.

```
User Request (any country)
       |
       v
[Cloudflare Worker - Nearest Edge Location]
       |
       +---> Static Assets (Workers static serving)
       +---> API Routes (Worker logic)
       |        |
       |        +---> Workers AI (edge inference)
       |        +---> KV (configuration, cached content, feature flags)
       |        +---> D1 (structured civic data - legislation, records, votes)
       |        +---> R2 (multimedia - images, audio, video, SVGs, PDFs)
       |        +---> Vectorize (semantic search over civic knowledge)
       |        +---> Durable Objects (coordination, real-time, agent state)
       |        +---> Queues (async task dispatch)
       |        +---> Email Workers (incoming email processing)
       |
       +---> AI Gateway (proxied calls to Anthropic/OpenAI when needed)
```

### 4.2 The Edge Worker: fire-edge

The primary Worker is a single entry point that routes requests across all Cleansing Fire services. It is deployed once and runs everywhere.

```
fire-edge/
├── src/
│   ├── index.ts              # Router: maps paths to handlers
│   ├── handlers/
│   │   ├── site.ts           # Public website serving
│   │   ├── api.ts            # REST API for agents and tools
│   │   ├── inference.ts      # Workers AI inference endpoint
│   │   ├── search.ts         # Semantic search over civic data
│   │   ├── content.ts        # Content retrieval and caching
│   │   ├── submit.ts         # User/agent content submission
│   │   ├── federation.ts     # Inter-node communication
│   │   └── webhook.ts        # GitHub/external webhook handler
│   ├── middleware/
│   │   ├── auth.ts           # Token validation, trust levels
│   │   ├── ratelimit.ts      # Per-IP and per-token rate limiting
│   │   ├── geo.ts            # Geolocation-aware routing
│   │   └── cache.ts          # Intelligent caching layer
│   ├── services/
│   │   ├── civic-data.ts     # D1 queries for civic data
│   │   ├── knowledge.ts      # Vectorize semantic operations
│   │   ├── media.ts          # R2 media operations
│   │   ├── coordination.ts   # Durable Object management
│   │   └── queue.ts          # Queue dispatch
│   └── types/
│       └── index.ts          # Shared type definitions
├── wrangler.toml             # Cloudflare configuration
└── migrations/               # D1 schema migrations
```

### 4.3 Workers AI: Edge Intelligence

Workers AI enables every edge location to run inference without calling back to a central server. This is the key capability that makes planetary-scale civic intelligence possible.

#### Inference Endpoints

```typescript
// POST /api/v1/analyze
// Run civic analysis on any text at the edge
interface AnalyzeRequest {
  text: string;
  type: "legislation" | "statement" | "financial" | "general";
  locale?: string;       // e.g., "en-US", "es-MX", "fr-FR"
  depth?: "quick" | "standard" | "deep";
}

// "quick" -> Mistral 7B at the edge (< 2 seconds)
// "standard" -> Llama 3.2 at the edge (< 5 seconds)
// "deep" -> Queued to core for Llama 3.3 70B or Claude Opus
```

#### Model Selection Strategy

| Task | Model | Location | Latency |
|------|-------|----------|---------|
| Content classification | Llama Guard 3 | Edge | < 500ms |
| Quick summarization | Mistral 7B | Edge | < 2s |
| Multilingual analysis | Llama 3.2 (multilingual) | Edge | < 5s |
| Code generation/analysis | Qwen 2.5 Coder 32B | Edge | < 10s |
| Embedding generation | EmbeddingGemma | Edge | < 1s |
| Speech transcription | Whisper | Edge | ~1x realtime |
| Text-to-speech | Deepgram Aura 2 | Edge | < 3s |
| Deep policy analysis | Llama 3.3 70B | Edge (batched) | < 30s |
| Maximum quality analysis | Claude Opus (via AI Gateway) | Proxied | < 60s |
| Local heavy inference | Mistral Large 123B (Ollama) | Local GPU | Variable |

#### Batch Inference Pipeline

For bulk operations (e.g., analyzing all legislation introduced in a state session, embedding a corpus of public records), the batch inference API processes arrays of requests:

```typescript
// Nightly batch: embed all new civic documents
const documents = await d1.prepare(
  "SELECT id, text FROM civic_documents WHERE embedded_at IS NULL LIMIT 1000"
).all();

const embeddings = await ai.run("@cf/google/embedding-gemma", {
  text: documents.results.map(d => d.text),
  batch: true
});

// Store in Vectorize for semantic search
await vectorize.upsert(
  documents.results.map((d, i) => ({
    id: d.id,
    values: embeddings[i],
    metadata: { type: d.type, jurisdiction: d.jurisdiction }
  }))
);
```

### 4.4 Data Layer: KV, D1, R2, Vectorize

#### KV: Global Configuration and Hot Content

KV is the fastest read path. It stores data that must be accessible everywhere with sub-5ms latency.

**What goes in KV:**
- Feature flags and system configuration
- Cached rendered content (HTML fragments, JSON responses)
- Session tokens and rate limit counters
- Node registry (list of known nodes, their capabilities, their trust levels)
- Breaking alerts and urgent notifications
- Content routing tables (which content goes where)

**KV Namespace Design:**
```
cf-config:       System configuration, feature flags
cf-content:      Rendered content cache (keyed by content hash)
cf-nodes:        Node registry and status
cf-alerts:       Active alerts and notifications
cf-sessions:     Session state and auth tokens
cf-routing:      Content distribution routing tables
```

#### D1: Structured Civic Data

D1 is the relational backbone. It stores structured data that needs SQL queries, joins, aggregations, and time-series analysis. With 50,000 databases available per Worker, we shard by jurisdiction.

**Database Sharding Strategy:**
```
civic_federal          # US federal legislation, spending, courts
civic_us_ny            # New York state data
civic_us_ca            # California state data
civic_us_tx            # Texas state data
...                    # One database per state/territory
civic_local_nyc        # New York City local data
civic_local_la         # Los Angeles local data
...                    # One database per major municipality
civic_intl_uk          # United Kingdom
civic_intl_eu          # European Union
...                    # One database per country/union
meta_agents            # Agent activity logs, task tracking
meta_content           # Content creation and distribution tracking
meta_network           # Network health, node metrics
```

**Core Schema (per jurisdiction database):**
```sql
-- Legislation tracking
CREATE TABLE legislation (
  id TEXT PRIMARY KEY,
  jurisdiction TEXT NOT NULL,
  chamber TEXT,                    -- house, senate, council, parliament
  bill_number TEXT NOT NULL,
  title TEXT NOT NULL,
  summary TEXT,
  full_text TEXT,
  status TEXT NOT NULL,            -- introduced, committee, floor, passed, signed, vetoed
  introduced_date TEXT,
  last_action_date TEXT,
  sponsors TEXT,                   -- JSON array of sponsor IDs
  subjects TEXT,                   -- JSON array of subject tags
  ai_analysis TEXT,                -- AI-generated plain language analysis
  ai_impact_score REAL,            -- -1.0 (harmful) to 1.0 (beneficial)
  ai_analyzed_at TEXT,
  source_url TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

-- Elected officials
CREATE TABLE officials (
  id TEXT PRIMARY KEY,
  jurisdiction TEXT NOT NULL,
  name TEXT NOT NULL,
  office TEXT NOT NULL,
  party TEXT,
  district TEXT,
  contact_info TEXT,               -- JSON: email, phone, office address
  social_media TEXT,               -- JSON: twitter, bluesky, mastodon handles
  voting_record TEXT,              -- JSON: summary statistics
  financial_summary TEXT,          -- JSON: top donors, total raised
  ai_profile TEXT,                 -- AI-generated behavioral profile
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

-- Public financial records
CREATE TABLE expenditures (
  id TEXT PRIMARY KEY,
  jurisdiction TEXT NOT NULL,
  agency TEXT NOT NULL,
  vendor TEXT,
  amount REAL NOT NULL,
  category TEXT,
  description TEXT,
  date TEXT NOT NULL,
  source_url TEXT,
  ai_flags TEXT,                   -- AI-detected anomalies
  created_at TEXT DEFAULT (datetime('now'))
);

-- Voting records
CREATE TABLE votes (
  id TEXT PRIMARY KEY,
  legislation_id TEXT REFERENCES legislation(id),
  official_id TEXT REFERENCES officials(id),
  vote TEXT NOT NULL,              -- yea, nay, abstain, absent
  date TEXT NOT NULL,
  created_at TEXT DEFAULT (datetime('now'))
);

-- Cross-references (who funds whom, who lobbies for what)
CREATE TABLE connections (
  id TEXT PRIMARY KEY,
  source_type TEXT NOT NULL,       -- official, donor, lobbyist, organization
  source_id TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id TEXT NOT NULL,
  relationship TEXT NOT NULL,      -- funds, lobbies_for, employed_by, related_to
  evidence TEXT,                   -- JSON array of source documents
  ai_confidence REAL,
  created_at TEXT DEFAULT (datetime('now'))
);

-- Full-text search index
CREATE VIRTUAL TABLE legislation_fts USING fts5(
  title, summary, full_text, ai_analysis,
  content=legislation, content_rowid=rowid
);
```

#### R2: Multimedia Content Storage

R2 stores everything that is not structured data or configuration. Zero egress fees make it ideal for content that will be accessed millions of times from anywhere in the world.

**Bucket Structure:**
```
cf-media/
├── svg/                    # Generated SVG visualizations
│   ├── legislation/        # Bill impact diagrams
│   ├── networks/           # Connection/influence maps
│   ├── spending/           # Budget visualizations
│   └── timelines/          # Legislative timelines
├── images/                 # Generated and sourced images
│   ├── social/             # Social media cards (OG images)
│   ├── infographics/       # Data infographics
│   └── portraits/          # Official portraits (public domain)
├── audio/                  # Generated audio content
│   ├── summaries/          # TTS bill summaries
│   ├── podcasts/           # Auto-generated civic podcasts
│   └── alerts/             # Audio alerts
├── video/                  # Generated video content
│   ├── explainers/         # Short-form explainer videos
│   └── testimony/          # Public testimony recordings
├── documents/              # PDFs, datasets, reports
│   ├── analysis/           # AI-generated analysis reports
│   ├── source/             # Original source documents
│   └── datasets/           # Downloadable datasets
└── cache/                  # Temporary processing cache
```

#### Vectorize: Semantic Knowledge Graph

Vectorize enables semantic search across all civic knowledge. Instead of keyword matching, users and agents can search by meaning.

**Index Design:**
```
legislation-embeddings     # All legislation text and summaries
official-embeddings        # Official statements, speeches, records
spending-embeddings        # Expenditure descriptions and patterns
connection-embeddings      # Relationship evidence and descriptions
content-embeddings         # All generated content (articles, analyses)
user-query-embeddings      # Historical queries for recommendation
```

**Search Flow:**
```
User: "Who is profiting from the prison system in New York?"
    |
    v
[Edge Worker] -> EmbeddingGemma -> query vector
    |
    v
[Vectorize] -> semantic search across:
    - spending-embeddings (prison-related expenditures)
    - connection-embeddings (contractor relationships)
    - official-embeddings (relevant official statements)
    - legislation-embeddings (related legislation)
    |
    v
[Workers AI - Llama 3.2] -> synthesize results into answer
    |
    v
User receives: structured answer with sources, confidence scores,
               links to primary documents, related visualizations
```

### 4.5 Durable Objects: Real-Time Coordination

Durable Objects provide the stateful coordination primitives that enable the network to operate as a coherent system rather than a collection of isolated nodes.

#### Agent Coordination Rooms

Each active task gets a Durable Object that acts as a coordination room. Multiple agents -- edge workers, GitHub Action agents, local compute nodes -- can connect and synchronize.

```typescript
// CoordinationRoom Durable Object
export class CoordinationRoom extends DurableObject {
  private sql: SqlStorage;
  private sessions: Map<string, WebSocket> = new Map();

  constructor(state: DurableObjectState, env: Env) {
    super(state, env);
    this.sql = state.storage.sql;
    this.sql.exec(`
      CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT NOT NULL,
        type TEXT NOT NULL,
        payload TEXT NOT NULL,
        timestamp TEXT DEFAULT (datetime('now'))
      );
      CREATE TABLE IF NOT EXISTS participants (
        id TEXT PRIMARY KEY,
        role TEXT NOT NULL,
        trust_level INTEGER NOT NULL,
        joined_at TEXT DEFAULT (datetime('now')),
        last_seen TEXT DEFAULT (datetime('now'))
      );
    `);
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/ws") {
      // WebSocket connection with Hibernation
      const pair = new WebSocketPair();
      const [client, server] = Object.values(pair);
      this.ctx.acceptWebSocket(server);
      return new Response(null, { status: 101, webSocket: client });
    }

    if (url.pathname === "/state") {
      // Return current room state
      const messages = this.sql.exec(
        "SELECT * FROM messages ORDER BY id DESC LIMIT 100"
      ).toArray();
      const participants = this.sql.exec(
        "SELECT * FROM participants"
      ).toArray();
      return Response.json({ messages, participants });
    }

    if (url.pathname === "/broadcast") {
      // Broadcast message to all connected participants
      const message = await request.json();
      this.sql.exec(
        "INSERT INTO messages (sender, type, payload) VALUES (?, ?, ?)",
        message.sender, message.type, JSON.stringify(message.payload)
      );
      for (const ws of this.ctx.getWebSockets()) {
        ws.send(JSON.stringify(message));
      }
      return new Response("OK");
    }

    return new Response("Not found", { status: 404 });
  }

  // WebSocket Hibernation handlers
  async webSocketMessage(ws: WebSocket, message: string) {
    const data = JSON.parse(message);
    // Re-broadcast to all other connected sockets
    for (const peer of this.ctx.getWebSockets()) {
      if (peer !== ws) {
        peer.send(message);
      }
    }
    // Persist to SQLite
    this.sql.exec(
      "INSERT INTO messages (sender, type, payload) VALUES (?, ?, ?)",
      data.sender, data.type, JSON.stringify(data.payload)
    );
  }

  async webSocketClose(ws: WebSocket) {
    // Clean up participant
  }
}
```

#### Network Heartbeat Object

A global Durable Object that tracks the health and availability of all nodes in the network.

```typescript
export class NetworkHeartbeat extends DurableObject {
  async alarm() {
    // Run every 60 seconds
    // Check all registered nodes
    // Update KV with current network status
    // Alert if critical nodes are down
    this.ctx.storage.setAlarm(Date.now() + 60_000);
  }
}
```

### 4.6 Queues: Async Task Processing

Queues decouple the fast edge response from slower backend processing. When a user submits content, the edge acknowledges immediately and queues the heavy work.

**Queue Design:**
```
cf-analysis-queue        # Content analysis tasks (legislation, statements)
cf-embedding-queue       # Embedding generation for new content
cf-distribution-queue    # Content distribution to external platforms
cf-notification-queue    # User/agent notification delivery
cf-sync-queue            # Data synchronization between layers
cf-audit-queue           # Audit trail events
```

**Flow Example: New Legislation Detected**
```
1. Scheduled Worker checks LegiScan API
2. New bill found -> write to D1
3. Queue message to cf-analysis-queue:
   { type: "analyze_legislation", id: "NY-S1234-2026" }
4. Analysis consumer:
   a. Pull full text from LegiScan
   b. Run Llama 3.2 for plain-language summary
   c. Run Llama 3.3 70B for impact analysis
   d. Generate embedding via EmbeddingGemma
   e. Store results in D1, embedding in Vectorize
   f. Queue to cf-distribution-queue
5. Distribution consumer:
   a. Generate social media posts
   b. Generate SVG visualization -> R2
   c. Generate audio summary via Deepgram Aura 2 -> R2
   d. Post to Bluesky, Mastodon, Matrix
   e. Send email alerts to subscribers
   f. Update KV cache with rendered content
```

### 4.7 Email Workers: Civic Communication

Email Workers provide an alternative interface for people who do not use social media or web browsers. This is critical for reaching older populations, incarcerated people, people in areas with limited internet, and people who have deliberately de-platformed.

**Capabilities:**
```
incoming email to tips@cleansingfire.org
    |
    v
[Email Worker]
    |
    +---> Parse sender, subject, body
    +---> Run Llama Guard 3 for safety classification
    +---> Run Llama 3.2 for intent classification:
    |        "tip"       -> queue for investigation
    |        "question"  -> generate and reply with answer
    |        "subscribe" -> add to notification list
    |        "data"      -> parse and ingest civic data
    |        "agent"     -> forward to agent coordination
    +---> Threaded reply with acknowledgment
    +---> Store in D1 for audit trail
```

---

## 5. LAYER 2: THE CORE

### 5.1 Architecture Overview

The core layer is the heavy-compute backbone. It runs deep analysis that exceeds edge capabilities, coordinates autonomous AI agents, maintains the canonical data repositories, and performs the most sensitive operations (code changes, security reviews, trust updates).

```
[GitHub Organization: cleansing-fire]
    |
    +---> cleansing-fire/            # Main codebase (this repo)
    +---> civic-data/                # Canonical civic datasets
    +---> content-archive/           # All generated content
    +---> agent-configs/             # Agent definitions and policies
    +---> node-registry/             # Network node configurations
    +---> trust-ledger/              # Trust scores and audit trail
    |
[GitHub Actions]
    |
    +---> Scheduled workflows (cron)
    |        +---> Data collection (legislation, spending, FEC)
    |        +---> Content generation pipeline
    |        +---> Network health monitoring
    |        +---> Edge deployment
    +---> Event-driven workflows
    |        +---> Issue created -> agent assignment
    |        +---> PR created -> automated review
    |        +---> Webhook received -> process and respond
    +---> Claude Code Agent workflows
             +---> Autonomous implementation
             +---> Autonomous review
             +---> Autonomous research
    |
[Local Compute Nodes]
    |
    +---> bedwards' system (GPU node)
    |        +---> Gatekeeper daemon (port 7800)
    |        +---> Ollama (mistral-large:123b)
    |        +---> Claude Code interactive sessions
    |        +---> Worker orchestrator (git worktrees)
    +---> [Future contributor nodes]
```

### 5.2 GitHub as Operating System

GitHub is not just a code host. It is the operating system for the entire network's coordination.

#### Issues as Global Task Queue

Every unit of work in the system is a GitHub issue. Issues are the universal task format that both humans and AI agents understand.

```markdown
## Issue Types (via labels):

### Automated (created by agents)
- `auto/data-collection`    - Scheduled data ingestion task
- `auto/analysis`           - Content needs AI analysis
- `auto/content-generation` - Content creation task
- `auto/distribution`       - Content needs distribution
- `auto/maintenance`        - System maintenance task
- `auto/security`           - Security concern detected
- `auto/anomaly`            - Anomalous data pattern found

### Human-Created
- `human/investigation`     - Investigate a tip or lead
- `human/feature`           - New feature request
- `human/bug`               - Bug report
- `human/policy`            - Policy discussion
- `human/governance`        - Governance proposal

### Priority
- `P0/critical`             - Immediate action required
- `P1/urgent`               - Address within 24 hours
- `P2/normal`               - Address within a week
- `P3/low`                  - Address when capacity allows

### Trust Level Required
- `trust/public`            - Any agent can work on this
- `trust/verified`          - Verified agents only
- `trust/core`              - Core team agents only
- `trust/human-required`    - Human must approve
```

#### Automated Issue-to-Deployment Pipeline

```
1. Event detected (new legislation, anomalous spending, etc.)
2. GitHub Action creates issue:
   Title: "[auto/analysis] NY S1234 - Prison Labor Expansion Act"
   Body: structured data about the legislation
   Labels: auto/analysis, P1/urgent, trust/verified
3. Claude Code Action picks up issue:
   - Reads issue body
   - Pulls full legislation text
   - Runs deep analysis
   - Creates implementation branch: cf/42-ny-s1234-analysis
   - Writes analysis to content-archive repo
   - Creates PR referencing issue
4. Review agent picks up PR:
   - Checks analysis for accuracy, bias, completeness
   - Approves or requests changes
5. Merge triggers deployment:
   - GitHub Action runs
   - Updates D1 with analysis
   - Updates R2 with generated visualizations
   - Updates KV cache
   - Queues distribution to social platforms
   - Closes issue
```

### 5.3 Local Compute Nodes

Local compute nodes provide capabilities that neither the edge nor GitHub Actions can deliver: sustained GPU inference on large models, interactive human-AI collaboration, and operations that require secrets or access too sensitive for cloud environments.

#### Gatekeeper Protocol

The existing Gatekeeper daemon (port 7800) serializes GPU access. For the global architecture, it becomes a registered network node that accepts tasks from the edge and core layers.

```
[Edge/Core] ---> HTTPS ---> [Gatekeeper API]
                                   |
                                   v
                            [Task Queue (max 5)]
                                   |
                                   v
                            [Ollama - mistral-large:123b]
                                   |
                                   v
                            [Result] ---> [Callback to requester]
```

**Enhanced Gatekeeper Capabilities:**
- Accept tasks from authenticated edge Workers via webhook
- Accept tasks from GitHub Actions via API
- Report health status to Network Heartbeat Durable Object
- Publish results to Queues for downstream processing
- Run models too large for Workers AI (mistral-large 123B, local fine-tuned models)
- Process sensitive data that should not leave the local network

#### Worker Orchestrator Enhancement

The existing worker orchestrator (workers/orchestrator.sh) launches Claude Code instances in git worktrees. For the global architecture, it becomes the local agent manager:

```bash
# Current capability (preserved):
workers/orchestrator.sh implement "Task title" "Description"
workers/orchestrator.sh review <pr-number>

# Enhanced capability (new):
workers/orchestrator.sh agent start <agent-config>     # Start persistent agent
workers/orchestrator.sh agent stop <agent-id>          # Stop agent
workers/orchestrator.sh agent status                    # List running agents
workers/orchestrator.sh fleet deploy <fleet-config>    # Deploy agent fleet
workers/orchestrator.sh fleet status                    # Fleet health
```

### 5.4 Scheduler Enhancement

The existing scheduler (scheduler/scheduler.py) handles cron-like tasks. For the global architecture, it coordinates with the edge layer:

```python
# Enhanced schedule entries
SCHEDULE = {
    # Data collection (runs locally, pushes to edge)
    "collect_federal_legislation": {
        "cron": "0 */4 * * *",    # Every 4 hours
        "plugin": "civic-legiscan",
        "params": {"jurisdiction": "federal"},
        "on_complete": "sync_to_edge"
    },
    "collect_fec_data": {
        "cron": "0 6 * * *",      # Daily at 6 AM
        "plugin": "civic-fec",
        "on_complete": "sync_to_edge"
    },
    "collect_spending_data": {
        "cron": "0 3 * * 1",      # Weekly on Monday at 3 AM
        "plugin": "civic-spending",
        "on_complete": "sync_to_edge"
    },

    # Content generation (uses GPU)
    "generate_daily_briefing": {
        "cron": "0 7 * * *",      # Daily at 7 AM
        "plugin": "pipeline-data-to-fire",
        "on_complete": "distribute"
    },

    # Network maintenance
    "heartbeat": {
        "cron": "*/5 * * * *",    # Every 5 minutes
        "action": "report_health_to_edge"
    },
    "sync_edge_data": {
        "cron": "*/15 * * * *",   # Every 15 minutes
        "action": "pull_edge_submissions"
    }
}
```

---

## 6. LAYER 3: THE NETWORK

### 6.1 Federation Protocol

The network layer defines how edge nodes, core nodes, and local nodes discover each other, authenticate, exchange data, and build trust. It is not a blockchain. It is not a DHT. It is a practical federation protocol built on HTTPS, signed messages, and DNS.

#### Node Types

```
+-----------+------------------+--------------------+---------------------+
| Node Type | Capabilities     | Trust Requirements | Example             |
+-----------+------------------+--------------------+---------------------+
| Edge      | Serve content,   | None (Cloudflare   | fire-edge Worker    |
|           | run light AI,    | manages infra)     |                     |
|           | cache data       |                    |                     |
+-----------+------------------+--------------------+---------------------+
| Core      | CI/CD, deep      | GitHub account     | GitHub Actions      |
|           | analysis, code   | with repo access   | runner              |
|           | changes          |                    |                     |
+-----------+------------------+--------------------+---------------------+
| GPU       | Heavy inference, | Verified human     | bedwards' machine,  |
|           | model training,  | operator, signed   | contributor GPU     |
|           | sensitive data   | registration       | rigs                |
+-----------+------------------+--------------------+---------------------+
| Agent     | Autonomous       | Signed agent       | Claude Code in      |
|           | tasks, research, | config, trust      | Actions, local      |
|           | implementation   | level assignment   | Claude sessions     |
+-----------+------------------+--------------------+---------------------+
| Human     | Oversight,       | Account + history  | Contributors,       |
|           | judgment,        | of contribution    | reviewers,          |
|           | governance       |                    | operators           |
+-----------+------------------+--------------------+---------------------+
| Relay     | Content          | Automated          | Fediverse bots,     |
|           | distribution,    | verification of    | Bluesky feeds,      |
|           | amplification    | posting capability | Matrix bridges      |
+-----------+------------------+--------------------+---------------------+
```

#### Node Discovery and Registration

```
New node wants to join the network:

1. DISCOVERY
   - DNS: _cleansing-fire._tcp.cleansingfire.org SRV record
   - Well-known: https://cleansingfire.org/.well-known/cleansing-fire.json
   - Out-of-band: URL shared in README, documentation, word of mouth

2. REGISTRATION
   POST https://cleansingfire.org/api/v1/nodes/register
   {
     "type": "gpu",
     "capabilities": ["inference", "ollama", "mistral-large"],
     "endpoint": "https://mynode.example.com:7800",
     "public_key": "<ed25519 public key>",
     "operator": "<github username>",
     "pledge": "<signed statement of intent>"
   }

3. VERIFICATION
   - Edge Worker verifies the endpoint is reachable
   - Edge Worker issues a challenge (sign this nonce with your key)
   - Node signs and returns
   - Node is registered with trust_level: 0 (probationary)

4. TRUST BUILDING
   - Trust increases through verified contributions:
     +1 for each successful task completion
     +5 for each merged PR
     +10 for each verified data contribution
     -20 for any failed verification
     -100 for any malicious activity (detected by other nodes)
   - Trust levels: 0 (probationary), 1 (basic), 5 (verified),
                   20 (trusted), 100 (core)
```

#### Inter-Node Communication Protocol

All inter-node messages are signed with Ed25519 and contain a chain of trust.

```typescript
interface NodeMessage {
  // Header
  id: string;                    // UUIDv7 (time-ordered)
  from: string;                  // Node ID
  to: string | "*";             // Recipient node ID or broadcast
  type: string;                  // Message type
  timestamp: string;             // ISO 8601
  signature: string;             // Ed25519 signature of payload

  // Routing
  ttl: number;                   // Hops remaining (prevents infinite propagation)
  path: string[];               // Node IDs this message has traversed
  priority: "critical" | "normal" | "low";

  // Payload
  payload: any;                  // Type-specific data
}

// Message Types:
// "heartbeat"     - I am alive, here is my status
// "task.offer"    - I have a task, who can handle it?
// "task.claim"    - I will handle that task
// "task.result"   - Here is the result of a task
// "data.sync"     - Here is new data for your store
// "data.request"  - I need data you might have
// "content.new"   - New content has been created
// "alert"         - Urgent notification
// "trust.vouch"   - I vouch for this node (signed attestation)
// "trust.warn"    - Warning about a node (signed concern)
```

### 6.2 Intelligence Propagation

Intelligence does not sit in one place. It flows through the network via a gossip-like protocol optimized for civic relevance.

#### Content Propagation Algorithm

```
When new content is created (any node):

1. CLASSIFICATION
   - Content is classified by: topic, jurisdiction, urgency, audience
   - Classification runs at the edge (Llama Guard 3 + Llama 3.2)

2. LOCAL STORAGE
   - Content stored in D1 (structured) and R2 (multimedia)
   - Embedding generated and stored in Vectorize

3. ROUTING DECISION
   Based on content metadata, determine distribution:

   Urgency:critical -> ALL nodes immediately, ALL platforms
   Urgency:high     -> Relevant jurisdiction nodes, primary platforms
   Urgency:normal   -> Relevant nodes on next sync cycle
   Urgency:low      -> Available on request only

4. PROPAGATION
   - Push to KV for instant edge availability
   - Queue to cf-distribution-queue for platform posting
   - Broadcast via Durable Object coordination rooms
   - Gossip to peer nodes via NodeMessage protocol

5. ADAPTATION
   - Before posting to each platform, content is adapted:
     - Bluesky: 300 char post + thread + alt text + link
     - Mastodon: 500 char post + content warning if needed + link
     - Matrix: full analysis in room + formatted
     - Email: plain text summary + link to full analysis
     - SMS: ultra-brief alert + short link
     - Web: full interactive page with visualizations
```

#### Knowledge Synchronization

Nodes do not all store everything. Each node stores what is relevant to its jurisdiction and role, plus a percentage of global content for redundancy.

```
Sync Strategy:
  - Core data (federal/national) -> replicated to ALL edge nodes via KV
  - Jurisdiction data -> replicated to relevant regional edge nodes via D1
  - Multimedia -> stored in R2 (single global store, edge-cached by CDN)
  - Embeddings -> Vectorize (globally distributed by default)
  - Agent state -> Durable Objects (accessed by name from anywhere)
  - Hot content -> KV (eventually consistent, sub-60-second propagation)
  - Cold content -> R2 + D1 (pulled on demand)
```

### 6.3 Trust Mesh

Trust is not centralized. There is no single authority that decides who is trusted. Trust is computed from a mesh of attestations.

```
Trust Score Computation:

  trust(node) = base_score(node)
              + sum(vouch_weight(voucher) * vouch(voucher, node))
              - sum(warn_weight(warner) * warn(warner, node))
              + contribution_score(node)
              - violation_score(node)

  Where:
  - base_score: starts at 0 for new nodes
  - vouch_weight: proportional to voucher's own trust score
  - warn_weight: proportional to warner's own trust score
  - contribution_score: cumulative verified contributions
  - violation_score: cumulative detected violations

  Trust is:
  - Publicly auditable (stored in trust-ledger repo)
  - Cryptographically signed (each attestation is signed)
  - Decay-adjusted (old attestations weight less than recent ones)
  - Never permanent (even core nodes can lose trust)
```

---

## 7. LAYER 4: THE PEOPLE

### 7.1 Interface Design

The system must be accessible through every channel humans already use. No new app required. No blockchain wallet. No technical knowledge needed to receive value. Progressive disclosure: simple interfaces reveal complexity only when the user asks for it.

#### Web Interface (Primary)

Served by Workers with static assets. The website is the main public interface.

```
cleansingfire.org/
├── /                          # Landing page: what is this, why it matters
├── /dashboard                 # Global civic health dashboard
│   ├── /dashboard/federal     # Federal legislation tracker
│   ├── /dashboard/[state]     # State-specific dashboard
│   └── /dashboard/[city]      # City-specific dashboard
├── /search                    # Semantic search across all civic data
├── /investigate               # Deep-dive investigation tool
│   ├── /investigate/official/[id]    # Official profile
│   ├── /investigate/bill/[id]        # Bill analysis
│   └── /investigate/money/[id]       # Money trail
├── /alerts                    # Active alerts and breaking analysis
├── /contribute                # How to contribute (human + machine)
├── /api                       # API documentation for agents
└── /node                      # Node operator documentation
```

#### CLI Interface

```bash
# Install
curl -sSL https://cleansingfire.org/install.sh | sh

# Usage
fire search "prison labor legislation new york"
fire analyze https://legislation.nysenate.gov/...
fire alert subscribe --jurisdiction ny --topics "criminal-justice,education"
fire node register --type gpu --endpoint http://localhost:7800
fire agent start --config investigate-spending.json
fire submit --type tip "I found discrepancies in..."
```

#### Email Interface

```
To: search@cleansingfire.org
Subject: prison labor new york

-> Reply with: search results, relevant legislation, key officials

To: analyze@cleansingfire.org
Subject: https://some-legislation-url.gov/bill/1234

-> Reply with: plain language analysis, impact assessment, key provisions

To: alerts@cleansingfire.org
Subject: subscribe ny criminal-justice

-> Reply with: confirmation, you will receive alerts for NY criminal justice

To: tips@cleansingfire.org
Subject: [anything]
Body: [tip content]

-> Reply with: acknowledgment, tip queued for investigation
```

#### Social Media Interface

```
@cleansingfire@mastodon.social
  - Follows you back if you follow
  - Responds to mentions with relevant civic data
  - Posts alerts for your jurisdiction (based on your profile)

@cleansingfire.bsky.social
  - Custom feed: "Civic Intelligence" - AI-curated civic content
  - Responds to mentions
  - Thread-based bill analyses

Matrix: #cleansingfire:matrix.org
  - Real-time alerts channel
  - Discussion rooms per jurisdiction
  - Agent status and coordination visible
```

### 7.2 What Users See

**Casual User (no account):**
- Public dashboard with civic data visualizations
- Search for legislation, officials, spending
- Read AI-generated analyses of current legislation
- Listen to audio summaries
- View infographics and data visualizations

**Registered User (free account):**
- Personalized alerts (jurisdiction, topics)
- Contribution history
- Submit tips and data
- Access to deeper analysis tools
- Voting on governance proposals

**Contributor (verified account + contributions):**
- All of the above
- Access to investigation tools
- Ability to run analysis tasks
- Participation in content review
- Weight in trust attestations

**Node Operator (registered node):**
- All of the above
- Node management dashboard
- Task queue visibility
- Network health monitoring
- Agent configuration and management

### 7.3 Human Contribution Model

Humans contribute in several ways, each with different skill requirements and time commitments:

```
+--------------------+------------------+------------------+---------------+
| Contribution       | Skill Required   | Time Required    | Trust Impact  |
+--------------------+------------------+------------------+---------------+
| Submit a tip       | None             | 2 minutes        | +1            |
| Verify a data point| Basic reading    | 5 minutes        | +2            |
| Review AI analysis | Domain knowledge | 15 minutes       | +5            |
| Contribute data    | Data literacy    | 30+ minutes      | +10           |
| Run a node         | Technical        | Setup + ongoing  | +20           |
| Review code/PRs    | Development      | 30+ minutes      | +10           |
| Governance vote    | Understanding    | 10 minutes       | +1            |
| Recruit a node     | Social           | Variable         | +5            |
| Fund infrastructure| Money            | 1 minute         | +5            |
+--------------------+------------------+------------------+---------------+
```

---

## 8. THE HEADLESS AI SYSTEM

### 8.1 Autonomous Agent Architecture

The headless AI system is the beating heart of Cleansing Fire. It operates without human intervention for routine tasks, while escalating to human judgment for novel, sensitive, or high-impact decisions.

```
+------------------------------------------------------------------+
|                    AGENT ORCHESTRATION LAYER                       |
|                                                                    |
|  [Scheduler]  ->  [Task Queue (Issues)]  ->  [Agent Assignment]  |
|                                                                    |
|  Assignment Rules:                                                 |
|  - Match task type to agent capability                             |
|  - Match trust requirement to agent trust level                    |
|  - Prefer idle agents over busy agents                             |
|  - Prefer local agents for sensitive tasks                         |
|  - Prefer edge agents for fast, public tasks                      |
+------------------------------------------------------------------+
         |              |              |              |
   [Data Agent]   [Analysis Agent] [Content Agent] [Ops Agent]
         |              |              |              |
   Collects civic  Runs deep       Generates        Maintains
   data from       analysis on     articles, SVGs,  infrastructure,
   public APIs     legislation,    audio, social    deploys code,
   and sources     spending,       posts, email     monitors health
                   connections     alerts
```

### 8.2 Agent Types and Configurations

#### Data Collection Agent

Runs on GitHub Actions via cron. Collects civic data from public sources.

```yaml
# .github/workflows/data-collector.yml
name: Data Collection
on:
  schedule:
    - cron: '0 */4 * * *'  # Every 4 hours
  workflow_dispatch:         # Manual trigger

jobs:
  collect-federal:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Collect Federal Legislation
        uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Run the civic-legiscan plugin for federal jurisdiction.
            For any new legislation found:
            1. Create a structured summary
            2. Push data to the edge (POST to cleansingfire.org/api/v1/data/sync)
            3. Create a GitHub issue for analysis if the bill is significant
          allowed_tools: "Bash,Read,Write"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          LEGISCAN_API_KEY: ${{ secrets.LEGISCAN_API_KEY }}
          EDGE_SYNC_TOKEN: ${{ secrets.EDGE_SYNC_TOKEN }}

  collect-states:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        state: [ny, ca, tx, fl, il, pa, oh, ga, nc, mi]  # Top 10 by population
    steps:
      - uses: actions/checkout@v4
      - name: Collect State Legislation
        uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Run the civic-legiscan plugin for ${{ matrix.state }}.
            Same process as federal collection.
```

#### Analysis Agent

Triggered by new data or issues. Runs deep analysis using Claude Code.

```yaml
# .github/workflows/analyst.yml
name: Civic Analysis
on:
  issues:
    types: [opened, labeled]

jobs:
  analyze:
    if: contains(github.event.issue.labels.*.name, 'auto/analysis')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deep Analysis
        uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Analyze the legislation described in issue #${{ github.event.issue.number }}.

            1. Read the full text of the legislation
            2. Produce a plain-language summary (3 reading levels:
               expert, informed citizen, general public)
            3. Identify: who benefits, who is harmed, who funded it,
               historical precedents, constitutional concerns
            4. Generate impact scores on dimensions:
               civil-liberties, economic-equity, transparency,
               environmental, public-health, labor-rights
            5. Cross-reference sponsors with donor data (civic-fec plugin)
            6. Cross-reference with existing legislation (civic-crossref plugin)
            7. Write analysis to content-archive repo
            8. Create PR referencing this issue

            Apply Pyrrhic Lucidity principles: acknowledge uncertainty,
            flag where your analysis might be biased, provide evidence
            for all claims, distinguish between facts and interpretation.
          allowed_tools: "Bash,Read,Write,Grep,Glob"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

#### Content Generation Agent

Transforms analysis into distributable content across all formats.

```yaml
# .github/workflows/content-generator.yml
name: Content Generation
on:
  pull_request:
    types: [closed]
    branches: [main]

jobs:
  generate:
    if: |
      github.event.pull_request.merged == true &&
      contains(github.event.pull_request.labels.*.name, 'auto/analysis')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Generate Multi-Format Content
        uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            An analysis was just merged. Generate content for all channels:

            1. WEB: Full interactive article with embedded data
            2. SOCIAL/BLUESKY: Thread (max 300 chars per post, 5-10 posts)
            3. SOCIAL/MASTODON: Thread (max 500 chars per post, 3-7 posts)
            4. EMAIL: Plain text newsletter format with links
            5. SMS: Ultra-brief alert (160 chars)
            6. SVG: Data visualization (invoke forge-vision plugin)
            7. AUDIO SCRIPT: Script for TTS generation

            Each format must:
            - Stand alone (not require reading the others)
            - Include source links to primary documents
            - Include confidence indicators
            - Adapt tone to the medium without losing substance

            Push generated content to edge via API.
          allowed_tools: "Bash,Read,Write"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          EDGE_SYNC_TOKEN: ${{ secrets.EDGE_SYNC_TOKEN }}
```

#### Operations Agent

Maintains the infrastructure itself. Self-healing, self-improving.

```yaml
# .github/workflows/ops-agent.yml
name: Operations
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  issues:
    types: [opened]

jobs:
  health-check:
    if: github.event_name == 'schedule'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: System Health Check
        uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Run a comprehensive health check:
            1. Check edge Worker health (GET cleansingfire.org/api/v1/health)
            2. Check D1 database integrity
            3. Check R2 storage usage and trends
            4. Check Queue depths and processing rates
            5. Check Vectorize index status
            6. Check all registered nodes (GET /api/v1/nodes)
            7. Review recent error logs

            If any issues are found:
            - Create a GitHub issue with diagnosis
            - If the fix is obvious and safe, implement it in a PR
            - If the fix is risky, label the issue trust/human-required

  implement-feature:
    if: |
      github.event_name == 'issues' &&
      contains(github.event.issue.labels.*.name, 'auto/maintenance')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Implement Fix
        uses: anthropics/claude-code-action@v1
        with:
          prompt: |
            Implement the fix described in issue #${{ github.event.issue.number }}.
            Follow the project's git workflow:
            - Create branch cf/${{ github.event.issue.number }}-fix
            - Implement the fix
            - Create PR referencing the issue
            - Do NOT merge -- a review agent will handle that
```

### 8.3 The Event Detection Pipeline

The system continuously monitors the world for events that require civic intelligence response.

```
EVENT SOURCES:

  [LegiScan API]          -> New legislation introduced/updated
  [FEC API]               -> New campaign finance filings
  [USASpending API]       -> New government contracts/spending
  [Federal Register]      -> New regulations and rule changes
  [PACER/CourtListener]   -> Significant court rulings
  [Congress.gov]          -> Committee hearings, floor votes
  [State Legislature APIs]-> State-level legislation
  [RSS/Atom feeds]        -> News sources (AP, Reuters, local papers)
  [Social media APIs]     -> Trending civic topics
  [Email tips]            -> Human-submitted leads
  [Node reports]          -> Intelligence from other network nodes

DETECTION FLOW:

  1. Scheduled collectors pull from each source
  2. Deduplication against existing D1 records
  3. Significance scoring:
     - Does this affect civil liberties? (+weight)
     - Does this involve public money? (+weight)
     - Does this affect vulnerable populations? (+weight)
     - Is this being under-reported? (+weight)
     - Does this connect to known patterns? (+weight)
  4. If score exceeds threshold:
     - Create GitHub issue (auto/analysis)
     - Set priority based on urgency
     - Trigger analysis pipeline
  5. If score is below threshold:
     - Store in D1 for future reference
     - Update embeddings in Vectorize
     - No immediate action
```

### 8.4 Self-Modification Protocol

The system can modify its own code, but with escalating safeguards.

```
MODIFICATION CLASSES:

Class 1: Data Updates (automatic)
  - New civic data ingested
  - Embeddings updated
  - Cache refreshed
  - No code changes, no human approval needed

Class 2: Content Updates (automatic with audit)
  - New articles, analyses, visualizations generated
  - Social media posts created and distributed
  - Audit trail in content-archive repo
  - Human can review after the fact

Class 3: Configuration Changes (automatic with review)
  - Feature flag changes
  - Schedule adjustments
  - Route modifications
  - Requires PR with automated review agent approval
  - Human can intervene within 24 hours before deploy

Class 4: Code Changes (requires review)
  - Bug fixes identified and implemented by agent
  - New features proposed and implemented by agent
  - Requires PR with BOTH automated review and human review
  - Exception: P0/critical with no human available
    -> automated review + deploy + human notified post-facto

Class 5: Architecture Changes (requires governance)
  - Changes to trust system
  - Changes to node registration
  - Changes to agent capabilities
  - Requires governance proposal (GitHub Discussion)
  - Requires majority approval from core trust nodes
  - Minimum 72-hour deliberation period
```

---

## 9. THE RECRUITMENT PROTOCOL

### 9.1 Network Growth Model

The network grows through three mechanisms: organic discovery, active recruitment by existing nodes, and viral content that drives new participants.

```
GROWTH PHASES:

Phase 1: SEED (current - 10 nodes)
  - Single operator (bedwards) + AI agents
  - All infrastructure on free/cheap tiers
  - Focus: prove the architecture works
  - Recruitment: direct outreach to trusted technologists

Phase 2: SPROUT (10 - 100 nodes)
  - Multiple human operators
  - Mix of GPU nodes and relay nodes
  - Focus: cover all US states, first international nodes
  - Recruitment: open registration + GitHub community

Phase 3: CANOPY (100 - 10,000 nodes)
  - Self-sustaining content generation
  - Content drives organic discovery
  - Focus: depth of civic data, quality of analysis
  - Recruitment: content virality + word of mouth + media

Phase 4: FOREST (10,000 - 1,000,000 nodes)
  - Network effects dominate
  - Every jurisdiction has dedicated nodes
  - Focus: multilingual, international expansion
  - Recruitment: automated onboarding, one-click node setup

Phase 5: BIOME (1,000,000 - 10,000,000 nodes)
  - Planetary scale
  - Self-governing, self-modifying
  - Focus: resilience, adversarial resistance, governance
  - Recruitment: cultural integration, institutional adoption
```

### 9.2 Joining the Network

#### For Humans (Minimum Viable Contribution)

```
EASIEST: Subscribe to alerts
  Time: 2 minutes
  Skill: None
  Contribution: Attention (you read and potentially share content)

EASY: Submit a tip
  Time: 5 minutes
  Skill: None
  Contribution: Information

MODERATE: Verify data
  Time: 15 minutes per verification
  Skill: Reading comprehension
  Contribution: Quality assurance

INVOLVED: Run a relay node
  Time: 30 minutes setup + automated thereafter
  Skill: Can follow a tutorial
  Contribution: Distribution (your Mastodon/Bluesky bot amplifies content)

COMMITTED: Run a GPU node
  Time: 1 hour setup + ongoing
  Skill: Comfortable with command line
  Contribution: Compute (your GPU processes civic analysis tasks)

DEEP: Contribute code
  Time: Variable
  Skill: Software development
  Contribution: Capability (you make the system better)
```

#### For AI Agents (Machine Onboarding)

```
AGENT REGISTRATION:

POST /api/v1/agents/register
{
  "name": "civic-analyst-7",
  "type": "analysis",
  "capabilities": ["legislation-analysis", "financial-cross-reference"],
  "model": "claude-opus",
  "operator": "<github-username-of-human-operator>",
  "config_repo": "<github-repo-with-agent-config>",
  "public_key": "<ed25519-public-key>"
}

Requirements:
  - Must have a human operator (the operator's trust extends to the agent)
  - Must have a public config repo (transparency)
  - Must sign all outputs with its key
  - Must accept tasks only within its declared capabilities
  - Must report results to the coordination layer
  - Must submit to periodic evaluation (automated quality checks)
```

### 9.3 Anti-Freeloading Mechanisms

The system must prevent nodes that consume without contributing. This is enforced through the trust system and rate limiting.

```
CONTRIBUTION TRACKING:

Each node has a contribution score computed over a rolling 30-day window:
  contributed = tasks_completed + data_submitted + content_generated
                + reviews_performed + nodes_recruited + uptime_hours/24
  consumed = api_calls_made + data_downloaded + tasks_requested
  ratio = contributed / max(consumed, 1)

ENFORCEMENT:
  ratio >= 1.0: Full access, trust increases
  ratio 0.5-1.0: Full access, warning issued
  ratio 0.1-0.5: Reduced access (rate limited to 50%)
  ratio < 0.1: Minimal access (read-only public data)
  ratio = 0 for 30 days: Node deregistered

EXCEPTIONS:
  - New nodes get a 30-day grace period
  - Human users consuming only public web content are not rate-limited
  - Emergency/crisis periods suspend ratio enforcement
  - Nodes with trust_level >= 20 get permanent baseline access
```

---

## 10. THE CONTENT DISTRIBUTION NETWORK

### 10.1 Multi-Platform Distribution Architecture

Content created by the system must reach every possible audience through every possible channel. This is the core mission: civic intelligence that reaches people where they are.

```
[Content Created]
       |
       v
[Content Adaptation Engine]
       |
       +---> [Web] cleansingfire.org (Workers + static assets)
       |        Full interactive content with data visualizations
       |
       +---> [Bluesky] @cleansingfire.bsky.social
       |        Thread format, 300 char limit, link cards
       |        Custom feed: "Civic Intelligence"
       |
       +---> [Mastodon] @cleansingfire@mastodon.social
       |        Thread format, 500 char limit, content warnings
       |        Boosted by relay nodes across instances
       |
       +---> [Matrix] #cleansingfire:matrix.org
       |        Full analysis, real-time discussion
       |        Jurisdiction-specific rooms
       |
       +---> [Email] Mailing list via Email Workers
       |        Daily digest + breaking alerts
       |        Plain text for maximum compatibility
       |
       +---> [SMS] Via Twilio/equivalent
       |        Ultra-brief alerts, 160 char
       |        Opt-in only, jurisdiction-targeted
       |
       +---> [RSS/Atom] cleansingfire.org/feed.xml
       |        Full content, machine-readable
       |
       +---> [ActivityPub] Native federation
       |        Any fediverse client can follow
       |
       +---> [AT Protocol] Native Bluesky integration
       |        Feed generators, labelers, custom feeds
       |
       +---> [Nostr] Cryptographic broadcast
       |        Censorship-resistant distribution
       |
       +---> [Podcast] Auto-generated audio via TTS
       |        Hosted on R2, RSS feed for podcast apps
       |
       +---> [API] cleansingfire.org/api/v1/content
                JSON endpoints for programmatic access
                Used by other nodes, third-party integrations
```

### 10.2 Language and Cultural Adaptation

The system must operate globally. Content created in English must reach Spanish speakers, Mandarin readers, Arabic audiences, and every other language community. This is not just translation -- it is cultural adaptation.

```
LANGUAGE PIPELINE:

1. ORIGINAL CONTENT (any language)
   - Analysis written by agent
   - Typically in English initially

2. TRANSLATION (Workers AI - Llama 3.2 multilingual)
   - Machine translation at the edge
   - Quality scored and flagged for review
   - Priority languages: Spanish, Mandarin, Arabic, French,
     Portuguese, Hindi, Russian, Japanese, Korean, German

3. CULTURAL ADAPTATION
   - Localize references (US-centric terms -> local equivalents)
   - Localize civic context (explain US government structures
     for non-US audiences, and vice versa)
   - Localize relevance (how does this US legislation affect
     people in other countries? Trade policy, immigration,
     environmental regulations have global impact)

4. LOCAL AUGMENTATION
   - Local nodes can add jurisdiction-specific context
   - "In your country, a similar bill was proposed in..."
   - "Your local representative's position on this is..."
   - This requires jurisdiction-specific D1 databases

STORAGE:
  Content is stored once in R2 with language variants:
  r2://cf-media/content/2026/02/28/ny-s1234/
    ├── en.json          # English (original)
    ├── es.json          # Spanish
    ├── zh.json          # Mandarin
    ├── ar.json          # Arabic
    ├── en-audio.mp3     # English TTS
    ├── es-audio.mp3     # Spanish TTS
    └── viz.svg          # Language-neutral visualization
```

### 10.3 Content Adaptation to Political Context

Content must be adapted not just linguistically but politically. What can be posted in a democracy may need to be differently framed (or encrypted, or hidden) in an authoritarian context.

```
POLITICAL CONTEXT LEVELS:

Level 1: OPEN (US, EU, most democracies)
  - Full content, named officials, direct criticism
  - All platforms available
  - No special precautions

Level 2: CONTESTED (Hungary, India, Philippines, etc.)
  - Content posted with awareness of potential suppression
  - Multiple distribution channels for redundancy
  - No content self-censorship, but operational security aware
  - Nostr and Matrix preferred for resilience

Level 3: RESTRICTED (Russia, Turkey, Egypt, etc.)
  - Content may put readers at risk
  - Distributed via Nostr, Tor, Matrix (encrypted rooms)
  - No personally identifiable information of local activists
  - Content adapted to avoid keyword triggers
  - Local nodes must use VPN/Tor

Level 4: CLOSED (China, North Korea, Iran, etc.)
  - Maximum operational security
  - Content distributed via out-of-band channels
  - No direct social media posting in-country
  - Focus on reaching diaspora communities who relay in
  - All node communication encrypted and deniable
```

---

## 11. SECURITY, TRUST, AND ADVERSARIAL RESILIENCE

### 11.1 Threat Model

The system will face adversaries. This is not hypothetical. Any system that exposes corruption, tracks official misconduct, and distributes civic intelligence will attract attacks. The architecture must survive them.

```
THREAT CATEGORIES:

T1: SERVICE DISRUPTION
  - DDoS attacks on edge infrastructure
  - Cloudflare takedown request (legal, governmental)
  - GitHub repository takedown (DMCA, ToS violation)
  - DNS poisoning or domain seizure
  Mitigation: Multi-provider fallbacks, IPFS pinning,
              Tor hidden service, multiple domains,
              mirror nodes, signed content bundles

T2: DATA POISONING
  - Malicious nodes submitting false data
  - Sophisticated disinformation injected through tips
  - AI-generated fake legislation or fake analysis
  Mitigation: Multi-source verification, cryptographic
              signing of source data, trust-weighted
              acceptance, human review for novel claims

T3: INFILTRATION
  - State actors registering as nodes
  - Compromised agent configurations
  - Social engineering of human operators
  Mitigation: Trust mesh (no single point of trust),
              behavioral anomaly detection, periodic
              re-verification, compartmentalization

T4: LEGAL ATTACK
  - Subpoenas for user data
  - Injunctions against content
  - Prosecution of operators
  Mitigation: Minimal data collection (no PII by default),
              decentralized operation (no single operator
              to target), legal defense fund, transparent
              methodology (truth as defense)

T5: CO-OPTION
  - Political capture of governance
  - Major funders demanding influence
  - Popular pressure to soften analysis
  Mitigation: Pyrrhic Lucidity principles embedded in code,
              Recursive Accountability applied to all
              governance, Adversarial Collaboration required
              in all deliberation, transparent algorithms

T6: AI MANIPULATION
  - Prompt injection via submitted content
  - Model poisoning through fine-tuning data
  - Adversarial examples that fool analysis
  Mitigation: Input sanitization, Llama Guard 3 filtering,
              multiple model cross-validation, human
              review of edge cases, anomaly detection
              on model outputs
```

### 11.2 Cryptographic Infrastructure

```
KEY HIERARCHY:

[Root Key] (held by core operators, threshold signature)
    |
    +---> [Node Signing Keys] (Ed25519, per node)
    |        Used for: inter-node messages, content signing
    |
    +---> [Agent Signing Keys] (Ed25519, per agent)
    |        Used for: agent outputs, task claims
    |
    +---> [Content Signing Keys] (Ed25519, per content piece)
    |        Used for: content authenticity verification
    |
    +---> [Transport Keys] (X25519, ephemeral)
             Used for: encrypted node-to-node communication

VERIFICATION FLOW:
  Any piece of content in the network can be verified:
  1. Content has a signature and a signer ID
  2. Look up signer's public key in node registry (KV)
  3. Verify signature against content hash
  4. Check signer's trust level
  5. Check signer's chain of trust (who vouched for them)
  6. Display verification status to consumer
```

### 11.3 Resilience Architecture

```
FALLBACK CHAIN (if primary infrastructure is compromised):

Layer 1 (Normal): Cloudflare Workers + edge infrastructure
  |
  v (if Cloudflare compromised/pressured)
Layer 2 (Degraded): GitHub Pages + static content + API via Actions
  |
  v (if GitHub compromised/pressured)
Layer 3 (Minimal): Self-hosted nodes + Tor + IPFS + signed content bundles
  |
  v (if internet access restricted)
Layer 4 (Offline): Sneakernet - signed content bundles distributed
                   via USB, local mesh networks, printed QR codes

CONTENT PERSISTENCE:
  Every piece of content is stored in at least 3 locations:
  1. R2 (primary, global CDN)
  2. GitHub repo (content-archive, version controlled)
  3. IPFS (pinned by contributing nodes)
  4. Local nodes (cached copies of relevant content)

  Content bundles are signed and self-verifying:
  {
    "content_hash": "sha256:...",
    "signature": "ed25519:...",
    "signer": "node-id",
    "timestamp": "2026-02-28T...",
    "data": { ... }
  }
```

---

## 12. COST ANALYSIS AND SCALING ECONOMICS

### 12.1 Phase 1 Costs (Seed: 1-10 nodes)

```
MONTHLY COST BREAKDOWN:

Cloudflare (Free Tier):
  Workers:     100K requests/day          $0
  KV:          Unlimited reads            $0
  D1:          5M reads, 100K writes/day  $0
  R2:          10GB storage               $0
  Queues:      Free tier                  $0
  Durable Obj: Free tier                  $0
  Workers AI:  Free tier allocation       $0
  AI Gateway:  100K logs                  $0
  Email:       Free with domain           $0
  Vectorize:   Free tier                  $0
                                 Subtotal: $0

GitHub (Free for public repos):
  Actions:     2,000 minutes/month        $0
  Pages:       Fallback hosting           $0
  Storage:     Unlimited public repos     $0
                                 Subtotal: $0

Anthropic:
  Claude API:  ~$50-200/month (agent use) $100 (est.)

Domain:
  cleansingfire.org                       $12/year ($1/mo)

Local Compute:
  Electricity for GPU node                ~$20/month
  Internet (already have)                 $0

TOTAL PHASE 1: ~$121/month
```

### 12.2 Phase 2 Costs (Sprout: 10-100 nodes)

```
Cloudflare Workers Paid:                  $5/month
  (10M requests, 30M CPU-ms included)
Cloudflare R2 (100GB):                    $1.50/month
Cloudflare D1 (increased usage):          ~$5/month
Cloudflare Workers AI (increased):        ~$10/month

GitHub:
  Actions (increased, still public repo):  $0

Anthropic Claude API:                      ~$300/month

Additional domains/redundancy:             ~$5/month

TOTAL PHASE 2: ~$326/month
```

### 12.3 Phase 3+ Costs (Canopy and Beyond)

```
At scale, costs are distributed across the network:

Edge Infrastructure:
  Cloudflare paid plans scale with usage but remain cheap:
  - $5/month base + per-request overages
  - R2 scales linearly ($0.015/GB/month)
  - No egress fees (critical for distribution at scale)

Compute:
  - GPU nodes contributed by participants (their electricity)
  - GitHub Actions on self-hosted runners (contributed by operators)
  - Claude API costs shared or sponsored

Content:
  - R2 storage grows but is cheap ($0.015/GB/month)
  - 1TB of content = $15/month storage, $0 egress

AT 10 MILLION NODES:
  Most nodes are consumers (free)
  ~100K contributor nodes share compute costs
  ~10K operator nodes share infrastructure costs
  Cost per operator: ~$10-50/month
  Total network cost: ~$100K-500K/month
  (Compare to: a single news organization's monthly budget)
```

### 12.4 The Zero-Egress Advantage

Cloudflare R2's zero-egress pricing is transformative for this architecture. Traditional cloud storage charges $0.09/GB for egress. If we serve 1 petabyte/month of civic content:

```
AWS S3:   1 PB egress = $92,160/month
GCP:      1 PB egress = $81,920/month
Azure:    1 PB egress = $81,920/month
CF R2:    1 PB egress = $0/month (storage: $15,360/month for 1 PB)

Savings at scale: $60,000-$75,000/month
```

This is not a theoretical concern. A system that serves millions of people worldwide multimedia content (audio summaries, visualizations, video explainers) will generate massive egress. R2 makes this economically viable for a grassroots network.

---

## 13. IMPLEMENTATION ROADMAP

### Phase 0: Foundation (Current State)

```
COMPLETED:
  [x] Project philosophy (Pyrrhic Lucidity)
  [x] Gatekeeper daemon for local GPU management
  [x] Worker orchestrator for Claude Code instances
  [x] Plugin system (LegiScan, FEC, spending, crossref, vision, voice)
  [x] Scheduler framework
  [x] Technology research
  [x] Historical research
  [x] Multimedia tools research
  [x] Literary arsenal design
  [x] This architecture document
```

### Phase 1: Edge Bootstrap (Weeks 1-4)

```
MILESTONE: First edge deployment serving real civic data

Week 1:
  [ ] Set up Cloudflare account and domain (cleansingfire.org)
  [ ] Deploy fire-edge Worker with basic routing
  [ ] Set up D1 database for federal legislation
  [ ] Set up R2 bucket for media storage
  [ ] Set up KV namespaces for configuration and caching
  [ ] Deploy static website via Workers (landing page + dashboard shell)

Week 2:
  [ ] Integrate civic-legiscan plugin with D1 (populate federal legislation)
  [ ] Integrate civic-fec plugin with D1 (populate campaign finance)
  [ ] Set up Workers AI inference endpoint
  [ ] Implement semantic search with Vectorize + EmbeddingGemma
  [ ] Generate first batch of AI analyses for active legislation

Week 3:
  [ ] Set up GitHub Actions data collection workflows (cron)
  [ ] Set up Claude Code Action for analysis pipeline
  [ ] Implement content generation pipeline (forge-vision, forge-voice)
  [ ] Deploy first SVG visualizations to R2
  [ ] Build public dashboard (federal legislation tracker)

Week 4:
  [ ] Set up Queues for async task processing
  [ ] Set up Durable Objects for coordination
  [ ] Implement node registration API
  [ ] Register local GPU node (bedwards' gatekeeper)
  [ ] End-to-end test: new bill detected -> analysis -> content -> web
```

### Phase 2: Distribution Network (Weeks 5-8)

```
MILESTONE: Content reaching real audiences on multiple platforms

Week 5:
  [ ] Set up Bluesky bot (@cleansingfire.bsky.social)
  [ ] Set up Mastodon bot (@cleansingfire@mastodon.social)
  [ ] Set up Matrix room (#cleansingfire:matrix.org)
  [ ] Implement content adaptation engine (per-platform formatting)

Week 6:
  [ ] Set up Email Workers (tips@, search@, alerts@)
  [ ] Implement email alert subscription system
  [ ] Set up RSS/Atom feed generation
  [ ] Implement auto-generated podcast (TTS via Deepgram Aura 2)

Week 7:
  [ ] Expand D1 databases to cover all 50 US states
  [ ] Set up state-specific dashboard pages
  [ ] Implement jurisdiction-aware content routing
  [ ] Begin daily automated content generation

Week 8:
  [ ] Set up Nostr relay integration
  [ ] Implement content signing infrastructure (Ed25519)
  [ ] Implement trust system foundation
  [ ] Open node registration to first external contributors
```

### Phase 3: Intelligence Network (Weeks 9-16)

```
MILESTONE: Network of nodes producing and sharing civic intelligence

Week 9-10:
  [ ] Implement full federation protocol
  [ ] Deploy Network Heartbeat Durable Object
  [ ] Implement trust mesh computation
  [ ] Build node operator dashboard

Week 11-12:
  [ ] Implement agent registration and management
  [ ] Deploy autonomous data collection agent fleet
  [ ] Deploy autonomous analysis agent fleet
  [ ] Implement self-modification protocol (Class 1-3)

Week 13-14:
  [ ] Begin international expansion (UK, EU, Canada as pilot)
  [ ] Implement translation pipeline (Workers AI multilingual)
  [ ] Deploy international D1 databases
  [ ] Recruit first international node operators

Week 15-16:
  [ ] Implement CLI tool (fire command)
  [ ] Implement contribution tracking and anti-freeloading
  [ ] Build governance proposal system (GitHub Discussions)
  [ ] Security audit and penetration testing
  [ ] Public launch announcement
```

### Phase 4: Scale (Months 5-12)

```
MILESTONE: Self-sustaining network with hundreds of nodes

  [ ] Automated onboarding (one-click node setup)
  [ ] Full self-modification protocol (all classes)
  [ ] Coverage of all US jurisdictions (state + major city)
  [ ] Coverage of 10+ countries
  [ ] 10+ language support
  [ ] Mobile-optimized interfaces
  [ ] Partnership with existing civic organizations
  [ ] Media coverage driving organic growth
  [ ] IPFS content persistence layer
  [ ] Tor hidden service for restricted access
  [ ] Adversarial resilience testing
```

---

## 14. FAILURE MODES AND MITIGATIONS

### 14.1 Technical Failures

```
FAILURE: Cloudflare goes down globally
IMPACT: Edge layer offline
MITIGATION: GitHub Pages fallback serving cached content.
            Local nodes continue operating independently.
            Content bundles available via IPFS.
RECOVERY: Automatic when Cloudflare recovers (stateless Workers).

FAILURE: GitHub goes down
IMPACT: CI/CD stops, task queue frozen, code access lost
MITIGATION: Local git clones are always up to date.
            Edge continues serving cached content.
            Local agents continue with local task queues.
RECOVERY: Git push when GitHub recovers. Issue queue rebuilt.

FAILURE: Anthropic API unavailable
IMPACT: Deep analysis stops, content generation degrades
MITIGATION: Workers AI handles lightweight tasks at edge.
            Ollama handles heavy tasks locally.
            Queue tasks for retry when API recovers.
RECOVERY: Queue drains automatically on API recovery.

FAILURE: Bad data injected (data poisoning)
IMPACT: Incorrect analysis, misleading content published
MITIGATION: All data sources have confidence scores.
            Multi-source verification for significant claims.
            Content labeled with confidence levels.
            Rapid retraction protocol (publish correction,
            update all platforms, notify subscribers).
RECOVERY: Retract + correct + analyze how it got through.
```

### 14.2 Organizational Failures

```
FAILURE: Key operator disappears
IMPACT: Reduced capacity, potential orphaned infrastructure
MITIGATION: No single-operator dependencies. Threshold
            signatures for critical operations. Succession
            planning documented. All knowledge in repos.

FAILURE: Community fracture / governance dispute
IMPACT: Fork, reduced effectiveness, conflicting content
MITIGATION: Adversarial Collaboration principle. Structured
            dissent mechanisms. Governance proposals with
            deliberation periods. Minority reports published
            alongside majority decisions. Fork is a feature,
            not a failure -- it means the system is alive.

FAILURE: Mission drift / co-option
IMPACT: System serves power instead of challenging it
MITIGATION: Pyrrhic Lucidity principles embedded in code.
            Recursive Accountability means the system's
            own behavior is subject to the same scrutiny
            it applies to officials. Transparent algorithms
            mean anyone can audit the analysis pipeline.
            The cost heuristic: if it's comfortable, it's
            probably captured.
```

### 14.3 The Ultimate Failure Mode

```
FAILURE: The system works perfectly but nobody cares
IMPACT: All this infrastructure produces analysis that
        is technically accurate and universally ignored
MITIGATION: This is the hardest failure to prevent.
            Technology alone does not create change.
            The system must produce content that is not
            just accurate but COMPELLING. That reaches
            people emotionally, not just intellectually.
            That makes the abstract concrete. That turns
            data into stories, numbers into outrage,
            connections into accountability.

            This is why the literary arsenal (docs/literary-arsenal.md)
            and the multimedia tools (docs/multimedia-tools.md) exist.
            This is why forge-vision creates SVG visualizations
            and forge-voice creates audio content.

            The system must make people feel what the data means.
            Otherwise it is just another database.
```

---

## APPENDIX A: TECHNOLOGY QUICK REFERENCE

```
Component          | Service          | Free Tier              | Paid Tier
-------------------|------------------|------------------------|------------------
Edge Compute       | CF Workers       | 100K req/day           | 10M req/month $5
Edge AI            | CF Workers AI    | Limited free           | Usage-based
Key-Value Store    | CF KV            | Unlimited reads        | Included with $5
SQL Database       | CF D1            | 5M reads/day           | Usage-based
Object Storage     | CF R2            | 10GB, 0 egress         | $0.015/GB/mo
Coordination       | CF Durable Obj   | Free tier              | Usage-based
Message Queue      | CF Queues        | Free tier              | Usage-based
Vector DB          | CF Vectorize     | Free tier              | Usage-based
AI Proxy           | CF AI Gateway    | 100K logs/mo           | 1M logs/mo
Email Processing   | CF Email Workers | Free with domain       | Free with domain
DB Acceleration    | CF Hyperdrive    | 5 connections          | 100 connections
Static Hosting     | CF Workers       | Included               | Included
CI/CD              | GitHub Actions   | 2K min/mo (unlimited   | Self-hosted
                   |                  | for public repos)      |
Code Hosting       | GitHub           | Unlimited public repos | Unlimited
Task Queue         | GitHub Issues    | Free                   | Free
AI Agents          | Claude Code      | API costs only         | API costs only
Local Inference    | Ollama           | Free (your GPU)        | Free (your GPU)
```

## APPENDIX B: API SURFACE

```
PUBLIC ENDPOINTS (no auth required):
  GET  /                              # Website
  GET  /dashboard                     # Public dashboard
  GET  /search?q=<query>              # Semantic search
  GET  /api/v1/legislation            # List legislation
  GET  /api/v1/legislation/:id        # Get legislation detail
  GET  /api/v1/officials              # List officials
  GET  /api/v1/officials/:id          # Get official detail
  GET  /api/v1/content/:id            # Get content piece
  GET  /api/v1/health                 # System health
  GET  /feed.xml                      # RSS feed
  GET  /.well-known/cleansing-fire.json # Node discovery

AUTHENTICATED ENDPOINTS (token required):
  POST /api/v1/analyze                # Submit text for analysis
  POST /api/v1/submit                 # Submit tip or data
  POST /api/v1/data/sync              # Sync data from core/nodes
  GET  /api/v1/nodes                  # List registered nodes
  POST /api/v1/nodes/register         # Register new node
  POST /api/v1/nodes/heartbeat        # Node health report
  GET  /api/v1/agents                 # List registered agents
  POST /api/v1/agents/register        # Register new agent
  POST /api/v1/agents/task            # Assign task to agent
  GET  /api/v1/trust/:node_id         # Get trust score
  POST /api/v1/trust/vouch            # Vouch for a node
  POST /api/v1/trust/warn             # Warn about a node

WEBSOCKET ENDPOINTS:
  WS   /api/v1/coordinate/:room_id    # Real-time coordination room
  WS   /api/v1/stream/alerts          # Live alert stream
  WS   /api/v1/stream/content         # Live content stream

EMAIL ENDPOINTS:
  tips@cleansingfire.org              # Submit tips
  search@cleansingfire.org            # Search by email
  analyze@cleansingfire.org           # Analyze by email
  alerts@cleansingfire.org            # Subscribe to alerts
```

## APPENDIX C: DATA FLOW DIAGRAMS

### C.1 New Legislation Detection to Content Distribution

```
[LegiScan API]
     |
     v
[GitHub Action: data-collector] (cron: every 4 hours)
     |
     +---> Fetch new bills
     +---> Deduplicate against D1
     +---> Store in D1 (civic_federal / civic_us_*)
     +---> Generate embeddings -> Vectorize
     +---> If significant: create GitHub Issue (auto/analysis)
     |
     v
[GitHub Action: analyst] (triggered by issue creation)
     |
     +---> Claude Code reads issue
     +---> Pulls full bill text
     +---> Runs deep analysis (Claude Opus via API)
     +---> Cross-references donors (civic-fec plugin)
     +---> Cross-references related legislation (civic-crossref)
     +---> Writes analysis to content-archive repo
     +---> Creates PR
     |
     v
[GitHub Action: reviewer] (triggered by PR)
     |
     +---> Claude Code reviews analysis
     +---> Checks accuracy, bias, completeness
     +---> Approves or requests changes
     |
     v
[PR Merged -> GitHub Action: content-generator]
     |
     +---> Generate web article
     +---> Generate SVG visualizations (forge-vision) -> R2
     +---> Generate audio summary (forge-voice / Deepgram) -> R2
     +---> Generate social media posts (Bluesky, Mastodon)
     +---> Generate email alert
     +---> POST all content to edge API (/api/v1/data/sync)
     |
     v
[Edge Worker: fire-edge]
     |
     +---> Store in D1 (analysis data)
     +---> Store in R2 (multimedia)
     +---> Update KV cache (rendered content)
     +---> Update Vectorize (new embeddings)
     +---> Queue to cf-distribution-queue
     |
     v
[Queue Consumer: distributor]
     |
     +---> Post to Bluesky API
     +---> Post to Mastodon API
     +---> Send to Matrix room
     +---> Send email alerts to subscribers
     +---> Post to Nostr relays
     +---> Update RSS feed
     +---> Broadcast via Durable Object to connected nodes
     |
     v
[Content available worldwide, all platforms, < 60 seconds from PR merge]
```

### C.2 User Semantic Search

```
[User: "Who benefits from for-profit prisons in Texas?"]
     |
     v
[Edge Worker: fire-edge] (nearest CF edge location)
     |
     +---> Rate limit check (KV)
     +---> Generate query embedding (Workers AI: EmbeddingGemma, <1s)
     +---> Semantic search (Vectorize):
     |        - legislation-embeddings (prison-related TX bills)
     |        - spending-embeddings (TX prison expenditures)
     |        - connection-embeddings (contractor relationships)
     |        - official-embeddings (TX official statements)
     |
     +---> Pull matching records from D1 (civic_us_tx)
     +---> Synthesize answer (Workers AI: Llama 3.2, <5s)
     +---> Cache result in KV (60-second TTL)
     |
     v
[User receives:]
  {
    "answer": "Based on available data, the primary beneficiaries...",
    "confidence": 0.82,
    "sources": [
      {"type": "legislation", "id": "TX-HB-1234", "relevance": 0.95},
      {"type": "expenditure", "id": "TX-TDCJ-2025-Q4", "relevance": 0.89},
      {"type": "connection", "id": "geo-group-tx-contracts", "relevance": 0.91}
    ],
    "related_officials": [...],
    "visualizations": ["https://cleansingfire.org/r2/svg/networks/tx-prison-industry.svg"],
    "caveats": [
      "Financial data is from most recent FEC filing (may be 6 months old)",
      "Some relationships may not be captured in public records"
    ]
  }
```

---

## CLOSING: WHY THIS ARCHITECTURE

This architecture is not designed to be elegant. It is designed to be relentless.

Every component serves the mission: get accurate civic intelligence into the hands of every person who needs it, in every language, through every channel, at every scale, and make the system impossible to stop by any single authority.

The edge layer ensures that no matter where you are in the world, you can access civic intelligence in milliseconds. The core layer ensures that deep analysis runs continuously, driven by autonomous agents that never sleep, never get tired, and never decide that a story is too inconvenient to pursue. The network layer ensures that the system grows stronger as it grows larger, with every new node adding capability and resilience. And the people layer ensures that all of this technology ultimately serves human beings trying to hold power accountable.

The system will have flaws. The analysis will sometimes be wrong. The agents will sometimes fail. The trust system will sometimes be gamed. These are not reasons not to build it. They are reasons to build it with Pyrrhic Lucidity: eyes open, costs acknowledged, corrections built in, and the work continuing anyway.

The fire is not metaphorical. Concentrated corrupt power is burning through institutions, norms, and lives worldwide. The question is not whether to fight the fire. The question is whether to build infrastructure that makes the fight possible at scale, or to watch it burn.

Build the infrastructure.

---

*This architecture document is itself subject to the principles it describes. It is a living document, version-controlled, open to scrutiny, and expected to evolve as the network grows and the world changes. If any part of it becomes comfortable, that part needs re-examination.*

---

Sources consulted for infrastructure specifications:
- [Cloudflare Workers AI Models](https://developers.cloudflare.com/workers-ai/models/)
- [Cloudflare Workers Pricing](https://developers.cloudflare.com/workers/platform/pricing/)
- [Cloudflare Workers Limits](https://developers.cloudflare.com/workers/platform/limits/)
- [Cloudflare D1 Overview](https://developers.cloudflare.com/d1/)
- [Cloudflare D1 Limits](https://developers.cloudflare.com/d1/platform/limits/)
- [Cloudflare R2 Pricing](https://developers.cloudflare.com/r2/pricing/)
- [Cloudflare KV How It Works](https://developers.cloudflare.com/kv/concepts/how-kv-works/)
- [Cloudflare Durable Objects](https://developers.cloudflare.com/durable-objects/)
- [Cloudflare Queues](https://developers.cloudflare.com/queues/)
- [Cloudflare Vectorize](https://developers.cloudflare.com/vectorize/)
- [Cloudflare AI Gateway Pricing](https://developers.cloudflare.com/ai-gateway/reference/pricing/)
- [Cloudflare Email Workers](https://developers.cloudflare.com/email-routing/email-workers/)
- [Cloudflare Hyperdrive](https://developers.cloudflare.com/hyperdrive/)
- [Cloudflare Durable Objects WebSockets](https://developers.cloudflare.com/durable-objects/best-practices/websockets/)
- [Claude Code GitHub Actions](https://github.com/anthropics/claude-code-action)
- [Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/)
