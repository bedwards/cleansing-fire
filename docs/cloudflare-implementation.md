# CLOUDFLARE IMPLEMENTATION PLAN

## Cleansing Fire: Edge Worker Architecture and Deployment

Implementation Date: 2026-02-28
Status: ACTIVE IMPLEMENTATION
Depends On: docs/global-architecture.md (master architecture)

---

## TABLE OF CONTENTS

1. [Guiding Constraint](#1-guiding-constraint)
2. [Cloudflare Capability Inventory (Feb 2026)](#2-cloudflare-capability-inventory-feb-2026)
3. [Worker Projects](#3-worker-projects)
4. [Architecture Diagram](#4-architecture-diagram)
5. [Data Flow](#5-data-flow)
6. [Integration with Local Infrastructure](#6-integration-with-local-infrastructure)
7. [Integration with GitHub](#7-integration-with-github)
8. [Cost Analysis](#8-cost-analysis)
9. [Phase-by-Phase Rollout](#9-phase-by-phase-rollout)

---

## 1. GUIDING CONSTRAINT

The Cloudflare edge projects are **not** duplicates of the GitHub Pages site. GitHub Pages serves the static public-facing documentation and investigation reports. The Cloudflare workers are the **live intelligence infrastructure**: API endpoints, AI inference, semantic search, real-time coordination, and data pipelines. They are separate projects deployed via GitHub Actions using Wrangler.

---

## 2. CLOUDFLARE CAPABILITY INVENTORY (Feb 2026)

This is the concrete, current-state inventory of what Cloudflare offers that we will use. Every item here has been verified against Cloudflare's documentation and changelogs as of February 2026.

### 2.1 Workers Runtime

- **Execution**: V8 isolates at 300+ edge locations in 100+ countries
- **Free tier**: 100,000 requests/day, 10ms CPU time per invocation
- **Paid tier** ($5/month base): 10M requests/month, 30M CPU-ms, $0.30/million additional
- **Memory**: 128MB per Worker
- **Languages**: JavaScript, TypeScript, Python, Rust (via WASM)
- **Static assets**: Built directly into Workers (Pages is in maintenance mode)
- **Workers Builds**: Automatic CI/CD from GitHub/GitLab (GA)
- **Wrangler v4**: Shell tab completions, multi-environment type generation, improved consistency
- **Best Practices guide**: Published February 15, 2026

### 2.2 Workers AI

- **50+ models** running serverless at 200+ edge cities
- **LLMs available now**:
  - Llama 3.3 70B (speculative decoding, 2-4x faster)
  - Llama 4 Scout (17B params, 16 experts, natively multimodal)
  - OpenAI gpt-oss-120b (production reasoning) and gpt-oss-20b (low latency)
  - Qwen 2.5 Coder 32B (code generation)
  - GLM-4.7-Flash (multilingual, 131K context window)
  - Mistral 7B Instruct v0.2
- **Embeddings**: BGE-M3 (multi-lingual, 100+ languages), EmbeddingGemma
- **Image generation**: Leonardo Phoenix, Lucid Origin, FLUX.2 klein 9B
- **Speech**: Whisper (STT), Deepgram Nova 3 (real-time STT), Deepgram Aura 2 (TTS), MeloTTS
- **Safety**: Llama Guard 3 (content classification)
- **Batch inference API**: Bulk operations for embeddings and summarization at scale
- **OpenAI-compatible API format**: Drop-in replacement for OpenAI SDK calls
- **Pricing**: Free tier includes limited inference; paid scales per-neuron-per-second

### 2.3 AI Search (formerly AutoRAG)

- Fully managed Retrieval-Augmented Generation pipeline
- Uses R2, Vectorize, and Workers AI in combination
- External model support (OpenAI, Anthropic) added in late 2025
- Minimal configuration: point it at your data, get search

### 2.4 KV (Key-Value Store)

- Eventually consistent global store, p99 reads under 5ms (rearchitected 2025)
- Hot key reads: 500 microseconds to 10ms
- Changes visible locally immediately, globally within 60 seconds
- Unlimited reads on free tier; paid included with $5/month plan
- Maximum value size: 25MB, no limit on keys per namespace

### 2.5 D1 (SQLite at the Edge)

- 10GB per database, up to 50,000 databases per Worker
- Read replicas distributed globally (no extra charge)
- Time Travel: point-in-time recovery to any minute within 30 days
- Free tier: 5M rows read/day, 100K rows written/day
- 6 simultaneous connections per Worker invocation

### 2.6 R2 (Object Storage)

- S3-compatible API, **zero egress fees ever**
- Free tier: 10GB storage, 1M Class A ops, 10M Class B ops/month
- Paid: $0.015/GB-month standard, $0.01/GB-month infrequent access
- R2 Data Catalog for automatic metadata management

### 2.7 Vectorize

- 50K namespaces/indexes per account
- 5 million vectors per index
- Integrated with Workers AI for embedding generation
- Semantic search, classification, recommendation, anomaly detection

### 2.8 Durable Objects

- Stateful serverless functions with globally unique names
- Each has embedded SQLite database with strong consistency
- WebSocket support with Hibernation API (zero cost during hibernation)
- **Available on free tier** since April 2025
- Point-in-time recovery API for embedded SQLite (30-day window)
- deleteAll() now clears alarms too (compatibility date 2026-02-24+)
- Use @cloudflare/actors library for fan-out and broadcast messaging

### 2.9 Queues

- At-least-once delivery, 5,000 messages/second per queue
- 250 concurrent consumers, pull-based consumers available
- Dead letter queues, individual message acknowledgment
- **Available on free tier** since February 2026 (10,000 ops/day)
- Event subscriptions from KV, R2, Workers AI, Vectorize

### 2.10 AI Gateway

- Proxy for AI API calls (OpenAI, Anthropic, Workers AI, Hugging Face)
- Caching (up to 90% latency reduction for identical requests), rate limiting, logging
- **Unified Billing**: Pay for third-party model usage via Cloudflare invoice
- Free tier: 100K logs/month; paid: 1M logs/month

### 2.11 Email Workers

- Process incoming email programmatically
- AI-powered email parsing, summarization, labeling
- Threaded replies supported
- New: Transactional email sending (GA late 2025)

### 2.12 Cloudflare Containers (Public Beta)

- Docker containers deployed to Cloudflare edge, integrated with Workers
- Workers can serve as API Gateway or Service Mesh for containers
- Up to 400 GiB memory, 100 vCPUs, 2 TB disk per deployment
- GPU support available for heavy compute

### 2.13 Cloudflare Calls (Open Beta)

- Real-time audio/video via WebRTC, Cloudflare network as singular SFU
- Raw WebRTC audio piped as PCM in Workers
- WebSocket support for real-time AI inference (voice agents)
- Deepgram STT/TTS running in 330+ cities

### 2.14 Hyperdrive

- Database connection pooling for external PostgreSQL/MySQL
- Regional prepared statement caching (5x faster)
- Free tier: 5 connections; paid: up to 100

### 2.15 Browser Rendering with Playwright (GA)

- Headless browser automation at the edge
- Useful for scraping public records, government websites

### 2.16 Media Transformations (GA)

- Image resizing, format conversion, optimization at the edge

---

## 3. WORKER PROJECTS

Each Worker is a separate Cloudflare project with its own wrangler.toml, deployed independently. They live in the `edge/` directory at the repository root.

### 3.1 fire-api (Main API Gateway)

**Purpose**: The public entry point for all programmatic access. Handles investigation queries, plugin orchestration, and proxies to other workers.

**Routes**:
- `GET /health` -- Health check and status
- `GET /api/investigate/:entity` -- Run an investigation on a named entity
- `GET /api/bills/:state` -- Get legislation for a state
- `GET /api/spending/:keyword` -- Search government spending
- `POST /api/chat` -- Conversational AI (proxies to Workers AI)

**Bindings**:
- KV: `CACHE` (response caching), `CONFIG` (system configuration)
- D1: `CIVIC_DB` (civic data queries)
- R2: `MEDIA` (serve investigation media)
- Service binding: `FIRE_AI` (route AI requests to fire-ai worker)
- Queue: `TASK_QUEUE` (dispatch async work)

**Location**: `edge/fire-api/`

### 3.2 fire-ai (AI Inference Worker)

**Purpose**: Dedicated AI inference endpoint. Handles all Workers AI model calls -- text analysis, embeddings, summarization, content classification.

**Routes**:
- `POST /ai/analyze` -- Analyze text (legislation, statements, financials)
- `POST /ai/embed` -- Generate embeddings for semantic search
- `POST /ai/summarize` -- Summarize documents
- `POST /ai/classify` -- Content safety classification via Llama Guard

**Bindings**:
- Workers AI: `AI` (model inference)
- Vectorize: `VECTOR_INDEX` (store and query embeddings)
- KV: `AI_CACHE` (cache inference results)
- AI Gateway: Configured for logging, caching, and fallback

**Location**: `edge/fire-ai/`

### 3.3 fire-search (Planned -- Phase 2)

**Purpose**: Semantic search over all civic data using Vectorize and AI Search.

**Routes**:
- `GET /search?q=...` -- Semantic search across all civic data
- `GET /search/similar/:id` -- Find documents similar to a given ID
- `POST /search/ingest` -- Ingest new documents into the search index

**Bindings**:
- Vectorize: `CIVIC_VECTORS` (semantic search index)
- D1: `CIVIC_DB` (metadata lookups)
- Workers AI: `AI` (query embedding generation)

### 3.4 fire-ingest (Planned -- Phase 3)

**Purpose**: Data ingestion pipeline. Consumes from Queues, processes incoming civic data, stores in D1/R2, generates embeddings for Vectorize.

**Bindings**:
- Queue consumer: `INGEST_QUEUE`
- D1: `CIVIC_DB` (write structured data)
- R2: `MEDIA` (store documents and media)
- Workers AI: `AI` (generate embeddings on ingest)
- Vectorize: `CIVIC_VECTORS` (index new embeddings)

### 3.5 fire-realtime (Planned -- Phase 4)

**Purpose**: Real-time coordination via Durable Objects and WebSockets. Handles live investigation dashboards, agent-to-agent communication, collaborative analysis sessions.

**Bindings**:
- Durable Objects: `COORDINATION_ROOM`, `AGENT_SESSION`
- KV: `PRESENCE` (who is online)

---

## 4. ARCHITECTURE DIAGRAM

```
                    USERS / AGENTS / PLUGINS
                           |
                           v
              +------------------------+
              |  Cloudflare Edge (CDN)  |
              |  300+ global locations  |
              +------------------------+
                     |         |
          +----------+         +----------+
          |                               |
   +------v-------+             +---------v------+
   |   fire-api   |  service    |    fire-ai     |
   |  (API GW)    |--binding--->|  (Inference)   |
   |              |             |                |
   | Routes:      |             | Routes:        |
   |  /health     |             |  /ai/analyze   |
   |  /api/invest.|             |  /ai/embed     |
   |  /api/bills  |             |  /ai/summarize |
   |  /api/spend  |             |  /ai/classify  |
   |  /api/chat   |             |                |
   +------+-------+             +-------+--------+
          |                             |
          +----+----+----+----+    +----+----+
          |    |    |    |    |    |    |    |
         KV   D1   R2  Queue |   AI  Vec  KV
                         |    |        |
                  +------v----v--------v------+
                  |    Async Pipeline          |
                  |  fire-ingest (Phase 3)     |
                  |    Queue -> D1/R2/Vec      |
                  +---------------------------+
                         |
              +----------v-----------+
              |   fire-search        |
              |   (Phase 2)          |
              |   Vectorize + D1     |
              +----------------------+
                         |
              +----------v-----------+
              |   fire-realtime      |
              |   (Phase 4)          |
              |   Durable Objects    |
              |   WebSockets         |
              +----------------------+

         ============ BOUNDARY ============

              +----------------------+
              |   GitHub Actions     |
              |   (CI/CD Pipeline)   |
              |   deploys workers    |
              |   via wrangler       |
              +----------------------+
                         |
              +----------v-----------+
              |   GitHub Pages       |
              |   (Static Site)      |
              |   Reports / Docs     |
              |   SEPARATE PROJECT   |
              +----------------------+
                         |
              +----------v-----------+
              |   Local Infra        |
              |   gatekeeper         |
              |   ollama             |
              |   plugins            |
              |   scheduler          |
              +----------------------+
```

### Key Architectural Points

1. **fire-api is the gateway**. All external requests hit fire-api first. It handles routing, authentication, rate limiting, and caching. It delegates AI work to fire-ai via Cloudflare service bindings (zero-latency internal calls, no public network hop).

2. **fire-ai is isolated**. AI inference is compute-heavy and has different scaling characteristics than API routing. Isolating it lets us scale, cache, and rate-limit AI independently.

3. **GitHub Pages is separate**. The static site (`docs/` served via GitHub Pages) displays investigation reports and documentation. It is a read-only public site. The Cloudflare workers provide the live API backend that the site (and agents and plugins) call into.

4. **Local infrastructure connects via Queues and API**. The gatekeeper, plugins, and scheduler on local machines push data to fire-api and consume from Queues. They do not need Cloudflare accounts -- they use API tokens.

---

## 5. DATA FLOW

### 5.1 Investigation Query Flow

```
User/Agent sends: GET /api/investigate/john-doe
       |
       v
  fire-api: Check KV cache for "investigate:john-doe"
       |
       +---> Cache HIT: return cached result (< 5ms)
       |
       +---> Cache MISS:
                |
                +---> Query D1: SELECT * FROM entities WHERE name = 'john-doe'
                +---> Query D1: SELECT * FROM legislation WHERE sponsor = 'john-doe'
                +---> Query D1: SELECT * FROM spending WHERE entity = 'john-doe'
                |
                +---> Service call to fire-ai: POST /ai/analyze
                |         |
                |         +---> Workers AI: Run Llama 3.3 70B analysis
                |         +---> Return structured analysis
                |
                +---> Combine D1 data + AI analysis
                +---> Store in KV cache (TTL: 1 hour)
                +---> Return response
```

### 5.2 Data Ingestion Flow

```
Plugin/Scheduler discovers new data
       |
       v
  POST fire-api /api/ingest
       |
       v
  fire-api: Validate, enqueue to TASK_QUEUE
       |
       v
  fire-ingest: Dequeue message
       |
       +---> Parse and normalize data
       +---> Write structured data to D1
       +---> Store documents/media in R2
       +---> Call fire-ai: POST /ai/embed (generate embeddings)
       +---> Upsert embeddings into Vectorize
       +---> Update KV cache invalidation flags
```

### 5.3 Chat / Conversational AI Flow

```
User sends: POST /api/chat { message: "Who profits from NYC zoning changes?" }
       |
       v
  fire-api: Forward to fire-ai via service binding
       |
       v
  fire-ai:
       +---> Generate query embedding via BGE-M3
       +---> Search Vectorize for relevant civic data
       +---> Retrieve top-k document chunks from D1
       +---> Construct prompt with retrieved context (RAG)
       +---> Run Llama 3.3 70B with context + user message
       +---> Return AI response with source citations
```

---

## 6. INTEGRATION WITH LOCAL INFRASTRUCTURE

### 6.1 Gatekeeper

The local gatekeeper daemon (`daemon/gatekeeper.py` or similar) communicates with Cloudflare workers:

- **Pushes data**: Calls `POST fire-api /api/ingest` with FOIA results, scraped records, plugin output
- **Pulls tasks**: Polls `GET fire-api /api/tasks/pending` for work items
- **Reports status**: Calls `POST fire-api /api/nodes/heartbeat` with local node health

Authentication: API token stored locally, validated by fire-api via KV lookup.

### 6.2 Plugins

Plugins (`plugins/`) generate civic data through scraping, FOIA processing, and analysis. They interact with the edge:

- **Output upload**: Plugin results are POSTed to fire-api for ingestion
- **AI assistance**: Plugins can call fire-ai endpoints for analysis they cannot do locally
- **Fallback**: If Cloudflare is unreachable, plugins write to local output directory for later sync

### 6.3 Scheduler

The scheduler (`scheduler/`) orchestrates recurring tasks:

- **Cron via GitHub Actions**: Scheduled workflows call fire-api to trigger data refresh
- **Local cron**: Scheduler daemon runs plugins, uploads results to edge
- **Queue-based**: Scheduler enqueues recurring work to TASK_QUEUE

### 6.4 Ollama (Local Heavy Inference)

For tasks too large or sensitive for edge inference:

- Local Ollama runs Mistral Large 123B, DeepSeek, or other models
- fire-ai can be configured to route "deep" analysis requests back to local Ollama via API
- AI Gateway tracks cost and latency for both edge and local inference paths

---

## 7. INTEGRATION WITH GITHUB

### 7.1 GitHub Actions for Deployment

All Cloudflare worker deployments happen through GitHub Actions. The workflow lives at `.github/workflows/deploy-workers.yml`.

**Trigger**: Push to `main` branch with changes in `edge/` directory.

**Process**:
1. Checkout code
2. Install Node.js and wrangler
3. For each worker (`fire-api`, `fire-ai`):
   - `cd edge/<worker-name>`
   - `npx wrangler deploy`
4. Run health checks against deployed workers
5. Report status

**Secrets required**:
- `CLOUDFLARE_API_TOKEN` -- Scoped to Workers deployment
- `CLOUDFLARE_ACCOUNT_ID` -- Account identifier

### 7.2 GitHub Pages (Separate)

GitHub Pages is configured separately and deploys the `docs/` directory as a static site. It does not deploy Cloudflare workers. The static site may call fire-api endpoints for live data, but is fully functional without them (graceful degradation).

### 7.3 GitHub Issues as Task Queue

GitHub Issues labeled `edge-task` can be consumed by fire-api:
- fire-api polls or receives webhooks for new issues
- Parses structured task descriptions
- Dispatches to appropriate pipeline
- Comments on issue with results

---

## 8. COST ANALYSIS

### 8.1 Free Tier Budget (Starting Point)

| Service | Free Tier Limit | Our Phase 1 Usage | Headroom |
|---------|----------------|-------------------|----------|
| Workers | 100K requests/day | ~5K requests/day | 95% |
| Workers AI | Limited free inference | ~500 inferences/day | Varies by model |
| KV | Unlimited reads, 1K writes/day | ~200 writes/day | 80% |
| D1 | 5M rows read/day, 100K written | ~50K reads, ~1K writes | 99% |
| R2 | 10GB storage, 1M Class A ops | ~1GB, ~10K ops | 90% |
| Queues | 10K operations/day | ~1K operations/day | 90% |
| Vectorize | Included with Workers | ~10K vectors | Minimal |
| AI Gateway | 100K logs/month | ~15K logs/month | 85% |
| Durable Objects | Free tier available | ~100 objects | Minimal |

**Phase 1 total cost: $0/month** (within free tier)

### 8.2 Paid Tier Budget (Scale-Up)

When we exceed free tier (estimated at ~50K daily active users):

| Service | Monthly Cost | Notes |
|---------|-------------|-------|
| Workers Paid | $5 base | Includes 10M requests, 30M CPU-ms |
| Workers AI | ~$10-50 | Depends on model usage |
| D1 | $0.75/M reads | Scales with traffic |
| R2 | $0.015/GB | Zero egress |
| KV | Included | With paid plan |
| Queues | Included | With paid plan |
| Vectorize | Included | With paid plan |
| AI Gateway | Included | 1M logs with paid |
| **Total** | **$15-60/month** | At moderate scale |

### 8.3 Cost Controls

- **KV caching**: Aggressively cache AI inference results. Identical queries return from cache.
- **AI Gateway caching**: Identical AI API calls served from cache (90% latency reduction, 100% cost reduction for cached hits).
- **Batch inference**: Nightly batch jobs for embeddings and bulk analysis, cheaper than real-time.
- **Model tiering**: Use Mistral 7B (cheap, fast) for simple tasks; reserve Llama 3.3 70B for deep analysis.
- **Rate limiting**: Per-IP and per-token rate limits prevent abuse.

---

## 9. PHASE-BY-PHASE ROLLOUT

### Phase 1: Foundation (Weeks 1-2)

**Deploy fire-api and fire-ai with basic routes.**

Deliverables:
- [x] `edge/fire-api/wrangler.toml` -- API gateway config
- [x] `edge/fire-api/src/index.js` -- Basic route handling
- [x] `edge/fire-ai/wrangler.toml` -- AI worker config
- [x] `edge/fire-ai/src/index.js` -- AI inference endpoints
- [x] `.github/workflows/deploy-workers.yml` -- CI/CD pipeline
- [ ] Cloudflare account setup and API token creation
- [ ] First successful deployment via GitHub Actions
- [ ] Health check passing on both workers

Infrastructure to provision:
- 1 KV namespace: `CACHE`
- 1 KV namespace: `CONFIG`
- 1 KV namespace: `AI_CACHE`
- Workers AI binding on fire-ai
- Service binding: fire-api -> fire-ai

### Phase 2: Data and Search (Weeks 3-4)

**Add D1 databases, Vectorize indexes, and fire-search worker.**

Deliverables:
- [ ] D1 database: `civic_federal` with core schema
- [ ] D1 database: `civic_us_ny` (pilot state)
- [ ] Vectorize index: `civic-embeddings`
- [ ] `edge/fire-search/` worker with semantic search
- [ ] Batch embedding pipeline for existing civic data
- [ ] fire-api routes for `/api/bills` and `/api/spending` backed by D1

### Phase 3: Ingestion Pipeline (Weeks 5-6)

**Build fire-ingest worker and connect to local plugins.**

Deliverables:
- [ ] Queue: `TASK_QUEUE` and `INGEST_QUEUE`
- [ ] `edge/fire-ingest/` worker consuming from queues
- [ ] Plugin output -> fire-api -> Queue -> fire-ingest -> D1/R2/Vectorize
- [ ] R2 bucket for media and document storage
- [ ] Gatekeeper integration for bidirectional sync

### Phase 4: Real-Time Coordination (Weeks 7-8)

**Deploy fire-realtime with Durable Objects and WebSockets.**

Deliverables:
- [ ] `edge/fire-realtime/` worker with Durable Objects
- [ ] Live investigation dashboard WebSocket endpoint
- [ ] Agent coordination rooms
- [ ] Presence tracking via KV

### Phase 5: Advanced Capabilities (Weeks 9+)

**Leverage newer Cloudflare services as they mature.**

- AI Search (AutoRAG) integration for managed RAG pipeline
- Email Workers for incoming tip processing
- Cloudflare Containers for heavy compute (PDF processing, large-scale scraping)
- Cloudflare Calls for real-time voice briefings
- Browser Rendering for automated government website monitoring
- Workers for Platforms if we open the system to third-party plugin developers

---

## APPENDIX A: WRANGLER.TOML REFERENCE

Each worker's `wrangler.toml` is documented inline. See:
- `edge/fire-api/wrangler.toml`
- `edge/fire-ai/wrangler.toml`

Key wrangler v4 best practices:
- Always set `compatibility_date` to a recent date
- Use `[env.staging]` and `[env.production]` for environment separation
- Run `npx wrangler types` to generate TypeScript bindings
- Use `npx wrangler dev` for local development
- Use `npx wrangler deploy --dry-run` to preview before deployment

## APPENDIX B: SECURITY

- All API tokens stored in GitHub Secrets, never in code
- Workers validate incoming requests via auth middleware
- Rate limiting applied at fire-api level
- Llama Guard 3 classification on all user-submitted content
- KV-based blocklists for known abuse patterns
- CORS configured to allow only known origins
- All inter-worker communication via service bindings (not public network)
