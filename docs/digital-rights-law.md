# Digital Rights Law: A Survival Guide for Civic Technologists

## The Legal Landscape for Activists, Investigators, and Civic Hackers

### The Cleansing Fire Project

*Research Date: 2026-02-28*

---

> "The law is not a shield for the powerful. It is a battlefield. And like all battlefields, the side that knows the terrain wins." -- Pyrrhic Lucidity, applied to legal defense

---

## HOW TO USE THIS DOCUMENT

This is not legal advice. This is legal literacy. The difference matters. Legal advice tells you what to do in your specific situation -- that requires a licensed attorney who knows your jurisdiction, your facts, and your risk tolerance. Legal literacy tells you what questions to ask, what traps exist, what protections are available, and when you need to stop and call a lawyer before you do anything else.

This document builds on and complements the existing Cleansing Fire research:

- **[Intelligence and OSINT](intelligence-and-osint.md)** describes what you can investigate and how. This document describes the legal boundaries of that investigation -- where the line is, how the line moves, and what happens when you cross it.
- **[Fork Protection](fork-protection.md)** describes how to protect the project's integrity. This document describes the legal mechanisms that can be used to attack, suppress, or co-opt civic technology projects -- and how to defend against them.
- **[Movement Strategy](movement-strategy.md)** describes how to build and sustain a movement. This document describes the legal risks that movement participants face and the legal protections they can invoke.

Every section includes a **Risk Level Assessment** (LOW / MEDIUM / HIGH / CRITICAL) and a **When to Call a Lawyer** checklist. If you find yourself in a HIGH or CRITICAL situation, stop reading and start calling. The [Legal Defense Resources](#10-legal-defense-resources) section at the end lists organizations that provide free or reduced-cost legal representation to digital rights activists.

---

## TABLE OF CONTENTS

1. [Computer Fraud and Abuse Act (CFAA)](#1-computer-fraud-and-abuse-act-cfaa)
2. [First Amendment and Digital Speech](#2-first-amendment-and-digital-speech)
3. [Whistleblower Protection Laws](#3-whistleblower-protection-laws)
4. [FOIA and Public Records](#4-foia-and-public-records)
5. [SEC Whistleblower Program](#5-sec-whistleblower-program)
6. [Anti-SLAPP Laws](#6-anti-slapp-laws)
7. [Data Privacy Laws: GDPR, CCPA, and Activist Implications](#7-data-privacy-laws-gdpr-ccpa-and-activist-implications)
8. [Terms of Service as Law](#8-terms-of-service-as-law)
9. [International Considerations](#9-international-considerations)
10. [Legal Defense Resources](#10-legal-defense-resources)

---

# 1. COMPUTER FRAUD AND ABUSE ACT (CFAA)

**Risk Level: CRITICAL**

The Computer Fraud and Abuse Act, 18 U.S.C. Section 1030, is the single most dangerous federal law for digital activists, civic hackers, security researchers, and investigative technologists. Enacted in 1986 -- before the World Wide Web existed -- it criminalizes "unauthorized access" to computers and computer systems. The problem is that "unauthorized access" has never been clearly defined, and prosecutors have exploited that ambiguity to target activists, researchers, and journalists whose work embarrassed powerful institutions.

If you do any work that involves accessing computer systems, scraping data, or probing security vulnerabilities, you need to understand the CFAA. Not understanding it can land you in federal prison.

## 1.1 What the Law Actually Says

The CFAA criminalizes two broad categories of conduct:

1. **Accessing a computer "without authorization"** (Section 1030(a)(2)) -- gaining access to a computer system you have no permission to access at all.
2. **"Exceeding authorized access"** (Section 1030(a)(2), (a)(4)) -- having some legitimate access to a system but going beyond the boundaries of that access to obtain information you were not authorized to see.

Penalties range from misdemeanors (up to 1 year) to felonies (up to 10 years for a first offense, 20 years for repeat offenses). Civil liability is also possible under Section 1030(g), which allows private parties to sue for damages.

The critical ambiguity: What counts as "authorization"? Does violating a website's terms of service transform authorized access into unauthorized access? Does accessing a publicly available URL that the website operator did not intend to be public constitute unauthorized access? Does scraping public data from a website that says "no scraping" in its terms of service make you a federal criminal?

For decades, the answer was: maybe. And "maybe" is enough to prosecute.

## 1.2 The Aaron Swartz Case (2011-2013)

**United States v. Aaron Swartz** is the case that crystallized the dangers of the CFAA for the digital rights community.

Aaron Swartz was a programmer, activist, and co-founder of Reddit. In 2010-2011, he used MIT's network to download approximately 4.8 million academic articles from JSTOR, a digital library of academic journals. JSTOR's content was largely funded by public research grants. MIT had an institutional subscription to JSTOR, and Swartz was a research fellow at Harvard, which also had access.

What Swartz did: He connected a laptop to MIT's network in a wiring closet, wrote a script to download articles in bulk, and evaded JSTOR's download limits (which throttled automated access) by cycling through IP addresses and MAC addresses.

What happened: Federal prosecutors charged Swartz with 13 felony counts under the CFAA and wire fraud statutes, carrying a maximum penalty of 35 years in prison and $1 million in fines. JSTOR itself settled its civil claims and declined to press charges. MIT did not actively seek prosecution but did not oppose it.

Prosecutors offered a plea deal: 6 months in federal prison. Swartz refused, arguing that what he did was civil disobedience, not crime. On January 11, 2013, Aaron Swartz died by suicide at age 26.

**What this case teaches civic technologists:**

- Federal prosecutors have enormous discretion in how they charge CFAA cases. The same conduct can be charged as a misdemeanor or as a stack of felonies carrying decades of prison time.
- The intent of the actor is largely irrelevant to charging decisions. Swartz was trying to liberate publicly funded research, not steal trade secrets or commit fraud. Prosecutors charged him the same way they would charge a corporate data thief.
- Institutional actors (JSTOR, MIT) may not want prosecution, but that does not stop prosecutors from pursuing it. The government does not need a victim's cooperation to press charges.
- Evading technical access controls (download limits, IP blocks) can be construed as circumventing authorization, even if the underlying data is technically accessible.

**Citation:** United States v. Swartz, No. 11-cr-10260 (D. Mass. 2011); see also *The Internet's Own Boy* (documentary, 2014).

## 1.3 The Weev Case (2010-2013)

**United States v. Auernheimer** (740 F.3d 1279 (3d Cir. 2014)) is the case that demonstrated how the CFAA can criminalize accessing publicly available information.

Andrew "Weev" Auernheimer discovered that AT&T's website exposed the email addresses and ICC-ID numbers of iPad owners through a publicly accessible URL. No password was required. No authentication was bypassed. The URLs followed a predictable numeric pattern, and Auernheimer's associate, Daniel Spitler, wrote a script that iterated through ID numbers, collecting approximately 114,000 email addresses of iPad users -- including government officials, military personnel, and corporate executives.

Auernheimer and Spitler reported the vulnerability to Gawker Media, which published it. AT&T was embarrassed. Federal prosecutors charged both with conspiracy and CFAA violations.

Auernheimer was convicted and sentenced to 41 months in federal prison. The Third Circuit Court of Appeals eventually reversed the conviction -- but on venue grounds (the alleged crime did not occur in New Jersey, where the trial was held), not on the merits of whether accessing publicly available URLs constitutes "unauthorized access."

**What this case teaches:**

- Accessing publicly available information can be prosecuted under the CFAA if the system operator did not "intend" that information to be accessed in that manner.
- The CFAA does not require bypassing any technical security measure. Guessing a URL pattern and visiting public web pages was sufficient for prosecution.
- Embarrassing a powerful corporation (AT&T) with a legitimate security disclosure can trigger federal prosecution.
- Even when convictions are reversed, the defendant has already served time, spent hundreds of thousands of dollars on legal fees, and had their life disrupted.

## 1.4 Van Buren v. United States (2021) -- The Supreme Court Weighs In

**Van Buren v. United States**, 593 U.S. 374 (2021), is the most significant CFAA case to reach the Supreme Court. Nathan Van Buren was a Georgia police officer who accepted a bribe to search a law enforcement database for information about a license plate. He had legitimate access to the database as part of his job, but he used that access for an improper purpose (personal financial gain, not law enforcement).

The question: Does using an authorized system for an unauthorized purpose constitute "exceeding authorized access" under the CFAA?

The Supreme Court held 6-3 that it does not. Justice Amy Coney Barrett, writing for the majority, held that "exceeding authorized access" means accessing information in areas of a computer system that the user is not entitled to access -- not using information the user is entitled to access for an improper purpose.

**Why this matters for activists:**

- Van Buren narrowed the CFAA by rejecting the broadest interpretation -- that any misuse of an authorized system constitutes a federal crime.
- Before Van Buren, prosecutors could argue that violating an employer's computer use policy (e.g., "this database is for work purposes only") was a federal crime. That argument is now foreclosed.
- However, Van Buren did not address the "without authorization" prong. It only addressed "exceeding authorized access." If you have no authorization to access a system at all, Van Buren does not help you.
- Van Buren also did not address whether violating a website's Terms of Service constitutes accessing the website "without authorization." That question remains open.

**Citation:** Van Buren v. United States, 593 U.S. 374 (2021).

## 1.5 Recent Reforms and Their Limits

**Aaron's Law (proposed, never enacted).** Following Swartz's death, Representatives Zoe Lofgren and Ron Wyden introduced "Aaron's Law" (multiple sessions, starting 2013). The bill would have amended the CFAA to exclude violations of Terms of Service and narrowed the definition of "unauthorized access." It has been introduced repeatedly and has never passed. As of 2026, no version of Aaron's Law has been enacted.

**CFAA Reform Act proposals.** Various reform proposals have circulated since 2021, some attempting to codify Van Buren's holding, others attempting broader reform. The legislative environment remains hostile to meaningful CFAA reform because the law is useful to corporate interests and federal prosecutors alike.

**State-level computer fraud statutes.** Most states have their own computer fraud laws, many modeled on the CFAA. Some are broader than the CFAA. California Penal Code Section 502, for example, criminalizes accessing computer systems "without permission." Virginia Computer Crimes Act, Va. Code Section 18.2-152.3 through 18.2-152.14, includes broad prohibitions. State prosecutors can charge conduct under state law even if federal prosecutors decline.

## 1.6 Practical Guidance for Civic Technologists

**What is generally safe under the CFAA:**
- Accessing information that is genuinely publicly available (no login required, no technical barriers circumvented, no terms of service prohibiting access)
- Using official APIs within their documented rate limits and terms
- Filing FOIA requests and analyzing the results
- Reading court documents, SEC filings, and other public records
- Analyzing data you have been lawfully given access to

**What creates CFAA risk:**
- Circumventing any technical access control (CAPTCHA, rate limit, IP block, login screen)
- Accessing systems using credentials you obtained without authorization
- Scraping websites that have Terms of Service prohibiting scraping (see Section 8)
- Using automated tools to access systems in ways the operator has not sanctioned
- Accessing internal systems of an employer for purposes outside your job duties (pre-Van Buren this was riskier; post-Van Buren, less so for the "exceeding authorized access" prong)

**When to call a lawyer:**
- Before you begin any project that involves accessing non-public computer systems
- Before you scrape any large dataset from a commercial platform
- If you receive a cease-and-desist letter related to computer access
- If you are contacted by law enforcement about computer access
- If you discover a security vulnerability and want to disclose it responsibly

---

# 2. FIRST AMENDMENT AND DIGITAL SPEECH

**Risk Level: MEDIUM**

The First Amendment to the U.S. Constitution prohibits the government from abridging the freedom of speech. It does not protect you from private actors (your employer can fire you for your speech; a platform can ban you). But it provides powerful protections when the government tries to suppress digital activism, investigative journalism, or civic technology work.

## 2.1 When Is Code Speech?

The question of whether computer code qualifies as protected speech under the First Amendment has been litigated repeatedly.

**Bernstein v. United States** (9th Cir. 1996, 1999). Daniel Bernstein, a mathematician at UC Berkeley, challenged export restrictions on encryption software. The government classified cryptographic source code as a "munition" under ITAR (International Traffic in Arms Regulations) and required an export license to publish it. The Ninth Circuit held that source code is speech protected by the First Amendment, and that the export licensing scheme was an unconstitutional prior restraint.

**Universal City Studios v. Corley** (273 F.3d 429, 2d Cir. 2001). The Second Circuit held that while source code has an expressive component protected by the First Amendment, the government can regulate the functional aspects of code. The court upheld the DMCA's anti-circumvention provisions as applied to DeCSS (code that decrypted DVD copy protection), finding that the regulation targeted the code's functional capacity to decrypt, not its expressive content.

**The current state:** Code is speech, but it is not purely speech. Courts apply intermediate scrutiny to regulations of code's functional aspects, meaning the government must show a substantial interest and a reasonable fit between the regulation and that interest. Regulations that target the expressive content of code receive strict scrutiny. Regulations that target its functional operation receive intermediate scrutiny.

**What this means for civic technologists:** Publishing source code, writing about algorithms, and sharing analytical tools are generally protected speech activities. But if your code is designed to circumvent access controls (DMCA Section 1201), or if its primary function is to access systems without authorization (CFAA), the speech protection may not shield you from prosecution.

## 2.2 When Is Scraping Protected?

Web scraping exists in a legal gray zone that implicates the CFAA, copyright law, contract law (Terms of Service), and the First Amendment.

**hiQ Labs v. LinkedIn** (938 F.3d 985, 9th Cir. 2019; on remand, 31 F.4th 1180, 9th Cir. 2022). This is the most important scraping case for civic technologists. hiQ scraped publicly available LinkedIn profiles to provide workforce analytics. LinkedIn sent a cease-and-desist letter demanding hiQ stop scraping, then implemented technical measures to block hiQ's access.

The Ninth Circuit held that scraping publicly available data likely does not violate the CFAA because the data is publicly accessible -- there is no "authorization" gate to bypass. The court distinguished between systems that require authentication (where scraping without permission could violate the CFAA) and publicly available websites (where there is no "authorization" to exceed).

**Sandvig v. Barr** (451 F. Supp. 3d 73, D.D.C. 2020). Researchers wanted to test whether employment websites discriminated based on race by creating fictitious profiles -- which would violate the sites' Terms of Service. The court held that the CFAA does not criminalize mere Terms of Service violations for accessing publicly available websites, and noted First Amendment concerns with criminalizing socially valuable research.

**What this means:** Scraping publicly available data is on relatively strong legal ground post-hiQ. But "publicly available" is the key phrase. If data requires a login, if you circumvent CAPTCHAs or rate limits, or if you violate a site's robots.txt, the legal risk increases substantially.

## 2.3 When Is Whistleblowing Protected Speech?

Whistleblowing implicates both the First Amendment and specific whistleblower protection statutes (covered in Section 3). The First Amendment analysis depends on whether the whistleblower is a government employee, a private employee, or a member of the public.

**Garcetti v. Ceballos** (547 U.S. 410 (2006)). The Supreme Court held that when public employees make statements pursuant to their official duties, they are not speaking as citizens and the First Amendment does not insulate them from employer discipline. This is devastating for government whistleblowers: if your job is to review contracts and you discover fraud, reporting that fraud is part of your job duties, and therefore not protected by the First Amendment.

**Lane v. Franks** (573 U.S. 228 (2014)). The Supreme Court somewhat limited Garcetti, holding that testimony in a criminal trial by a public employee about conduct observed in the course of employment is citizen speech protected by the First Amendment, even if the testimony related to the employee's official duties.

**The practical upshot:** Government employees who blow the whistle need statutory whistleblower protections (Section 3), not just the First Amendment. The First Amendment alone is insufficient to protect most government whistleblowers from retaliation.

## 2.4 Prior Restraint and Publication

**Near v. Minnesota** (283 U.S. 697 (1931)) and **New York Times Co. v. United States** (403 U.S. 713 (1971), the "Pentagon Papers" case) established that prior restraint -- government action preventing publication before it occurs -- is presumptively unconstitutional. This means the government generally cannot prevent you from publishing information, though it may be able to punish you after publication if the information was obtained illegally.

**What this means for civic technologists:** If you have lawfully obtained information (through FOIA, public records, tips from sources, or OSINT), the government faces an extremely high bar to prevent you from publishing it. But if the information was obtained through arguably illegal means (unauthorized access, theft of classified documents), you may face criminal prosecution after publication even if the publication itself cannot be enjoined.

---

# 3. WHISTLEBLOWER PROTECTION LAWS

**Risk Level: HIGH (for the whistleblower)**

Whistleblower protection laws are the legal infrastructure that makes accountability possible. Without them, individuals who discover fraud, corruption, or illegality within powerful institutions have no safe way to report it. The Cleansing Fire [OSINT document](intelligence-and-osint.md) describes whistleblower infrastructure from a technical perspective. This section covers the legal protections and their gaps.

The most important thing to understand about whistleblower protection: **the protections are narrow, inconsistent, and riddled with exceptions.** The gap between the protection the law promises and the protection it actually delivers has destroyed lives.

## 3.1 Federal Whistleblower Protections

**Whistleblower Protection Act (WPA), 5 U.S.C. Section 2302(b)(8).** Protects federal employees who disclose information they reasonably believe evidences a violation of law, gross mismanagement, gross waste of funds, abuse of authority, or a substantial and specific danger to public health or safety. Protection is limited to disclosures made to specific authorized recipients (the Office of Special Counsel, the Inspector General, or Congress). Disclosures to the media are generally not protected under the WPA.

**Whistleblower Protection Enhancement Act (WPEA) of 2012.** Strengthened the WPA by extending protections to disclosures made during the normal course of duties (partially addressing the Garcetti problem), clarifying that "any disclosure" qualifies (not just disclosures through specified channels), and adding protections for employees of the Transportation Security Administration.

**Intelligence Community Whistleblower Protection Act (ICWPA), 5 U.S.C. App. Section 8H.** Provides a mechanism for intelligence community employees to report urgent concerns to the Inspector General and, through the IG, to the congressional intelligence committees. This is the law that was invoked in the 2019 Ukraine whistleblower complaint. Critically, the ICWPA does not protect against retaliation -- it only provides a reporting channel. Intelligence community whistleblowers who face retaliation must rely on Presidential Policy Directive 19 (PPD-19), which provides some protection but is not judicially enforceable.

**Sarbanes-Oxley Act Section 806, 18 U.S.C. Section 1514A.** Protects employees of publicly traded companies who report securities fraud, shareholder fraud, bank fraud, or violations of SEC rules. Provides a cause of action for retaliation, including reinstatement, back pay, and compensatory damages.

**Dodd-Frank Act Section 922, 15 U.S.C. Section 78u-6.** Creates the SEC Whistleblower Program (covered in detail in Section 5). Provides anti-retaliation protections for individuals who report securities violations to the SEC, and uniquely offers financial rewards of 10-30% of sanctions exceeding $1 million.

**False Claims Act (qui tam), 31 U.S.C. Sections 3729-3733.** Allows private individuals to file lawsuits on behalf of the government against entities that have defrauded the government. The whistleblower (called a "relator") can receive 15-30% of the recovered funds. This is the most financially powerful whistleblower mechanism -- qui tam recoveries have exceeded $70 billion since 1986.

## 3.2 State Whistleblower Protections

State-level whistleblower protections vary enormously. Some states provide broad protection; others provide almost none.

**Strong protections:** California (Cal. Lab. Code Section 1102.5), New York (N.Y. Lab. Law Section 740, strengthened in 2022), New Jersey (Conscientious Employee Protection Act, N.J. Stat. Section 34:19-1 et seq.), and Illinois provide broad anti-retaliation protections covering both public and private employees, with causes of action for damages.

**Weak protections:** Many states limit whistleblower protections to public employees, require reporting through internal channels before external disclosure, or provide only narrow categories of protected disclosures.

**Key consideration:** State and federal protections can overlap, and a whistleblower may have claims under both. But the procedural requirements differ -- some require administrative exhaustion before filing suit, some have short statutes of limitations (as brief as 30 days for some federal claims), and some require reporting to specific agencies. Missing a deadline or reporting to the wrong entity can waive your protections.

## 3.3 The Cases That Define the Landscape

### Edward Snowden (2013)

Edward Snowden, a contractor for the NSA, disclosed classified documents revealing mass surveillance programs (PRISM, XKeyscore, bulk metadata collection) to journalists Glenn Greenwald and Laura Poitras. Snowden was charged under the Espionage Act of 1917 (18 U.S.C. Sections 793-798), which does not allow a public interest defense. Under the Espionage Act, the fact that the disclosed information revealed illegal government activity is legally irrelevant.

**What Snowden's case teaches:**
- Intelligence community contractors have virtually no legal protection for whistleblowing, even when the disclosed activity is later found to violate the law (the NSA's bulk metadata program was ruled illegal by the Second Circuit in ACLU v. Clapper, 785 F.3d 787 (2d Cir. 2015)).
- The Espionage Act does not distinguish between selling secrets to a foreign government and disclosing them to journalists in the public interest.
- Snowden received a presidential pardon from President Biden on December 23, 2024 -- more than a decade after his disclosures. The pardon does not change the law; it was an exercise of executive clemency specific to Snowden.

### Reality Winner (2017)

Reality Winner, an NSA linguist, leaked a single classified document to The Intercept showing Russian interference in the 2016 U.S. election. The document was an NSA intelligence report describing Russian hacking of U.S. election infrastructure.

**What went wrong:** The Intercept, in seeking comment from the NSA before publication, shared a copy of the document. The document contained printer tracking dots (Machine Identification Code) and other metadata that identified the specific printer and time of printing. The NSA identified Winner as the source within days. She was charged under the Espionage Act, pleaded guilty, and was sentenced to 5 years and 3 months -- the longest sentence ever imposed for an unauthorized disclosure to the media at that time.

**What this teaches:**
- Operational security failures can be fatal. The OSINT document covers this in detail, but the legal lesson is that even a single disclosure of a single document can result in years of imprisonment.
- The Espionage Act has been used increasingly aggressively against leakers since the Obama administration, which prosecuted more Espionage Act cases against leakers than all previous administrations combined.
- The media organization's security practices matter. The Intercept's handling of the document contributed directly to Winner's identification.

### Chelsea Manning (2010-2017)

Chelsea Manning, a U.S. Army intelligence analyst, disclosed approximately 750,000 classified and sensitive military and diplomatic documents to WikiLeaks, including the "Collateral Murder" video showing a U.S. Apache helicopter attack that killed Iraqi civilians and two Reuters journalists.

Manning was convicted of violations of the Espionage Act and other charges, acquitted of "aiding the enemy," and sentenced to 35 years. President Obama commuted her sentence in 2017 after she had served approximately 7 years, including extended periods of solitary confinement that the UN Special Rapporteur on Torture characterized as cruel, inhuman, and degrading treatment.

### Daniel Ellsberg (1971)

Daniel Ellsberg leaked the Pentagon Papers -- a 7,000-page classified study of U.S. decision-making in Vietnam -- to The New York Times and The Washington Post. The Supreme Court refused to block publication (New York Times Co. v. United States, 403 U.S. 713 (1971)). Ellsberg was charged under the Espionage Act, but the case was dismissed due to government misconduct (the "White House Plumbers" broke into Ellsberg's psychiatrist's office, and the government engaged in illegal wiretapping).

**The Ellsberg contrast:** Ellsberg benefited from a legal environment that no longer exists. The government's own misconduct provided the basis for dismissal. Modern surveillance capabilities make it far harder for leakers to remain anonymous, and modern prosecutors are far less likely to engage in the kind of blatant misconduct that got Ellsberg's case dismissed.

## 3.4 Practical Guidance for Potential Whistleblowers

1. **Talk to a lawyer before you do anything.** Organizations listed in Section 10 provide confidential consultations. This is not optional -- it is the single most important step.
2. **Understand which laws protect your specific situation.** Federal employee? Private sector? Intelligence community? Contractor? The applicable law differs for each.
3. **Use protected channels when they exist.** Disclosures to an Inspector General or to Congress are generally better protected than disclosures to the media.
4. **Document everything.** Keep contemporaneous records of what you observed, when you observed it, who you reported it to, and what response you received. Store these records securely, outside your employer's systems.
5. **Assume your communications are monitored.** Use the operational security practices described in the [OSINT document](intelligence-and-osint.md). Use secure communication channels (Signal, SecureDrop) for sensitive discussions.
6. **Understand the retaliation timeline.** Most whistleblower retaliation statutes have short filing deadlines. Missing the deadline can waive your claim entirely.

---

# 4. FOIA AND PUBLIC RECORDS

**Risk Level: LOW**

The Freedom of Information Act (5 U.S.C. Section 552) is one of the most powerful and underused tools available to civic technologists. FOIA gives any person the right to request records from federal agencies. You do not need to be a U.S. citizen. You do not need to be a journalist. You do not need to explain why you want the records. The burden is on the agency to justify withholding, not on you to justify requesting.

## 4.1 How FOIA Works

**Who can file:** Any person. Individuals, corporations, organizations, foreign nationals. There is no standing requirement.

**What agencies are covered:** All federal executive branch agencies, departments, and independent regulatory agencies. FOIA does not cover Congress, the federal courts, or the Executive Office of the President (though the Office of Management and Budget and other EOP components are covered).

**What records are covered:** Any recorded information -- documents, emails, memos, reports, data, photographs, audio/video recordings, electronic records -- held by a covered agency. The record does not need to exist at the time of the request; if the agency can create it from existing data with reasonable effort, it may be required to do so.

**How to file:** Submit a written request (letter, email, or online portal) to the agency's FOIA office describing the records you seek with "reasonable particularity." You do not need to cite FOIA or use magic words. Many agencies now accept requests through online portals (e.g., FOIAonline, agency-specific portals).

## 4.2 The Nine Exemptions

FOIA has nine exemptions that allow agencies to withhold information. Understanding these exemptions is essential to filing effective requests and challenging improper withholdings.

**Exemption 1: Classified Information.** Information properly classified under Executive Order 13526 (or successor orders) in the interest of national defense or foreign policy. Agencies frequently over-classify to avoid disclosure. Challenge: request a Vaughn index (itemized justification for each withholding) and argue that the classification is improper.

**Exemption 2: Internal Personnel Rules.** Narrowed by *Milner v. Department of the Navy*, 562 U.S. 562 (2011), to cover only internal personnel rules and practices (e.g., parking regulations). Previously used broadly; now quite narrow.

**Exemption 3: Statutory Exemptions.** Information exempted by other federal statutes (e.g., tax return information under 26 U.S.C. Section 6103, intelligence sources and methods under the National Security Act).

**Exemption 4: Trade Secrets and Confidential Business Information.** Commercial or financial information obtained from a person that is privileged or confidential. After *Food Marketing Institute v. Argus Leader Media*, 588 U.S. 427 (2019), information is "confidential" if it is customarily kept private by the submitter. This exemption is frequently invoked by government contractors to prevent disclosure of contract terms, pricing, and performance data.

**Exemption 5: Deliberative Process Privilege.** Inter-agency or intra-agency memoranda that would not be available by law to a party other than an agency in litigation. This is the most frequently abused exemption. Agencies routinely invoke Exemption 5 to withhold any internal communication, even when the deliberative process has concluded and the decision has been made. Challenge: argue that the deliberative process is complete and the privilege no longer applies, or that the factual portions of the document are segregable from the deliberative portions.

**Exemption 6: Personal Privacy.** Personnel, medical, and similar files whose disclosure would constitute a clearly unwarranted invasion of personal privacy. This requires a balancing test: the public interest in disclosure versus the privacy interest of the individual.

**Exemption 7: Law Enforcement Records.** Records compiled for law enforcement purposes, but only if disclosure would cause one of six specified harms (interfere with enforcement proceedings, deprive a person of a fair trial, constitute an unwarranted invasion of privacy, reveal a confidential source, disclose investigative techniques, or endanger someone's safety).

**Exemption 8: Financial Institution Regulation.** Information related to the examination, operating, or condition reports of financial institutions.

**Exemption 9: Geological Information.** Geological and geophysical information concerning wells. (Yes, really. This exemption exists to protect oil companies.)

## 4.3 How to File Effective FOIA Requests

**Be specific.** "All records relating to X" is less effective than "All emails sent or received by [named official] between [date range] containing the terms [specific keywords] relating to [specific subject]." Specificity reduces the agency's ability to claim the request is too broad.

**Name names.** If you know which officials were involved in the decision or activity you are investigating, name them. Records of specific individuals are easier to search for than records of an entire agency.

**Use date ranges.** Narrow your request to a specific time period. This reduces the volume of responsive records and makes it harder for the agency to claim undue burden.

**Request fee waivers.** FOIA provides for fee waivers when disclosure "is in the public interest because it is likely to contribute significantly to public understanding of the operations or activities of the government and is not primarily in the commercial interest of the requester." News media and educational requesters receive preferential fee treatment.

**File with multiple agencies.** If your investigation involves multiple agencies, file parallel requests. Agencies sometimes disclose information that another agency withheld, because each agency makes its own exemption determinations independently.

**Track your requests.** Agencies are required to respond within 20 business days (though most do not). Track deadlines and follow up. If the agency does not respond, you have the right to file an administrative appeal and, ultimately, a FOIA lawsuit.

## 4.4 State Public Records Laws

Every state has its own public records law, often called "sunshine laws" or "open records acts." These laws vary enormously in scope, exemptions, fees, and enforcement.

**Strong states:** Texas (Texas Public Information Act), Florida (Florida Sunshine Law -- one of the broadest in the nation; Florida's public records law is why you see so many "Florida Man" stories -- journalists can access arrest records easily), California (California Public Records Act), New York (FOIL -- Freedom of Information Law).

**Weak states:** Some states have broad exemptions for law enforcement, limited enforcement mechanisms, or allow agencies to charge exorbitant fees that effectively deny access.

**Key resource:** The Reporters Committee for Freedom of the Press maintains an Open Government Guide (https://www.rcfp.org/open-government-guide/) with state-by-state analysis of public records laws.

## 4.5 FOIA Litigation

When an agency improperly withholds records, you can sue in federal district court under 5 U.S.C. Section 552(a)(4)(B). FOIA litigation has several favorable features for requesters:

- **De novo review.** The court reviews the agency's withholding decision from scratch, giving no deference to the agency's determination.
- **Burden on the agency.** The agency bears the burden of justifying each withholding.
- **Attorney's fees.** If you "substantially prevail," the court can award attorney's fees and litigation costs.
- **Vaughn index.** The court can require the agency to produce a detailed index describing each withheld document and the exemption claimed for each.

**Organizations that litigate FOIA cases:** The Reporters Committee for Freedom of the Press, the American Civil Liberties Union, the Electronic Frontier Foundation, the Knight First Amendment Institute at Columbia University, MuckRock, and the National Security Archive at George Washington University.

---

# 5. SEC WHISTLEBLOWER PROGRAM

**Risk Level: LOW (if done correctly)**

The SEC Whistleblower Program, created by the Dodd-Frank Act in 2010 and codified at 15 U.S.C. Section 78u-6, is unique among whistleblower programs because it offers substantial financial rewards and strong anti-retaliation protections. Since its inception, the program has awarded over $2 billion to whistleblowers and has resulted in enforcement actions recovering billions more.

## 5.1 How It Works

**Eligibility:** Any individual who voluntarily provides original information to the SEC that leads to a successful enforcement action resulting in sanctions exceeding $1 million. "Original information" means information derived from independent knowledge or analysis, not from publicly available sources (though analysis of public sources can qualify if it reveals violations not already known to the SEC).

**Rewards:** 10-30% of the monetary sanctions collected in the enforcement action. The percentage depends on factors including the significance of the information, the degree of assistance provided, the SEC's programmatic interest in deterrence, and the whistleblower's participation in internal compliance systems.

**Anti-retaliation:** Dodd-Frank Section 78u-6(h) prohibits employers from retaliating against employees who report to the SEC. Remedies include reinstatement, double back pay, and attorney's fees. The Supreme Court held in *Digital Realty Trust, Inc. v. Somers*, 583 U.S. 149 (2018), that Dodd-Frank's anti-retaliation protections apply only to individuals who report to the SEC, not to purely internal reporters (internal reporters may still be protected under Sarbanes-Oxley).

## 5.2 Anonymous Reporting

You can report to the SEC anonymously if you are represented by an attorney. The attorney submits the tip on your behalf, and your identity is disclosed to the SEC only if the investigation progresses. This provides a significant degree of protection during the early stages.

**Filing process:**
1. Submit a tip online through the SEC's Tip, Complaint, and Referral (TCR) system, or use SEC Form TCR.
2. If filing anonymously, retain an attorney who will serve as your intermediary.
3. Provide as much specific, detailed information as possible. Tips that include documents, transaction records, communications, or other evidence are far more likely to result in investigation than conclusory allegations.
4. Respond to SEC staff follow-up inquiries promptly.

## 5.3 What Qualifies

The SEC Whistleblower Program covers violations of federal securities laws, including:
- Securities fraud (market manipulation, insider trading, Ponzi schemes)
- Accounting fraud and financial statement manipulation
- Foreign bribery (FCPA violations)
- Market manipulation
- Offering fraud
- Unregistered securities offerings
- Failure to file required reports
- Broker-dealer misconduct
- Municipal securities violations

## 5.4 Relevance to Civic Technologists

If your OSINT investigation (as described in the [Intelligence and OSINT document](intelligence-and-osint.md)) or your corporate power mapping (as described in the [Corporate Power Map](corporate-power-map.md)) reveals potential securities violations, the SEC Whistleblower Program provides a legal, protected, and financially incentivized channel for reporting. This is particularly relevant for investigations into:

- Corporate executives whose public statements conflict with internal realities (potential securities fraud)
- Companies that underreport environmental liabilities, labor violations, or regulatory non-compliance in SEC filings
- Political spending or lobbying that creates undisclosed conflicts of interest for publicly traded companies
- Dark money networks that involve securities law violations

---

# 6. ANTI-SLAPP LAWS

**Risk Level: MEDIUM**

SLAPP stands for Strategic Lawsuit Against Public Participation. A SLAPP suit is a lawsuit filed not to win on the merits, but to silence critics through the cost and stress of litigation. A corporation or wealthy individual sues an activist, journalist, or critic for defamation, tortious interference, or another tort, knowing that the mere existence of the lawsuit -- regardless of its merit -- imposes financial and emotional costs that deter continued criticism.

Anti-SLAPP laws provide a mechanism to dismiss these suits quickly, before the defendant incurs significant legal costs, and to recover attorney's fees from the plaintiff.

## 6.1 State Anti-SLAPP Statutes

There is no federal anti-SLAPP statute. Protection depends entirely on state law, and state laws vary dramatically.

**Strong anti-SLAPP states:**

- **California** (Cal. Civ. Proc. Code Section 425.16): The gold standard. Covers any act in furtherance of the right of petition or free speech in connection with a public issue. Provides for early dismissal (special motion to strike), attorney's fees to the prevailing defendant, and an immediate right to appeal if the motion is denied.
- **Texas** (Tex. Civ. Prac. & Rem. Code Section 27): Broad protection covering communications on matters of public concern. Provides for dismissal, attorney's fees, and sanctions.
- **Oregon** (ORS 31.150-31.155): Covers written or oral statements made in connection with an issue of public interest. Provides for special motion to strike, attorney's fees, and $10,000 statutory damages to the defendant.
- **Washington** (RCW 4.24.525): Covers communications related to government proceedings, public issues, or matters of public concern. Provides for dismissal and attorney's fees.

**Weak or no anti-SLAPP states:**

- **New York**: Had a very narrow anti-SLAPP law until 2020, when it was significantly strengthened (N.Y. Civ. Rights Law Sections 70-a, 76-a). The strengthened version covers any communication in connection with a matter of public interest. However, the 2020 amendments have been subject to legal challenges and inconsistent judicial interpretation.
- **Virginia**: Anti-SLAPP law is limited to statements made at public hearings.
- Several states (including Pennsylvania, until recently) have no anti-SLAPP statute at all.

## 6.2 Federal Litigation

When SLAPP suits are filed in federal court (or removed to federal court based on diversity jurisdiction), the availability of state anti-SLAPP protections is uncertain. Federal courts are split on whether state anti-SLAPP statutes apply in federal court. The D.C. Circuit has held that the D.C. Anti-SLAPP Act applies in federal court (*Abbas v. Foreign Policy Group*, 783 F.3d 1328 (D.C. Cir. 2015)). Other circuits have reached different conclusions.

## 6.3 Practical Guidance

- **Know your state's anti-SLAPP law before you publish.** If you are publishing investigative findings about a powerful entity, understand what procedural protections are available to you if you are sued.
- **Document your research process.** Anti-SLAPP motions and defamation defenses both benefit from evidence that you conducted your investigation carefully and in good faith.
- **Consider where you publish.** If your state has weak or no anti-SLAPP protection, publishing through an organization based in a strong anti-SLAPP state may provide better protection.
- **Respond immediately to threats.** If you receive a legal threat, do not ignore it. Contact a First Amendment attorney. Organizations listed in Section 10 can help.

---

# 7. DATA PRIVACY LAWS: GDPR, CCPA, AND ACTIVIST IMPLICATIONS

**Risk Level: MEDIUM**

Data privacy laws present a complex dual-use problem for civic technologists. On one hand, they provide important protections for activists and their communities. On the other hand, they can be weaponized by powerful actors to suppress legitimate investigation.

## 7.1 GDPR (General Data Protection Regulation)

The EU's GDPR (Regulation 2016/679) is the most comprehensive data privacy law in the world. It applies to any organization that processes personal data of individuals in the EU, regardless of where the organization is based.

**How GDPR helps activists:**
- **Right of access (Article 15).** You can demand that any organization tell you what personal data it holds about you, where it got it, and who it has shared it with. This is a powerful investigative tool: file access requests with companies you suspect of mishandling your data or the data of your community.
- **Right to erasure (Article 17).** The "right to be forgotten." You can demand deletion of your personal data in many circumstances. This helps activists who have been doxxed or whose personal information has been collected by hostile actors.
- **Data breach notification (Article 33).** Organizations must report data breaches to regulators within 72 hours. This creates public accountability for security failures.

**How GDPR is used against activists:**
- **Right to erasure weaponized.** Corporations and individuals whose misconduct has been documented can invoke the right to erasure to demand removal of investigative findings that contain personal data. The tension between the right to erasure and the public interest in accountability has been litigated extensively but remains unresolved in many contexts.
- **"Legitimate interest" constraints.** GDPR requires a legal basis for processing personal data. Investigative journalism has a carve-out (Article 85), but the scope of this carve-out varies by EU member state. Civic technologists who are not formally journalists may face challenges establishing a legal basis for processing personal data in the course of investigations.
- **Compliance costs.** GDPR compliance is expensive and complex. This disproportionately burdens small organizations, independent investigators, and activist groups who may lack the resources to implement full GDPR compliance programs.

**Journalism exemption (Article 85):** GDPR requires member states to reconcile data protection with freedom of expression and information, including journalistic purposes. The scope of this exemption varies significantly by country. Germany provides broad protection for press activities. France is more restrictive. The definition of "journalism" in the digital age -- does blogging count? Does OSINT investigation count? -- is contested.

## 7.2 CCPA/CPRA (California Consumer Privacy Act / California Privacy Rights Act)

California's CCPA (Cal. Civ. Code Section 1798.100 et seq.), as amended by the CPRA (effective January 1, 2023), is the strongest data privacy law in the United States. It applies to businesses that meet certain revenue or data-volume thresholds and collect personal information from California residents.

**Key rights under CCPA/CPRA:**
- Right to know what personal information is collected, used, and shared
- Right to delete personal information
- Right to opt out of the sale or sharing of personal information
- Right to correct inaccurate personal information
- Right to limit use and disclosure of sensitive personal information
- Private right of action for data breaches involving unencrypted personal information (Cal. Civ. Code Section 1798.150)

**Relevance to civic technologists:** The CCPA's data breach private right of action is significant. If a company you are investigating has had a data breach affecting California residents, the affected individuals can sue for statutory damages of $100-$750 per consumer per incident, or actual damages, whichever is greater. Class action lawsuits under this provision have resulted in significant settlements.

## 7.3 When Privacy Laws Conflict with Accountability

The fundamental tension: data privacy laws protect individuals from having their personal information exposed. But accountability work often requires exposing personal information -- the identity of corporate officers who made specific decisions, the addresses of properties owned by officials, the financial relationships between public figures and private entities.

**The public figure doctrine** (borrowed from defamation law) provides some relief: public officials and public figures have diminished privacy expectations regarding their official conduct. But the scope of this principle under data privacy law (as opposed to defamation law) is still developing.

**Best practices:**
- Focus on the conduct, not the person. Document what was done, not irrelevant personal details of who did it.
- Minimize personal data collection. Collect only what is necessary for accountability purposes.
- Secure the data you do collect. Privacy laws impose obligations to protect personal data. A breach of your own systems that exposes personal data of investigation subjects could expose you to liability.
- Understand the jurisdiction. GDPR applies differently than CCPA, and both apply differently than laws in other jurisdictions.

---

# 8. TERMS OF SERVICE AS LAW

**Risk Level: HIGH**

Terms of Service (ToS) agreements are the legal mechanism through which private platforms regulate user behavior. For civic technologists, the critical question is whether violating a platform's ToS can transform otherwise legal conduct into a federal crime under the CFAA.

## 8.1 The ToS + CFAA Problem

Before Van Buren, many federal courts held that violating a website's Terms of Service could constitute "unauthorized access" or "exceeding authorized access" under the CFAA. Under this theory, if a website's ToS says "you may not scrape this site," and you scrape it, you have "exceeded your authorized access" and committed a federal crime.

**The stakes are enormous.** Almost every major platform's Terms of Service prohibits:
- Automated access or scraping
- Creating fake accounts or misrepresenting your identity
- Accessing the site for competitive intelligence purposes
- Using the site for purposes the operator has not approved

Under the broad reading of the CFAA, virtually every OSINT investigator, security researcher, and civic technologist who uses a major platform as part of their work is arguably committing a federal crime.

## 8.2 Post-Van Buren Landscape

Van Buren narrowed the "exceeding authorized access" prong of the CFAA, but it did not directly address whether ToS violations constitute access "without authorization." Lower courts have been grappling with this question.

**Cases to watch:**

- **hiQ Labs v. LinkedIn** (discussed in Section 2.2) held that scraping publicly available data does not violate the CFAA even when the site operator has sent a cease-and-desist letter. But the Ninth Circuit's reasoning was specific to publicly available data and may not extend to data behind a login wall.
- **Sandvig v. Barr** (discussed in Section 2.2) held that CFAA does not criminalize ToS violations on publicly available websites, at least in the context of academic research.

**The current state:** The trend in federal courts is away from criminalizing ToS violations under the CFAA, but the issue is not fully settled. A researcher who creates a fake account to investigate discrimination on a platform, for example, may violate the platform's ToS (which prohibits fake accounts) and thereby access the platform "without authorization" -- a theory that some courts might still accept.

## 8.3 Platform-Specific Risks

**X/Twitter:** Terms of Service prohibit automated access, scraping, and use of the platform to create datasets. The platform has aggressively enforced these terms, including suing data scrapers and researchers. The API terms impose additional restrictions.

**Facebook/Meta:** Terms of Service prohibit fake accounts, automated access, and scraping. Meta has sued researchers who created browser extensions to collect data for academic research. The *Facebook v. Power Ventures* case (844 F.3d 1058 (9th Cir. 2016)) held that continued access after receiving a cease-and-desist letter constituted "unauthorized access" under the CFAA.

**LinkedIn:** As noted in the hiQ case, LinkedIn has aggressively litigated against scrapers, though the Ninth Circuit ruled in hiQ's favor for publicly available data.

**Google:** Terms of Service prohibit automated access and scraping. Google has taken legal action against scrapers, though it has also been more supportive of academic research access.

## 8.4 Practical Guidance

- **Read the Terms of Service** before using any platform for investigative purposes. Know what is prohibited.
- **Use official APIs** when available. API access is generally explicitly authorized and comes with clear terms.
- **Avoid creating fake accounts.** This is the most legally risky platform activity, as it involves affirmative misrepresentation to gain access.
- **Document the public interest** in your work. If you are investigated or sued, demonstrating that your work served the public interest (as opposed to commercial interest) strengthens your legal position.
- **Use publicly available data whenever possible.** The legal protections for accessing publicly available data are stronger than for data behind authentication barriers.
- **Consult with an attorney** before beginning any systematic investigation that involves a major platform.

---

# 9. INTERNATIONAL CONSIDERATIONS

**Risk Level: VARIES BY JURISDICTION**

Digital activism crosses borders. Data, code, and communications flow internationally. An investigator in the United States may be analyzing data about a British corporation, using tools developed by German privacy advocates, while communicating with sources in authoritarian countries. The legal implications are different in every jurisdiction.

## 9.1 United Kingdom

**Official Secrets Act 1989.** The UK's Official Secrets Act criminalizes the unauthorized disclosure of government information by current and former government employees and government contractors. Unlike the U.S. Espionage Act, the OSA is specifically designed for leaks (rather than espionage per se), but it is similarly harsh: no public interest defense is available. Section 5 of the OSA also criminalizes the receipt and further disclosure of leaked information by journalists and members of the public, though this provision has been rarely prosecuted.

**Computer Misuse Act 1990.** The UK's equivalent of the CFAA. Section 1 criminalizes "unauthorized access to computer material." Section 2 criminalizes unauthorized access with intent to commit further offenses. Section 3 criminalizes unauthorized modification of computer material. Like the CFAA, the CMA's definition of "unauthorized access" is broad and has been applied to cases involving publicly accessible systems.

**Investigatory Powers Act 2016 ("Snooper's Charter").** Provides legal authority for bulk data collection by UK intelligence agencies. Relevant to activists because it means UK-based communications are subject to extensive government surveillance.

**Data Protection Act 2018 (UK GDPR).** Post-Brexit, the UK has its own version of GDPR. The journalism exemption (Schedule 2, Part 5) is similar to the EU's Article 85 framework but implemented differently.

**Defamation law.** The UK has historically been a haven for defamation plaintiffs ("libel tourism") because English defamation law places the burden of proof on the defendant (unlike U.S. law, where the plaintiff must prove falsity). The Defamation Act 2013 introduced a "serious harm" requirement and strengthened defenses for publication on matters of public interest, but the UK remains a more plaintiff-friendly jurisdiction for defamation claims than the United States.

**SPEECH Act (2010).** In response to libel tourism, the U.S. enacted the Securing the Protection of our Enduring and Established Constitutional Heritage (SPEECH) Act, 28 U.S.C. Sections 4101-4105, which prohibits U.S. courts from enforcing foreign defamation judgments that are inconsistent with the First Amendment. This means a UK defamation judgment against a U.S.-based activist generally cannot be enforced in the United States.

## 9.2 European Union

**EU regulatory framework for digital rights:**

- **GDPR** (discussed in Section 7.1)
- **Digital Services Act (DSA) (2022/2065).** Imposes transparency obligations on digital platforms and provides for researcher access to platform data. Article 40 of the DSA requires very large online platforms to provide access to data for vetted researchers. This is potentially a powerful tool for civic technologists, though the vetting process and access mechanisms are still being developed.
- **Digital Markets Act (DMA) (2022/1925).** Targets "gatekeeper" platforms (Google, Apple, Meta, Amazon, Microsoft) with interoperability and data portability requirements. Relevant to civic technologists because it mandates data portability and interoperability that could facilitate independent analysis of platform data.
- **AI Act (2024/1689).** The world's first comprehensive AI regulation. Classifies AI systems by risk level and imposes transparency and accountability requirements. Relevant to civic technologists building AI-powered investigation tools.
- **EU Whistleblowing Directive (2019/1937).** Requires EU member states to establish whistleblower protection frameworks. Provides protection for individuals who report breaches of EU law through internal channels, external channels (to competent authorities), or public disclosures (in specified circumstances). Broader in scope than most U.S. whistleblower protections.

## 9.3 Press Freedom and Activist Safety by Region

The Reporters Without Borders (RSF) World Press Freedom Index provides annual rankings of press freedom by country. These rankings are a useful proxy for the legal environment facing digital activists, though the correlation is imperfect.

**Relatively safe jurisdictions for digital activism (as of 2025 rankings):**
- Nordic countries (Norway, Denmark, Sweden, Finland consistently top the rankings)
- Netherlands, Portugal, Ireland
- Canada, New Zealand

**Moderate-risk jurisdictions:**
- United States (ranked in the 40s in recent years, reflecting erosion of press freedom norms)
- United Kingdom (ranked in the 20s-30s, with concerns about the Official Secrets Act and surveillance)
- France (concerns about police violence against journalists covering protests)
- Germany (generally strong, but concerns about intelligence oversight)

**High-risk jurisdictions:**
- Russia, China, Iran, Saudi Arabia, Turkey, Egypt, India (declining)
- Any country where journalism or digital activism has been criminalized de facto or de jure

## 9.4 Cross-Border Enforcement

**Mutual Legal Assistance Treaties (MLATs).** The U.S. has MLATs with dozens of countries. These treaties allow law enforcement agencies to request assistance in investigating and prosecuting crimes that span borders. If you are a U.S.-based activist investigating a foreign corporation, the foreign government may be able to request U.S. law enforcement assistance.

**CLOUD Act (2018).** The Clarifying Lawful Overseas Use of Data Act allows U.S. law enforcement to compel U.S.-based technology companies to produce data stored overseas, and allows foreign governments with "qualifying orders" to compel U.S. companies to produce data. This has significant implications for activists who use U.S.-based services (Google, Microsoft, Apple) to store sensitive data.

**Practical implications:**
- **Use end-to-end encryption.** Services that do not store unencrypted data cannot produce it in response to legal process.
- **Understand where your data is stored.** Data stored in the EU may be subject to different legal protections than data stored in the United States.
- **Be cautious about travel.** If you have published investigative findings that embarrass a government, that government may have legal mechanisms to detain or prosecute you if you enter its jurisdiction. This is not paranoia -- it has happened to journalists and activists repeatedly.

## 9.5 Sanctions and Export Controls

U.S. sanctions law (administered by OFAC -- the Office of Foreign Assets Control) and export controls (administered by BIS -- the Bureau of Industry and Security) can create legal risks for civic technologists who provide technology, training, or support to individuals or organizations in sanctioned countries.

**OFAC sanctions** prohibit U.S. persons from providing goods, services, or technology to sanctioned individuals, entities, or countries. This can include software tools, cloud services, and technical training. There are general licenses and specific license exceptions for "internet communications" and "personal communications," but the scope of these exceptions is not always clear.

**EAR (Export Administration Regulations)** control the export of "dual-use" technology -- technology that has both civilian and military applications. Strong encryption software was historically subject to export controls (see the Bernstein case in Section 2.1). While encryption export controls have been substantially relaxed, other technologies may still be subject to control.

**Relevance:** If you are building civic technology tools and making them available to users in sanctioned countries (Iran, North Korea, Cuba, Syria, Russia, and others), you need to understand the export control implications. Many open-source licenses explicitly do not address export control compliance, leaving the obligation on the distributor.

---

# 10. LEGAL DEFENSE RESOURCES

**If you are in legal trouble, these organizations can help. Many provide free or reduced-cost representation to digital rights activists, journalists, and civic technologists.**

## 10.1 Digital Rights and Technology

**Electronic Frontier Foundation (EFF)**
- Website: https://www.eff.org
- Focus: Digital civil liberties, free speech online, privacy, innovation
- Legal services: Direct representation in impact litigation, amicus briefs, legal analysis
- Key programs: Coders' Rights Project (defending security researchers and developers), FOIA litigation, challenging surveillance
- Contact for legal help: info@eff.org

**Software Freedom Law Center (SFLC)**
- Website: https://softwarefreedom.org
- Focus: Legal representation for open-source software projects
- Services: Free legal representation for developers of free, libre, and open-source software

**Software Freedom Conservancy**
- Website: https://sfconservancy.org
- Focus: Nonprofit home for open-source projects, providing legal and organizational infrastructure

## 10.2 Press Freedom and Journalism

**Reporters Committee for Freedom of the Press (RCFP)**
- Website: https://www.rcfp.org
- Focus: Free legal resources for journalists
- Key resources: Legal defense hotline (1-800-336-4243), Open Government Guide, First Amendment handbooks, iFOIA (FOIA filing tool)
- Legal help: Free legal defense hotline available 24/7

**Freedom of the Press Foundation (FPF)**
- Website: https://freedom.press
- Focus: Protecting and supporting independent journalism
- Key programs: SecureDrop (secure whistleblowing platform), U.S. Press Freedom Tracker, digital security training for journalists

**Committee to Protect Journalists (CPJ)**
- Website: https://cpj.org
- Focus: Promoting press freedom worldwide
- Services: Journalist assistance program, safety advisories, advocacy

**Knight First Amendment Institute at Columbia University**
- Website: https://knightcolumbia.org
- Focus: First Amendment litigation and research in the digital age
- Services: Impact litigation, academic research, amicus briefs

## 10.3 Whistleblower Support

**National Whistleblower Center (NWC)**
- Website: https://www.whistleblowers.org
- Focus: Supporting whistleblowers and advancing whistleblower law
- Services: Legal referrals, educational resources, advocacy for stronger whistleblower protections

**Government Accountability Project (GAP)**
- Website: https://whistleblower.org
- Focus: Promoting government and corporate accountability through whistleblower advocacy
- Services: Legal representation for whistleblowers, advocacy, public education

**Whistleblower Network News**
- Website: https://whistleblowersblog.org
- Focus: News and analysis of whistleblower cases and policy
- Services: Information resource for potential whistleblowers

**ExposeFacts**
- Website: https://exposefacts.org
- Focus: Supporting whistleblowers who reveal information about government surveillance, war, and civil liberties violations
- Founded by: Institute for Public Accuracy

## 10.4 Civil Liberties

**American Civil Liberties Union (ACLU)**
- Website: https://www.aclu.org
- Focus: Broad civil liberties, including free speech, privacy, technology rights
- Services: Direct litigation, legislative advocacy, public education
- Key programs: Speech, Privacy, and Technology Project; National Security Project

**Brennan Center for Justice**
- Website: https://www.brennancenter.org
- Focus: Democracy, voting rights, justice reform, government accountability
- Services: Legal advocacy, policy analysis, litigation

**Electronic Privacy Information Center (EPIC)**
- Website: https://epic.org
- Focus: Privacy and civil liberties in the digital age
- Services: Litigation, advocacy, FOIA requests, policy analysis

## 10.5 International

**Access Now**
- Website: https://www.accessnow.org
- Focus: Digital rights worldwide
- Services: Digital Security Helpline (24/7 assistance for activists, journalists, and human rights defenders facing digital threats), policy advocacy, RightsCon conference

**Article 19**
- Website: https://www.article19.org
- Focus: Freedom of expression and information worldwide (named for Article 19 of the Universal Declaration of Human Rights)
- Services: Legal analysis, advocacy, litigation support

**Citizen Lab (University of Toronto)**
- Website: https://citizenlab.ca
- Focus: Research on digital threats to civil society, including surveillance technology, internet censorship, and targeted attacks
- Services: Research publications, technical analysis, expert testimony

**Digital Defenders Partnership**
- Website: https://www.digitaldefenders.org
- Focus: Rapid-response grants and support for human rights defenders under digital threat
- Services: Emergency grants for digital security, sustainable protection grants

---

# APPENDIX A: QUICK REFERENCE -- RISK ASSESSMENT BY ACTIVITY

| Activity | Legal Risk (U.S.) | Primary Law | Notes |
|----------|-------------------|-------------|-------|
| Analyzing public records | LOW | FOIA, state open records | Core protected activity |
| Filing FOIA requests | LOW | 5 U.S.C. Section 552 | Any person can file |
| Publishing investigative findings | LOW-MEDIUM | First Amendment | Higher risk if information was illegally obtained |
| Scraping publicly available websites | MEDIUM | CFAA, Copyright | Stronger post-hiQ, but not fully settled |
| Creating fake accounts for investigation | HIGH | CFAA, platform ToS | Affirmative misrepresentation increases risk |
| Circumventing access controls | HIGH-CRITICAL | CFAA, DMCA | Even technical controls like CAPTCHAs |
| Disclosing classified information | CRITICAL | Espionage Act | No public interest defense |
| Accessing non-public systems without permission | CRITICAL | CFAA | Federal felony |
| Reporting securities fraud to SEC | LOW | Dodd-Frank | Protected and potentially rewarded |
| Building and distributing security tools | MEDIUM | CFAA, DMCA | Depends on tool's purpose and marketing |
| Vulnerability disclosure | MEDIUM | CFAA | Safer with coordinated disclosure programs |
| Receiving leaked documents | LOW-MEDIUM | First Amendment | Bartnicki v. Vopper provides some protection |
| Cross-border data transfer | MEDIUM | GDPR, CLOUD Act | Jurisdiction-dependent |

---

# APPENDIX B: KEY CASE LAW QUICK REFERENCE

| Case | Year | Court | Holding | Significance |
|------|------|-------|---------|--------------|
| Bernstein v. United States | 1999 | 9th Cir. | Source code is protected speech | First Amendment protects code |
| New York Times v. United States | 1971 | SCOTUS | Prior restraint on publication unconstitutional | Pentagon Papers; press freedom |
| Bartnicki v. Vopper | 2001 | SCOTUS | Publishing lawfully obtained information on public concern is protected | Protects journalists who receive leaked info |
| Van Buren v. United States | 2021 | SCOTUS | "Exceeding authorized access" means accessing off-limits areas, not misusing permitted access | Narrowed CFAA |
| hiQ Labs v. LinkedIn | 2022 | 9th Cir. | Scraping publicly available data likely does not violate CFAA | Protects web scraping |
| Garcetti v. Ceballos | 2006 | SCOTUS | Employee speech pursuant to official duties not protected by 1A | Limits government employee whistleblowing |
| Food Marketing Institute v. Argus Leader | 2019 | SCOTUS | FOIA Exemption 4 covers information "customarily kept private" | Broadened FOIA Exemption 4 |
| Digital Realty v. Somers | 2018 | SCOTUS | Dodd-Frank anti-retaliation requires SEC reporting | Must report to SEC for Dodd-Frank protection |
| Near v. Minnesota | 1931 | SCOTUS | Prior restraint is presumptively unconstitutional | Foundation of press freedom |

---

# APPENDIX C: TIMELINE OF KEY LEGAL DEVELOPMENTS

- **1966** -- Freedom of Information Act enacted
- **1971** -- Pentagon Papers case (New York Times Co. v. United States)
- **1986** -- Computer Fraud and Abuse Act enacted
- **1989** -- UK Official Secrets Act
- **1990** -- UK Computer Misuse Act
- **1996** -- Bernstein v. United States (code as speech)
- **1998** -- Digital Millennium Copyright Act (DMCA) enacted
- **2001** -- Bartnicki v. Vopper (publication of leaked information)
- **2002** -- Sarbanes-Oxley Act (corporate whistleblower protections)
- **2006** -- Garcetti v. Ceballos (government employee speech)
- **2010** -- Dodd-Frank Act (SEC Whistleblower Program)
- **2010** -- SPEECH Act (protects against foreign libel tourism)
- **2011** -- Aaron Swartz arrested; charged under CFAA
- **2012** -- Whistleblower Protection Enhancement Act
- **2013** -- Aaron Swartz dies; Edward Snowden disclosures
- **2014** -- Weev conviction reversed (on venue grounds)
- **2016** -- EU General Data Protection Regulation adopted (effective 2018)
- **2017** -- Reality Winner arrested
- **2018** -- California Consumer Privacy Act enacted (effective 2020)
- **2018** -- CLOUD Act enacted
- **2019** -- EU Whistleblowing Directive
- **2020** -- Sandvig v. Barr (CFAA does not criminalize ToS violations for research)
- **2020** -- California Privacy Rights Act (effective 2023)
- **2021** -- Van Buren v. United States (Supreme Court narrows CFAA)
- **2022** -- hiQ Labs v. LinkedIn (Ninth Circuit, scraping public data)
- **2022** -- EU Digital Services Act and Digital Markets Act
- **2024** -- EU AI Act
- **2024** -- Edward Snowden pardoned

---

# APPENDIX D: FURTHER READING

**Books:**
- *The Hacker Crackdown: Law and Disorder on the Electronic Frontier* by Bruce Sterling (1992) -- historical context for computer crime law
- *This Machine Kills Secrets* by Andy Greenberg (2012) -- history of digital whistleblowing
- *No Place to Hide* by Glenn Greenwald (2014) -- the Snowden disclosures and surveillance law
- *Habeas Data: Privacy vs. the Rise of Surveillance Tech* by Cyrus Farivar (2018) -- privacy law and technology
- *Fancy Bear Goes Phishing* by Scott Shapiro (2023) -- cybersecurity, law, and hacking history

**Academic Resources:**
- Harvard Cyberlaw Clinic: https://clinic.cyber.harvard.edu
- Stanford Center for Internet and Society: https://cyberlaw.stanford.edu
- Berkman Klein Center for Internet & Society: https://cyber.harvard.edu
- Oxford Internet Institute: https://www.oii.ox.ac.uk

**Legal Databases:**
- PACER (Public Access to Court Electronic Records): https://pacer.uscourts.gov (federal court filings)
- Google Scholar (case law search): https://scholar.google.com
- CourtListener: https://www.courtlistener.com (free legal research)
- RECAP: https://free.law/recap (free access to PACER documents)

---

*This document is part of the Cleansing Fire Project. It is intended as educational material for civic technologists and is not legal advice. For legal advice specific to your situation, consult a licensed attorney in your jurisdiction. The legal landscape described here is current as of the research date but may have changed. Laws are amended, cases are decided, and regulations are issued continuously. Verify current law before relying on any information in this document.*

*The organizations listed in Section 10 are not affiliated with the Cleansing Fire Project. Their inclusion is based on their public missions and track records. Listings do not constitute endorsement by those organizations of this project or its goals.*

---

> "Know the law. Use the law. Change the law. And when the law is unjust, break it consciously, with full knowledge of the consequences, and make the breaking itself an argument for reform." -- Pyrrhic Lucidity, applied to civil disobedience
