/**
 * fire-api: Main API Gateway Worker
 *
 * The public entry point for all Cleansing Fire API requests.
 * Handles investigation queries, legislation lookup, spending search,
 * and proxies AI requests to the fire-ai worker via service binding.
 *
 * Bindings (configured in wrangler.toml):
 *   - CACHE:     KV namespace for response caching
 *   - CONFIG:    KV namespace for system configuration
 *   - CIVIC_DB:  D1 database for structured civic data
 *   - MEDIA:     R2 bucket for investigation media
 *   - FIRE_AI:   Service binding to fire-ai worker
 *   - TASK_QUEUE: Queue producer for async tasks
 */

// ---------------------------------------------------------------------------
// CORS and shared headers
// ---------------------------------------------------------------------------

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...CORS_HEADERS,
    },
  });
}

function errorResponse(message, status = 500) {
  return jsonResponse({ error: message }, status);
}

// ---------------------------------------------------------------------------
// Route handlers
// ---------------------------------------------------------------------------

/**
 * GET /health
 * Health check endpoint. Returns worker status and binding availability.
 */
async function handleHealth(request, env) {
  const status = {
    status: "ok",
    worker: "fire-api",
    timestamp: new Date().toISOString(),
    bindings: {
      kv_cache: !!env.CACHE,
      kv_config: !!env.CONFIG,
      d1_civic: !!env.CIVIC_DB,
      r2_media: !!env.MEDIA,
      fire_ai: !!env.FIRE_AI,
      task_queue: !!env.TASK_QUEUE,
    },
  };
  return jsonResponse(status);
}

/**
 * GET /api/investigate/:entity
 * Run an investigation on a named entity (person, organization, agency).
 * Checks cache first, then queries D1 and calls fire-ai for analysis.
 */
async function handleInvestigate(request, env, entity) {
  if (!entity || entity.trim() === "") {
    return errorResponse("Entity parameter is required", 400);
  }

  const cacheKey = `investigate:${entity.toLowerCase()}`;

  // Check KV cache first
  if (env.CACHE) {
    const cached = await env.CACHE.get(cacheKey, { type: "json" });
    if (cached) {
      return jsonResponse({ ...cached, cached: true });
    }
  }

  // Query D1 for structured civic data about this entity
  let entityData = { entity, records: [] };

  if (env.CIVIC_DB) {
    try {
      const results = await env.CIVIC_DB.prepare(
        `SELECT * FROM entities WHERE name LIKE ?1 COLLATE NOCASE LIMIT 20`
      )
        .bind(`%${entity}%`)
        .all();

      const legislation = await env.CIVIC_DB.prepare(
        `SELECT * FROM legislation WHERE sponsor LIKE ?1 COLLATE NOCASE LIMIT 20`
      )
        .bind(`%${entity}%`)
        .all();

      const spending = await env.CIVIC_DB.prepare(
        `SELECT * FROM spending WHERE entity LIKE ?1 COLLATE NOCASE LIMIT 20`
      )
        .bind(`%${entity}%`)
        .all();

      entityData.records = {
        entities: results.results || [],
        legislation: legislation.results || [],
        spending: spending.results || [],
      };
    } catch (err) {
      // D1 may not have tables yet in Phase 1. Gracefully degrade.
      entityData.records = { note: "Database not yet provisioned" };
    }
  }

  // Call fire-ai for analysis if the service binding is available
  let analysis = null;
  if (env.FIRE_AI) {
    try {
      const aiResponse = await env.FIRE_AI.fetch(
        new Request("https://fire-ai/ai/analyze", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            text: `Investigate entity: ${entity}. Known data: ${JSON.stringify(entityData.records)}`,
            type: "general",
            depth: "standard",
          }),
        })
      );
      if (aiResponse.ok) {
        analysis = await aiResponse.json();
      }
    } catch (err) {
      analysis = { note: "AI analysis unavailable", error: err.message };
    }
  }

  const result = {
    entity,
    data: entityData.records,
    analysis,
    timestamp: new Date().toISOString(),
  };

  // Cache the result for 1 hour
  if (env.CACHE) {
    await env.CACHE.put(cacheKey, JSON.stringify(result), {
      expirationTtl: 3600,
    });
  }

  return jsonResponse(result);
}

/**
 * GET /api/bills/:state
 * Get legislation for a given state. Returns bills from D1.
 */
async function handleBills(request, env, state) {
  if (!state || state.trim() === "") {
    return errorResponse("State parameter is required", 400);
  }

  const url = new URL(request.url);
  const limit = Math.min(parseInt(url.searchParams.get("limit") || "50"), 200);
  const offset = parseInt(url.searchParams.get("offset") || "0");
  const status = url.searchParams.get("status"); // introduced, passed, signed, vetoed

  const cacheKey = `bills:${state.toLowerCase()}:${limit}:${offset}:${status || "all"}`;

  // Check cache
  if (env.CACHE) {
    const cached = await env.CACHE.get(cacheKey, { type: "json" });
    if (cached) {
      return jsonResponse({ ...cached, cached: true });
    }
  }

  if (!env.CIVIC_DB) {
    return jsonResponse({
      state: state.toUpperCase(),
      bills: [],
      note: "Database not yet provisioned. Deploy Phase 2 for D1 integration.",
    });
  }

  try {
    let query = `SELECT * FROM legislation WHERE jurisdiction = ?1`;
    const params = [state.toUpperCase()];

    if (status) {
      query += ` AND status = ?2`;
      params.push(status);
    }

    query += ` ORDER BY introduced_date DESC LIMIT ?${params.length + 1} OFFSET ?${params.length + 2}`;
    params.push(limit, offset);

    const stmt = env.CIVIC_DB.prepare(query);
    const results = await stmt.bind(...params).all();

    const result = {
      state: state.toUpperCase(),
      bills: results.results || [],
      count: results.results?.length || 0,
      limit,
      offset,
      timestamp: new Date().toISOString(),
    };

    // Cache for 30 minutes
    if (env.CACHE) {
      await env.CACHE.put(cacheKey, JSON.stringify(result), {
        expirationTtl: 1800,
      });
    }

    return jsonResponse(result);
  } catch (err) {
    return errorResponse(`Database query failed: ${err.message}`, 500);
  }
}

/**
 * GET /api/spending/:keyword
 * Search government spending records by keyword.
 */
async function handleSpending(request, env, keyword) {
  if (!keyword || keyword.trim() === "") {
    return errorResponse("Keyword parameter is required", 400);
  }

  const url = new URL(request.url);
  const limit = Math.min(parseInt(url.searchParams.get("limit") || "50"), 200);
  const minAmount = parseFloat(url.searchParams.get("min_amount") || "0");

  const cacheKey = `spending:${keyword.toLowerCase()}:${limit}:${minAmount}`;

  // Check cache
  if (env.CACHE) {
    const cached = await env.CACHE.get(cacheKey, { type: "json" });
    if (cached) {
      return jsonResponse({ ...cached, cached: true });
    }
  }

  if (!env.CIVIC_DB) {
    return jsonResponse({
      keyword,
      records: [],
      note: "Database not yet provisioned. Deploy Phase 2 for D1 integration.",
    });
  }

  try {
    const results = await env.CIVIC_DB.prepare(
      `SELECT * FROM spending
       WHERE (description LIKE ?1 COLLATE NOCASE OR entity LIKE ?1 COLLATE NOCASE)
       AND amount >= ?2
       ORDER BY amount DESC
       LIMIT ?3`
    )
      .bind(`%${keyword}%`, minAmount, limit)
      .all();

    const result = {
      keyword,
      records: results.results || [],
      count: results.results?.length || 0,
      min_amount: minAmount,
      timestamp: new Date().toISOString(),
    };

    // Cache for 30 minutes
    if (env.CACHE) {
      await env.CACHE.put(cacheKey, JSON.stringify(result), {
        expirationTtl: 1800,
      });
    }

    return jsonResponse(result);
  } catch (err) {
    return errorResponse(`Database query failed: ${err.message}`, 500);
  }
}

/**
 * POST /api/chat
 * Conversational AI endpoint. Proxies to fire-ai for Workers AI inference.
 * Accepts { message: string, context?: string[] } in the request body.
 */
async function handleChat(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return errorResponse("Invalid JSON body", 400);
  }

  if (!body.message || typeof body.message !== "string") {
    return errorResponse("message field is required and must be a string", 400);
  }

  if (!env.FIRE_AI) {
    return errorResponse(
      "AI service not available. The fire-ai worker is not bound.",
      503
    );
  }

  try {
    // Forward to fire-ai for inference
    const aiResponse = await env.FIRE_AI.fetch(
      new Request("https://fire-ai/ai/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          text: body.message,
          type: "general",
          depth: body.depth || "standard",
          context: body.context || [],
        }),
      })
    );

    if (!aiResponse.ok) {
      const errText = await aiResponse.text();
      return errorResponse(`AI service error: ${errText}`, aiResponse.status);
    }

    const aiResult = await aiResponse.json();
    return jsonResponse({
      response: aiResult.analysis || aiResult,
      model: aiResult.model || "unknown",
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    return errorResponse(`AI service unavailable: ${err.message}`, 503);
  }
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

/**
 * Match URL paths to handler functions. Uses simple string matching
 * rather than a framework to keep the Worker lightweight.
 */
function matchRoute(pathname) {
  // Static routes
  if (pathname === "/health" || pathname === "/") {
    return { handler: "health", params: {} };
  }

  // Parameterized routes
  const investigateMatch = pathname.match(/^\/api\/investigate\/(.+)$/);
  if (investigateMatch) {
    return {
      handler: "investigate",
      params: { entity: decodeURIComponent(investigateMatch[1]) },
    };
  }

  const billsMatch = pathname.match(/^\/api\/bills\/([a-zA-Z]{2})$/);
  if (billsMatch) {
    return {
      handler: "bills",
      params: { state: billsMatch[1] },
    };
  }

  const spendingMatch = pathname.match(/^\/api\/spending\/(.+)$/);
  if (spendingMatch) {
    return {
      handler: "spending",
      params: { keyword: decodeURIComponent(spendingMatch[1]) },
    };
  }

  if (pathname === "/api/chat") {
    return { handler: "chat", params: {} };
  }

  return null;
}

// ---------------------------------------------------------------------------
// Worker entry point (ES modules format)
// ---------------------------------------------------------------------------

export default {
  async fetch(request, env, ctx) {
    // Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    const url = new URL(request.url);
    const route = matchRoute(url.pathname);

    if (!route) {
      return errorResponse("Not found", 404);
    }

    try {
      switch (route.handler) {
        case "health":
          return await handleHealth(request, env);

        case "investigate":
          if (request.method !== "GET") {
            return errorResponse("Method not allowed", 405);
          }
          return await handleInvestigate(request, env, route.params.entity);

        case "bills":
          if (request.method !== "GET") {
            return errorResponse("Method not allowed", 405);
          }
          return await handleBills(request, env, route.params.state);

        case "spending":
          if (request.method !== "GET") {
            return errorResponse("Method not allowed", 405);
          }
          return await handleSpending(request, env, route.params.keyword);

        case "chat":
          if (request.method !== "POST") {
            return errorResponse("Method not allowed. Use POST.", 405);
          }
          return await handleChat(request, env);

        default:
          return errorResponse("Not found", 404);
      }
    } catch (err) {
      return errorResponse(`Internal error: ${err.message}`, 500);
    }
  },
};
