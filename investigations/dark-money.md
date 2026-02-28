# Investigation Template: Dark Money Network

Trace the flow of undisclosed political spending through 501(c)(4) organizations, LLCs, and shell companies to identify the ultimate funders of political influence.

## Target Network
[ORGANIZATION_OR_NETWORK_NAME]

## Phase 1: Entity Mapping (plugins/corp-sec)
- Organization type (501(c)(4), 501(c)(6), LLC, etc.)
- State of incorporation and registered agent
- Officers and directors
- Related entities and subsidiaries
- IRS Form 990 filings (for nonprofits)
- Corporate filings and annual reports

## Phase 2: Money Flow
### Political Spending (plugins/civic-fec)
- Independent expenditures
- Electioneering communications
- Contributions to other political committees
- Spending by election cycle
- Which candidates or issues supported/opposed

### Cross-Organization Transfers (plugins/civic-crossref)
- Grants to/from other 501(c) organizations
- Money laundering patterns: A → B → C → political spending
- Timing of transfers relative to elections
- Geographic patterns of spending

## Phase 3: Network Analysis
### Corporate Connections (plugins/corp-sec + plugins/osint-social)
- Shared officers/directors across organizations
- Shared addresses or registered agents
- Common law firms or accounting firms
- Industry connections of board members
- Social network overlap of key figures

### Lobbying Overlap (plugins/lobby-tracker)
- Do network entities share lobbyists?
- Coordinated lobbying on the same issues
- Revolving door connections

## Phase 4: Source Identification
- Known donors (from any disclosure)
- Industry associations connected to the network
- Foundation grants received
- Corporate sponsors (events, programs)
- Real estate and asset ownership patterns
- Tax records and liens

## Phase 5: Impact Assessment
### Legislative (plugins/civic-legiscan)
- Bills aligned with network's spending
- Outcomes: did the spending work?
- Policy changes attributable to the network

### News Coverage (plugins/news-monitor)
- Investigative reporting on this network
- Legal challenges to disclosure requirements
- Statements from network spokespeople
- Whistleblower reports

## Phase 6: Synthesis
- Network map: who funds whom, who benefits
- Total estimated spending (disclosed + estimated undisclosed)
- Key hidden actors identified
- Methods used to obscure funding sources
- Legal vs ethical analysis
- Public interest implications
- Recommended follow-up (FOIA, state-level records, etc.)

## Dark Money Red Flags
Watch for:
- Multiple organizations at the same address
- LLCs created shortly before elections
- Officers who are lawyers or accountants (nominees)
- Sudden large grants between organizations
- Organizations with vague names and purposes
- 501(c)(4)s spending >50% on political activity
- Shell LLCs contributing to Super PACs

## Output Format
1. Executive summary
2. Network diagram (Mermaid or ASCII)
3. Money flow chart with amounts and dates
4. Key actors identified with confidence levels
5. Methods of obscuration documented
6. Timeline of key events
7. Sources and methodology
8. Recommended next steps
