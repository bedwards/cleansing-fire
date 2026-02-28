/**
 * fire-ai: AI Inference Worker
 *
 * Dedicated AI inference endpoint using Cloudflare Workers AI.
 * Provides text analysis, embedding generation, summarization,
 * and content classification for the Cleansing Fire platform.
 *
 * This worker is called by fire-api via service binding (internal,
 * zero-latency) or can be called directly for testing.
 *
 * Bindings (configured in wrangler.toml):
 *   - AI:           Workers AI model inference
 *   - VECTOR_INDEX: Vectorize index for semantic search
 *   - AI_CACHE:     KV namespace for caching inference results
 */

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

const MODELS = {
  // Fast analysis -- low latency, good for classification and short tasks
  fast: "@cf/mistral/mistral-7b-instruct-v0.2",

  // Standard analysis -- balanced quality and speed
  standard: "@cf/meta/llama-3.3-70b-instruct-fp8-fast",

  // Multilingual -- for non-English content
  multilingual: "@cf/glm/glm-4.7-flash",

  // Code analysis -- for analyzing legislative markup, data formats
  code: "@cf/qwen/qwen2.5-coder-32b-instruct",

  // Embeddings -- multilingual, 100+ languages
  embedding: "@cf/baai/bge-m3",

  // Content safety classification
  safety: "@cf/meta/llama-guard-3-8b",
};

// ---------------------------------------------------------------------------
// Shared utilities
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

/**
 * Generate a cache key from the model name and input text.
 * Uses a simple hash to keep keys manageable.
 */
async function cacheKey(prefix, input) {
  const data = new TextEncoder().encode(input);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
  return `${prefix}:${hashHex}`;
}

// ---------------------------------------------------------------------------
// Route handlers
// ---------------------------------------------------------------------------

/**
 * POST /ai/analyze
 * Analyze text using Workers AI. Supports different analysis types
 * and depth levels.
 *
 * Request body:
 *   {
 *     text: string,          // The text to analyze
 *     type: string,          // "legislation" | "statement" | "financial" | "general"
 *     depth: string,         // "quick" | "standard" | "deep"
 *     context?: string[]     // Optional additional context documents
 *   }
 */
async function handleAnalyze(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return errorResponse("Invalid JSON body", 400);
  }

  if (!body.text || typeof body.text !== "string") {
    return errorResponse("text field is required and must be a string", 400);
  }

  const type = body.type || "general";
  const depth = body.depth || "standard";
  const context = body.context || [];

  // Select model based on depth
  let model;
  switch (depth) {
    case "quick":
      model = MODELS.fast;
      break;
    case "deep":
      model = MODELS.standard;
      break;
    case "standard":
    default:
      model = MODELS.standard;
      break;
  }

  // Check cache
  const key = await cacheKey(`analyze:${type}:${depth}`, body.text);
  if (env.AI_CACHE) {
    const cached = await env.AI_CACHE.get(key, { type: "json" });
    if (cached) {
      return jsonResponse({ ...cached, cached: true });
    }
  }

  // Build the analysis prompt based on type
  const systemPrompts = {
    legislation: `You are a civic intelligence analyst specializing in legislation analysis. Analyze the following legislative text. Identify: (1) who benefits, (2) who is harmed, (3) financial implications, (4) lobbying connections, (5) precedent in other jurisdictions. Be specific and cite provisions.`,

    statement: `You are a civic intelligence analyst specializing in public statements. Analyze the following statement by a public figure. Identify: (1) factual claims that can be verified, (2) contradictions with their voting record or financial disclosures, (3) rhetorical techniques used, (4) what is NOT being said. Be specific.`,

    financial: `You are a civic intelligence analyst specializing in financial analysis. Analyze the following financial data or disclosure. Identify: (1) unusual patterns, (2) potential conflicts of interest, (3) comparison to similar entities, (4) regulatory concerns. Be specific and quantitative.`,

    general: `You are a civic intelligence analyst. Analyze the following text in the context of government accountability and public interest. Identify key facts, concerns, connections, and areas requiring further investigation. Be specific and actionable.`,
  };

  const systemPrompt = systemPrompts[type] || systemPrompts.general;

  let userMessage = body.text;
  if (context.length > 0) {
    userMessage += "\n\nAdditional context:\n" + context.join("\n---\n");
  }

  if (!env.AI) {
    return errorResponse("Workers AI binding not available", 503);
  }

  try {
    const result = await env.AI.run(model, {
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userMessage },
      ],
      max_tokens: depth === "quick" ? 512 : depth === "deep" ? 2048 : 1024,
      temperature: 0.3,
    });

    const response = {
      analysis: result.response || result,
      model,
      type,
      depth,
      timestamp: new Date().toISOString(),
    };

    // Cache the result (1 hour for analysis)
    if (env.AI_CACHE) {
      await env.AI_CACHE.put(key, JSON.stringify(response), {
        expirationTtl: 3600,
      });
    }

    return jsonResponse(response);
  } catch (err) {
    return errorResponse(`AI inference failed: ${err.message}`, 500);
  }
}

/**
 * POST /ai/embed
 * Generate vector embeddings for text using Workers AI.
 * Optionally stores embeddings in Vectorize for later search.
 *
 * Request body:
 *   {
 *     text: string | string[],   // Text(s) to embed
 *     store?: boolean,           // Whether to store in Vectorize (default: false)
 *     ids?: string[],            // IDs for stored vectors (required if store=true)
 *     metadata?: object[]        // Metadata for stored vectors
 *   }
 */
async function handleEmbed(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return errorResponse("Invalid JSON body", 400);
  }

  if (!body.text) {
    return errorResponse("text field is required", 400);
  }

  const texts = Array.isArray(body.text) ? body.text : [body.text];
  const store = body.store || false;

  if (store && (!body.ids || body.ids.length !== texts.length)) {
    return errorResponse(
      "When store=true, ids array must be provided with same length as text array",
      400
    );
  }

  if (!env.AI) {
    return errorResponse("Workers AI binding not available", 503);
  }

  try {
    // Generate embeddings using BGE-M3 (multilingual)
    const result = await env.AI.run(MODELS.embedding, {
      text: texts,
    });

    const embeddings = result.data || result;

    // Optionally store in Vectorize
    if (store && env.VECTOR_INDEX) {
      const vectors = texts.map((text, i) => ({
        id: body.ids[i],
        values: embeddings[i],
        metadata: body.metadata?.[i] || {},
      }));

      await env.VECTOR_INDEX.upsert(vectors);
    }

    return jsonResponse({
      embeddings,
      count: texts.length,
      model: MODELS.embedding,
      stored: store,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    return errorResponse(`Embedding generation failed: ${err.message}`, 500);
  }
}

/**
 * POST /ai/summarize
 * Summarize text using Workers AI.
 *
 * Request body:
 *   {
 *     text: string,          // The text to summarize
 *     max_length?: number,   // Target summary length in words (default: 200)
 *     format?: string        // "paragraph" | "bullets" | "headline" (default: "paragraph")
 *   }
 */
async function handleSummarize(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return errorResponse("Invalid JSON body", 400);
  }

  if (!body.text || typeof body.text !== "string") {
    return errorResponse("text field is required and must be a string", 400);
  }

  const maxLength = body.max_length || 200;
  const format = body.format || "paragraph";

  // Check cache
  const key = await cacheKey(`summarize:${format}:${maxLength}`, body.text);
  if (env.AI_CACHE) {
    const cached = await env.AI_CACHE.get(key, { type: "json" });
    if (cached) {
      return jsonResponse({ ...cached, cached: true });
    }
  }

  const formatInstructions = {
    paragraph: `Write a concise summary in ${maxLength} words or fewer as a single paragraph.`,
    bullets: `Write a summary as ${Math.min(Math.ceil(maxLength / 30), 10)} bullet points. Each bullet should be one clear sentence.`,
    headline: `Write a single headline (under 15 words) that captures the most important finding.`,
  };

  const prompt = `${formatInstructions[format] || formatInstructions.paragraph}

Text to summarize:
${body.text}`;

  if (!env.AI) {
    return errorResponse("Workers AI binding not available", 503);
  }

  try {
    const result = await env.AI.run(MODELS.fast, {
      messages: [
        {
          role: "system",
          content:
            "You are a summarization engine for civic intelligence. Produce clear, factual summaries. Never editorialize. Include specific names, numbers, and dates when present in the source.",
        },
        { role: "user", content: prompt },
      ],
      max_tokens: format === "headline" ? 64 : 512,
      temperature: 0.2,
    });

    const response = {
      summary: result.response || result,
      format,
      model: MODELS.fast,
      timestamp: new Date().toISOString(),
    };

    // Cache summaries for 2 hours
    if (env.AI_CACHE) {
      await env.AI_CACHE.put(key, JSON.stringify(response), {
        expirationTtl: 7200,
      });
    }

    return jsonResponse(response);
  } catch (err) {
    return errorResponse(`Summarization failed: ${err.message}`, 500);
  }
}

/**
 * POST /ai/classify
 * Classify content for safety using Llama Guard 3.
 *
 * Request body:
 *   {
 *     text: string    // The text to classify
 *   }
 */
async function handleClassify(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return errorResponse("Invalid JSON body", 400);
  }

  if (!body.text || typeof body.text !== "string") {
    return errorResponse("text field is required and must be a string", 400);
  }

  if (!env.AI) {
    return errorResponse("Workers AI binding not available", 503);
  }

  try {
    const result = await env.AI.run(MODELS.safety, {
      messages: [{ role: "user", content: body.text }],
    });

    return jsonResponse({
      classification: result.response || result,
      model: MODELS.safety,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    return errorResponse(`Classification failed: ${err.message}`, 500);
  }
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

function matchRoute(pathname) {
  if (pathname === "/ai/analyze") return "analyze";
  if (pathname === "/ai/embed") return "embed";
  if (pathname === "/ai/summarize") return "summarize";
  if (pathname === "/ai/classify") return "classify";
  if (pathname === "/health") return "health";
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
      return errorResponse("Not found. Available routes: /ai/analyze, /ai/embed, /ai/summarize, /ai/classify", 404);
    }

    // All AI routes require POST (except health)
    if (route !== "health" && request.method !== "POST") {
      return errorResponse("Method not allowed. Use POST.", 405);
    }

    try {
      switch (route) {
        case "health":
          return jsonResponse({
            status: "ok",
            worker: "fire-ai",
            timestamp: new Date().toISOString(),
            bindings: {
              ai: !!env.AI,
              vectorize: !!env.VECTOR_INDEX,
              kv_cache: !!env.AI_CACHE,
            },
            models: MODELS,
          });

        case "analyze":
          return await handleAnalyze(request, env);

        case "embed":
          return await handleEmbed(request, env);

        case "summarize":
          return await handleSummarize(request, env);

        case "classify":
          return await handleClassify(request, env);

        default:
          return errorResponse("Not found", 404);
      }
    } catch (err) {
      return errorResponse(`Internal error: ${err.message}`, 500);
    }
  },
};
