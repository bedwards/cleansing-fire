# Headless Mode Patterns

> How Claude Code operates non-interactively for autonomous workflows.

## Overview

Headless mode is when Claude Code runs without a human in the loop — piped input, no TTY, autonomous decision-making. This is the mechanism that enables Cleansing Fire to operate as an autonomous civic intelligence system.

The system follows a strict escalation protocol: **automatic for routine, human for novel**.

## Pattern 1: Issue → Implementation → PR

The core development loop. A GitHub issue triggers autonomous implementation.

```bash
# From GitHub Actions or local scheduler
claude --print --dangerously-skip-permissions \
  "Read issue #$ISSUE_NUMBER. Implement the feature described. \
   Create branch cf/$ISSUE_NUMBER-<description>. \
   Commit changes. Create a PR referencing the issue."
```

**When to use**: Issues labeled `auto/maintenance` or `auto/feature`
**Trust level required**: Class 4 (Code Changes — requires review)
**Safeguards**: PR created, never auto-merged, review required

## Pattern 2: PR Review

Claude reads a PR diff and posts review comments.

```bash
claude --print --dangerously-skip-permissions \
  "Review PR #$PR_NUMBER. Check for: \
   1. CLAUDE.md convention compliance \
   2. Security issues (hardcoded secrets, SQL injection, XSS) \
   3. Plugin contract violations \
   4. Missing error handling \
   5. Regressions against existing tests \
   Post review comments via gh pr review."
```

**When to use**: All PRs (via `claude-review.yml` workflow)
**Trust level required**: Class 3 (Configuration — automatic with review)
**Safeguards**: Review comments only, never approves/merges autonomously

## Pattern 3: Fix Cycle

Claude reads review comments, makes targeted fixes, and pushes.

```bash
claude --print --dangerously-skip-permissions \
  "Read the review comments on PR #$PR_NUMBER. \
   For each actionable comment: \
   1. Understand the criticism \
   2. Make the fix on the same branch \
   3. Commit with message referencing the review comment \
   Push all fixes."
```

**When to use**: After a review identifies fixable issues
**Trust level required**: Class 4 (Code Changes)
**Safeguards**: Same PR, visible in diff, still requires final review

## Pattern 4: Investigation Pipeline

Accept a target entity and run the full investigation pipeline.

```bash
claude --print --dangerously-skip-permissions \
  "Investigate '$ENTITY'. Run these plugins in order: \
   1. civic-fec: search for campaign contributions \
   2. civic-spending: search for government contracts \
   3. corp-sec: search for SEC filings \
   4. lobby-tracker: search for lobbying disclosures \
   5. civic-crossref: cross-reference all findings \
   6. forge-vision: generate money flow diagram \
   7. forge-voice: generate executive summary \
   Output: JSON report to stdout."
```

**When to use**: New investigation targets from scheduler or tips
**Trust level required**: Class 1 (Data Updates — automatic)
**Safeguards**: No external writes, output is data only

## Pattern 5: Content Generation

Transform analysis data into distributable content.

```bash
claude --print --dangerously-skip-permissions \
  "Generate content from this analysis: $ANALYSIS_JSON. \
   Create: \
   1. Social post (Bluesky format, 300 chars max) \
   2. Thread (5-10 posts) \
   3. Digest (newsletter format) \
   4. SVG visualization (via forge-vision) \
   Output: JSON with all formats."
```

**When to use**: After analysis completes (triggered by merged analysis PRs)
**Trust level required**: Class 2 (Content — automatic with audit)
**Safeguards**: Content queued for human review before publishing

## Pattern 6: Scheduled Maintenance

Run on cron for routine system health.

```bash
claude --print --dangerously-skip-permissions \
  "Run system health check: \
   1. Verify all plugins are executable and pass basic tests \
   2. Check integrity-manifest.json hashes \
   3. Verify CI pipeline is green \
   4. Check edge worker health endpoints \
   5. Report any issues as GitHub issues labeled auto/maintenance."
```

**When to use**: Every 6 hours (via ops-agent workflow)
**Trust level required**: Class 1 (Data — automatic)
**Safeguards**: Read-only operations, issues created for any fixes needed

## Pattern 7: Emergency Response

Triggered by CI failure on main or edge health check failure.

```bash
claude --print --dangerously-skip-permissions \
  "EMERGENCY: Main branch CI is failing. \
   1. Read the failing run logs \
   2. Diagnose the root cause \
   3. If the fix is safe (test fix, config fix): implement and PR \
   4. If the fix is risky: create issue labeled trust/human-required \
   5. If edge is down: check deploy-workers.yml logs and redeploy"
```

**When to use**: Automated alert from monitoring
**Trust level required**: Class 4 (Code Changes), escalated to human if risky
**Safeguards**: PR required, never direct-push to main

## Self-Modification Classes

From [Global Architecture Section 8.4](global-architecture.md):

| Class | Type | Approval | Examples |
|-------|------|----------|----------|
| 1 | Data Updates | Automatic | New civic data, embeddings, cache refresh |
| 2 | Content Updates | Automatic + audit | Articles, social posts, visualizations |
| 3 | Config Changes | Automatic + review | Feature flags, schedules, routes |
| 4 | Code Changes | Requires review | Bug fixes, new features |
| 5 | Architecture Changes | Requires governance | Trust system, node registration, agent capabilities |

## Environment Variables for Headless Mode

```bash
# Required for headless Claude Code
export ANTHROPIC_API_KEY="..."

# Cleansing Fire specific
export CF_PROJECT_DIR="/path/to/cleansing-fire"
export CF_TEST_MODE="1"                    # Offline mode for plugins
export CF_GATEKEEPER_URL="http://localhost:7800"  # Local LLM gateway
```

## Scheduler Integration

The `scheduler/scheduler.py` daemon manages 25 tasks across 6 categories:

- **Sense**: Data collection from public APIs
- **Analyze**: Deep analysis of collected data
- **Create**: Content generation from analysis
- **Distribute**: Multi-platform content distribution
- **Improve**: Self-improvement and code maintenance
- **System**: Health checks and infrastructure monitoring

See `specs/deployment-spec.yaml` for scheduler configuration.

## Safety Boundaries

From `specs/agent-capabilities.yaml`:

1. **Never** auto-merge to main without human review (except P0 with no human available)
2. **Never** modify safety-critical files without human confirmation
3. **Never** post content without audit trail
4. **Never** escalate trust levels without governance approval
5. **Always** sign outputs with agent key
6. **Always** log all actions for transparency
7. **Always** apply Pyrrhic Lucidity principles to generated analysis
