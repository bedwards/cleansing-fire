# Intelligence, OSINT, and Investigative Infrastructure

## A Comprehensive Guide for Civic Accountability and Transparency Activism

### The Cleansing Fire Project

*Research Date: 2026-02-28*

---

> "The line between watching the watchers and becoming the watchers is thinner than anyone admits. Cross it consciously, with constraint, or cross it unconsciously and become what you oppose." -- Pyrrhic Lucidity, Principle VI

---

## Table of Contents

1. [Open Source Intelligence (OSINT) -- The Legal Arsenal](#1-open-source-intelligence-osint--the-legal-arsenal)
2. [Tools of the Trade](#2-tools-of-the-trade)
3. [Investigative Journalism Techniques](#3-investigative-journalism-techniques)
4. [Whistleblower Infrastructure](#4-whistleblower-infrastructure)
5. [Counter-Intelligence and Operational Security](#5-counter-intelligence-and-operational-security)
6. [Autonomous AI Agents for Intelligence](#6-autonomous-ai-agents-for-intelligence)
7. [Ethical Framework -- Pyrrhic Lucidity Applied to Intelligence](#7-ethical-framework--pyrrhic-lucidity-applied-to-intelligence)

---

## 1. Open Source Intelligence (OSINT) -- The Legal Arsenal

Open Source Intelligence is intelligence collected from publicly available sources. It is the foundation of civic accountability work because it is legal, verifiable, and reproducible. Unlike classified intelligence, OSINT can be published, shared, and subjected to adversarial peer review. Its power comes not from secrecy but from systematic collection, correlation, and analysis of information that is already in the public domain but scattered across thousands of sources in forms that resist easy synthesis.

The core insight: power hides not through secrecy alone but through complexity. Corruption is often documented in public records -- corporate filings, court documents, property deeds, campaign finance reports, lobbying disclosures -- but the connections between these records are invisible unless someone builds the map. That is what OSINT does. It builds the map.

---

### 1.1 Bellingcat Methodology: Geolocation, Chronolocation, Open Source Verification

Bellingcat, founded by Eliot Higgins in 2014, pioneered a systematic methodology for verifying and investigating events using only publicly available information. Their approach has been used to identify the perpetrators of the MH17 shootdown, document chemical weapons use in Syria, and track military movements worldwide. The methodology is fully transferable to civic accountability work.

**Bellingcat's Online Investigation Toolkit:** https://bellingcat.gitbook.io/toolkit

**Core Techniques:**

**Geolocation** -- determining where a photo or video was taken by analyzing visual clues:
- **Environmental analysis**: Trees, vegetation, terrain, weather patterns, sun position, shadows, and architecture all provide location indicators. Flora and fauna are specific to climatic zones. Building styles, signage languages, road markings, and vehicle types narrow location to specific countries or regions.
- **Infrastructure matching**: Power line configurations, road surface types, bollard styles, street furniture, traffic signs, and utility markers vary by jurisdiction. Comparing these against reference databases narrows location.
- **Cross-referencing with satellite imagery**: Once a general area is identified from visual clues, satellite imagery from Google Earth, Sentinel Hub, or Mapillary street-level imagery can confirm exact locations.
- **Shadow analysis for chronolocation**: The angle and length of shadows in an image, combined with known latitude and sun position calculations (using tools like SunCalc -- https://www.suncalc.org), can determine the approximate time and date a photo was taken.

**Chronolocation** -- determining when an image or video was captured:
- Shadow length and direction mapped against solar position for the identified location
- Weather verification against historical weather data (Weather Underground, OGIMET)
- Vegetation state (leafing, flowering, snow cover) cross-referenced with seasonal norms
- Visible celestial bodies (star positions, moon phase) for nighttime imagery
- Metadata analysis when available (EXIF data in images, though often stripped by social media platforms)

**Open Source Verification** -- confirming that media depicts what it claims:
- Reverse image search (Google Images, TinEye, Yandex Images) to find the earliest instance of an image
- Video analysis frame-by-frame to identify inconsistencies, edits, or signs of manipulation
- Metadata extraction and analysis (when preserved)
- Multi-source corroboration: the same event documented from multiple independent sources
- Temporal consistency: do all available sources agree on timing?

**Bellingcat's GitHub organization** hosts open-source tools: https://github.com/bellingcat

Key Bellingcat tools include:
- **auto-archiver**: Automatically archives social media posts and web pages
- **telegram-phone-number-checker**: Check if phone numbers are associated with Telegram accounts
- **open-questions**: Framework for structuring investigations

**Practice resources**: Bellingcat publishes regular OSINT challenges that serve as training exercises, including geolocation puzzles of increasing difficulty.

---

### 1.2 Social Media Intelligence (SOCMINT)

Social media is the largest voluntary surveillance apparatus ever built. People -- including corporate executives, government officials, and their associates -- routinely post information that reveals locations, relationships, activities, assets, and timelines. SOCMINT is the systematic collection and analysis of this public data.

**What is publicly collectible:**
- Posts, comments, likes, shares, and their timestamps
- Profile information, follower/following networks, group memberships
- Geotags and location check-ins
- Photos and videos (which may contain EXIF metadata, background location clues, or identifiable individuals)
- Historical posts (people forget what they posted years ago)
- Network relationships: who interacts with whom, how frequently, and in what context

**Key approaches:**

**Profile reconstruction**: Building a comprehensive picture of a target's public digital footprint across all platforms. People use consistent usernames, profile photos, or biographical details across platforms. Tools like Sherlock and Holehe automate cross-platform discovery.

**Network mapping**: Identifying clusters of connected accounts, shared followers, coordinated posting behavior, or mutual interactions that reveal organizational structures not visible from any single account.

**Temporal analysis**: Tracking how posting patterns, relationships, and stated positions change over time, especially around key events (contract awards, regulatory decisions, political campaigns).

**Sentiment and narrative analysis**: Identifying coordinated messaging campaigns, astroturfing operations, or influence networks by analyzing language patterns, posting times, and content similarity across accounts.

**Platform-specific considerations:**
- **X (Twitter)**: Public by default. Historical tweets are powerful because people forget what they said. Advanced search operators allow filtering by date range, user, location, and keywords.
- **LinkedIn**: Professional connections reveal corporate relationships, career trajectories, board memberships, and institutional affiliations. People voluntarily disclose employment history that would otherwise require corporate registry searches.
- **Facebook/Instagram**: Privacy settings vary, but group memberships, event attendance, and tagged photos often remain public or semi-public. Instagram location tags and story content provide real-time location data.
- **TikTok/YouTube**: Video content provides rich visual intelligence. Background details, locations, timestamps, and associated accounts all provide investigative leads.
- **Telegram**: Groups and channels are often public. Used extensively by political movements, gray-market commerce, and as a primary communication platform in many countries.
- **Reddit**: Post and comment histories reveal interests, locations, professional knowledge, and social connections. Deleted posts are often archived by third-party services.

**Legal boundaries**: Collecting publicly posted information is legal in most jurisdictions. Creating fake accounts to access private content, circumventing privacy settings, or scraping data in violation of platform terms of service occupies grayer legal territory. The principle: if someone chose to make it public, documenting it is legitimate journalism.

---

### 1.3 Financial Intelligence (FININT) -- Following the Money

Corruption leaves financial trails. Money must move -- from bribes through shell companies, from donors through PACs, from public contracts to private accounts. These movements create records, many of which are public. Financial intelligence is the art of finding and connecting these records.

**Public financial data sources:**

**Campaign finance:**
- **Federal Election Commission (FEC)**: https://www.fec.gov/data/ -- All federal campaign contributions, expenditures, and committee filings. Full API access.
- **OpenSecrets (Center for Responsive Politics)**: https://www.opensecrets.org -- Aggregated and analyzed campaign finance data, lobbying disclosures, revolving door tracking. Bulk data downloads available.
- **FollowTheMoney (National Institute on Money in Politics)**: https://www.followthemoney.org -- State-level campaign finance data across all 50 states.

**Corporate financial records:**
- **SEC EDGAR**: https://www.sec.gov/cgi-bin/browse-edgar -- All filings by publicly traded companies. 10-K annual reports, 10-Q quarterly reports, 8-K current event reports, proxy statements, insider trading reports (Form 4). The SEC provides free RESTful APIs at data.sec.gov delivering JSON-formatted data with no authentication required. Rate limit: 10 requests/second.
- **EDGAR Full-Text Search**: https://efts.sec.gov/LATEST/search-index?q= -- Search across the full text of all EDGAR filings.

**Property and real estate:**
- County assessor and recorder websites (vary by jurisdiction)
- Property transfer databases reveal real estate transactions, shell company purchases, and asset movement patterns
- Zillow/Redfin/public MLS data for property valuations

**Lobbying and government contracts:**
- **Lobbying Disclosure Act database**: https://lda.senate.gov/filings/public/filing/search/
- **USASpending.gov**: https://www.usaspending.gov -- All federal contract, grant, loan, and spending data. Full API.
- **Federal Procurement Data System**: https://www.fpds.gov -- Federal contract data.
- **State lobbying registries**: Vary by state, but most require disclosure of lobbyist clients, issues, and compensation.

**International financial records:**
- **ICIJ Offshore Leaks Database**: https://offshoreleaks.icij.org -- Searchable database from the Panama Papers, Paradise Papers, Pandora Papers, and other leaks. Contains information on over 810,000 offshore entities.
- **OpenCorporates**: https://opencorporates.com -- The largest open database of corporate data, with records on over 200 million companies worldwide.
- **Open Ownership**: https://register.openownership.org -- Global beneficial ownership data.

**Suspicious activity and enforcement:**
- **FinCEN (Financial Crimes Enforcement Network)**: Suspicious Activity Reports (SARs) are not publicly available, but enforcement actions and advisories are published at https://www.fincen.gov
- **OFAC Sanctions Lists**: https://sanctionssearch.ofac.treas.gov -- Specially Designated Nationals and blocked persons.
- **SEC Enforcement Actions**: https://www.sec.gov/litigation.shtml -- All SEC enforcement actions, including settled cases, administrative proceedings, and litigation releases.

**The follow-the-money methodology:**
1. **Identify the money flow**: Who paid whom, how much, when, and for what stated purpose?
2. **Trace the entities**: Who actually controls the companies involved? Beneficial ownership research through corporate registries, SEC filings, and the ICIJ Offshore Leaks Database.
3. **Find the patterns**: Do payments correlate with government actions, contract awards, regulatory decisions, or votes?
4. **Cross-reference**: Do the same names, addresses, or entities appear across multiple seemingly unrelated transactions?
5. **Document the timeline**: Build a chronological narrative of money movements alongside political and regulatory events.

---

### 1.4 Corporate Intelligence -- SEC Filings, Court Records, Patent Analysis

Corporations generate enormous public paper trails. Understanding how to read and cross-reference these records is a core investigative skill.

**SEC filings deep dive:**
- **10-K (Annual Report)**: The most comprehensive public document a company produces. Contains financial statements, risk factors (companies are legally required to disclose risks, which often reveals information they would prefer to hide), executive compensation, related-party transactions, legal proceedings, and segment reporting. Read the footnotes -- that is where the bodies are buried.
- **10-Q (Quarterly Report)**: Less comprehensive than 10-K but more current. Interim financial statements and management discussion.
- **8-K (Current Report)**: Filed when a material event occurs -- executive departures, acquisitions, lawsuits, defaults, changes in auditors. 8-Ks often contain information the company has not yet publicized.
- **DEF 14A (Proxy Statement)**: Executive compensation details, board member backgrounds, shareholder proposals, and related-party transactions. Reveals governance structures and conflicts of interest.
- **Form 4 (Insider Trading)**: Filed within two business days of insider transactions. Tracks when executives and directors buy or sell company stock. Patterns of insider selling before bad news or buying before good news can indicate foreknowledge.
- **Schedule 13D/13G**: Filed when an entity acquires more than 5% of a company's shares. Reveals activist investors, acquisition attempts, and major ownership changes.

**Court records:**
- **PACER (Public Access to Court Electronic Records)**: https://pacer.uscourts.gov -- Electronic access to all federal court documents. $0.10/page, though charges are waived if quarterly usage is $30 or less (75% of users pay nothing in a given quarter).
- **RECAP (Archive of PACER documents)**: https://www.courtlistener.com/recap/ -- Free, public archive of PACER documents contributed by users of the RECAP browser extension (maintained by the Free Law Project: https://free.law/recap/). Install the RECAP extension and every PACER document you access is automatically contributed to the public archive, and anything already in the archive is available to you for free.
- **State courts**: Access varies dramatically by state. Some states (e.g., New York, California) offer online access to case dockets. Others require in-person visits or mail requests.
- **What to look for in court records**: Lawsuits reveal disputes, contract breaches, fraud allegations, employment discrimination, environmental violations, and patent disputes. Bankruptcy filings expose financial structures, creditor lists, and asset valuations. Divorce proceedings sometimes reveal hidden assets. Criminal cases against employees or executives can expose corporate misconduct.

**Patent and intellectual property analysis:**
- **USPTO Patent Full-Text Database**: https://patft.uspto.gov -- Search all U.S. patents and patent applications.
- **Google Patents**: https://patents.google.com -- More user-friendly search across international patent databases.
- **Patent analysis reveals**: Technology direction, research priorities, inventor networks, licensing relationships, potential infringement, and acquisition targets.

**Beneficial ownership and corporate structure:**
- **State corporate registries**: Every state maintains a database of registered corporations, LLCs, and other entities. Secretary of State websites provide basic information (registered agent, formation date, officers/directors in some states).
- **OpenCorporates**: https://opencorporates.com -- Aggregates corporate registry data from jurisdictions worldwide.
- **Corporate mapping**: Building org charts of subsidiaries, affiliates, joint ventures, and associated entities to understand the full structure of a corporate group. Particularly valuable for identifying shell companies, nominee directors, and layered ownership structures.

---

### 1.5 Geospatial Intelligence (GEOINT) -- Satellite Imagery and Mapping

Satellite imagery has become accessible to civilian investigators. What was once the exclusive domain of intelligence agencies is now available to anyone with an internet connection. This democratization of overhead imagery is one of the most powerful tools available for accountability work.

**Free and open satellite imagery:**

**Copernicus / Sentinel satellites (European Space Agency):**
- **Copernicus Browser**: https://browser.dataspace.copernicus.eu -- Free access to Sentinel-1 (radar), Sentinel-2 (optical, 10m resolution), and Sentinel-3 (ocean/land monitoring) data.
- Sentinel-2 provides global coverage with 10-meter resolution and a 5-day revisit cycle. Sufficient for monitoring construction, deforestation, large-scale environmental damage, and industrial activity.
- All Sentinel data is free and open under the Copernicus Open Access policy.

**USGS/NASA Landsat:**
- **EarthExplorer**: https://earthexplorer.usgs.gov -- Access to the full Landsat archive (1972-present) and other datasets. 30-meter resolution for Landsat 8/9.
- **Landsat on AWS**: https://landsatonaws.com -- Cloud-hosted Landsat data for programmatic access.

**Commercial imagery (varying access models):**

**Planet Labs:**
- Operates the largest fleet of Earth observation satellites. Daily coverage of the entire planet at 3-5m resolution (PlanetScope) and 50cm resolution (SkySat for tasked collection).
- **Planet Insights Platform**: Commercial access starts at approximately 25 euros/month for nonprofit use.
- Planet acquired Sentinel Hub in 2023 and is unifying the platforms. As of 2025, EO Browser has been retired and functionality is being migrated to the Planet Insights Platform.

**Maxar (DigitalGlobe):**
- Highest-resolution commercial imagery (30cm). Historical archive back to 1999.
- Some imagery available through Google Earth.

**Google Earth / Google Earth Pro:**
- Free access to historical satellite imagery with time-slider functionality.
- Not real-time, but the historical archive is invaluable for documenting changes over time.
- Google Earth Pro (free desktop application) provides measurement tools, GPS import/export, and higher-resolution printing.

**Mapping and analysis tools:**

**QGIS** (https://qgis.org): Free, open-source geographic information system. Full-featured GIS with support for raster and vector data, georeferencing, spatial analysis, and cartographic output. Supports plugins for accessing Sentinel Hub, OpenStreetMap, and other data sources. The civilian equivalent of military GIS tools.

**Leaflet** (https://leafletjs.com): Open-source JavaScript library for interactive web maps. Lightweight, mobile-friendly, and extensively documented. Used for publishing investigative map visualizations.

**Mapbox** (https://www.mapbox.com): Maps platform with generous free tier. Custom map styles, geocoding, routing, and satellite imagery. Free tier includes 50,000 map loads/month.

**Overpass Turbo** (https://overpass-turbo.eu): Query engine for OpenStreetMap data. Allows searching for specific features (buildings, roads, facilities) in any area.

**Investigative applications of GEOINT:**
- **Environmental monitoring**: Tracking deforestation, illegal mining, pollution, water diversion, or construction in protected areas. Before/after satellite imagery provides irrefutable evidence.
- **Conflict documentation**: Monitoring military movements, facility construction, destruction of civilian infrastructure.
- **Asset verification**: Confirming the existence (or non-existence) of facilities, properties, or infrastructure claimed in financial statements or government reports.
- **Supply chain investigation**: Tracking shipping movements via AIS (Automatic Identification System) data (MarineTraffic: https://www.marinetraffic.com), and flight movements via ADS-B data (FlightRadar24: https://www.flightradar24.com, ADS-B Exchange: https://www.adsbexchange.com).

---

### 1.6 Network Analysis -- Mapping Connections

Power operates through networks -- of people, organizations, money, and influence. Network analysis makes these connections visible. The goal is not to surveil individuals but to map the structural relationships through which power flows and corruption operates.

**What to map:**
- **People-to-organizations**: Board memberships, employment, advisory roles, consulting relationships
- **Organizations-to-organizations**: Subsidiaries, joint ventures, shared directors (interlocking directorates), contractual relationships, supply chains
- **Money flows**: Campaign contributions, lobbying expenditures, contract payments, investments, loan relationships
- **Communication patterns**: Co-appearances at events, co-authorship, shared affiliations, social media connections
- **Temporal patterns**: How networks change around key events -- who enters the network before a contract award? Who exits after a scandal?

**Network analysis concepts:**
- **Centrality**: Which nodes (people/organizations) are most connected? Betweenness centrality identifies brokers -- entities that connect otherwise separate clusters.
- **Clustering**: Which groups of entities form tight clusters? Clusters may represent factions, coalitions, or coordinated groups.
- **Bridges**: Which connections link otherwise separate clusters? These are the critical relationships that enable coordination across organizational boundaries.
- **Anomalies**: Unexpected connections (why does this environmental regulator share a board member with this mining company?) or missing connections (why do these co-conspirators have no documented relationship?).

**Data sources for network construction:**
- SEC filings (board memberships, executive compensation, related-party transactions)
- Corporate registries (officers, directors, registered agents)
- Campaign finance data (donor networks, PAC relationships)
- Lobbying disclosures (client-lobbyist relationships)
- Court records (co-defendants, witness lists, named parties)
- Event attendance lists, conference programs
- Academic publications (co-authorship networks)
- Patent filings (co-inventor networks)
- Social media connections (public follower/following relationships)

---

### 1.7 Document Intelligence -- Analyzing Leaked and Public Documents at Scale

Large document sets -- whether from FOIA responses, leaked archives, court discovery, or public databases -- contain patterns invisible to anyone reading one document at a time. Document intelligence is the discipline of extracting structure, entities, relationships, and anomalies from document sets too large for human reading.

**The pipeline:**

1. **Ingestion**: Converting documents from their native formats (PDF, DOCX, email, scanned images) into searchable, structured text.
2. **OCR (Optical Character Recognition)**: For scanned documents. Modern OCR (Tesseract, Google Cloud Vision, Amazon Textract) handles multi-language, handwritten, and degraded text.
3. **Entity extraction**: Identifying people, organizations, locations, dates, monetary amounts, and other entities mentioned in documents. Named Entity Recognition (NER) models automate this at scale.
4. **Relationship extraction**: Identifying stated relationships between entities (X paid Y, A is a subsidiary of B, C attended meeting with D).
5. **Deduplication and entity resolution**: Determining that "John R. Smith," "J. Smith," and "John Smith, CFO of Acme Corp" are the same person.
6. **Cross-referencing**: Connecting entities found in documents to external databases (corporate registries, campaign finance data, court records).
7. **Anomaly detection**: Identifying documents that differ from expected patterns -- unusual payment amounts, missing signatures, backdated documents, inconsistent terminology.
8. **Timeline construction**: Building chronological narratives from dated documents.

**Key platforms:**
- **Aleph (OCCRP)**: See Section 2 tools below for full details.
- **DocumentCloud**: See Section 2 tools below.
- **Apache Tika**: See Section 2 tools below.
- **Datashare (ICIJ)**: https://datashare.icij.org -- The platform ICIJ uses internally for its collaborative investigations, including the Panama Papers and Pandora Papers. Open source, supports batch document processing, NER, and full-text search.

---

### 1.8 Web Archiving

The internet forgets -- and powerful actors actively make it forget. Websites are taken down, posts are deleted, pages are modified. Web archiving preserves the record.

**Archiving services:**

**Wayback Machine (Internet Archive):**
- URL: https://web.archive.org
- The largest web archive, containing over 1 trillion web pages and 99+ petabytes of data as of October 2025.
- **Availability API**: `https://archive.org/wayback/available?url=<target_url>` -- Check if a URL has been archived. Returns JSON with the closest available snapshot.
- **CDX API**: `https://web.archive.org/cdx/search/cdx?url=<target_url>&output=json` -- Returns all archived snapshots of a URL with timestamps.
- **Save Page Now**: `https://web.archive.org/save/<target_url>` -- Manually trigger archiving of a page.
- **Python library**: `waybackpy` (https://pypi.org/project/waybackpy/) for programmatic access.
- **2025 challenges**: An 87% drop in page captures among news publications occurred from May to October 2025. Some news organizations (The Guardian, New York Times) have begun blocking the Wayback Machine due to AI scraping concerns. This makes self-archiving increasingly critical.

**Archive.today (archive.ph):**
- Independent archiving service that creates snapshot copies of web pages.
- Particularly useful because it preserves the page as rendered (including dynamically loaded content), not just the raw HTML.
- No API, but manual archiving via https://archive.today or automated through tools.

**Self-archiving tools:**
- **wabarc/wayback** (https://github.com/wabarc/wayback): Open-source archiving tool that integrates with Internet Archive, Archive.today, Ghostarchive, IPFS, and local file systems. Runs as a CLI, web server, or messaging bot (Telegram, Discord, Slack, etc.).
- **ArchiveBox** (https://archivebox.io): Self-hosted web archiving solution. Archives pages as HTML, screenshots, PDFs, and WARC files. Runs on any server.
- **HTTrack** (https://www.httrack.com): Downloads entire websites for offline browsing and archiving.
- **SingleFile** browser extension: Saves complete web pages (including CSS, images, and JavaScript-rendered content) as a single HTML file.
- **Conifer (formerly Webrecorder)** (https://conifer.rhizome.org): Creates high-fidelity web archives that replay exactly as the original page appeared, including interactive content.

**Best practices:**
- Archive early and often. Pages disappear without warning.
- Archive to multiple services simultaneously (Wayback Machine AND Archive.today AND local copies).
- Preserve original URLs and timestamps for evidentiary chain.
- For critical evidence, save cryptographic hashes (SHA-256) of archived content to establish tampering detection.

---

### 1.9 Dark Web Monitoring

The dark web -- websites accessible only through anonymizing networks like Tor -- hosts whistleblower submission platforms, leaked document repositories, and forums where stolen corporate data surfaces. Ethical monitoring of these spaces is legitimate OSINT, subject to clear boundaries.

**What is legitimate to monitor:**
- Whistleblower submission platforms (SecureDrop instances, GlobaLeaks instances)
- Leaked corporate databases that appear on paste sites or forums
- Public forums discussing corporate malfeasance or government corruption
- Ransomware gang leak sites where stolen corporate data is published (this data reveals security failures, internal communications, and sometimes evidence of wrongdoing)
- Marketplaces and forums as indicators of broader criminal ecosystem activity

**What is NOT legitimate:**
- Purchasing stolen data, credentials, or personal information
- Participating in illegal markets or criminal forums (beyond passive observation)
- Downloading or distributing child sexual abuse material (a criminal offense regardless of investigative intent)
- Accessing systems using stolen credentials
- Any action that facilitates or participates in criminal activity

**Ethical framework:**
The legal standard is generally clear: passively observing publicly posted content on the dark web is legal. Active participation in criminal activity is not. The ethical standard should be stricter: monitor only when there is a specific investigative purpose, document only what is relevant to accountability work, and protect any personal information of uninvolved parties encountered during monitoring.

**Access:**
- **Tor Browser**: https://www.torproject.org -- The standard tool for accessing .onion sites.
- **Tails OS**: Provides a full operating environment that routes all traffic through Tor and leaves no trace on the host machine. See Section 5 for details.

**Dark web OSINT tools:**
- **Ahmia** (https://ahmia.fi): Search engine for Tor hidden services. Also accessible via Tor.
- **OnionScan** (https://github.com/s-rah/onionscan): Scans .onion services for security issues and information leaks.
- **DarkOwl**: Commercial dark web intelligence platform with API access for enterprise monitoring.
- **IntelX (Intelligence X)** (https://intelx.io): Search engine that indexes the dark web, paste sites, data leaks, and other sources. Free tier available with limited searches.

---

## 2. Tools of the Trade

This section provides specific tool details -- what each tool does, how to deploy it, what it costs, and what its limitations are.

---

### 2.1 Link Analysis and Reconnaissance

#### Maltego

**What it is**: The industry-standard graphical link analysis tool for OSINT. Visualizes relationships between entities (people, companies, domains, IP addresses, social media accounts, phone numbers) as interactive network graphs. Connections are discovered through "Transforms" -- automated queries to data sources.

**URL**: https://www.maltego.com

**Editions:**
- **Community Edition (CE)**: Free. Limited to 12 entities per graph, limited Transform access. Sufficient for learning the methodology.
- **Maltego Pro**: From $1,999/year for individuals. Full graph capability, access to the Transform Hub.
- **Maltego Enterprise**: Custom pricing for teams.

**Transform Hub**: Maltego's marketplace of data integrations, including deep and dark web, cryptocurrency, social media, person-of-interest databases, company intelligence, network infrastructure, and more. Some Transforms are free; many require separate subscriptions to the underlying data providers.

**Key capabilities:**
- Visual link analysis and network mapping
- Entity relationship discovery through automated Transforms
- Integration with hundreds of OSINT data sources
- Geospatial link analysis for mapping entities to locations
- Collaborative investigation features in Enterprise edition

**Limitations**: The free Community Edition is severely limited. Full capability requires significant investment. The tool is powerful but can create a false sense of completeness -- it only finds what its Transforms can access.

---

#### SpiderFoot

**What it is**: Open-source OSINT automation platform that collects, analyzes, and connects data from 200+ sources automatically. Eliminates hours of manual reconnaissance.

**URL**: https://spiderfoot.net | **GitHub**: https://github.com/smicallef/spiderfoot

**License**: MIT (fully open source and free)

**Deployment:**
```bash
# Clone and run locally
git clone https://github.com/smicallef/spiderfoot.git
cd spiderfoot
pip3 install -r requirements.txt
python3 sf.py -l 127.0.0.1:5001
# Access web UI at http://127.0.0.1:5001
```

**Target types**: IP addresses, domain names, hostnames, ASNs, subnets, email addresses, person names, phone numbers, usernames, Bitcoin addresses.

**Key features:**
- Scans 200+ data sources per target
- Correlation rules (introduced in SpiderFoot 4.0): YAML-based rules that analyze scan results to identify patterns and relationships
- Web-based UI for configuration and result visualization
- CSV, JSON, and graph export
- API for programmatic access

**Commercial option**: SpiderFoot HX is the hosted cloud version with additional features and managed infrastructure.

**Use case for civic accountability**: Feed in a company name, executive name, or domain, and SpiderFoot will automatically discover associated entities, relationships, exposed infrastructure, and data leaks across hundreds of sources.

---

#### Recon-ng

**What it is**: A full-featured web reconnaissance framework written in Python, modeled after Metasploit's interface. Designed for systematic information gathering from open sources.

**URL**: https://github.com/lanmaster53/recon-ng

**License**: Open source (GPL-3.0)

**Installation:**
```bash
# Pre-installed on Kali Linux, or:
git clone https://github.com/lanmaster53/recon-ng.git
cd recon-ng
pip install -r REQUIREMENTS
./recon-ng
```

**Key features:**
- Modular architecture with installable modules for different data sources
- Database-backed workflow -- results are stored in a SQLite database for querying and export
- Modules cover: domains, hosts, contacts, credentials, vulnerabilities, and reporting
- API key management for integrating with Shodan, HaveIBeenPwned, VirusTotal, and other services
- CSV, JSON, XML, and HTML report output

**Example workflow:**
```
[recon-ng][default] > marketplace install all
[recon-ng][default] > workspaces create target_investigation
[recon-ng][target_investigation] > modules load recon/domains-hosts/hackertarget
[recon-ng][target_investigation] > options set SOURCE example.com
[recon-ng][target_investigation] > run
```

---

### 2.2 Email and Username Discovery

#### theHarvester

**What it is**: Email address, subdomain, host, and employee name discovery tool. Queries 38+ public data sources to enumerate a target domain's digital footprint.

**URL**: https://github.com/laramies/theHarvester

**License**: Open source (GPL-2.0)

**Current version**: 4.8.2

**Installation:**
```bash
git clone https://github.com/laramies/theHarvester.git
cd theHarvester
pip3 install -r requirements.txt
python3 theHarvester.py -d target-domain.com -b all
```

**Data sources include**: Google, Bing, Shodan, LinkedIn, Hunter.io, VirusTotal, Censys, AnubisDB, GitHub, and many more.

**Use case**: Given a company domain, discover all associated email addresses, subdomains, employee names, and exposed infrastructure. Cross-reference discovered emails with Holehe to find associated accounts.

---

#### Holehe

**What it is**: Checks whether an email address is registered on 120+ online platforms by probing password reset and registration endpoints. Does not send notifications to the target email.

**URL**: https://github.com/megadose/holehe

**License**: Open source (GPL-3.0)

**Installation:**
```bash
pip3 install holehe
holehe target@example.com
```

**Web interface available at**: https://holeheosint.com (for non-CLI users)

**Platforms checked**: Twitter, Instagram, Snapchat, Imgur, Spotify, Adobe, Amazon, Apple, and 110+ more.

**Use case**: After discovering email addresses via theHarvester, use Holehe to determine which platforms each address is registered on. This reveals the digital footprint without accessing any private information.

---

#### Sherlock

**What it is**: Hunts for a given username across 400+ social networks and websites. Determines where a username is active by checking URL patterns.

**URL**: https://github.com/sherlock-project/sherlock

**License**: Open source (MIT)

**Current version**: 0.16.0

**Installation:**
```bash
pip3 install sherlock-project
sherlock username_to_search
```

**Key features:**
- Checks 400+ platforms
- Outputs results to text files, CSV, or XLSX
- Supports bulk username input via JSON
- Proxy and Tor support for anonymous querying
- Available on Apify (https://apify.com/misceres/sherlock) for cloud execution

**Use case**: A target uses the same username across multiple platforms. Sherlock discovers all accounts, revealing platforms and communities the target participates in.

---

### 2.3 Infrastructure and Device Discovery

#### Shodan

**What it is**: A search engine for internet-connected devices. Crawls the internet and indexes service banners, revealing what devices are connected, what software they run, and what ports are open.

**URL**: https://www.shodan.io | **API**: https://developer.shodan.io/api

**Pricing**: Free tier (50 results per search). Academic: $19/month. Membership: $69/year (unlimited searches, API access).

**What Shodan indexes**: Web servers (HTTP/HTTPS), FTP, SSH, Telnet, SNMP, IMAP, SMTP, SIP, RTSP, databases, industrial control systems (SCADA), webcams, routers, and any device with an IP address and open port.

**CLI:**
```bash
pip install shodan
shodan init YOUR_API_KEY
shodan search "org:target_company"
```

**Investigative applications:**
- Discover all internet-facing infrastructure belonging to a target organization
- Identify misconfigured or vulnerable systems (exposed databases, open admin panels)
- Find IoT devices, security cameras, and industrial control systems
- Historical data shows how infrastructure changes over time
- In September 2025, Cisco researchers used Shodan to discover over 1,100 publicly exposed Ollama LLM servers -- demonstrating how the tool reveals organizational security posture

**Complementary tools:**
- **Censys** (https://search.censys.io): Similar to Shodan but focuses on certificate and protocol analysis. Free tier available.
- **ZoomEye** (https://www.zoomeye.org): Chinese equivalent of Shodan with a different index and perspective.

---

#### Google Dorking / Advanced Search Operators

**What it is**: Using Google's advanced search operators to discover information not readily available through standard searches. One of the most powerful and underutilized OSINT techniques.

**Core operators:**
- `site:target.com` -- Limit results to a specific domain
- `filetype:pdf` / `filetype:xls` / `filetype:doc` -- Find specific file types
- `inurl:admin` / `inurl:login` -- Find pages with specific URL patterns
- `intitle:"index of"` -- Find open directory listings
- `intext:"confidential"` -- Find pages containing specific text
- `cache:target.com/page` -- View Google's cached version of a page
- `"exact phrase"` -- Search for exact string matches
- `daterange:` -- Filter by date range (Julian date format)

**Investigative examples:**
```
site:target-company.com filetype:pdf "confidential"
site:target-company.com filetype:xls "employee" OR "salary" OR "budget"
"target person name" filetype:pdf
inurl:target-company.com/wp-content/uploads
site:pacer.gov "company name"
```

**Google Hacking Database (GHDB)**: https://www.exploit-db.com/google-hacking-database -- Maintained collection of dorking queries organized by category.

**Beyond Google:**
- **Bing dorking**: Bing supports many of the same operators and sometimes indexes content Google does not.
- **Yandex**: Russian search engine with different indexing priorities. Particularly strong for reverse image search.
- **DuckDuckGo**: Supports `site:` and `filetype:` operators while providing additional privacy.

---

### 2.4 Social Media Tools

#### Twint (Twitter Intelligence Tool)

**What it is**: Advanced Twitter/X scraping tool that does not use the official API, bypassing rate limits and the 3,200-tweet history cap.

**URL**: https://github.com/twintproject/twint

**Key advantages:**
- No API key required
- No authentication needed
- No rate limits (API-independent)
- Scrapes followers, following lists, tweets, favorites, and retweets
- Supports advanced search operators (date ranges, hashtags, keywords, mentions)
- Output to CSV, JSON, SQLite, or Elasticsearch

**Note**: Twitter/X has increasingly blocked scraping tools. Twint's effectiveness depends on the current state of Twitter's anti-scraping measures. Test before relying on it for an investigation.

#### Instaloader

**What it is**: Downloads pictures, videos, captions, and metadata from Instagram profiles, hashtags, and stories.

**URL**: https://instaloader.github.io | **GitHub**: https://github.com/instaloader/instaloader

**Installation:**
```bash
pip3 install instaloader
instaloader profile target_username
instaloader "#targethashtag"
```

**Features**: Downloads posts, stories, highlights, tagged posts, IGTV, and profile metadata. Supports login for accessing content visible only to authenticated users (using your own legitimate account).

#### yt-dlp

**What it is**: Command-line tool to download video and audio from YouTube and 1000+ other sites. Fork of youtube-dl with active development.

**URL**: https://github.com/yt-dlp/yt-dlp

**Installation:**
```bash
pip3 install yt-dlp
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID"
yt-dlp --write-info-json --write-thumbnail --write-subs URL
```

**Investigative use**: Preserve video evidence before it can be deleted. Download metadata (upload date, description, channel info, view counts) alongside the video. Extract subtitles for text analysis.

---

### 2.5 Network Visualization

#### Gephi

**What it is**: The leading open-source platform for network visualization and analysis. Used by Bellingcat and investigative journalists worldwide for visualizing relationship networks.

**URL**: https://gephi.org | Free, open source (GPL-3.0 / CDDL)

**Key features:**
- Real-time visualization of large networks (tested with 100,000+ nodes)
- Multiple layout algorithms (ForceAtlas2, Fruchterman-Reingold, Yifan Hu)
- Statistical analysis: centrality, clustering, community detection, path analysis
- Filtering and partitioning by attributes
- High-quality export for publication

**Gephi Lite** (2025): Web-based version for lightweight analysis without installation. Presented at Digital Humanities 2025.

**Import formats**: CSV, GraphML, GEXF, GDF, Pajek, and direct import from Neo4j.

#### Neo4j

**What it is**: The most widely-used graph database. Stores data as nodes and relationships, making it natural for representing networks of people, organizations, and money flows.

**URL**: https://neo4j.com

**Editions:**
- **Community Edition**: Free, open source. Single-instance deployment.
- **AuraDB Free**: Cloud-hosted, free tier with limited resources.
- **Enterprise**: Paid, with clustering, security, and administration features.

**Why it matters**: Neo4j was used by ICIJ for the Panama Papers, Pandora Papers, and FinCEN Files investigations. Linkurious Enterprise (the visual exploration layer on top of Neo4j) enabled 600+ journalists across 150 media organizations to collaboratively explore complex financial networks.

**Query language**: Cypher -- a declarative graph query language:
```cypher
// Find all companies where a person is a director
MATCH (p:Person {name: "John Smith"})-[:DIRECTOR_OF]->(c:Company)
RETURN p, c

// Find shortest path between two entities
MATCH path = shortestPath(
  (a:Entity {name: "Company A"})-[*]-(b:Entity {name: "Company B"})
)
RETURN path

// Find people who are directors of multiple companies
MATCH (p:Person)-[:DIRECTOR_OF]->(c:Company)
WITH p, count(c) as companies
WHERE companies > 3
RETURN p.name, companies ORDER BY companies DESC
```

**ICIJ Offshore Leaks Database on Neo4j**: https://neo4j.com/developer-blog/exploring-the-pandora-papers-with-neo4j/ -- ICIJ provides its Offshore Leaks data in a format directly importable into Neo4j.

#### Linkurious

**What it is**: Commercial graph visualization platform built on top of Neo4j. The tool ICIJ used for the Pandora Papers and FinCEN Files investigations.

**URL**: https://linkurious.com

**Key advantage**: Collaborative investigation -- multiple journalists can simultaneously explore the same graph database, annotate findings, and share discoveries.

---

### 2.6 Document Analysis Platforms

#### Aleph (OCCRP)

**What it is**: A data platform created by the Organized Crime and Corruption Reporting Project (OCCRP) for tracking people and companies across millions of documents. Consolidates corporate registries, financial records, leaks, legal filings, sanctions lists, and more into a single searchable, cross-referenced platform.

**Public instance**: https://aleph.occrp.org -- Free and accessible to journalists, researchers, and the public.

**URL**: https://docs.aleph.occrp.org | **GitHub**: https://github.com/alephdata/aleph

**Aleph Pro** (launched October 2025): Rebuilt from the ground up with enhanced performance and new features.
- **Free forever** for nonprofit journalism organizations (including OCCRP network members). Includes core investigative toolset, 1TB data storage, unlimited users, community support.
- **At-cost pricing** for civic tech groups and civil society organizations (pays only server and infrastructure costs).

**OpenAleph** (https://openaleph.org): A community fork committed to maintaining Aleph as a fully open-source commons, started by the Data and Research Center (DARC) after OCCRP introduced the commercial Aleph Pro tier.

**Key features:**
- Entity cross-referencing across millions of documents
- Network visualization showing connections between people, companies, and addresses
- Upload and process your own document sets
- Named entity extraction
- Full-text search across all indexed documents
- Integration with FollowTheMoney data model (https://followthemoney.tech) -- a schema for representing entities and relationships in investigative data

---

#### DocumentCloud

**What it is**: Open-source platform for uploading, analyzing, annotating, collaborating on, and publishing primary source documents. Used by 8,400+ journalists in 1,619+ organizations worldwide.

**URL**: https://www.documentcloud.org | Free for journalists and researchers

**Key features:**
- OCR for scanned documents
- Named entity extraction
- Multilanguage support
- Annotation and collaboration tools
- Public embedding of documents in news stories
- Full API for programmatic access
- **Add-Ons**: Community-built extensions including table extraction from PDFs, website scraping, and AI-powered summarization
- **Free transcription** powered by OpenAI Whisper for audio and video recordings (with timestamps)
- Document repository hosts 3.6+ million source documents with 824+ million public views

**Operated by**: MuckRock (since 2018 merger)

---

#### Apache Tika

**What it is**: Java-based toolkit for detecting file types and extracting metadata and text from over 1,400 file formats. The backbone of many document processing pipelines.

**URL**: https://tika.apache.org | **GitHub**: https://github.com/apache/tika

**License**: Apache License 2.0

**Current version**: 3.2.3 (requires Java 11+, Tika 2.x / Java 8 reached EOL April 2025)

**Supported formats**: PDF, DOCX, XLSX, PPTX, emails (EML, MSG, MBOX), images (with OCR via Tesseract), audio, video, HTML, XML, and hundreds more.

**Deployment:**
```bash
# Run as a server
java -jar tika-server-standard-3.2.3.jar

# Or use Docker
docker run -p 9998:9998 apache/tika

# Extract text from a document
curl -T document.pdf http://localhost:9998/tika
```

**Use case**: Process incoming document dumps automatically. Feed FOIA responses, court documents, or leaked files through Tika to extract searchable text and metadata, then index the results in Elasticsearch or Aleph for investigation.

---

### 2.7 Data Cleaning and Reconciliation

#### OpenRefine

**What it is**: Free, open-source desktop application for working with messy data -- cleaning, transforming, reconciling, and extending it with external data sources.

**URL**: https://openrefine.org | **GitHub**: https://github.com/OpenRefine/OpenRefine

**License**: BSD-3-Clause

**Key features:**
- **Faceted browsing**: Explore and filter large datasets by values, text patterns, or numeric ranges
- **Clustering**: Automatically identify and merge variant spellings of the same name (critical for entity resolution)
- **Reconciliation**: Semi-automated matching of local data against external authority sources (Wikidata, corporate registries, etc.) via the Reconciliation Service API
- **GREL expressions**: Powerful expression language for data transformation
- **URL fetch**: Built-in HTTP client for enriching data from web APIs
- **Undo/redo history**: Complete audit trail of all transformations
- **Geocoding**: Convert addresses to geographic coordinates

**Investigative use case**: You receive a FOIA response containing 50,000 rows of contract data with inconsistently formatted company names, dates in multiple formats, and dollar amounts as text. OpenRefine clusters similar company names ("Acme Corp," "ACME Corporation," "Acme Corp.") for reconciliation, standardizes dates and currencies, and reconciles company names against OpenCorporates or SEC EDGAR data to add corporate identifiers.

---

### 2.8 Geocoding and Mapping

**QGIS**: See Section 1.5 above. Full-featured open-source GIS.

**Leaflet**: See Section 1.5 above. JavaScript library for web maps.

**Mapbox**: See Section 1.5 above. Maps platform with free tier.

**Additional tools:**
- **kepler.gl** (https://kepler.gl): Open-source geospatial analysis tool for large-scale datasets. Visualizes millions of data points on a map. Created by Uber.
- **Nominatim** (https://nominatim.openstreetmap.org): Free geocoding service from OpenStreetMap. Converts addresses to coordinates and vice versa.
- **Mapillary** (https://www.mapillary.com): Crowdsourced street-level imagery. Open alternative to Google Street View with historical imagery.

---

### 2.9 AI-Enhanced OSINT

**How LLMs are transforming OSINT:**

- **Document summarization at scale**: Process thousands of pages of FOIA responses, court filings, or leaked documents. LLMs extract key facts, entities, and relationships far faster than human review.
- **Entity extraction and resolution**: Modern NER models identify people, organizations, locations, and dates with high accuracy. LLMs handle disambiguation ("Apple" the company vs. "apple" the fruit) better than rule-based systems.
- **Cross-referencing**: Feed an LLM a set of entities discovered in one dataset and ask it to identify potential matches in another dataset, accounting for name variations, aliases, and transliterations.
- **Pattern detection**: LLMs can identify unusual patterns in financial data, communication metadata, or organizational structures that would be invisible to keyword search.
- **Translation**: Modern models handle dozens of languages, enabling investigation across jurisdictions without dedicated translators.
- **Report generation**: Synthesize findings from multiple sources into coherent investigative narratives.

**Tools:**
- **Local LLMs via Ollama** (https://ollama.com): Run models locally for sensitive investigations. No data leaves your machine. Supports Llama, Mistral, Mixtral, and others. The Cleansing Fire gatekeeper daemon already manages local Ollama access.
- **LangChain / LlamaIndex**: Frameworks for building document processing pipelines that combine LLMs with retrieval augmented generation (RAG) for querying large document sets.
- **Hugging Face Transformers**: Open-source NLP models for NER, classification, summarization, and translation.
- **Google Pinpoint** (https://journaliststudio.google.com/pinpoint/about): AI-powered document analysis tool designed specifically for journalists. Free. Handles OCR, entity extraction, and search across large document sets. Alternative to DocumentCloud for AI-driven analysis.

---

## 3. Investigative Journalism Techniques

---

### 3.1 Follow the Money -- ICIJ and OCCRP Methodology

The International Consortium of Investigative Journalists (ICIJ) and the Organized Crime and Corruption Reporting Project (OCCRP) have developed and refined the most sophisticated collaborative investigation methodologies in journalism history. Their techniques are replicable.

**The ICIJ model (used for Panama Papers, Pandora Papers, FinCEN Files):**

1. **Receive and secure the data**: The Panama Papers comprised 2.6 TB of data (11.5 million documents) from the Panamanian law firm Mossack Fonseca. The Pandora Papers comprised 2.94 TB (11.9 million records) from 14 offshore service providers.

2. **Process and structure**: Only 4% of the Pandora Papers files were structured (spreadsheets, CSV, database files). The rest were PDFs, emails, images, and other unstructured formats. ICIJ used Python scripts for automated data extraction where possible, and machine learning tools (Fonduer, scikit-learn) to classify and separate documents.

3. **Make it searchable**: All documents were processed through OCR and indexed in a searchable platform. For the Pandora Papers, ICIJ used their own Datashare platform (https://datashare.icij.org) plus Linkurious Enterprise on Neo4j for graph visualization.

4. **Distribute for collaborative analysis**: ICIJ shared the data with 600+ journalists across 150 media organizations in 117 countries. Each journalist searched for entities relevant to their jurisdiction while contributing findings back to the shared knowledge base.

5. **Cross-reference with external data**: Investigators brought in sanctions lists, politically exposed persons (PEP) databases, previous leaks, corporate registries, and public records to identify the beneficial owners behind offshore structures.

6. **Build narratives**: Individual investigations were assembled from the evidence, then fact-checked, legally reviewed, and coordinated for simultaneous global publication.

**ICIJ Offshore Leaks Database**: https://offshoreleaks.icij.org
- Contains data from the Panama Papers, Paradise Papers, Pandora Papers, Bahamas Leaks, and Offshore Leaks investigations.
- 810,000+ offshore entities searchable by name, jurisdiction, or intermediary.
- Free, open access for anyone.
- Downloadable in bulk for analysis.

---

### 3.2 FinCEN Files Investigation Techniques

The FinCEN Files investigation (published September 2020) was based on 2,657 leaked documents from the U.S. Treasury's Financial Crimes Enforcement Network, including 2,121 Suspicious Activity Reports (SARs) covering over 200,000 suspicious transactions valued at over $2 trillion between 1999 and 2017.

**Technical approach:**

1. **Data standardization**: ICIJ processed 400 spreadsheets containing data on 100,000+ transactions. After removing duplicates and standardizing bank names, investigators could search within the data for people, companies, and patterns.

2. **Graph database analysis**: Using Linkurious Enterprise on Neo4j, journalists visually navigated complex transaction networks to understand the parties involved. The graph structure revealed clusters of connected entities that spreadsheet analysis would have missed.

3. **SAR pattern analysis**: Investigators analyzed 109 suspicious activity reports filed by the Panamanian law firm Alcogal to identify patterns in anti-money-laundering compliance failures.

4. **Employee profile research**: Journalists read through several thousand publicly available employee profiles (likely LinkedIn) to identify connections between lawyers at offshore service providers and government positions -- the revolving door between regulation and the regulated industry.

5. **Cross-leak analysis**: Entities found in the FinCEN Files were cross-referenced against the Panama Papers, Paradise Papers, and other prior investigations to build a more complete picture.

**Methodological takeaway**: The most powerful technique is not any single tool but the combination of structured data analysis, graph visualization, and domain expertise from journalists who understand the financial systems being investigated. Technology amplifies human understanding; it does not replace it.

---

### 3.3 Building Source Networks

Sources -- human beings with inside knowledge who choose to share information -- remain the most valuable intelligence asset in any investigation. Technology cannot replace the trust relationships that produce source information.

**Principles:**
- **Reciprocity**: Sources provide information because they believe it serves a purpose. Investigators must demonstrate competence, seriousness, and follow-through.
- **Protection above all**: A source's safety is more important than any story. If publishing will endanger a source, do not publish until the source is protected.
- **Compartmentalization**: No single person should know all sources. Information about source identity should be shared on a strict need-to-know basis.
- **Verification**: Source information must be independently verified. Sources can be wrong, biased, or deliberately deceptive.
- **Legal awareness**: Know the shield laws in your jurisdiction. Understand when and how source protections can be overridden by courts.

**Building networks:**
- Attend industry conferences, regulatory hearings, and court proceedings in your investigative area
- Monitor professional communities (LinkedIn groups, industry forums, professional associations)
- Review public employment records, SEC filings, and lobbying disclosures to identify potential sources with relevant knowledge and possible motivation
- Former employees are often more willing to talk than current employees
- Whistleblower tip lines (MuckRock, SecureDrop instances) create inbound source channels

---

### 3.4 Document Verification and Authentication

Not all documents are genuine. Fabricated documents can be planted to discredit investigators or to advance disinformation. Verification is non-negotiable.

**Verification techniques:**
- **Metadata analysis**: Document creation dates, author fields, software versions, and modification history. Be aware that metadata can be faked, but inconsistencies (e.g., a document claiming to be from 2015 created in a software version released in 2020) are strong indicators of fabrication.
- **Typography and formatting**: Official documents use specific fonts, layouts, stamps, and formatting conventions. Compare suspect documents against verified examples from the same source.
- **Content consistency**: Do the facts stated in the document align with independently verifiable information? Are the names, titles, dates, and reference numbers consistent with known records?
- **Provenance**: How did the document arrive? Through a known and previously reliable source? Anonymously? Was it solicited or unsolicited?
- **Multi-source corroboration**: Can the claims in the document be verified through independent sources?
- **Expert consultation**: For specialized documents (financial statements, legal filings, scientific reports), consult domain experts who can identify inconsistencies invisible to generalists.

---

### 3.5 Collaborative Investigation Platforms

#### Aleph / OpenAleph

See Section 2.6 above. The primary platform for cross-border investigative collaboration on corporate and financial data.

#### OCCRP I-Hub

The ICIJ/OCCRP investigative hub providing shared infrastructure, secure communication, and collaborative tools for investigative journalists worldwide. Access is typically limited to ICIJ/OCCRP member organizations and vetted partners.

#### Datashare (ICIJ)

**URL**: https://datashare.icij.org | **GitHub**: https://github.com/ICIJ/datashare

Open-source document search and analysis tool developed by ICIJ. Supports batch processing of documents with named entity recognition, full-text search, and collaborative annotations. Used internally by ICIJ for all major investigations.

---

### 3.6 Freedom of Information (FOIA/FOIL) Filing at Scale

Freedom of Information laws exist at the federal level (FOIA, 1966) and in all 50 states (under various names -- FOIL in New York, Public Records Act in California, etc.). They compel government agencies to release records upon request, with specific exemptions for classified information, personal privacy, law enforcement, and other categories.

FOIA is not a polite request. It is a legal demand backed by statute. Agencies are required to respond, and failure to comply is legally actionable.

#### MuckRock

**URL**: https://www.muckrock.com

**What it is**: A 501(c)(3) nonprofit that partially automates the FOIA filing process. Used by thousands of users to file, track, and share public records requests at federal, state, and local levels.

**Key features:**
- Web interface for composing and filing requests
- Automatic identification of correct agencies and contacts
- Tracking of response deadlines (FOIA requires a response within 20 business days at the federal level)
- Automatic follow-up on delinquent requests
- 30-minute submission delay for review before sending
- All requests and responses are published publicly (unless user opts out), creating a shared knowledge base
- Integration with DocumentCloud for publishing received documents

**Pricing**: Basic accounts are free. Pro accounts ($40/month) include additional request capacity and priority support.

**Filing strategy for civic accountability:**
- **File broadly**: Submit parallel requests to multiple agencies that may hold relevant records.
- **Be specific**: Vague requests are easily denied or delayed. Specify date ranges, record types, named individuals, and specific programs.
- **Know the exemptions**: Agencies will invoke exemptions (b)(1) through (b)(9) at the federal level. Know which exemptions apply and which are being improperly invoked.
- **Appeal denials**: Agencies count on requesters giving up. Always appeal denials, especially partial denials where documents are released with excessive redactions.
- **File administratively first, then litigate if necessary**: Organizations like the Reporters Committee for Freedom of the Press (https://www.rcfp.org) provide legal support for FOIA litigation.

**FOIA Machine**: https://www.foiamachine.org -- Another free tool for managing FOIA requests, operated by the Reynolds Journalism Institute.

#### State-Level Public Records Laws

Every state has its own public records law with different rules, exemptions, response deadlines, and fee structures.

**Key variations:**
- **Response deadlines** range from 3 business days (Connecticut) to 30 days (some states) to no statutory deadline (Mississippi).
- **Fee structures** vary from free (some states waive fees for journalists or when disclosure serves the public interest) to per-page copying charges.
- **Exemptions** vary significantly. Some states exempt law enforcement records broadly; others have narrow exemptions.
- **Electronic records**: Most states now require agencies to provide records in electronic format when they exist electronically.

**Resources:**
- **Reporters Committee FOIA Guide**: https://www.rcfp.org/open-government-guide/ -- State-by-state guide to open records laws.
- **National Freedom of Information Coalition**: https://www.nfoic.org -- Tracks state-level FOIA developments.
- **Student Press Law Center**: https://splc.org/open-records/ -- Additional state-level resources.

---

### 3.7 Court Record Mining

Court records are among the richest public data sources for investigative work. Lawsuits, criminal cases, bankruptcy proceedings, and regulatory enforcement actions generate documents that reveal corporate behavior, financial structures, internal communications, and relationships that no other public source captures.

#### PACER (Federal Courts)

**URL**: https://pacer.uscourts.gov

- Electronic access to all federal court documents: district courts, courts of appeals, bankruptcy courts
- $0.10 per page, but fees are waived if quarterly usage does not exceed $30 (75% of users pay nothing)
- Search by party name, case number, date range, nature of suit, or judge
- Case Management/Electronic Case Files (CM/ECF) system stores all filings

**Searching strategy**: Search for a company or individual as a party across all federal courts. Review docket sheets for interesting filings (complaints, motions for summary judgment, discovery disputes, sealed document motions, settlement agreements).

#### RECAP (Free PACER Archive)

**URL**: https://www.courtlistener.com/recap/ | **Browser extension**: https://free.law/recap/

- Maintained by the Free Law Project (https://free.law)
- Install the RECAP browser extension (Firefox, Chrome, Safari) and every PACER document you access is automatically uploaded to the free, public RECAP Archive
- Anything another RECAP user has already accessed is available to you for free inside PACER
- CourtListener provides free full-text search across all RECAP documents
- Also includes federal appellate opinions, oral arguments, and judge information

#### State Courts

Access varies dramatically by state:
- **New York**: NYSCEF (https://iapps.courts.state.ny.us/nyscef/) for e-filed cases; WebCivil Supreme for older cases
- **California**: Each county maintains its own system. Los Angeles Superior Court has an online portal.
- **Many states**: Increasingly offering online access through vendors like Tyler Technologies (Odyssey), Thomson Reuters (C-Track), or Tybera

**What to look for in court records:**
- **Civil complaints**: Allegations of fraud, breach of contract, environmental damage, employment discrimination, antitrust violations
- **Discovery materials**: Depositions, interrogatory responses, and document productions sometimes attached as exhibits to motions
- **Sealed documents and protective orders**: The existence of sealed filings itself is informative (what is being hidden?)
- **Bankruptcy filings**: Complete lists of assets, liabilities, creditors, and often detailed financial statements
- **Expert witness reports**: Technical analysis that would cost tens of thousands to commission independently
- **Settlement agreements**: Sometimes public, sometimes sealed. Public settlements reveal the terms of resolution.

---

## 4. Whistleblower Infrastructure

Whistleblowers are the single most important source of information about institutional corruption. Every major exposure of the last two decades -- Enron, NSA surveillance, Panama Papers, Facebook's internal research, Boeing safety failures -- was initiated by individuals inside the institution who chose to share what they knew. Protecting these people is both a moral imperative and a practical necessity for accountability work.

---

### 4.1 SecureDrop

**What it is**: An open-source whistleblower submission system designed for media organizations to securely receive documents and communicate with anonymous sources. Originally created by Aaron Swartz and Kevin Poulsen, now maintained by the Freedom of the Press Foundation.

**URL**: https://securedrop.org | **GitHub**: https://github.com/freedomofpress/securedrop

**Current version**: 2.12.10 (as of early 2026)

**How it works:**
1. A source accesses the news organization's SecureDrop instance through the Tor Browser via a .onion address.
2. The source submits documents and/or messages without creating an account or providing any identifying information.
3. The source receives a randomly generated codename used for subsequent communication.
4. Journalists access submissions on an air-gapped Secure Viewing Station (SVS) -- a computer that has never been and will never be connected to the internet.
5. All submissions are encrypted using GPG and can only be decrypted on the SVS.

**Architecture:**
- **Application Server**: Runs the SecureDrop web application as a Tor hidden service.
- **Monitor Server**: Sends alerts to administrators (not connected to the application server network).
- **Secure Viewing Station**: Air-gapped computer (typically a laptop with network hardware physically removed) running Tails OS. This is where journalists decrypt and view submissions.
- **Network firewall**: Dedicated hardware firewall isolating SecureDrop infrastructure.

**Who runs SecureDrop instances**: Over 50 organizations worldwide, including The New York Times, The Washington Post, The Guardian, The Intercept, ProPublica, CBC, Bloomberg, Forbes, The Associated Press, and many others. A directory of instances is maintained at https://securedrop.org/directory.

**2025-2026 developments:**
- SecureDrop Workstation left pilot stage in 2024, with 2025 focused on usability improvements including driverless printing, simplified installation, and removal of Whonix in favor of vanilla Tor.
- Automated migration to Ubuntu Noble (24.04) completed for most instances in 2025.
- New journalist application rewrite is feature-complete and undergoing security audit (expected release early 2026).

**Deployment considerations:**
- Requires dedicated hardware (two servers + firewall + air-gapped workstation)
- IT expertise for setup and maintenance
- Organizational commitment to monitoring the system and responding to submissions
- Legal preparation for handling sensitive material

---

### 4.2 GlobaLeaks

**What it is**: Free, open-source whistleblowing software that enables any organization to set up a secure, anonymous reporting platform. More lightweight than SecureDrop, designed for broader adoption including corporate compliance, government anti-corruption, and civil society.

**URL**: https://www.globaleaks.org | **GitHub**: https://github.com/globaleaks/globaleaks-whistleblowing-software

**License**: AGPL-3.0

**Current adoption**: Over 30,000 organizations worldwide. 7,000+ public agencies in Italy alone (ministries, hospitals, municipalities) use GlobaLeaks for EU Whistleblower Directive compliance.

**Key features:**
- **Tor integration**: Uses Tor Onion Services for source anonymity
- **End-to-end encryption**: Submissions are encrypted and available only to configured recipients
- **Multilanguage**: Internationalized in 90+ languages
- **Customizable questionnaires**: Organizations can define custom submission forms
- **Multi-recipient**: Route submissions to specific departments or individuals
- **File attachment support**: Secure document upload
- **Whistleblower status tracking**: Sources can check the status of their submission

**Deployment:**
```bash
# Ubuntu/Debian installation
wget https://deb.globaleaks.org/install-globaleaks.sh
chmod +x install-globaleaks.sh
./install-globaleaks.sh
# Access admin panel at https://localhost:8443
```

**Differences from SecureDrop:**
- GlobaLeaks is designed for easier deployment and broader use cases (corporate compliance, not just journalism)
- Does not require air-gapped hardware (though Tor integration provides anonymity)
- More suitable for organizations without dedicated IT security staff
- SecureDrop provides stronger security guarantees through its air-gapped architecture

**Recognized as a Digital Public Good** by the Digital Public Goods Alliance.

---

### 4.3 Secure Communication

#### Signal

**URL**: https://signal.org

**What it is**: The gold standard for encrypted messaging. Open-source, operated by the Signal Foundation (nonprofit).

**Security properties:**
- End-to-end encryption by default for all messages, calls, and group chats using the Signal Protocol
- Perfect forward secrecy (PFS): Each message uses a temporary key that is discarded, protecting past messages even if a future key is compromised
- Sealed sender: Minimizes metadata by hiding sender identity from Signal's servers
- Disappearing messages: Configurable auto-deletion timer
- No ads, no trackers, no data mining
- Open-source client and server code

**Limitations:**
- Requires a phone number for registration (a metadata risk -- the phone number links your Signal identity to your real identity unless you use a burner number)
- Centralized server infrastructure (Signal Foundation operates the servers)
- Message content is encrypted, but Signal knows when you send messages and to whom (though "sealed sender" mitigates this)

#### Session

**URL**: https://getsession.org

**What it is**: A fork of Signal that removes the phone number requirement and routes messages through a decentralized onion network.

**Security properties:**
- No phone number or email required for registration -- provides a randomly generated Session ID
- Messages routed through decentralized onion network (hybrid routing, with full Lokinet integration expected)
- No central server that can be compelled to produce records
- End-to-end encryption using the Signal Protocol
- Open source

**Limitations:**
- Smaller user base than Signal (network effect matters for communication tools)
- Feature set is less complete than Signal (no voice/video calls in some versions)
- Decentralized routing can introduce message delivery latency

#### Briar

**URL**: https://briarproject.org

**What it is**: A messaging app designed for activists, journalists, and high-risk users that can function without internet access.

**Security properties:**
- **No central servers**: Messages are sent peer-to-peer
- **Works without internet**: Falls back to Bluetooth or Wi-Fi Direct when internet is unavailable (critical for protests, natural disasters, or internet shutdowns)
- **Tor routing**: When internet is available, all traffic goes through Tor
- **No metadata**: Because there are no servers, there are no metadata logs
- **End-to-end encryption**
- Open source

**Limitations:**
- **Android only** (as of 2025)
- **Text only** -- no voice, video, or file attachments
- **Both parties must be online simultaneously** for message delivery (no offline message queue)
- **Designed for specialized use**, not daily communication

**Choosing the right tool:**
- **Signal**: Best for most secure communication needs. Use when both parties have phone numbers they are willing to share.
- **Session**: Best when phone number privacy is critical and some latency is acceptable.
- **Briar**: Best for high-risk environments where internet access is unreliable or where no metadata at all is acceptable.
- **For maximum security**: Use different tools for different purposes. Compartmentalize.

---

### 4.4 Tor Hidden Services for Anonymous Submission

Beyond SecureDrop and GlobaLeaks, organizations can create custom Tor hidden services (.onion addresses) for anonymous submission. This requires more technical expertise but provides flexibility.

**Basic architecture:**
- A server running a web application accessible only as a .onion service
- Submissions encrypted at rest using the recipient's public key
- No logging of source IP addresses (Tor provides this by design)
- Server hardened and regularly updated

**Resources:**
- **Tor Project documentation**: https://community.torproject.org/onion-services/
- **OnionShare** (https://onionshare.org): Simple tool for sharing files over Tor. Generates a temporary .onion address for one-time file sharing. Can also host a basic website or create a chat room, all as Tor hidden services.

---

### 4.5 Air-Gapped Systems

An air-gapped system is a computer that has never been connected to any network and never will be. It is the highest level of protection for handling sensitive material because no remote attack can reach it.

**How to build an air-gapped workstation:**
1. **Hardware**: Use a dedicated laptop. Physically remove or disable the Wi-Fi card, Bluetooth module, and any cellular modem. Some practitioners fill the Ethernet port with epoxy.
2. **Operating system**: Install Tails OS from a verified USB drive. Tails runs entirely in RAM and leaves no trace on the host hardware.
3. **Data transfer**: Use new, dedicated USB drives for transferring encrypted files to the air-gapped machine. Never connect these USB drives to a networked computer after they have been used on the air-gapped machine. Maintain a strict one-directional data flow.
4. **Encryption**: All files transferred to the air-gapped machine should be encrypted (GPG). Decrypt only on the air-gapped machine.
5. **Physical security**: Store the air-gapped machine in a secure location. Do not use it near windows (laser microphone risk), near other devices (electromagnetic emanation risk -- though this is primarily a nation-state concern), or in locations accessible to unauthorized personnel.

**SecureDrop's Secure Viewing Station** follows this model. It is the most widely deployed air-gapped document handling system in journalism.

---

### 4.6 Legal Protections for Whistleblowers

Legal protections for whistleblowers exist but are incomplete, inconsistent across jurisdictions, and frequently insufficient against well-resourced adversaries.

#### United States

**Federal protections:**
- **Whistleblower Protection Act (1989, amended 2012)**: Protects federal employees who disclose government illegality, waste, fraud, abuse, or threats to public health/safety. Protection is through the Office of Special Counsel and the Merit Systems Protection Board.
- **Sarbanes-Oxley Act (2002), Section 806**: Protects employees of publicly traded companies who report securities fraud or violations of SEC regulations.
- **Dodd-Frank Act (2010)**: Created the SEC whistleblower program with financial rewards (10-30% of sanctions over $1 million). Also includes anti-retaliation protections.
- **False Claims Act (qui tam provisions)**: Allows private individuals to sue on behalf of the government when they discover fraud against federal programs. Successful whistleblowers receive 15-30% of recovered amounts.

**Limitations:**
- Intelligence community employees face much weaker protections and must report through internal channels
- National security whistleblowers (e.g., Edward Snowden, Reality Winner) face Espionage Act prosecution with no public interest defense
- Anti-retaliation protections are reactive, not preventive -- whistleblowers must suffer retaliation before seeking legal remedy
- Legal proceedings are slow and expensive. Whistleblowers often face years of litigation while their careers are destroyed.

#### European Union

**EU Whistleblower Directive (2019/1937):**
- Sets minimum standards for whistleblower protection across all EU member states
- Requires organizations with 50+ employees to establish internal reporting channels
- Mandates confidentiality of whistleblower identity
- Prohibits retaliation (dismissal, demotion, harassment, blacklisting)
- Requires confirmation of report receipt within 7 days and status update within 3 months
- **Implementation status (2025)**: All member states have adopted national implementing laws, though compliance quality varies. Germany was fined 34 million euros for late implementation. Czech Republic, Hungary, Estonia, and Luxembourg were also penalized.

#### Practical reality

The law provides a floor, not a ceiling, of protection. In practice:
- Whistleblowers routinely face career destruction regardless of legal protections
- Legal processes take years; employment consequences are immediate
- Powerful targets use countersuits, SLAPP actions, and criminal referrals to intimidate
- Social ostracism, professional blacklisting, and mental health impacts are not addressed by legal protections

**The imperative**: Because legal protections are insufficient, technological protections (SecureDrop, encrypted communication, air-gapped handling) are essential. The best protection for a source is anonymity that was never compromised, not legal remedy after compromise.

---

### 4.7 History of Whistleblowing Impact

Understanding the history is essential because it demonstrates both the power and the cost of whistleblowing.

**Daniel Ellsberg (Pentagon Papers, 1971)**: Leaked the classified Department of Defense study revealing that the U.S. government had systematically lied to Congress and the public about the Vietnam War. Published by The New York Times and The Washington Post. The Supreme Court ruled in favor of publication in *New York Times Co. v. United States*. Ellsberg faced espionage charges that were dismissed due to government misconduct (illegal wiretapping, burglary of his psychiatrist's office).

**Edward Snowden (NSA mass surveillance, 2013)**: Leaked classified NSA documents revealing the scope of global mass surveillance programs, including PRISM (collection from internet companies) and the bulk collection of phone metadata. Published by The Guardian and The Washington Post. Resulted in the USA FREEDOM Act (2015), which reformed some surveillance authorities, and global changes to encryption standards and technology company policies. Snowden was charged under the Espionage Act and lives in exile in Russia.

**Reality Winner (Russian election interference, 2017)**: Leaked a classified NSA report documenting Russian government attempts to hack U.S. election infrastructure. Arrested after the report was published by The Intercept, which inadvertently revealed identifying information in the leaked document (printer tracking dots). Sentenced to 5 years and 3 months -- the longest sentence for an unauthorized disclosure to the media. Released in 2021.

**Frances Haugen (Facebook/Meta internal research, 2021)**: Disclosed internal Facebook research showing the company knew its products harmed children and amplified misinformation but chose profit over safety. Testified before Congress and European Parliament. Her disclosures fueled the push for platform regulation worldwide, including the EU Digital Services Act.

**Lesson**: Every major whistleblower faced severe personal consequences. The information they revealed changed public understanding and policy, but the cost to the individual was enormous. This is why infrastructure for protecting whistleblowers is not optional -- it is the precondition for the information flow on which accountability depends.

---

### 4.8 Protecting Sources Technologically and Legally

**Technological protections:**
- **Never know the source's identity if you do not need to**: SecureDrop is designed so that journalists can receive and verify information without ever learning who the source is.
- **Encrypted communication from first contact**: If a source reaches out through insecure channels, immediately move to encrypted channels. But the damage may already be done -- the initial contact creates a metadata record.
- **Air-gapped document handling**: See Section 4.5.
- **Metadata stripping**: Documents may contain metadata (authorship, creation dates, printer tracking dots, embedded GPS coordinates in photos) that can identify the source. Use tools like MAT2 (https://0xacab.org/jfrber/mat2) to strip metadata before publication.
- **Secure deletion**: When source-identifying material must be destroyed, use secure deletion tools. On SSDs, full disk encryption with key destruction is more reliable than file-level deletion.
- **Compartmentalization**: Limit knowledge of the source's identity to the minimum number of people. Different team members should handle different aspects of the investigation.

**Legal protections:**
- **Shield laws**: Many U.S. states have reporter's shield laws that protect journalists from being compelled to reveal sources. There is no federal shield law. Strength and scope vary dramatically by state.
- **First Amendment protections**: The U.S. Constitution provides some protection for press freedom, but courts have been inconsistent in applying it to source protection.
- **Pre-publication legal review**: Before publishing any story that could expose a source, have a media lawyer review the material for any identifying information.
- **Threat modeling for the specific source**: What adversary is the source protected from? A private company has different capabilities than a nation-state. Tailor protections accordingly.

---

## 5. Counter-Intelligence and Operational Security

If you investigate power, power investigates you. Operational security is not paranoia; it is a professional requirement. Every major investigative journalist and activist organization has faced surveillance, harassment, legal threats, or worse. Planning for this is not optional.

---

### 5.1 Threat Modeling for Civic Investigators

A threat model answers five questions:
1. **What am I protecting?** (Source identities, unpublished investigation materials, communication records, personal information of team members)
2. **Who am I protecting it from?** (The specific adversary -- a corporation, a government agency, a criminal organization, an individual. Each has different capabilities.)
3. **How likely is the threat?** (A local business investigation faces different threats than investigating a nation-state intelligence agency.)
4. **What are the consequences of failure?** (Source exposure, legal liability, physical danger, career destruction, investigation compromise.)
5. **How much effort and inconvenience am I willing to accept?** (Security always has costs in usability. The protection level must be proportional to the threat.)

**Framework for civic investigators:**

| Threat Level | Adversary | Examples | Security Posture |
|---|---|---|---|
| **Low** | Individual, small business | Local corruption investigation | Standard encrypted messaging, secure passwords, full-disk encryption |
| **Medium** | Corporation, local government | Corporate malfeasance, municipal corruption | All of the above + dedicated investigation devices, VPN, compartmentalized communications, FOIA tracking, legal preparation |
| **High** | National government, organized crime | National security investigations, cartel or mafia investigations | All of the above + air-gapped systems, Tails/Qubes OS, Tor for all investigation activity, physical security measures, dedicated legal counsel |
| **Critical** | Nation-state intelligence services | Intelligence agency misconduct, authoritarian government investigation | All of the above + assumption of device compromise, frequent hardware rotation, physical counter-surveillance, multiple jurisdiction legal teams, extraction plans |

---

### 5.2 Digital Security for Activists and Investigators

#### Operating Systems

**Qubes OS** (https://www.qubes-os.org):
- A "reasonably secure operating system" that uses hardware virtualization (Xen hypervisor) to create isolated compartments ("qubes") for different activities.
- Your email runs in one qube, your web browsing in another, your investigation files in a third. If one is compromised, the others remain isolated.
- Used by SecureDrop for journalist workstations.
- Recommended by Edward Snowden and the Freedom of the Press Foundation.
- Learning curve is significant but the architecture provides protection that no conventional operating system can match.

**Tails** (https://tails.net):
- Portable operating system that runs from a USB drive, routes all traffic through Tor, and leaves no trace on the host computer.
- When you shut down, everything in RAM is wiped. No persistent storage unless explicitly configured.
- Designed for ease of use -- no Linux expertise required.
- Ideal for: working from shared or untrusted computers, travel, and any situation where you need a clean environment.

**When to use which:**
- **Qubes OS**: For your primary investigation workstation. Daily use with compartmentalized security.
- **Tails**: For travel, for using untrusted hardware, for one-off sensitive tasks, and for air-gapped workstations (SecureDrop SVS).

#### VPN Considerations

VPNs are widely recommended but frequently misunderstood:
- A VPN hides your traffic from your local network and ISP, but the VPN provider sees all your traffic.
- VPN providers can be compelled to provide logs (and have been, despite "no-log" policies).
- VPNs are useful for bypassing geographic restrictions and protecting against local network surveillance.
- VPNs are NOT sufficient for anonymity. For anonymity, use Tor.
- **VPN chaining** (routing through multiple VPN providers in series) increases complexity but is still vulnerable to a sufficiently resourced adversary who can compromise or compel all providers in the chain.

**Recommendation**: Use a reputable VPN (Mullvad -- accepts cash, no email required; ProtonVPN -- Swiss jurisdiction, open-source) for general protection. Use Tor for investigation-related activity where anonymity matters.

#### Other Security Basics

- **Password manager**: Bitwarden (open source), KeePassXC (local only, no cloud), or 1Password. Unique, randomly generated passwords for every service.
- **Multi-factor authentication**: Hardware keys (YubiKey) are strongest. TOTP apps (Aegis, andOTP) are second. SMS-based 2FA is weak and should be avoided for sensitive accounts.
- **Full-disk encryption**: BitLocker (Windows), FileVault (macOS), LUKS (Linux). Protects data if a device is seized.
- **Email encryption**: ProtonMail for end-to-end encrypted email. GPG for encrypting email with other providers (high learning curve).
- **Browser security**: Firefox with uBlock Origin, HTTPS Everywhere (now built into most browsers), and privacy-focused configuration. Tor Browser for anonymous browsing.
- **Phone security**: GrapheneOS (hardened Android for Pixel phones) or standard iOS/Android with app permissions locked down. Assume your phone is the weakest point in your security chain.

---

### 5.3 Compartmentalization

Compartmentalization is the practice of isolating different aspects of an investigation so that the compromise of one part does not expose the others.

**Practical compartmentalization:**
- **Separate devices**: Use a dedicated device for investigation work. Never use your personal phone or laptop for sensitive investigation activities.
- **Separate accounts**: Investigation email accounts separate from personal accounts. Different usernames, different passwords, different recovery methods.
- **Separate networks**: Do not conduct investigation activities on your home or office network. Use public Wi-Fi (through a VPN and/or Tor) or a dedicated mobile hotspot.
- **Separate personas**: For OSINT research that requires account creation, maintain research personas with no connection to your real identity.
- **Separate knowledge**: Team members should know only what they need for their specific role. Source-handling journalists should be separate from publication editors. Technical infrastructure maintainers should not have access to source identities.
- **Separate storage**: Investigation files on encrypted, dedicated storage. Not on the same machine that checks personal email or logs into social media.

**The failure mode of non-compartmentalization**: Reality Winner was identified because NSA could determine that only six people had printed the leaked document, and Winner had exchanged emails with The Intercept from her work computer. One leaked connection point (email to journalists from a work account) collapsed all compartmentalization.

---

### 5.4 How Power Fights Back

Understanding the adversary's toolkit is essential for defensive planning.

#### SLAPP Lawsuits (Strategic Lawsuits Against Public Participation)

**What they are**: Lawsuits filed not to win but to impose legal costs, drain resources, and intimidate. The plaintiff does not expect to prevail on the merits -- the goal is to make the cost of defending the lawsuit exceed the cost of silence.

**Current landscape (2025):**
- 38 states and the District of Columbia have anti-SLAPP laws (as of June 2025)
- Anti-SLAPP laws typically allow early dismissal before costly discovery, recovery of attorney's fees for successful defendants, automatic stay of discovery upon filing an anti-SLAPP motion, and immediate appeal of anti-SLAPP motion denials
- However, freelance journalists and small organizations often cannot afford to defend against SLAPPs even with anti-SLAPP protections
- A 2024 database documented 500 SLAPP cases in a single year
- There is no federal anti-SLAPP law, though proposals have been introduced repeatedly

**Defenses:**
- **Anti-SLAPP motions**: File immediately in jurisdictions with anti-SLAPP statutes
- **Media law organizations**: The Reporters Committee for Freedom of the Press (https://www.rcfp.org) provides legal defense resources. The ACLU, EFF, and state press associations may also provide support.
- **Insurance**: Media liability insurance can cover defense costs. Some policies specifically cover SLAPP defense.
- **Publicity**: SLAPPs work best in silence. Publicizing the lawsuit as an attempted silencing tactic can generate support and deter the plaintiff.
- **Collective defense**: Organizations like the Press Freedom Defense Fund and the Freedom of the Press Foundation provide financial support for press freedom legal defense.

#### Doxxing and Harassment

Investigators and their families may face targeted harassment campaigns: publication of home addresses, phone numbers, and personal information; coordinated social media harassment; physical threats; employer pressure campaigns.

**Defenses:**
- Remove personal information from data broker sites (DeleteMe, Privacy Duck, or manual opt-out requests)
- Register property and vehicles through trusts or LLCs to obscure home address from public records
- Use P.O. boxes or virtual mail services for correspondence
- Lock down social media privacy settings for personal (non-professional) accounts
- Document all harassment (screenshots, archives) for potential legal action
- Report credible threats to law enforcement and maintain a legal record
- Have a pre-prepared response plan for doxxing events

#### Infiltration and Discrediting

Well-resourced adversaries may attempt to infiltrate investigative organizations with agents who gather intelligence, plant disinformation, or create internal conflicts. They may also attempt to discredit investigators through manufactured scandals, selective leaking of personal information, or association with disreputable groups.

**Defenses:**
- Vet new members and sources carefully
- Compartmentalize sensitive information
- Be skeptical of unsolicited sources who provide exactly what you need (too good to be true)
- Maintain rigorous verification standards for all information, regardless of source
- Keep personal conduct beyond reproach (the best defense against smear campaigns)
- Document the attempted discrediting itself as evidence of adversary activity

---

### 5.5 Legal Frameworks for Protection

- **Press freedom protections**: First Amendment (U.S.), Article 10 ECHR (Europe), national press freedom laws
- **Shield laws**: State-level protections for journalists refusing to reveal sources (no federal shield law in the U.S.)
- **Anti-SLAPP statutes**: 38 states + D.C.
- **Reporters Committee for Freedom of the Press**: https://www.rcfp.org -- Legal defense resources, hotline, and representation
- **Electronic Frontier Foundation**: https://www.eff.org -- Digital rights legal defense
- **Freedom of the Press Foundation**: https://freedom.press -- SecureDrop development, digital security training, press freedom advocacy
- **Committee to Protect Journalists**: https://cpj.org -- International press freedom, journalist safety, and legal support
- **GIJN (Global Investigative Journalism Network)**: https://gijn.org -- Resources, training, and legal support for investigative journalists worldwide

---

### 5.6 Insurance and Legal Defense

**Media liability insurance**: Covers defense costs for defamation lawsuits, invasion of privacy claims, and other media-related legal actions. Providers include Media/Professional Insurance (MPI), Chubb, and specialty brokers.

**Legal defense funds:**
- **Reporters Committee for Freedom of the Press**: Provides legal defense and amicus support
- **Press Freedom Defense Fund** (Freedom of the Press Foundation): Financial support for press freedom legal cases
- **Knight First Amendment Institute** (Columbia University): Litigates First Amendment cases
- **ACLU**: Takes cases involving press freedom and government transparency

**Pre-publication legal review**: Before publishing any major investigation, have a media lawyer review the material for defamation risk, privacy concerns, potential trade secret claims, and source protection issues. This is not censorship -- it is insurance against preventable legal exposure.

---

## 6. Autonomous AI Agents for Intelligence

The most powerful application of AI for civic accountability is not asking an LLM a question -- it is deploying autonomous agents that monitor, collect, correlate, and alert continuously. A single human investigator can monitor a handful of sources. An AI agent system can monitor thousands of sources 24 hours a day, 7 days a week, and surface anomalies that no human would notice.

---

### 6.1 Continuous Monitoring

**What AI agents can monitor:**
- **SEC EDGAR filings**: New 8-K filings (material events), insider trading (Form 4), beneficial ownership changes (Schedule 13D/13G), new corporate registrations. The SEC EDGAR API requires no authentication and allows 10 requests/second.
- **Court filings**: New cases, motions, and judgments in federal courts (PACER/RECAP) and state courts. Alert when target entities appear as parties.
- **Government contracts**: New awards on USASpending.gov and FPDS. Alert when target entities receive contracts or when contracts in monitored categories are awarded.
- **Regulatory actions**: SEC enforcement actions, EPA violations, OSHA citations, FDA warning letters, FTC complaints. Each agency publishes actions in structured or semi-structured formats.
- **Campaign finance**: FEC filings, state campaign finance databases. Alert on new contributions, expenditure patterns, or PAC formations.
- **Corporate registry changes**: New entities registered, officer changes, address changes in state corporate databases.
- **News and media**: RSS feeds, Google Alerts, social media mentions. Alert on target entity mentions.
- **Web changes**: Monitor target websites for changes (new pages, removed content, modified text) using tools like Visualping, ChangeTower, or custom scripts.

---

### 6.2 Entity Resolution

Entity resolution -- determining that different references across different databases refer to the same real-world entity -- is one of the most valuable and difficult intelligence tasks. It is also where AI provides the most leverage.

**The problem**: "John R. Smith, Director of Acme Corp" in an SEC filing, "J. Smith" in a campaign finance record, "John Smith" in a court filing, and "Johnny Smith" on LinkedIn may all be the same person. Or they may be five different people. Resolving this at scale across millions of records is impossible for humans and imperfect but tractable for AI.

**Approaches:**
- **Deterministic matching**: Exact matches on strong identifiers (SSN, EIN, DUNS number). High precision, low recall -- only works when strong identifiers are available.
- **Probabilistic matching**: Fuzzy matching on names, addresses, dates, and other attributes. Uses Jaro-Winkler or Levenshtein distance for name similarity, combined with contextual matching (same city, same industry, overlapping dates).
- **Machine learning models**: Train classifiers on labeled examples of match/non-match pairs. Features include name similarity, address similarity, organizational affiliation overlap, temporal overlap, and network proximity.
- **Graph-based resolution**: Use network structure to resolve entities. If two name variants appear in the same corporate network (shared board members, same registered agent, same address), they are more likely to be the same entity.

**Tools:**
- **dedupe** (https://github.com/dedupeio/dedupe): Open-source Python library for entity resolution using active learning. You label a few examples, and the model learns to resolve the rest.
- **Zingg** (https://github.com/zinggAI/zingg): Open-source ML-based entity resolution at scale, supporting Spark for big data workloads.
- **Splink** (https://github.com/moj-analytical-services/splink): Open-source probabilistic record linkage from UK Ministry of Justice. Scales to hundreds of millions of records.
- **OpenRefine clustering**: For smaller datasets, OpenRefine's built-in clustering algorithms provide quick entity resolution.

---

### 6.3 Anomaly Detection in Financial Data

AI agents can monitor financial data streams and flag anomalies that may indicate corruption, fraud, or other irregularities.

**What to look for:**
- **Unusual transaction patterns**: Payments just below reporting thresholds (structuring), round-number payments, payments to entities with no apparent business relationship
- **Timing anomalies**: Contract awards shortly after campaign contributions, regulatory decisions shortly after lobbying expenditures, insider trading before announcements
- **Network anomalies**: Entities that appear in multiple investigations, entities with unusually complex ownership structures, beneficial owners who also hold government positions
- **Statistical anomalies**: Bidding patterns in government contracts that deviate from expected distributions (potential bid rigging), financial statement values that follow Benford's Law violations (potential fabrication), revenue patterns that correlate suspiciously with regulatory or election cycles

**Techniques:**
- **Time series analysis**: Detect sudden changes in financial metrics that coincide with external events
- **Benford's Law analysis**: The leading digits of naturally occurring financial data follow a predictable distribution. Fabricated data often does not. Violations are a red flag (not proof) of manipulation.
- **Network centrality monitoring**: Track changes in entity centrality over time. An entity that suddenly becomes more central in a financial network may be involved in new activity.
- **Outlier detection**: Statistical methods (isolation forest, local outlier factor, autoencoders) can identify transactions or entities that deviate from established patterns.

---

### 6.4 Natural Language Processing for Document Analysis

**Capabilities at scale:**
- **Named Entity Recognition (NER)**: Extract people, organizations, locations, dates, and monetary amounts from unstructured text. Modern transformer-based models (SpaCy, Hugging Face NER models) achieve near-human accuracy.
- **Relationship extraction**: Identify stated relationships between entities ("X is a subsidiary of Y," "A was appointed by B," "C paid $X to D"). More experimental than NER but improving rapidly.
- **Summarization**: Condense long documents to key facts. Particularly valuable for legal filings, regulatory documents, and FOIA responses.
- **Classification**: Categorize documents by type, topic, relevance, or urgency. Train classifiers on labeled examples to sort incoming document streams.
- **Sentiment and stance detection**: Identify whether documents express positive, negative, or neutral positions on specific entities or topics.
- **Cross-document coreference resolution**: Determine that references to the same entity across different documents refer to the same real-world thing.
- **Translation**: Process documents in dozens of languages without dedicated translators.

**Pipeline for document intelligence:**
1. Ingest documents (Apache Tika for text extraction from any format)
2. Run NER to extract entities
3. Run relationship extraction to identify connections
4. Resolve entities across documents (entity resolution)
5. Build a knowledge graph from extracted entities and relationships
6. Run anomaly detection on the graph
7. Present findings to human investigators for validation

---

### 6.5 Automated FOIA Filing and Tracking

An AI agent system can partially automate the FOIA lifecycle:

1. **Request generation**: Given an investigation topic, generate targeted FOIA requests specifying relevant record types, date ranges, and custodians. LLMs can draft requests using templates optimized for each agency's processing patterns.
2. **Filing**: Submit requests through MuckRock's API or directly to agency FOIA portals.
3. **Tracking**: Monitor response deadlines and automatically generate follow-up communications when agencies exceed statutory timelines.
4. **Processing responses**: When documents are received, automatically process them through the document intelligence pipeline (OCR, NER, relationship extraction, indexing).
5. **Appeal generation**: When requests are denied, generate appeal letters citing applicable legal standards and challenging improper exemption claims.

**This is automatable today**: MuckRock provides the filing infrastructure, Apache Tika handles document processing, and LLMs can generate and adapt request language. The integration layer is what does not yet exist as a unified system.

---

### 6.6 Network Graph Construction from Unstructured Data

One of the highest-value AI applications is automatically constructing network graphs from unstructured text -- taking thousands of pages of documents and producing a visual map of who is connected to whom and how.

**Pipeline:**
1. Process documents through NER to extract entities
2. Identify co-occurrences: entities mentioned in the same document, paragraph, or sentence
3. Extract explicit relationships from text
4. Weight edges by frequency of co-occurrence and strength of stated relationship
5. Resolve duplicate entities
6. Import into Neo4j or Gephi for visualization and analysis
7. Run community detection algorithms to identify clusters
8. Run centrality analysis to identify key brokers and hubs

**Existing tools:**
- **SpaCy** (https://spacy.io): Industrial-strength NLP library with pre-trained NER models for multiple languages
- **Hugging Face Transformers**: State-of-the-art NLP models, including NER, relation extraction, and text classification
- **NetworkX** (Python library): Graph analysis in Python. Calculate centrality, detect communities, find shortest paths.
- **Neo4j + APOC procedures**: Graph algorithms running directly in the database

---

### 6.7 What the Cleansing Fire Project Can Build

Based on the gap analysis -- what exists, what is fragmented, and what is missing -- the Cleansing Fire project can build infrastructure that does not exist yet:

**1. Unified Civic Intelligence Platform (working name: "The Furnace")**

An autonomous agent system that:
- Monitors SEC EDGAR, PACER, USASpending.gov, FEC, state corporate registries, and regulatory agencies continuously
- Performs entity resolution across all data sources to maintain a unified knowledge graph
- Runs anomaly detection on financial flows, timing correlations, and network changes
- Generates alerts when monitored entities appear in new filings, cases, or transactions
- Provides a graph exploration interface for human investigators
- Runs locally (no cloud dependency) using the Cleansing Fire gatekeeper for LLM processing

No existing tool does all of this. Aleph is closest but is focused on document sets, not continuous monitoring. SpiderFoot automates OSINT but is cybersecurity-focused, not civic-accountability-focused. MuckRock handles FOIA but not broader intelligence gathering.

**2. Decentralized Evidence Preservation Network**

A protocol for:
- Cryptographically timestamping and distributing archived evidence across multiple nodes
- Ensuring that evidence cannot be silently removed or altered
- Providing verifiable provenance chains (this document was retrieved from this URL at this time, hashed at this time, distributed to N nodes)
- Using content-addressed storage (IPFS-style) so that evidence is identified by its content, not its location
- Operating without any single node whose seizure could destroy the archive

Nothing like this exists. The Wayback Machine is centralized (and increasingly blocked). Archive.today is a single point of failure. Self-hosted archives depend on individual servers. A decentralized evidence network would be resilient against legal takedown orders, technical failures, and hostile actors.

**3. Automated FOIA Pipeline**

An end-to-end system for:
- Generating FOIA requests based on investigation templates
- Filing through MuckRock API or directly to agency portals
- Tracking response deadlines and generating follow-ups
- Processing received documents through OCR, NER, and entity resolution
- Indexing results in a searchable knowledge base
- Generating appeal letters for denied requests
- Feeding discovered entities back into the monitoring pipeline

MuckRock handles the filing and tracking. Apache Tika handles document processing. LLMs handle request and appeal generation. But no integrated system connects them end-to-end with civic accountability as the explicit design goal.

**4. Correlation Engine: "Who Benefits?"**

A system specifically designed to answer the question corruption investigators ask most:
- Given a government action (contract award, regulatory decision, policy change, vote), who benefited financially?
- Given a financial relationship (campaign contribution, lobbying expenditure, consulting contract), what government actions followed?
- Given a person, what is their complete network of corporate, financial, political, and social connections across all available data sources?

This is the synthesis layer. Individual tools provide individual answers. The correlation engine asks the meta-question: across all available data, what patterns of benefit-exchange exist?

**Technical requirements for all of the above:**
- Pure Python with minimal dependencies (per Cleansing Fire conventions)
- Local-first architecture (no mandatory cloud services)
- Gatekeeper daemon for LLM task management
- Plugin architecture for data source adapters
- Neo4j or local graph database for knowledge graph storage
- Scheduler integration for continuous monitoring tasks
- Worker orchestration for parallel data processing

---

## 7. Ethical Framework -- Pyrrhic Lucidity Applied to Intelligence

Intelligence collection, even when entirely legal and focused on public data, creates power. The power to know, to expose, to connect, and to narrate. Pyrrhic Lucidity demands that we examine this power with the same rigor we apply to the power we oppose.

---

### 7.1 The Line Between Exposure and Harassment

Exposure serves accountability when it reveals the actions of people exercising institutional power in their institutional capacity. It becomes harassment when it targets private individuals, reveals personal information unrelated to the investigation, or is motivated by animus rather than accountability.

**Questions to ask before publishing:**
- Does this information reveal the exercise of power, or does it reveal private life?
- Would a reasonable person in the target's position expect this information to be scrutinized?
- Is the target a public figure exercising public authority, or a private individual?
- Does publishing this information serve the investigation, or does it serve vengeance?
- Would I accept this level of scrutiny applied to myself?

**The Pyrrhic cost**: Every exposure risks becoming harassment. Every investigation risks becoming obsession. The cost of this work is living with that ambiguity and making imperfect judgments under uncertainty. If you are never uncomfortable with your own actions, you are not examining them honestly.

---

### 7.2 Privacy of Individuals vs. Accountability of Power

This is not a binary. It is a gradient. The degree of scrutiny applied should be proportional to the degree of power held.

**The differential scrutiny principle:**
- **Public officials exercising public authority**: Highest scrutiny. Their official actions, financial interests, conflicts of interest, and public statements are fully legitimate targets of investigation. Their personal relationships and private behavior are relevant only when they directly affect the exercise of public duties.
- **Corporate executives of major institutions**: High scrutiny. Their corporate actions, compensation, business relationships, and public statements are legitimate targets. Personal information is relevant when it reveals conflicts of interest or unreported relationships that affect their institutional role.
- **Mid-level employees and functionaries**: Moderate scrutiny. Their official actions are relevant. Their personal information is almost never relevant and should be protected.
- **Private individuals with no institutional power**: Minimal scrutiny. Only relevant when directly involved in documented wrongdoing. Personal information should be protected by default.
- **Families and associates**: Protected unless directly involved in the conduct under investigation. Children are always off-limits.

---

### 7.3 Principle V (Minimum Viable Coercion) Applied to Surveillance

Pyrrhic Lucidity's Principle V states that coercion is sometimes necessary but always corrupting, and must face continuous pressure toward minimization.

Applied to intelligence gathering:
- **Collect the minimum data necessary** for the investigation. Do not build comprehensive dossiers on individuals when a specific question can be answered with specific data.
- **Retain data for the minimum time necessary**. When an investigation concludes, data about individuals not implicated in wrongdoing should be deleted.
- **Use the least intrusive method available**. If the answer is in a public filing, do not scrape someone's social media. If the answer is in a corporate registry, do not map their personal network.
- **Justify escalation**: Each escalation of investigative intensity should be documented and justified. Why is this level of scrutiny necessary? What question does it answer? What less intrusive method was insufficient?

---

### 7.4 When Does Watching the Watchers Become Watching Everyone?

This is the central ethical risk. Surveillance infrastructure built to expose corruption can be turned to surveill anyone. OSINT tools do not distinguish between powerful targets and private citizens. The same techniques that map a corrupt politician's financial network can map an activist's social network.

**Structural safeguards:**
- **Purpose limitation**: The Cleansing Fire project's intelligence tools should be architecturally constrained to their stated purpose. This means designing systems that are optimized for institutional accountability (corporate filings, government records, financial flows) rather than general-purpose surveillance.
- **Asymmetric design**: Build tools that are more effective against institutional power than against individuals. Tools that search SEC filings, PACER, and government contracts are inherently asymmetric -- they scrutinize institutions. Tools that scrape social media and map personal networks are symmetric -- they work equally well against anyone. Prefer asymmetric tools.
- **Transparency of method**: All tools and methods used by the project should be publicly documented. If we are not willing to explain how we found something, we should not have found it.
- **Audit trails**: The project's systems should log what was searched, when, and why. This creates accountability for the investigators themselves.

---

### 7.5 The Differential Solidarity Principle

Pyrrhic Lucidity's Principle VII (Differential Solidarity) states: weight toward the most exposed without essentializing identity.

Applied to intelligence:
- **Scrutiny flows upward**: The direction of investigation should be from the less powerful toward the more powerful, not the reverse.
- **Protect the exposed**: When investigation reveals information about lower-power individuals caught up in a powerful person's corruption (employees, associates, family members), default to protecting their privacy.
- **Power determines permissible scrutiny**: The higher the power held, the more intrusive the permissible investigation. A sitting senator's financial relationships are more scrutinizable than a junior staffer's social media posts.

---

### 7.6 Legal Boundaries

**What is legal:**
- Collecting and analyzing publicly available information (OSINT)
- Filing FOIA requests
- Accessing public court records
- Monitoring public social media accounts
- Archiving public web pages
- Using public APIs within their terms of service
- Conducting interviews with willing sources
- Receiving and publishing leaked documents (with some exceptions for classified material)

**What occupies legal gray areas:**
- Creating pseudonymous accounts to access semi-public spaces
- Scraping websites that prohibit it in their terms of service (CFAA implications vary by jurisdiction)
- Accessing dark web forums for monitoring purposes
- Using technical tools to identify anonymous online accounts
- Receiving stolen (as opposed to leaked) documents

**What is illegal:**
- Hacking into computer systems (Computer Fraud and Abuse Act)
- Wiretapping or intercepting communications without consent (Federal Wiretap Act)
- Stalking or harassment (state stalking laws)
- Impersonating law enforcement or government officials
- Bribery to obtain records
- Unauthorized access to non-public government databases
- In some jurisdictions, recording conversations without all-party consent

**The bright line**: If accessing the information requires circumventing a technical or legal access control, do not do it. If the information is available to anyone who looks in the right place, it is fair game.

---

### 7.7 The Corruption Gradient: Our Own Tools Can Be Turned Against Us

The final ethical warning. Every tool described in this document can be used for purposes opposite to those intended:
- OSINT tools built for accountability can be used for stalking
- Network analysis built to expose corruption can be used to map and target activists
- Whistleblower infrastructure built to protect sources can be compromised to identify them
- AI agents built to monitor institutional power can be pointed at private citizens
- Financial intelligence techniques built to follow corrupt money can be used for corporate espionage

**Structural mitigations:**
- **Open source everything**: All Cleansing Fire tools are open source. This means adversaries can use them too, but it also means the tools are subject to public scrutiny and cannot contain hidden backdoors.
- **Design for asymmetry**: Where possible, design tools that are structurally more useful for accountability than for surveillance. Tools that specialize in corporate registries and government databases are less useful for surveilling individuals than general-purpose OSINT platforms.
- **Recursive accountability (Principle VI)**: The Cleansing Fire project and its participants face the same scrutiny they apply to others. If you build surveillance tools, you accept being surveilled. If you demand transparency from institutions, you accept transparency about your own methods.
- **Kill switches**: Design systems with the ability to audit, restrict, and if necessary destroy their own capabilities. If a tool is being misused, the community must be able to shut it down.
- **The Pyrrhic cost acknowledged**: Building these tools makes the world more legible. More legibility means more power for whoever wields it. We build them because the alternative -- a world where institutional corruption is invisible and unaccountable -- is worse. But we do not pretend the tools are neutral, and we do not pretend we are incorruptible.

> "If it costs nothing to the actor, it is structurally suspect." Every tool in this document costs something -- in time, in resources, in ethical complexity, in the knowledge that what you build to expose corruption could itself become an instrument of oppression. That cost is the price of honest engagement. Pay it, or do not do this work.

---

## Appendix: Quick Reference -- Tool Index

| Tool | Purpose | License/Cost | URL |
|---|---|---|---|
| Maltego | Link analysis, OSINT platform | Free CE / $1,999+/yr Pro | https://www.maltego.com |
| SpiderFoot | Automated OSINT collection | MIT (Free) | https://github.com/smicallef/spiderfoot |
| Recon-ng | Web reconnaissance framework | GPL-3.0 (Free) | https://github.com/lanmaster53/recon-ng |
| theHarvester | Email/domain/subdomain discovery | GPL-2.0 (Free) | https://github.com/laramies/theHarvester |
| Shodan | Internet device search engine | Free tier / $69/yr | https://www.shodan.io |
| Holehe | Email-to-platform checker | GPL-3.0 (Free) | https://github.com/megadose/holehe |
| Sherlock | Username search across platforms | MIT (Free) | https://github.com/sherlock-project/sherlock |
| Gephi | Network visualization | GPL-3.0 (Free) | https://gephi.org |
| Neo4j | Graph database | Community: Free / Enterprise: Paid | https://neo4j.com |
| Linkurious | Graph visualization (commercial) | Commercial | https://linkurious.com |
| Aleph / OpenAleph | Investigative data platform | Free for nonprofits | https://aleph.occrp.org |
| DocumentCloud | Document analysis/publishing | Free | https://www.documentcloud.org |
| Apache Tika | Document text extraction | Apache 2.0 (Free) | https://tika.apache.org |
| OpenRefine | Data cleaning/reconciliation | BSD-3 (Free) | https://openrefine.org |
| QGIS | Geographic information system | GPL (Free) | https://qgis.org |
| Leaflet | Web mapping library | BSD-2 (Free) | https://leafletjs.com |
| SecureDrop | Whistleblower submission system | AGPL-3.0 (Free) | https://securedrop.org |
| GlobaLeaks | Whistleblowing platform | AGPL-3.0 (Free) | https://www.globaleaks.org |
| Signal | Encrypted messaging | AGPL-3.0 (Free) | https://signal.org |
| Session | Anonymous encrypted messaging | GPL-3.0 (Free) | https://getsession.org |
| Briar | Offline-capable encrypted messaging | GPL-3.0 (Free) | https://briarproject.org |
| Tails | Amnesic operating system | GPL (Free) | https://tails.net |
| Qubes OS | Security-focused operating system | GPL (Free) | https://www.qubes-os.org |
| MuckRock | FOIA filing platform | Free / $40/mo Pro | https://www.muckrock.com |
| Wayback Machine | Web archiving | Free | https://web.archive.org |
| ArchiveBox | Self-hosted web archiving | MIT (Free) | https://archivebox.io |
| Twint | Twitter/X OSINT scraping | MIT (Free) | https://github.com/twintproject/twint |
| Instaloader | Instagram data download | MIT (Free) | https://instaloader.github.io |
| yt-dlp | Video/audio download | Unlicense (Free) | https://github.com/yt-dlp/yt-dlp |
| dedupe | Entity resolution library | MIT (Free) | https://github.com/dedupeio/dedupe |
| SpaCy | NLP / NER library | MIT (Free) | https://spacy.io |
| Datashare (ICIJ) | Document analysis platform | AGPL-3.0 (Free) | https://datashare.icij.org |
| Google Pinpoint | AI document analysis | Free | https://journaliststudio.google.com/pinpoint |

---

## Appendix: Key Data Sources

| Source | Type | URL | Access |
|---|---|---|---|
| SEC EDGAR | Corporate filings | https://www.sec.gov/cgi-bin/browse-edgar | Free, API available |
| PACER | Federal court records | https://pacer.uscourts.gov | $0.10/page (waived under $30/quarter) |
| RECAP Archive | Free PACER mirror | https://www.courtlistener.com/recap/ | Free |
| FEC | Campaign finance | https://www.fec.gov/data/ | Free, API available |
| OpenSecrets | Analyzed political finance | https://www.opensecrets.org | Free |
| USASpending | Federal contracts/grants | https://www.usaspending.gov | Free, API available |
| ICIJ Offshore Leaks | Offshore entity database | https://offshoreleaks.icij.org | Free |
| OpenCorporates | Global corporate registry | https://opencorporates.com | Free (limited) / Paid |
| Copernicus Browser | Satellite imagery | https://browser.dataspace.copernicus.eu | Free |
| EarthExplorer | Satellite imagery (Landsat) | https://earthexplorer.usgs.gov | Free |
| OFAC Sanctions | Sanctions lists | https://sanctionssearch.ofac.treas.gov | Free |
| MarineTraffic | Ship tracking | https://www.marinetraffic.com | Free (limited) / Paid |
| FlightRadar24 | Flight tracking | https://www.flightradar24.com | Free (limited) / Paid |
| ADS-B Exchange | Unfiltered flight tracking | https://www.adsbexchange.com | Free |

---

*This document is a living resource for the Cleansing Fire project. It will be updated as tools evolve, laws change, and new methodologies are developed. All information is current as of February 2026.*

*The purpose is defensive: civic accountability, investigative journalism, and transparency activism. All methods described are legal. All tools are publicly available. The goal is exposure of concentrated power and corruption through open source methods -- nothing more, nothing less.*
