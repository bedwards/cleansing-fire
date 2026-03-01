# CFAA Case Law Tracker

> Living database of federal Computer Fraud and Abuse Act prosecutions, civil cases, and circuit splits relevant to civic technology and digital rights.

## Purpose

The CFAA (18 U.S.C. § 1030) is the primary federal computer crime statute. Its vague language — particularly "exceeds authorized access" and "without authorization" — has been used to prosecute security researchers, journalists, and civic technologists. This tracker monitors key cases to understand the current legal landscape.

---

## Landmark Supreme Court Decisions

### Van Buren v. United States (2021)
**593 U.S. 374** — *The most important CFAA case*

- **Facts**: Police officer accessed license plate database for non-law-enforcement purpose
- **Holding**: "Exceeds authorized access" means accessing information one is not entitled to access at all, not using permitted access for an improper purpose
- **Impact**: **NARROWED** CFAA scope significantly
- **Relevance**: Protects employees who access systems they're authorized to use for purposes the employer didn't intend — this reasoning extends to API users accessing public data

---

## Circuit Court Decisions

### hiQ Labs v. LinkedIn (9th Cir. 2022)
**938 F.3d 985** (rehearing en banc)

- **Facts**: hiQ scraped publicly available LinkedIn profiles; LinkedIn sent cease-and-desist
- **Holding**: Scraping publicly available data likely does not violate CFAA
- **Impact**: Strongest circuit protection for web scraping of public data
- **Relevance**: **Directly protects** Cleansing Fire's OSINT plugins that access public data
- **Status**: Settled after remand — no final precedent, but 9th Circuit reasoning stands

### Sandvig v. Barr (D.C. Cir. 2020)
**Sandvig v. Sessions, 315 F. Supp. 3d 1**

- **Facts**: Researchers wanted to test housing discrimination by creating fake profiles on websites (violating ToS)
- **Holding**: CFAA does not criminalize ToS violations
- **Impact**: Critical protection for research methodology that requires ToS violations
- **Relevance**: Protects research into platform discrimination

### Facebook v. Power Ventures (9th Cir. 2016)
**844 F.3d 1058**

- **Facts**: Power Ventures accessed Facebook data after receiving cease-and-desist
- **Holding**: Accessing a website after receiving a cease-and-desist letter *can* violate CFAA
- **Impact**: **Creates risk** for scrapers who receive C&D letters
- **Relevance**: Warning — if a target website explicitly revokes access, continued scraping may be CFAA violation

### Musacchio v. United States (2016)
**577 U.S. 237**

- **Facts**: Former employee accessed corporate system after authorization was revoked
- **Holding**: Access "without authorization" applies when authorization has been revoked
- **Impact**: Clear line between "exceeds authorized access" (Van Buren) and "without authorization" (Musacchio)

---

## Key Civil Cases

### Clearview AI Litigation (Multiple jurisdictions, 2020-present)

- **Facts**: Clearview scraped billions of social media photos for facial recognition
- **Status**: ACLU settlement (Illinois, 2022), ongoing in other states
- **Relevance**: Massive-scale scraping can trigger state biometric privacy laws even if CFAA doesn't apply

### Craigs Inc. v. Maloney (N.D. Cal. 2023)

- **Facts**: Researcher scraped Craigslist for housing discrimination research
- **Holding**: Pending — but court signaled sympathy for research purpose
- **Relevance**: Tests whether public interest research is protected

---

## DOJ Prosecution Policy (2022 Update)

On May 19, 2022, the DOJ issued [revised CFAA prosecution guidance](https://www.justice.gov/opa/pr/department-justice-announces-new-policy-charging-cases-under-computer-fraud-and-abuse-act):

> "The policy for the first time directs that good-faith security research should not be charged."

### What's Protected (per DOJ policy):
- ✓ Good-faith security research
- ✓ Testing, investigation, or correction of security flaws
- ✓ Activities conducted in accordance with bug bounty programs
- ✓ Research conducted to improve security of systems

### What's Still Prosecutable:
- ✗ Discovering vulnerabilities for extortion
- ✗ Accessing data to sell to criminals
- ✗ Using research as pretense for unauthorized access
- ✗ Accessing classified government systems

### Caveat:
> DOJ policy is not law. It can be changed by any future administration. Do not rely on prosecution discretion as a substitute for legal compliance.

---

## Active Circuit Splits

| Issue | Narrow Reading | Broad Reading | Status |
|-------|---------------|---------------|--------|
| ToS violation = CFAA crime? | 9th, D.C. Circuit: No | 1st, 5th, 11th: Possibly | Partially resolved by Van Buren |
| Scraping public data | 9th: Not CFAA violation | Some districts: Maybe | hiQ reasoning not universally adopted |
| Employee misuse of authorized access | All circuits post-Van Buren: Not CFAA | Pre-Van Buren cases still cited | Resolved by Van Buren |
| Cease-and-desist = revoking access? | Some courts: Not sufficient alone | 9th (Power Ventures): Yes | Active split |

---

## Relevance to Cleansing Fire

### Activities and Their Legal Status

| Activity | CFAA Risk | Post-Van Buren | Notes |
|----------|:---:|:---:|-------|
| Scraping public government APIs | NONE | ✓ | Public records |
| Scraping public social media | LOW | ✓ | hiQ supports; avoid C&D situations |
| FEC/SEC/USASpending data collection | NONE | ✓ | Government data explicitly public |
| Automated FOIA filing | NONE | ✓ | Filing public records requests |
| OSINT from public sources | NONE | ✓ | Public information |
| Vulnerability disclosure | LOW | ✓ | DOJ policy protects good-faith |
| Bypassing API rate limits | MODERATE | ⚠ | Could be "exceeding authorized access" |
| Creating test accounts on platforms | LOW | ✓ | Sandvig protects research |

### Recommendations

1. **Never bypass authentication** — always use public-facing interfaces
2. **Respect explicit access revocation** — if you receive a C&D, consult legal counsel
3. **Document research purpose** — good-faith intent is now legally meaningful
4. **Prefer government sources** — zero CFAA risk
5. **Monitor this tracker** — the legal landscape is still evolving

---

## Updates

*Last updated: 2025-03-01*

This is a living document. New cases should be added as they are decided with:
- Case name and citation
- Key facts and holding
- Impact assessment for civic tech
- Relevance to Cleansing Fire operations
