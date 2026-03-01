# Precursor Accountability Protocol

> Design framework for ensuring dual-use tools are used for civic good, not harm.

## The Problem

Cleansing Fire builds powerful civic intelligence tools: OSINT capabilities, network mapping, financial analysis, narrative detection. Every one of these tools could be misused for surveillance, harassment, doxing, or corporate intelligence. The same technology that exposes corruption can be turned against activists, journalists, and vulnerable populations.

This is the **precursor accountability problem**: how do you distribute tools of accountability without creating tools of oppression?

---

## Principles

### 1. Transparency Is Non-Negotiable
Every tool's capabilities, limitations, and potential for misuse must be publicly documented. If a tool can be used for harm, say so.

### 2. Power Should Flow Downward
Tools should empower citizens to hold institutions accountable — not the reverse. Design choices should structurally favor the less powerful party.

### 3. Harm Vectors Must Be Named
Each tool's design document must include a "Harm Vector Analysis" section listing specific ways it could be misused.

### 4. Friction Is a Feature
Misuse should require more effort than legitimate use. This is achieved through design, not prohibition.

---

## Protocol for New Tools

### Phase 1: Pre-Development Review

Before building any new capability, answer:

| Question | Required Answer |
|----------|----------------|
| Who benefits from this tool? | Must include non-institutional actors |
| Who could be harmed? | Must list specific vulnerable populations |
| Does this tool exist elsewhere? | If yes, what does our version add? |
| What's the worst-case misuse? | Must be concretely described |
| Can the tool be un-built? | Must have a deprecation plan |

### Phase 2: Harm Vector Analysis

For each tool, document:

```yaml
tool: [tool name]
harm_vectors:
  - vector: [specific misuse]
    severity: [low/medium/high/critical]
    likelihood: [low/medium/high]
    affected_population: [who gets hurt]
    mitigation: [design choice that reduces this risk]
    residual_risk: [what remains after mitigation]
```

### Phase 3: Design Mitigations

Apply these design patterns to reduce misuse potential:

**Pattern 1: Asymmetric Power Check**
Tools that analyze individuals should only work on *public officials*, *corporate officers*, and *entities with public disclosure obligations*. Private individuals should require explicit consent.

```python
# Example: OSINT plugin access control
def check_target(target):
    if target.is_public_official:
        return ALLOW
    if target.is_corporate_officer:
        return ALLOW
    if target.has_public_filings:
        return ALLOW
    if target.is_private_individual:
        return REQUIRE_CONSENT
```

**Pattern 2: Audit Trail**
Every use of a tool must be logged with:
- Who ran it
- What target was investigated
- What data was accessed
- When it was run
- Why (stated purpose)

**Pattern 3: Rate Limiting by Target**
No entity should be investigated more than N times per period without human review.

**Pattern 4: Aggregation Resistance**
Raw personal data should not be stored or aggregated. Analysis results should be stored, not the underlying records.

**Pattern 5: Sunset Clauses**
Investigation data has a maximum retention period after which it is automatically purged.

### Phase 4: Ongoing Monitoring

- Monthly review of tool usage patterns
- Anomaly detection on investigation targets (are private individuals being investigated?)
- Community reporting mechanism for suspected misuse
- Quarterly "red team" exercise: attempt to misuse tools and document findings

---

## Harm Vector Register

### Current Tools

| Tool | Primary Use | Worst-Case Misuse | Mitigation |
|------|------------|-------------------|------------|
| civic-fec | Campaign finance analysis | Donor harassment | Only public FEC records |
| fec-analysis | Network analysis | Stalking through donor connections | Aggregated output only |
| corp-sec | SEC filing analysis | Corporate espionage | Public filings only |
| osint-social | Social media research | Doxing individuals | Public profiles only |
| property-records | Land ownership investigation | Harassment via address exposure | Owner history, not current residents |
| lobby-tracker | Lobbying disclosure | Targeting lobbyists personally | Public filings only |
| source-verify | Source reliability assessment | Discrediting legitimate sources | Transparent methodology |
| narrative-detector | Media framing analysis | Manipulating narratives | Analysis is visible and auditable |
| corporate-tramcar | Satirical content | Defamation via generated content | Clearly marked as satire |

---

## When Tools Should NOT Be Built

Do not build tools that:

1. **Enable mass surveillance** of private individuals
2. **Facilitate doxing** by aggregating personal data across sources
3. **Create facial recognition** databases from scraped images
4. **Monitor political activity** of private citizens
5. **Track physical location** of individuals
6. **Score social behavior** of individuals
7. **Automate harassment** campaigns

These are hard limits. No exception, no governance override. These are existential red lines for the project.

---

## If Misuse Occurs

### Response Protocol

1. **Detect**: Automated monitoring flags anomalous usage
2. **Assess**: Human reviews the flagged activity
3. **Disable**: Revoke access to the misused tool
4. **Notify**: Alert affected parties if identifiable
5. **Report**: Public transparency report
6. **Patch**: Design changes to prevent recurrence
7. **Reflect**: Did the Precursor Protocol fail? Update it.

### Accountability Chain

```
Tool Creator → Plugin Registry → Deployment Spec → Agent Config → User Action
```

Each link in the chain has a responsible party who can be questioned, and each link is documented.

---

## Philosophical Foundation

From [philosophy.md](../philosophy.md):

> "The ethical weight of a tool is not in its mechanism but in its deployment... Every feature we build must pass the question: could this be turned against the people it's meant to serve?"

The Precursor Accountability Protocol exists because **we take this question seriously**. Not as a checkbox, but as a living practice.

See also:
- [Agent Capabilities](../specs/agent-capabilities.yaml) — G4 (Accountability Guardrails)
- [Digital Rights Law](digital-rights-law.md) — Legal framework for responsible technology
- [Anti-SLAPP Matrix](anti-slapp-matrix.md) — Legal protections for the project itself
