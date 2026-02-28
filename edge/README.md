# edge/ -- Cloudflare Worker Projects

This directory contains the Cloudflare Worker projects for the Cleansing Fire
edge infrastructure. Each subdirectory is an independent Worker with its own
`wrangler.toml` configuration and source code.

These workers are **not** duplicates of the GitHub Pages site. GitHub Pages
serves static investigation reports and documentation. These workers provide the
**live API backend**: AI inference, semantic search, data pipelines, and
real-time coordination.

## Projects

### fire-api/ -- API Gateway

The public entry point for all programmatic access to Cleansing Fire. Handles
investigation queries, legislation lookup, spending search, and proxies AI
requests to fire-ai.

- Routes: `/health`, `/api/investigate/:entity`, `/api/bills/:state`,
  `/api/spending/:keyword`, `/api/chat`
- Bindings: KV (cache, config), D1 (civic data), R2 (media), Queue (tasks),
  Service binding to fire-ai

### fire-ai/ -- AI Inference Worker

Dedicated AI inference endpoint using Cloudflare Workers AI. Handles text
analysis, embedding generation, summarization, and content classification.

- Routes: `/ai/analyze`, `/ai/embed`, `/ai/summarize`, `/ai/classify`
- Bindings: Workers AI, Vectorize, KV (inference cache)

### fire-markdown/ -- LLM-Accessible Markdown Proxy

Proxies the GitHub Pages site with content negotiation for LLM/agent
consumption. Returns normal HTML by default. When an LLM requests markdown
(via `Accept: text/markdown` header or `?format=md` query param), converts
HTML to markdown on the fly. Also serves `/llms.txt` following the
llmstxt.org standard.

- Routes: `/health`, `/llms.txt`, `/llms-full.txt`, `/*` (proxy)
- Content negotiation: `Accept: text/markdown` header, `?format=md` param
- Serves .md files directly with `text/markdown` content type
- No bindings required (stateless proxy)

### Planned Workers

- **fire-search/** -- Semantic search over civic data (Vectorize + D1)
- **fire-ingest/** -- Data ingestion pipeline (Queue consumer)
- **fire-realtime/** -- Real-time coordination (Durable Objects + WebSockets)

## Deployment

All workers are deployed via GitHub Actions using the Wrangler CLI. See
`.github/workflows/deploy-workers.yml`. Deployments trigger on push to `main`
when files in `edge/` change.

### Manual Deployment

```bash
cd edge/fire-api
npx wrangler deploy

cd edge/fire-ai
npx wrangler deploy

cd edge/fire-markdown
npx wrangler deploy
```

### Local Development

```bash
cd edge/fire-api
npx wrangler dev

# In another terminal:
cd edge/fire-ai
npx wrangler dev

# In another terminal:
cd edge/fire-markdown
npx wrangler dev
```

## Required Secrets

These must be configured in your Cloudflare account and in GitHub repository
secrets for CI/CD:

- `CLOUDFLARE_API_TOKEN` -- API token scoped to Workers deployment
- `CLOUDFLARE_ACCOUNT_ID` -- Your Cloudflare account identifier

## Architecture

See `docs/cloudflare-implementation.md` for the full implementation plan,
architecture diagrams, data flow, cost analysis, and phased rollout schedule.

See `docs/global-architecture.md` for the master architecture document covering
all four layers of the Cleansing Fire infrastructure.
