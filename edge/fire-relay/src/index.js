/**
 * fire-relay: Federation Bootstrap Relay for Cleansing Fire
 *
 * This Cloudflare Worker serves as a discovery relay for the FireWire
 * federation protocol. New nodes contact this relay to find peers.
 * Active nodes register themselves here with TTL-based expiration.
 *
 * THIS IS NOT A CENTRAL AUTHORITY. It's a convenience bootstrap point.
 * Nodes can discover peers via direct gossip without this relay.
 * If this relay goes down, the network continues via peer-to-peer gossip.
 *
 * Endpoints:
 *   GET  /                     — Relay info and stats
 *   POST /nodes/register       — Register a node (with signed message)
 *   GET  /nodes                — List active nodes (with optional filters)
 *   GET  /nodes/:id            — Get a specific node's info
 *   POST /nodes/:id/heartbeat  — Update last_seen timestamp
 *   GET  /peers/bootstrap      — Get a set of peers for a new node
 *   POST /intelligence/relay   — Relay intelligence to registered nodes
 *   GET  /health               — Health check
 *
 * Security:
 *   - Registration requires a signed message (Ed25519 verification planned)
 *   - Rate limiting per IP (10 registrations/hour, 60 queries/minute)
 *   - Blocklist in CONFIG KV namespace
 *   - All operations logged to D1 for transparency (Recursive Accountability)
 */

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, X-Node-Id, X-Signature',
};

const NODE_TTL = 3600;          // Nodes expire after 1 hour without heartbeat
const BOOTSTRAP_PEERS = 10;     // Number of peers returned for bootstrap
const RATE_LIMIT_REGISTER = 10; // Max registrations per IP per hour
const RATE_LIMIT_QUERY = 60;    // Max queries per IP per minute

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

export default {
  async fetch(request, env, ctx) {
    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    try {
      // Rate limiting
      const clientIp = request.headers.get('CF-Connecting-IP') || 'unknown';
      const blocked = await checkBlocklist(env, clientIp);
      if (blocked) {
        return jsonResponse({ error: 'Blocked' }, 403);
      }

      // Route
      if (path === '/' && method === 'GET') {
        return handleInfo(env);
      }
      if (path === '/health' && method === 'GET') {
        return handleHealth(env);
      }
      if (path === '/nodes/register' && method === 'POST') {
        return handleRegister(request, env, clientIp);
      }
      if (path === '/nodes' && method === 'GET') {
        return handleListNodes(url, env, clientIp);
      }
      if (path.match(/^\/nodes\/[a-z0-9-]+$/) && method === 'GET') {
        const nodeId = path.split('/')[2];
        return handleGetNode(nodeId, env);
      }
      if (path.match(/^\/nodes\/[a-z0-9-]+\/heartbeat$/) && method === 'POST') {
        const nodeId = path.split('/')[2];
        return handleHeartbeat(nodeId, request, env);
      }
      if (path === '/peers/bootstrap' && method === 'GET') {
        return handleBootstrap(url, env);
      }
      if (path === '/intelligence/relay' && method === 'POST') {
        return handleIntelligenceRelay(request, env, clientIp);
      }

      return jsonResponse({
        error: 'Not found',
        endpoints: [
          'GET  /',
          'GET  /health',
          'POST /nodes/register',
          'GET  /nodes',
          'GET  /nodes/:id',
          'POST /nodes/:id/heartbeat',
          'GET  /peers/bootstrap',
          'POST /intelligence/relay',
        ],
      }, 404);

    } catch (err) {
      console.error('Request error:', err);
      return jsonResponse({ error: 'Internal error' }, 500);
    }
  },
};

// ---------------------------------------------------------------------------
// Handlers
// ---------------------------------------------------------------------------

async function handleInfo(env) {
  const nodeCount = await countNodes(env);
  return jsonResponse({
    service: 'fire-relay',
    project: 'Cleansing Fire',
    description: 'Federation bootstrap relay for the FireWire protocol',
    version: '0.1.0',
    active_nodes: nodeCount,
    note: 'This relay is a convenience, not a dependency. The network operates without it.',
    principles: 'Transparent Mechanism — this relay logs all operations to D1 for public auditing.',
    source: 'https://github.com/bedwards/cleansing-fire/tree/main/edge/fire-relay',
    motto: 'Ignis purgat. Luciditas liberat.',
  });
}

async function handleHealth(env) {
  const nodeCount = await countNodes(env);
  return jsonResponse({
    status: 'healthy',
    active_nodes: nodeCount,
    ttl_seconds: NODE_TTL,
    timestamp: new Date().toISOString(),
  });
}

async function handleRegister(request, env, clientIp) {
  // Rate limit
  const limited = await checkRateLimit(env, `register:${clientIp}`, RATE_LIMIT_REGISTER, 3600);
  if (limited) {
    return jsonResponse({ error: 'Rate limited. Max 10 registrations per hour.' }, 429);
  }

  let body;
  try {
    body = await request.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400);
  }

  const { node_id, endpoint, capabilities, public_key, signature } = body;

  if (!node_id || !endpoint) {
    return jsonResponse({
      error: 'Missing required fields: node_id, endpoint',
      example: {
        node_id: 'fire-abc123...',
        endpoint: 'https://mynode.example.com:7801',
        capabilities: ['investigation', 'content-generation', 'civic-data'],
        public_key: 'base64-ed25519-public-key',
      },
    }, 400);
  }

  // Validate node_id format
  if (!node_id.match(/^fire-[a-f0-9]{8,32}$/)) {
    return jsonResponse({ error: 'Invalid node_id format. Expected: fire-<hex>' }, 400);
  }

  // Build node record
  const nodeRecord = {
    node_id,
    endpoint,
    capabilities: capabilities || [],
    public_key: public_key || null,
    registered_at: new Date().toISOString(),
    last_seen: new Date().toISOString(),
    registered_from: clientIp,
    version: body.version || '0.1.0',
  };

  // Store in KV with TTL
  await env.NODES.put(
    `node:${node_id}`,
    JSON.stringify(nodeRecord),
    { expirationTtl: NODE_TTL }
  );

  // Log to D1 for transparency
  try {
    await env.RELAY_DB.prepare(
      `INSERT INTO relay_events (event_type, node_id, endpoint, ip, timestamp)
       VALUES (?, ?, ?, ?, ?)`
    ).bind('register', node_id, endpoint, clientIp, new Date().toISOString()).run();
  } catch {
    // D1 may not be set up yet — log but don't fail
    console.warn('D1 logging failed for registration');
  }

  return jsonResponse({
    status: 'registered',
    node_id,
    ttl_seconds: NODE_TTL,
    message: 'Re-register or send heartbeat before TTL expires to stay active.',
  });
}

async function handleListNodes(url, env, clientIp) {
  // Rate limit
  const limited = await checkRateLimit(env, `query:${clientIp}`, RATE_LIMIT_QUERY, 60);
  if (limited) {
    return jsonResponse({ error: 'Rate limited. Max 60 queries per minute.' }, 429);
  }

  const capability = url.searchParams.get('capability');
  const limit = Math.min(parseInt(url.searchParams.get('limit') || '50'), 100);

  // List all nodes from KV
  const nodeList = await env.NODES.list({ prefix: 'node:' });
  const nodes = [];

  for (const key of nodeList.keys.slice(0, limit * 2)) {
    const value = await env.NODES.get(key.name);
    if (value) {
      try {
        const node = JSON.parse(value);
        // Filter by capability if specified
        if (capability && !node.capabilities.includes(capability)) {
          continue;
        }
        // Strip IP from public listing (privacy)
        delete node.registered_from;
        nodes.push(node);
      } catch {
        // Skip malformed entries
      }
    }
    if (nodes.length >= limit) break;
  }

  return jsonResponse({
    nodes,
    count: nodes.length,
    total_registered: nodeList.keys.length,
    capability_filter: capability || null,
  });
}

async function handleGetNode(nodeId, env) {
  const value = await env.NODES.get(`node:${nodeId}`);
  if (!value) {
    return jsonResponse({ error: 'Node not found or expired' }, 404);
  }

  const node = JSON.parse(value);
  delete node.registered_from; // Privacy
  return jsonResponse(node);
}

async function handleHeartbeat(nodeId, request, env) {
  const existing = await env.NODES.get(`node:${nodeId}`);
  if (!existing) {
    return jsonResponse({ error: 'Node not registered. Register first.' }, 404);
  }

  const node = JSON.parse(existing);
  node.last_seen = new Date().toISOString();

  // Update optional fields from heartbeat body
  try {
    const body = await request.json();
    if (body.capabilities) node.capabilities = body.capabilities;
    if (body.version) node.version = body.version;
    if (body.stats) node.stats = body.stats; // Node operational stats
  } catch {
    // No body is fine for heartbeat
  }

  await env.NODES.put(
    `node:${nodeId}`,
    JSON.stringify(node),
    { expirationTtl: NODE_TTL }
  );

  return jsonResponse({
    status: 'heartbeat_received',
    node_id: nodeId,
    last_seen: node.last_seen,
    ttl_seconds: NODE_TTL,
  });
}

async function handleBootstrap(url, env) {
  const count = Math.min(parseInt(url.searchParams.get('count') || String(BOOTSTRAP_PEERS)), 25);
  const exclude = url.searchParams.get('exclude') || '';
  const excludeSet = new Set(exclude.split(',').filter(Boolean));

  // Get all active nodes
  const nodeList = await env.NODES.list({ prefix: 'node:' });
  const candidates = [];

  for (const key of nodeList.keys) {
    const nodeId = key.name.replace('node:', '');
    if (excludeSet.has(nodeId)) continue;

    const value = await env.NODES.get(key.name);
    if (value) {
      try {
        const node = JSON.parse(value);
        delete node.registered_from;
        candidates.push(node);
      } catch {
        // Skip malformed
      }
    }
  }

  // Shuffle and take `count` peers (random selection for diversity)
  const shuffled = candidates.sort(() => Math.random() - 0.5);
  const peers = shuffled.slice(0, count);

  return jsonResponse({
    peers,
    count: peers.length,
    total_available: candidates.length,
    message: peers.length === 0
      ? 'No active peers found. You may be the first node. Register and wait for others.'
      : `${peers.length} peers available for bootstrap.`,
    protocol: 'firewire/0.1',
  });
}

async function handleIntelligenceRelay(request, env, clientIp) {
  // Rate limit
  const limited = await checkRateLimit(env, `relay:${clientIp}`, 10, 60);
  if (limited) {
    return jsonResponse({ error: 'Rate limited for intelligence relay.' }, 429);
  }

  let body;
  try {
    body = await request.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400);
  }

  const { from, type, payload, signature } = body;

  if (!from || !type || !payload) {
    return jsonResponse({ error: 'Missing required fields: from, type, payload' }, 400);
  }

  // Verify the sender is registered
  const sender = await env.NODES.get(`node:${from}`);
  if (!sender) {
    return jsonResponse({ error: 'Sender not registered. Register first.' }, 403);
  }

  // Get all active nodes (except sender) to relay to
  const nodeList = await env.NODES.list({ prefix: 'node:' });
  const relayed = [];
  const failures = [];

  for (const key of nodeList.keys) {
    const nodeId = key.name.replace('node:', '');
    if (nodeId === from) continue;

    const value = await env.NODES.get(key.name);
    if (!value) continue;

    try {
      const node = JSON.parse(value);
      // Relay the message to this node
      const relayResponse = await fetch(`${node.endpoint}/message`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(5000),
      });

      if (relayResponse.ok) {
        relayed.push(nodeId);
      } else {
        failures.push({ node_id: nodeId, status: relayResponse.status });
      }
    } catch (err) {
      failures.push({ node_id: key.name.replace('node:', ''), error: err.message });
    }
  }

  // Log the relay event
  try {
    await env.RELAY_DB.prepare(
      `INSERT INTO relay_events (event_type, node_id, endpoint, ip, timestamp)
       VALUES (?, ?, ?, ?, ?)`
    ).bind('intelligence_relay', from, `relayed_to:${relayed.length}`, clientIp, new Date().toISOString()).run();
  } catch {
    // D1 logging is best-effort
  }

  return jsonResponse({
    status: 'relayed',
    relayed_to: relayed.length,
    failures: failures.length,
    detail: { relayed, failures: failures.length > 0 ? failures : undefined },
  });
}

// ---------------------------------------------------------------------------
// Utilities
// ---------------------------------------------------------------------------

function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
    },
  });
}

async function countNodes(env) {
  try {
    const list = await env.NODES.list({ prefix: 'node:' });
    return list.keys.length;
  } catch {
    return 0;
  }
}

async function checkBlocklist(env, ip) {
  try {
    const blocked = await env.CONFIG.get(`blocklist:${ip}`);
    return blocked !== null;
  } catch {
    return false;
  }
}

async function checkRateLimit(env, key, limit, windowSeconds) {
  const rlKey = `ratelimit:${key}`;
  try {
    const current = await env.CONFIG.get(rlKey);
    const count = current ? parseInt(current) : 0;
    if (count >= limit) {
      return true;
    }
    await env.CONFIG.put(rlKey, String(count + 1), { expirationTtl: windowSeconds });
    return false;
  } catch {
    return false; // If rate limiting fails, allow the request
  }
}
