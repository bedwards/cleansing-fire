/**
 * fire-markdown: LLM-Accessible Markdown Proxy Worker
 *
 * Proxies the Cleansing Fire GitHub Pages site (bedwards.github.io/cleansing-fire)
 * with content negotiation for LLM/agent consumption.
 *
 * Behavior:
 *   - Default: pass-through proxy, returns HTML exactly as GitHub Pages serves it
 *   - Accept: text/markdown header: converts HTML responses to markdown
 *   - ?format=md query parameter: same as Accept: text/markdown
 *   - .md file requests: serves raw markdown with text/markdown content type
 *   - /llms.txt: returns the llms.txt index (proxied from docs/llms.txt on origin)
 *   - /llms-full.txt: returns expanded content listing
 *
 * Follows conventions:
 *   - Cloudflare "Markdown for Agents" (Accept: text/markdown content negotiation)
 *   - llmstxt.org standard (/llms.txt)
 *   - Claude Code / OpenCode agent conventions
 *
 * HTML-to-Markdown conversion is implemented inline (no npm dependencies).
 */

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const ORIGIN = "https://bedwards.github.io/cleansing-fire";

// ---------------------------------------------------------------------------
// CORS and shared headers
// ---------------------------------------------------------------------------

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, HEAD, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Accept",
};

// ---------------------------------------------------------------------------
// Content negotiation: detect markdown preference
// ---------------------------------------------------------------------------

/**
 * Determines if the client is requesting markdown content.
 * Checks: Accept header for text/markdown, ?format=md query param.
 */
function wantsMarkdown(request) {
  const url = new URL(request.url);

  // Query parameter takes priority (explicit request)
  const format = url.searchParams.get("format");
  if (format === "md" || format === "markdown") {
    return true;
  }

  // Check Accept header -- text/markdown must be present
  const accept = request.headers.get("Accept") || "";
  if (accept.includes("text/markdown")) {
    return true;
  }

  return false;
}

// ---------------------------------------------------------------------------
// HTML to Markdown converter (inline, no dependencies)
// ---------------------------------------------------------------------------
// A lightweight converter inspired by Turndown. Handles the subset of HTML
// that GitHub Pages produces. Not a full HTML parser -- uses regex-based
// tag matching which is sufficient for well-formed HTML from static sites.
// ---------------------------------------------------------------------------

/**
 * Decode HTML entities.
 */
function decodeEntities(text) {
  const entities = {
    "&amp;": "&",
    "&lt;": "<",
    "&gt;": ">",
    "&quot;": '"',
    "&#39;": "'",
    "&apos;": "'",
    "&nbsp;": " ",
    "&mdash;": "--",
    "&ndash;": "-",
    "&hellip;": "...",
    "&laquo;": '"',
    "&raquo;": '"',
    "&ldquo;": '"',
    "&rdquo;": '"',
    "&lsquo;": "'",
    "&rsquo;": "'",
    "&bull;": "*",
    "&middot;": "*",
    "&rarr;": "->",
    "&larr;": "<-",
    "&copy;": "(c)",
    "&reg;": "(R)",
    "&trade;": "(TM)",
  };

  let result = text;
  for (const [entity, replacement] of Object.entries(entities)) {
    result = result.split(entity).join(replacement);
  }

  // Handle numeric entities: &#xHEX; and &#DEC;
  result = result.replace(/&#x([0-9a-fA-F]+);/g, (_, hex) =>
    String.fromCodePoint(parseInt(hex, 16))
  );
  result = result.replace(/&#(\d+);/g, (_, dec) =>
    String.fromCodePoint(parseInt(dec, 10))
  );

  return result;
}

/**
 * Strip all HTML tags from a string, returning plain text.
 */
function stripTags(html) {
  return html.replace(/<[^>]*>/g, "");
}

/**
 * Convert an HTML string to Markdown.
 *
 * Strategy: process the HTML in passes, converting tags to markdown syntax.
 * This is a pragmatic approach that works well for static site HTML.
 */
function htmlToMarkdown(html) {
  let md = html;

  // ---- Phase 0: Remove non-content elements ----

  // Remove <script> and <style> blocks entirely
  md = md.replace(/<script[\s\S]*?<\/script>/gi, "");
  md = md.replace(/<style[\s\S]*?<\/style>/gi, "");
  md = md.replace(/<noscript[\s\S]*?<\/noscript>/gi, "");

  // Remove <head> block
  md = md.replace(/<head[\s\S]*?<\/head>/gi, "");

  // Remove HTML comments
  md = md.replace(/<!--[\s\S]*?-->/g, "");

  // Remove SVG blocks
  md = md.replace(/<svg[\s\S]*?<\/svg>/gi, "");

  // Remove nav elements (site chrome, not content)
  md = md.replace(/<nav[\s\S]*?<\/nav>/gi, "");

  // Remove footer elements (site chrome)
  md = md.replace(/<footer[\s\S]*?<\/footer>/gi, "");

  // Remove hidden/aria-hidden elements
  md = md.replace(/<[^>]+aria-hidden\s*=\s*["']true["'][^>]*>[\s\S]*?<\/[^>]+>/gi, "");

  // Remove sr-only / visually-hidden spans
  md = md.replace(/<[^>]+class\s*=\s*["'][^"']*\b(sr-only|visually-hidden)\b[^"']*["'][^>]*>[\s\S]*?<\/[^>]+>/gi, "");

  // ---- Phase 1: Block-level elements ----

  // Headings h1-h6
  md = md.replace(/<h1[^>]*>([\s\S]*?)<\/h1>/gi, (_, content) =>
    `\n# ${stripTags(content).trim()}\n`
  );
  md = md.replace(/<h2[^>]*>([\s\S]*?)<\/h2>/gi, (_, content) =>
    `\n## ${stripTags(content).trim()}\n`
  );
  md = md.replace(/<h3[^>]*>([\s\S]*?)<\/h3>/gi, (_, content) =>
    `\n### ${stripTags(content).trim()}\n`
  );
  md = md.replace(/<h4[^>]*>([\s\S]*?)<\/h4>/gi, (_, content) =>
    `\n#### ${stripTags(content).trim()}\n`
  );
  md = md.replace(/<h5[^>]*>([\s\S]*?)<\/h5>/gi, (_, content) =>
    `\n##### ${stripTags(content).trim()}\n`
  );
  md = md.replace(/<h6[^>]*>([\s\S]*?)<\/h6>/gi, (_, content) =>
    `\n###### ${stripTags(content).trim()}\n`
  );

  // Horizontal rules
  md = md.replace(/<hr\s*\/?>/gi, "\n---\n");

  // Blockquotes
  md = md.replace(/<blockquote[^>]*>([\s\S]*?)<\/blockquote>/gi, (_, content) => {
    const text = stripTags(content).trim();
    return "\n" + text.split("\n").map((line) => `> ${line.trim()}`).join("\n") + "\n";
  });

  // Pre/code blocks
  md = md.replace(
    /<pre[^>]*>\s*<code[^>]*(?:class\s*=\s*["'](?:language-)?(\w+)["'])?[^>]*>([\s\S]*?)<\/code>\s*<\/pre>/gi,
    (_, lang, content) => {
      const language = lang || "";
      const code = decodeEntities(stripTags(content)).trim();
      return `\n\`\`\`${language}\n${code}\n\`\`\`\n`;
    }
  );

  // Standalone pre blocks (no inner code tag)
  md = md.replace(/<pre[^>]*>([\s\S]*?)<\/pre>/gi, (_, content) => {
    const code = decodeEntities(stripTags(content)).trim();
    return `\n\`\`\`\n${code}\n\`\`\`\n`;
  });

  // ---- Phase 2: Lists ----

  // Ordered lists -- convert <li> within <ol> to numbered items
  md = md.replace(/<ol[^>]*>([\s\S]*?)<\/ol>/gi, (_, content) => {
    let index = 0;
    const items = content.replace(/<li[^>]*>([\s\S]*?)<\/li>/gi, (_, item) => {
      index++;
      return `${index}. ${stripTags(item).trim()}\n`;
    });
    return "\n" + stripTags(items).trim() + "\n";
  });

  // Unordered lists
  md = md.replace(/<ul[^>]*>([\s\S]*?)<\/ul>/gi, (_, content) => {
    const items = content.replace(/<li[^>]*>([\s\S]*?)<\/li>/gi, (_, item) => {
      return `- ${stripTags(item).trim()}\n`;
    });
    return "\n" + stripTags(items).trim() + "\n";
  });

  // Stray list items (outside of ul/ol)
  md = md.replace(/<li[^>]*>([\s\S]*?)<\/li>/gi, (_, content) =>
    `- ${stripTags(content).trim()}\n`
  );

  // Definition lists
  md = md.replace(/<dt[^>]*>([\s\S]*?)<\/dt>/gi, (_, content) =>
    `\n**${stripTags(content).trim()}**\n`
  );
  md = md.replace(/<dd[^>]*>([\s\S]*?)<\/dd>/gi, (_, content) =>
    `: ${stripTags(content).trim()}\n`
  );

  // ---- Phase 3: Tables ----

  md = md.replace(/<table[^>]*>([\s\S]*?)<\/table>/gi, (_, tableContent) => {
    const rows = [];
    const rowRegex = /<tr[^>]*>([\s\S]*?)<\/tr>/gi;
    let rowMatch;

    while ((rowMatch = rowRegex.exec(tableContent)) !== null) {
      const cells = [];
      const cellRegex = /<(?:th|td)[^>]*>([\s\S]*?)<\/(?:th|td)>/gi;
      let cellMatch;

      while ((cellMatch = cellRegex.exec(rowMatch[1])) !== null) {
        cells.push(stripTags(cellMatch[1]).trim());
      }
      rows.push(cells);
    }

    if (rows.length === 0) return "";

    let table = "\n";
    // Header row
    table += "| " + rows[0].join(" | ") + " |\n";
    table += "| " + rows[0].map(() => "---").join(" | ") + " |\n";
    // Data rows
    for (let i = 1; i < rows.length; i++) {
      table += "| " + rows[i].join(" | ") + " |\n";
    }
    return table + "\n";
  });

  // ---- Phase 4: Inline elements ----

  // Links -- extract href and text
  md = md.replace(/<a[^>]*href\s*=\s*["']([^"']*)["'][^>]*>([\s\S]*?)<\/a>/gi,
    (_, href, text) => {
      const linkText = stripTags(text).trim();
      if (!linkText) return "";
      // Skip anchor-only links
      if (href.startsWith("#")) return linkText;
      return `[${linkText}](${href})`;
    }
  );

  // Images
  md = md.replace(
    /<img[^>]*src\s*=\s*["']([^"']*)["'][^>]*alt\s*=\s*["']([^"']*)["'][^>]*\/?>/gi,
    (_, src, alt) => `![${alt}](${src})`
  );
  md = md.replace(
    /<img[^>]*alt\s*=\s*["']([^"']*)["'][^>]*src\s*=\s*["']([^"']*)["'][^>]*\/?>/gi,
    (_, alt, src) => `![${alt}](${src})`
  );
  // Images without alt
  md = md.replace(
    /<img[^>]*src\s*=\s*["']([^"']*)["'][^>]*\/?>/gi,
    (_, src) => `![](${src})`
  );

  // Bold
  md = md.replace(/<(?:strong|b)[^>]*>([\s\S]*?)<\/(?:strong|b)>/gi,
    (_, content) => `**${stripTags(content).trim()}**`
  );

  // Italic
  md = md.replace(/<(?:em|i)[^>]*>([\s\S]*?)<\/(?:em|i)>/gi,
    (_, content) => `*${stripTags(content).trim()}*`
  );

  // Inline code
  md = md.replace(/<code[^>]*>([\s\S]*?)<\/code>/gi,
    (_, content) => `\`${decodeEntities(stripTags(content)).trim()}\``
  );

  // Strikethrough
  md = md.replace(/<(?:del|s|strike)[^>]*>([\s\S]*?)<\/(?:del|s|strike)>/gi,
    (_, content) => `~~${stripTags(content).trim()}~~`
  );

  // Superscript / subscript (markdown doesn't have these, just use text)
  md = md.replace(/<sup[^>]*>([\s\S]*?)<\/sup>/gi, (_, c) => `^${stripTags(c).trim()}`);
  md = md.replace(/<sub[^>]*>([\s\S]*?)<\/sub>/gi, (_, c) => `_${stripTags(c).trim()}`);

  // Line breaks
  md = md.replace(/<br\s*\/?>/gi, "\n");

  // Paragraphs
  md = md.replace(/<p[^>]*>([\s\S]*?)<\/p>/gi, (_, content) => {
    const text = content.trim();
    if (!text) return "";
    return `\n${text}\n`;
  });

  // ---- Phase 5: Cleanup ----

  // Remove all remaining HTML tags
  md = md.replace(/<[^>]+>/g, "");

  // Decode HTML entities
  md = decodeEntities(md);

  // Collapse multiple blank lines into at most two
  md = md.replace(/\n{4,}/g, "\n\n\n");

  // Trim leading/trailing whitespace on each line
  md = md
    .split("\n")
    .map((line) => line.trimEnd())
    .join("\n");

  // Trim the whole document
  md = md.trim();

  return md;
}

// ---------------------------------------------------------------------------
// Estimate token count (rough heuristic: ~4 chars per token)
// ---------------------------------------------------------------------------

function estimateTokens(text) {
  return Math.ceil(text.length / 4);
}

// ---------------------------------------------------------------------------
// Proxy fetch from GitHub Pages origin
// ---------------------------------------------------------------------------

/**
 * Fetch a resource from the GitHub Pages origin.
 * Handles path rewriting (the worker receives / but origin needs /cleansing-fire/).
 */
async function fetchFromOrigin(pathname, env) {
  const origin = (env && env.ORIGIN) || ORIGIN;
  // The origin already includes /cleansing-fire, so we append the path directly
  let url = origin + pathname;

  // Normalize double slashes
  url = url.replace(/([^:])\/\//g, "$1/");

  const response = await fetch(url, {
    headers: {
      "User-Agent": "fire-markdown/1.0 (Cloudflare Worker)",
    },
    cf: {
      // Cache at edge for 5 minutes
      cacheTtl: 300,
      cacheEverything: true,
    },
  });

  return response;
}

// ---------------------------------------------------------------------------
// Route: /llms.txt and /llms-full.txt
// ---------------------------------------------------------------------------

/**
 * Serve llms.txt from the GitHub Pages origin (docs/llms.txt).
 * Falls back to a generated version if the static file doesn't exist.
 */
async function handleLlmsTxt(request, env, full = false) {
  const path = full ? "/llms-full.txt" : "/llms.txt";

  // Try to fetch the static file from origin
  const originResponse = await fetchFromOrigin(path, env);

  if (originResponse.ok) {
    const body = await originResponse.text();
    return new Response(body, {
      status: 200,
      headers: {
        "Content-Type": "text/markdown; charset=utf-8",
        "Cache-Control": "public, max-age=3600",
        "X-Content-Source": "static",
        ...CORS_HEADERS,
      },
    });
  }

  // Static file not found -- generate llms.txt dynamically
  const generated = full ? generateLlmsFullTxt(env) : generateLlmsTxt(env);
  return new Response(generated, {
    status: 200,
    headers: {
      "Content-Type": "text/markdown; charset=utf-8",
      "Cache-Control": "public, max-age=3600",
      "X-Content-Source": "generated",
      ...CORS_HEADERS,
    },
  });
}

/**
 * Generate a minimal llms.txt following the llmstxt.org specification.
 */
function generateLlmsTxt(env) {
  const origin = (env && env.ORIGIN) || ORIGIN;
  return `# Cleansing Fire

> Decentralized technology to shift power from corrupt concentrated authority toward the people. A philosophy of Pyrrhic Lucidity: see clearly, act anyway, bear the cost.

## Core Documentation

- [Getting Started](${origin}/getting-started.md): Installation, setup, and first steps with Claude Code CLI
- [Economics - The Ember Economy](${origin}/economics.md): Decentralized economic model with demurrage currency
- [Decentralized Systems](${origin}/decentralized-systems.md): Network, biological, and governance system design
- [Technology Research](${origin}/technology-research.md): Technical landscape and tool analysis
- [Global Architecture](${origin}/global-architecture.md): Master architecture across all infrastructure layers

## Investigation & Intelligence

- [Corporate Power Map](${origin}/corporate-power-map.md): Where power actually lives -- SEC, ownership chains, dark money
- [Intelligence and OSINT](${origin}/intelligence-and-osint.md): Open-source intelligence collection infrastructure
- [Historical Research](${origin}/historical-research.md): Power rebalancing patterns through history

## Optional

- [Game Theory](${origin}/game-theory.md): Strategic interaction models for power dynamics
- [Federation Protocol](${origin}/federation-protocol.md): Decentralized node federation specification
- [Fork Protection](${origin}/fork-protection.md): Integrity preservation across forks
- [Art and Media](${origin}/art-and-media.md): Visual and media content generation
- [Literary Arsenal](${origin}/literary-arsenal.md): Mottos, poems, slogans, manifestos, songs
- [Humor and Satire](${origin}/humor-and-satire.md): Satire as a weapon against power
- [Multimedia Tools](${origin}/multimedia-tools.md): Audio, video, and interactive media tools
- [Future Capabilities](${origin}/future-capabilities.md): Roadmap and planned features
- [Cloudflare Implementation](${origin}/cloudflare-implementation.md): Edge infrastructure plan
- [Claude Code Features](${origin}/claude-code-features.md): Claude Code CLI capabilities
- [Claude Code Tutorial](${origin}/claude-code-tutorial.md): Step-by-step Claude Code guide
- [Dual Documentation](${origin}/dual-documentation.md): Human + AI documentation architecture
- [Blue Sky Vision](${origin}/blue-sky-vision.md): Long-term aspirational goals
`;
}

/**
 * Generate llms-full.txt with expanded descriptions.
 */
function generateLlmsFullTxt(env) {
  const origin = (env && env.ORIGIN) || ORIGIN;
  return `# Cleansing Fire -- Full Documentation Index

> Decentralized technology to shift power from corrupt concentrated authority toward the people. Built on a philosophy of Pyrrhic Lucidity: the critic is compromised, the tools are contaminated, the audience is captured, and action is still required. See clearly. Act anyway. Bear the cost.

The project is agent-first but human-accessible. The human interface is Claude Code CLI. The system bootstraps itself: Claude reads the project documentation, understands the architecture, and guides the human. Other AI agents can fork and extend the system under the same philosophical constraints.

## Pages

- [Home](${origin}/): Landing page with paths for humans and AI agents
- [For Humans](${origin}/humans.html): Human-oriented documentation hub with all research categories
- [For AI Agents](${origin}/agents.html): Machine-readable specifications, schemas, and protocols

## Core Documentation

- [Getting Started](${origin}/getting-started.md): Complete setup guide. Install Claude Code CLI, clone the repo, configure API keys. First investigation walkthrough. Plugin system introduction. Covers macOS, Linux, and Windows.
- [Economics - The Ember Economy](${origin}/economics.md): Full decentralized economic model. Demurrage currency at 3 scales (local, regional, global). Commons protocol for shared resources. Production mesh for distributed manufacturing. Structural redistribution cycles. Anti-accumulation mechanisms.
- [Decentralized Systems](${origin}/decentralized-systems.md): Comprehensive survey of decentralization patterns from network theory, biological systems, and governance structures. Distributed consensus, mesh networking, mycelial intelligence, polycentric governance.
- [Technology Research](${origin}/technology-research.md): Analysis of the current technical landscape. Comparison of AI platforms, decentralized infrastructure, privacy tools, OSINT frameworks, and content distribution systems.
- [Global Architecture](${origin}/global-architecture.md): Master architecture document covering all four layers: local daemon + plugins, edge workers (Cloudflare), federation protocol, and content distribution. Data flow, security model, scaling strategy.

## Investigation & Intelligence

- [Corporate Power Map](${origin}/corporate-power-map.md): Detailed mapping of where power actually concentrates. SEC EDGAR analysis, OpenCorporates integration, LittleSis relationship mapping, beneficial ownership chain tracing, dark money network detection.
- [Intelligence and OSINT](${origin}/intelligence-and-osint.md): Open-source intelligence collection infrastructure. Data sources, collection pipelines, cross-referencing algorithms, entity resolution, timeline reconstruction, anomaly detection.
- [Historical Research](${origin}/historical-research.md): Patterns of power rebalancing throughout history. Case studies of successful and failed movements. Structural analysis of what works, what doesn't, and why.

## Protocols & Specifications

- [Federation Protocol](${origin}/federation-protocol.md): Complete specification for decentralized node federation. Discovery, authentication, data synchronization, conflict resolution, trust scoring.
- [Fork Protection](${origin}/fork-protection.md): Integrity preservation mechanisms across forks. The 7 Principles as constitutional constraints. Automated integrity verification. Corruption detection.
- [Dual Documentation](${origin}/dual-documentation.md): Architecture for maintaining parallel human and AI documentation. Sync protocols, drift detection, format specifications.

## Strategy & Theory

- [Game Theory](${origin}/game-theory.md): Strategic interaction models for power dynamics. Asymmetric games, coalition formation, information warfare, mechanism design for accountability.
- [Future Capabilities](${origin}/future-capabilities.md): Roadmap and planned features. Phased rollout, capability milestones, scaling targets.
- [Blue Sky Vision](${origin}/blue-sky-vision.md): Long-term aspirational goals. What the world looks like if this works.

## Content & Media

- [Art and Media](${origin}/art-and-media.md): Visual and media content generation. SVG visualizations, ASCII art, Mermaid diagrams, image prompt engineering, data visualization strategies.
- [Literary Arsenal](${origin}/literary-arsenal.md): The forge of language. Mottos, poems, slogans, manifestos, songs, speeches. Content templates for different audiences and contexts.
- [Humor and Satire](${origin}/humor-and-satire.md): Satire as a weapon against concentrated power. Parody generation, corporate doublespeak translation, meme templates, comedic framing strategies.
- [Multimedia Tools](${origin}/multimedia-tools.md): Audio, video, and interactive media generation tools. Podcast scripting, video essay outlines, interactive data explorers.

## Infrastructure

- [Cloudflare Implementation](${origin}/cloudflare-implementation.md): Edge infrastructure implementation plan. Workers architecture, KV/D1/R2 usage, service bindings, cost analysis, phased deployment.
- [Claude Code Features](${origin}/claude-code-features.md): Comprehensive guide to Claude Code CLI capabilities for this project.
- [Claude Code Tutorial](${origin}/claude-code-tutorial.md): Step-by-step tutorial for humans learning Claude Code through this project.
`;
}

// ---------------------------------------------------------------------------
// Route: Health check
// ---------------------------------------------------------------------------

function handleHealth() {
  return new Response(
    JSON.stringify({
      status: "ok",
      worker: "fire-markdown",
      timestamp: new Date().toISOString(),
      capabilities: [
        "html-passthrough",
        "html-to-markdown",
        "raw-markdown-serving",
        "llms-txt",
        "content-negotiation",
      ],
      conventions: {
        "Accept: text/markdown": "Returns markdown conversion of any HTML page",
        "?format=md": "Query parameter alternative to Accept header",
        "/llms.txt": "Site index following llmstxt.org standard",
        "/llms-full.txt": "Expanded site index with full descriptions",
      },
    }),
    {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        ...CORS_HEADERS,
      },
    }
  );
}

// ---------------------------------------------------------------------------
// Main request handler
// ---------------------------------------------------------------------------

async function handleRequest(request, env) {
  const url = new URL(request.url);
  const pathname = url.pathname;

  // Health check
  if (pathname === "/health") {
    return handleHealth();
  }

  // llms.txt routes
  if (pathname === "/llms.txt") {
    return handleLlmsTxt(request, env, false);
  }
  if (pathname === "/llms-full.txt") {
    return handleLlmsTxt(request, env, true);
  }

  // Determine if markdown is requested
  const markdownRequested = wantsMarkdown(request);

  // Fetch from origin
  const originResponse = await fetchFromOrigin(pathname, env);

  // If origin returned an error, pass it through
  if (!originResponse.ok) {
    return new Response(originResponse.body, {
      status: originResponse.status,
      headers: {
        "Content-Type": originResponse.headers.get("Content-Type") || "text/plain",
        ...CORS_HEADERS,
      },
    });
  }

  const contentType = originResponse.headers.get("Content-Type") || "";

  // If the request is for a .md file, serve it as text/markdown regardless
  if (pathname.endsWith(".md")) {
    const body = await originResponse.text();
    const tokens = estimateTokens(body);
    return new Response(body, {
      status: 200,
      headers: {
        "Content-Type": "text/markdown; charset=utf-8",
        "X-Markdown-Tokens": String(tokens),
        "X-Content-Source": "raw-markdown",
        "Cache-Control": "public, max-age=300",
        ...CORS_HEADERS,
      },
    });
  }

  // If markdown not requested, pass through the original response
  if (!markdownRequested) {
    // Clone headers and add CORS
    const headers = new Headers(originResponse.headers);
    for (const [key, value] of Object.entries(CORS_HEADERS)) {
      headers.set(key, value);
    }
    headers.set("X-Markdown-Available", "true");
    headers.set(
      "X-Markdown-Hint",
      'Add "Accept: text/markdown" header or "?format=md" query parameter for markdown version'
    );

    return new Response(originResponse.body, {
      status: originResponse.status,
      headers,
    });
  }

  // Markdown requested -- convert HTML to markdown
  if (contentType.includes("text/html")) {
    const html = await originResponse.text();
    const markdown = htmlToMarkdown(html);
    const tokens = estimateTokens(markdown);

    return new Response(markdown, {
      status: 200,
      headers: {
        "Content-Type": "text/markdown; charset=utf-8",
        "X-Markdown-Tokens": String(tokens),
        "X-Content-Source": "html-to-markdown",
        "X-Original-Content-Type": contentType,
        "Cache-Control": "public, max-age=300",
        ...CORS_HEADERS,
      },
    });
  }

  // For non-HTML content (images, etc.), pass through even if markdown requested
  const headers = new Headers(originResponse.headers);
  for (const [key, value] of Object.entries(CORS_HEADERS)) {
    headers.set(key, value);
  }

  return new Response(originResponse.body, {
    status: originResponse.status,
    headers,
  });
}

// ---------------------------------------------------------------------------
// Worker entry point (ES modules format)
// ---------------------------------------------------------------------------

export default {
  async fetch(request, env, ctx) {
    // Handle CORS preflight
    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          ...CORS_HEADERS,
          "Access-Control-Max-Age": "86400",
        },
      });
    }

    // Only allow GET and HEAD
    if (request.method !== "GET" && request.method !== "HEAD") {
      return new Response("Method not allowed", {
        status: 405,
        headers: CORS_HEADERS,
      });
    }

    try {
      return await handleRequest(request, env);
    } catch (err) {
      return new Response(
        JSON.stringify({
          error: "Internal error",
          message: err.message,
          worker: "fire-markdown",
        }),
        {
          status: 500,
          headers: {
            "Content-Type": "application/json",
            ...CORS_HEADERS,
          },
        }
      );
    }
  },
};
