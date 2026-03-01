# Anti-SLAPP & Computer Crime Law Matrix

> State-by-state guide to legal protections for civic technologists and journalists.

## What This Is

Two overlapping threats face civic tech projects:
1. **SLAPP suits** (Strategic Lawsuits Against Public Participation) — meritless lawsuits designed to silence critics through legal costs
2. **Computer crime laws** — overbroad statutes that can criminalize security research, scraping, and data journalism

This matrix maps protections and risks across all 50 states.

---

## Anti-SLAPP Protection by State

### Tier 1: Strong Protection ✓✓✓

| State | Statute | Covers Digital? | Fee Shifting | Early Dismissal | Appeal Rights |
|-------|---------|:-:|:-:|:-:|:-:|
| California | CCP §425.16 | ✓ | ✓ | ✓ | ✓ |
| Oregon | ORS 31.150 | ✓ | ✓ | ✓ | ✓ |
| Texas | TCPA Ch. 27 | ✓ | ✓ | ✓ | ✓ |
| Washington | RCW 4.24.525 | ✓ | ✓ | ✓ | ✓ |
| Nevada | NRS 41.637 | ✓ | ✓ | ✓ | ✓ |
| Indiana | IC 34-7-7 | ✓ | ✓ | ✓ | ✓ |

### Tier 2: Moderate Protection ✓✓

| State | Statute | Covers Digital? | Fee Shifting | Early Dismissal | Notes |
|-------|---------|:-:|:-:|:-:|------|
| New York | NYCRL §70-a,76-a | Partial | ✓ | ✓ | 2020 amendments strengthened |
| Illinois | 735 ILCS 110 | ✓ | ✓ | ✓ | Broad — covers government participation |
| Florida | FL §768.295 | Partial | ✓ | ✓ | Must show First Amendment nexus |
| Massachusetts | MA GL 231§59H | Limited | ✓ | ✓ | Narrow — petitioning government only |
| Connecticut | CGS §52-196a | ✓ | ✓ | ✓ | 2017 update added media |
| Maryland | MD CJ §5-807 | Partial | ✓ | ✓ | Recent improvements |
| Colorado | CRS 13-20-1101 | ✓ | ✓ | ✓ | Effective July 2024 |

### Tier 3: Weak/No Protection ✗

| State | Status | Risk Level | Notes |
|-------|--------|:---:|-------|
| Virginia | Limited | HIGH | Narrow statute, recent improvements |
| Ohio | None | HIGH | No anti-SLAPP protection |
| Pennsylvania | None | HIGH | No anti-SLAPP protection |
| Michigan | None | HIGH | Bills introduced but not passed |
| Alabama | None | HIGH | No protection |
| Mississippi | None | HIGH | No protection |
| Missouri | None | HIGH | **Cleansing Fire home state — highest risk** |
| South Carolina | None | HIGH | No protection |
| Iowa | None | HIGH | No protection |

> [!WARNING]
> Missouri has **no anti-SLAPP statute**. Civic tech operations based in Missouri should consider pre-publication legal review and liability insurance.

---

## Computer Crime Law Matrix

### Federal: Computer Fraud and Abuse Act (CFAA)

| Activity | Legal Risk | Case Law |
|----------|:---:|----------|
| Scraping public web pages | MODERATE | *hiQ v. LinkedIn* (9th Cir. 2022) — scraping public data likely not CFAA violation |
| Accessing public APIs | LOW | Generally permissible for public APIs |
| Automated research tools | MODERATE | Depends on ToS and "authorization" interpretation |
| Vulnerability disclosure | MODERATE | DOJ 2022 policy limits CFAA prosecution of good-faith research |
| OSINT (Open Source Intelligence) | LOW | Public information is public |
| Bypassing paywalls/auth | HIGH | Clearly exceeds "authorized access" |

### State Computer Crime Laws — Risk Matrix

| State | Statute | Overbroad? | Scraping Risk | OSINT Risk | Research Risk |
|-------|---------|:---:|:---:|:---:|:---:|
| California | PC §502 | Moderate | LOW | LOW | LOW |
| Georgia | GCCA §16-9-93 | **YES** | HIGH | MODERATE | HIGH |
| Virginia | VA §18.2-152.3 | Moderate | MODERATE | LOW | MODERATE |
| Missouri | §537.525, §569.095 | Moderate | MODERATE | LOW | MODERATE |
| New York | PL §156 | Low | LOW | LOW | LOW |
| Texas | PC §33.02 | Moderate | MODERATE | LOW | MODERATE |
| Florida | §815.06 | **YES** | HIGH | MODERATE | HIGH |
| Illinois | 720 ILCS 5/17-51 | Low | LOW | LOW | LOW |

> [!CAUTION]
> **Georgia** and **Florida** have particularly overbroad computer crime statutes that could criminalize standard research activities. Exercise extreme caution when operating investigations involving data in those states.

---

## Risk Mitigation for Cleansing Fire

### Legal Protections Built Into the System

1. **All plugins access only public APIs and public records** — no unauthorized access
2. **OSINT activities use only publicly available information** — no social engineering
3. **Content marked with confidence levels** — reduces defamation risk (source-verify plugin)
4. **AGPL license** — transparency as legal protection
5. **Philosophy.md** — documented good-faith public interest mission
6. **Human-in-the-loop** for publication — editorial review before distribution

### Recommended Actions

1. **Legal insurance**: Explore media liability insurance for the project
2. **Legal review**: Pre-publication review for high-profile investigations
3. **Jurisdiction selection**: Prefer operating in Tier 1 anti-SLAPP states
4. **Document good faith**: Maintain public accountability protocols
5. **Federal anti-SLAPP**: Support the SPEAK FREE Act (pending federal anti-SLAPP legislation)

---

## Resources

- [RCFP Anti-SLAPP Database](https://www.rcfp.org/anti-slapp-statutes/) — Reporters Committee for Freedom of the Press
- [EFF CFAA Reform](https://www.eff.org/issues/cfaa) — Electronic Frontier Foundation
- [DOJ CFAA Policy (2022)](https://www.justice.gov/opa/pr/department-justice-announces-new-policy-charging-cases-under-computer-fraud-and-abuse-act) — Good faith research exemption
- Cleansing Fire [digital-rights-law.md](digital-rights-law.md) — Full legal framework
