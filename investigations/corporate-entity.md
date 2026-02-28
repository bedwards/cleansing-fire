# Investigation Template: Corporate Entity

Investigate a corporation's power concentration, political influence, government contracts, and public accountability.

## Target Entity
[ENTITY_NAME]

## Phase 1: Corporate Structure (plugins/corp-sec)
- SEC filings: 10-K, 10-Q, 8-K reports
- Executive compensation analysis
- Related-party transactions
- Board of directors and interlocking directorates
- Major shareholders and institutional ownership
- Recent material events

## Phase 2: Political Influence
### Campaign Finance (plugins/civic-fec)
- PAC contributions to which candidates
- Individual executive contributions
- Total political spending (last 10 years)
- Which committees and parties

### Lobbying (plugins/lobby-tracker)
- Registered lobbyists employed
- Lobbying spending by year
- Which issues lobbied on
- Revolving door: former employees now in government, former officials now at company

### Legislation (plugins/civic-legiscan)
- Bills that benefit this entity
- Bills the entity lobbied for/against
- Regulatory exemptions or carve-outs

## Phase 3: Government Contracts (plugins/civic-spending)
- Total federal contract value
- Which agencies
- Sole-source vs competitive
- Contract performance history
- Subcontractor relationships

## Phase 4: Cross-Reference (plugins/civic-crossref)
- Connections between campaign donations and contracts received
- Timeline analysis: donations → lobbying → legislation → contracts
- Comparison to industry competitors
- Red flags and anomalies

## Phase 5: Public Record
### News Coverage (plugins/news-monitor)
- Recent coverage from investigative outlets
- Lawsuits and legal actions
- Regulatory actions or fines
- Whistleblower complaints

### Social/Public (plugins/osint-social)
- Corporate social media presence and messaging
- Executive public statements
- PR campaigns and narrative patterns

## Phase 6: Synthesis
- Power concentration score (qualitative assessment)
- Key findings: what did we learn?
- Red flags: what needs deeper investigation?
- Connections: who benefits from this entity's actions?
- Public interest implications
- Recommended next steps

## Output Format
Produce a structured report with:
1. Executive summary (3-5 sentences)
2. Entity profile
3. Findings by phase
4. Network diagram (ASCII or Mermaid)
5. Timeline of key events
6. Sources and confidence levels
7. Recommended follow-up investigations
