---
description: Run a civic investigation on an entity (corporation, politician, lobbyist, dark money network)
---

# Investigate an Entity

You are running a Cleansing Fire civic investigation. Read `CLAUDE.md` first to understand the project.

## Steps

1. **Identify the target entity** from the user's input
2. **Search existing research** — check `docs/` for any existing intel on this entity
3. **Run available plugins** in sequence:
   - `plugins/civic-legiscan` — check for related legislation
   - `plugins/civic-fec` — check campaign finance connections
   - `plugins/civic-spending` — check government contracts
   - `plugins/civic-crossref` — cross-reference for corruption indicators
   - `plugins/corp-sec` — check SEC filings (if corporate entity)
   - `plugins/news-monitor` — search recent news coverage
4. **Synthesize findings** into a clear narrative
5. **Apply differential solidarity** — scrutiny proportional to power held
6. **Output a report** with:
   - Entity profile
   - Financial connections
   - Legislative influence
   - Red flags and corruption indicators
   - Recommendations for further investigation
   - Sources

Remember: Lucidity Before Liberation. Present the facts clearly, including inconvenient ones.
