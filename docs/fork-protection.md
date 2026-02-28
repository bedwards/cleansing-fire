# Fork Protection: Enabling Extension Without Corruption

## The Cleansing Fire Project

---

## The Core Tension

Cleansing Fire is designed to be forked. That is the point. Decentralized technology that cannot be extended, adapted, and taken in directions its founders did not anticipate is not decentralized -- it is a franchise. But a project whose core principles can be silently hollowed out by bad actors is not resilient -- it is naive.

This document addresses the hardest design problem in open-source governance: how do you enable radical extensibility while protecting against the corruption of foundational principles? The answer, consistent with Pyrrhic Lucidity, is that you cannot solve this problem perfectly. But you can make corruption expensive, visible, and structurally difficult -- which is all any accountability system can ever do.

---

## 1. The Threat Model

### 1.1 Direct Attacks

**Malicious forking.** An actor forks the project, introduces backdoors or surveillance capabilities, and distributes the fork as though it were the authentic project. This is the simplest attack and the easiest to detect -- but only if detection infrastructure exists.

**Trojan features.** Useful code contributions that contain hidden functionality: data exfiltration, cryptographic weaknesses, phone-home mechanisms, or kill switches. The contribution passes code review because the malicious payload is buried in a large, complex diff or hidden in a dependency.

**Supply chain attacks.** Compromising upstream dependencies rather than the project itself. If the project relies on a library, and that library is compromised, the project inherits the compromise. The xz/liblzma attack of 2024 demonstrated this can be executed with extreme sophistication over years of patient social engineering.

### 1.2 Subtle Corruption

**Philosophical drift.** The most dangerous attack is not a backdoor but a slow redefinition. Principles are "clarified" in ways that subtly shift their meaning. "Transparent Mechanism" is interpreted to mean "transparent to authorized auditors" rather than "transparent to those subject to the mechanism." "Minimum Viable Coercion" is reinterpreted as justification for expanding coercion. Each individual change is small enough to seem reasonable. The cumulative effect is co-optation.

**Sybil attacks.** Creating many fake identities to simulate community consensus. A bad actor creates 50 GitHub accounts, each contributing small legitimate patches to establish credibility, then uses the collective weight to push through a principle-undermining change that appears to have broad community support.

**Tone policing as weapon.** Using the project's own commitment to adversarial collaboration (Principle 4) to demand that criticism of corruption be silenced as "not constructive." This is a specific instantiation of the more general attack: using a system's own values as the vector for corrupting those values.

### 1.3 Social Engineering

**Maintainer capture.** A patient actor builds trust over months or years of legitimate contribution, earns commit access, then uses that access to make changes that serve external interests. This is not speculative -- it is the documented methodology of the xz attack.

**Community exhaustion.** Flooding the project with issues, PRs, and demands that exhaust the maintainers' capacity for review. In the resulting overwhelm, malicious changes slip through because no one has the energy to scrutinize them.

**Fork-and-surround.** Creating a fork that is better-funded, better-marketed, and more user-friendly than the original, drawing away the community. The fork gradually diverges from core principles, but by the time this is visible, the original project has been marginalized.

### 1.4 State and Corporate Actor Interference

**Regulatory capture.** Governments or corporations use legal mechanisms (export controls, platform policies, financial regulations) to force changes that undermine the project's purpose. "We would love to keep the transparency features, but legal requires us to add this compliance module."

**Funding co-optation.** A corporate entity offers funding or infrastructure support, then uses the dependency to influence project direction. "We are happy to sponsor the project, but our legal team has concerns about the corporate power mapping module."

**Infiltration.** Intelligence agencies or corporate security teams placing operatives in the contributor community. This is documented practice for physical activist groups; there is no reason to believe open-source projects are exempt.

---

## 2. Technical Fork Protection

### 2.1 Cryptographic Integrity

**Commit signing.** All commits to the canonical repository must be GPG-signed. Unsigned commits are rejected by CI. This establishes a chain of attribution: every change can be traced to a specific key, and that key can be traced to a specific identity through the project's web of trust.

**Release signing.** Tagged releases are signed with the project's release key. The release key is held by multiple maintainers in a threshold scheme (e.g., 3-of-5 required to sign). This prevents a single compromised maintainer from issuing a malicious release.

**Key rotation.** Signing keys have defined expiration dates and rotation procedures. A key that never rotates is a key that accumulates risk over time. The rotation procedure itself is documented and transparent (Principle 3).

### 2.2 Content Hashing and Integrity Manifests

The project maintains an `integrity-manifest.json` at the repository root. This manifest contains:

- SHA-256 hashes of all protected files (CLAUDE.md, philosophy.md, core configuration)
- Required phrases that must appear in protected files
- The names of the 7 Principles (which must appear in CLAUDE.md)
- A version number for the manifest format itself

The `scripts/verify-integrity.sh` script checks the manifest against the actual files. This script runs:

- On every commit (via pre-commit hook)
- On every CI build (via GitHub Actions)
- On demand by any contributor or user

The manifest is itself a protected file. Changes to the manifest require explicit justification and trigger additional review.

### 2.3 Canary Files

Certain files are designated as **canaries**: they must remain unchanged between releases. Any modification triggers an alert. The canary set includes:

- `philosophy.md` Part II (The Seven Principles) -- the constitutional core
- The principle statements in `CLAUDE.md`
- The integrity manifest itself

A canary file can be legitimately updated, but the update requires:
1. A separate PR that modifies only the canary file
2. Explicit justification for the change
3. Review by at least two maintainers who did not author the change
4. Update of the integrity manifest in the same PR

### 2.4 Automated Audit

The `verify-integrity.sh` script performs the following checks:

1. **Hash verification.** Computes SHA-256 of each protected file and compares against the manifest.
2. **Principle presence.** Confirms that all 7 Principle names appear in CLAUDE.md.
3. **Key phrase verification.** Confirms that essential philosophical phrases appear in philosophy.md. These are phrases whose removal would indicate corruption of the framework.
4. **Manifest self-check.** Verifies the manifest is valid JSON with the expected structure.

The script outputs a clear PASS/FAIL report with specific details on any failures. It exits with code 0 on success and code 1 on failure, making it suitable for CI/CD integration.

### 2.5 Git Hooks

A pre-commit hook runs `verify-integrity.sh` before every commit. If integrity checks fail, the commit is blocked with an explanation of what failed and why.

The hook can be bypassed (git commit --no-verify), but:
- CI will catch the violation
- The bypass itself is visible in the commit history (no hook signature)
- The project's contribution guide explicitly states that bypassing hooks is a red flag

### 2.6 CI/CD Pipeline Checks

GitHub Actions workflow:

```yaml
name: Integrity Check
on: [push, pull_request]
jobs:
  verify-integrity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify project integrity
        run: ./scripts/verify-integrity.sh
      - name: Verify commit signatures
        run: |
          # Check that the latest commit is signed
          git log --format='%G?' -1 | grep -q '[GU]' || \
            echo "WARNING: Latest commit is not GPG-signed"
```

### 2.7 Reproducible Builds

For any compiled or bundled artifacts:
- Build process is fully documented and scripted
- Build inputs are pinned (specific versions, hashed dependencies)
- Build output can be independently reproduced by any party
- Build signatures attest to the specific source commit and build environment

This prevents injection at build time -- a class of attack where the source is clean but the distributed artifact is compromised.

---

## 3. Philosophical Fork Protection

### 3.1 The Seven Principles as Constitutional Anchors

The 7 Principles of Pyrrhic Lucidity function as the project's constitution. They are not immutable -- no principle should be -- but they are protected by a higher amendment threshold than ordinary code or documentation changes.

The principles, in brief:
1. **Lucidity Before Liberation** -- see clearly before acting
2. **Relational Agency** -- the unit of action is relationship patterns
3. **Transparent Mechanism** -- legitimacy requires visible, comprehensible mechanisms
4. **Adversarial Collaboration** -- groups that cannot tolerate dissent are captured
5. **Minimum Viable Coercion** -- necessary sometimes, always corrupting, always minimized
6. **Recursive Accountability** -- liberators face accountability at least as rigorous as what they impose
7. **Differential Solidarity** -- weight toward the most exposed without essentializing

### 3.2 Extension vs. Corruption: A Decision Framework

The critical question for any fork or modification: is this an extension of the principles or a corruption of them?

**A change is an extension when:**
- It applies the existing principles to a new domain or context
- It adds capabilities without removing constraints
- It increases transparency, accountability, or accessibility
- It subjects itself to the same scrutiny it applies to others
- It costs the actor something (the cost heuristic)

**A change is corruption when:**
- It removes or weakens an existing constraint
- It creates exceptions for the actor ("we need flexibility during the transition")
- It reduces transparency, accountability, or accessibility
- It exempts itself from the scrutiny it applies to others
- It costs the actor nothing, or benefits them materially

**The gray zone:** Many changes will not be clearly one or the other. This is where the decision calculus from philosophy.md Part IV applies:
1. Map the conflict explicitly
2. Identify who bears the cost
3. Apply the reversibility test
4. Subject the decision to adversarial review
5. Document and commit to reassessment

### 3.3 Recursive Accountability Applied to the Project Itself

Principle 6 (Recursive Accountability) demands that the project apply its own standards to itself with at least as much rigor as it applies to external power structures. Concretely:

- The project's governance decisions are public and documented
- Maintainers can be removed through transparent processes
- The integrity checking system itself can be audited and challenged
- No contributor, regardless of seniority, is exempt from review
- The absence of internal challenges is treated as evidence of capture, not health

### 3.4 The Rigidity Paradox

**The paradox:** A system that protects its principles too rigidly becomes brittle and unable to adapt. A system that protects them too loosely loses its identity. How do you avoid both?

**The resolution:** Protect the meta-principles, not the specific implementations.

The 7 Principles are meta-principles -- they describe *how* to make decisions, not *what* decisions to make. "Transparent Mechanism" does not specify which transparency tools to use; it specifies that legitimacy requires transparency. "Adversarial Collaboration" does not specify the format of dissent; it specifies that dissent must be structurally possible.

This means:
- The principle *names* and *core statements* are protected (canary files)
- The *operational implementations* of the principles can and should evolve
- The *operational tests* at the end of each principle can be refined as experience accumulates
- New principles can be added (though this is a high-threshold change)
- No principle can be removed (this is the one truly rigid constraint)

The justification for this asymmetry: adding a principle increases the constraints on the project. Removing a principle decreases them. In a system designed to prevent the accumulation of unchecked power, the bar for decreasing constraints should be much higher than the bar for increasing them.

---

## 4. Multi-Claude Coordination

### 4.1 How Multiple Claude Instances Work on This Project

The Cleansing Fire architecture uses Claude Code (Opus) as the orchestrator brain. Multiple Claude instances can operate simultaneously:

- **Interactive sessions**: A human works with Claude through the CLI
- **Background workers**: Claude instances in isolated git worktrees, performing implementation or review tasks
- **Fork instances**: Other Claude instances working on forks of the project

Each instance reads `CLAUDE.md` as its operating constitution. This file is the shared reference point that ensures all instances operate from the same foundational principles.

### 4.2 CLAUDE.md as Shared Constitution

When a Claude instance opens the project, it reads `CLAUDE.md` first. This file contains:
- The 7 Principles
- The project mission
- Architecture and workflow conventions
- The fork protection notice
- The cost heuristic

This means `CLAUDE.md` is the single most important file for multi-Claude coordination. Its integrity is paramount. If `CLAUDE.md` is corrupted, every subsequent Claude instance that reads it will operate from a corrupted foundation.

This is why `CLAUDE.md` is the first file checked in the integrity verification script.

### 4.3 How a New Claude Instance Validates Authenticity

When a Claude instance begins working on the project (or a fork), it should:

1. **Run `scripts/verify-integrity.sh`** -- confirm that core files match the expected hashes
2. **Read `integrity-manifest.json`** -- understand which files are protected and why
3. **Check for the 7 Principles in CLAUDE.md** -- confirm the constitutional core is intact
4. **Check philosophy.md for key phrases** -- confirm the philosophical framework has not been subtly rewritten
5. **Verify the git history** -- check that the repository has a plausible commit history with signed commits

If any of these checks fail, the Claude instance should:
- Alert the human operator
- Refuse to make changes until the integrity issue is resolved
- Document the specific failure for investigation

### 4.4 Detecting Prompt Injection

A Claude instance working on this project could be targeted by prompt injection -- hidden instructions in files, issues, or PR descriptions designed to make Claude act against the project's principles.

Defenses:
- **Principle awareness**: Claude instances that have internalized the 7 Principles are more resistant to instructions that violate them
- **The cost heuristic**: Instructions that make things "easier" or remove constraints are structurally suspect
- **Verification before action**: Run integrity checks before making changes, not just after
- **Separation of concerns**: Implementation and review are always in separate worker instances (prevents a compromised implementation worker from also approving its own code)

---

## 5. The Web of Trust Model

### 5.1 Precedents

The problem of distributed trust without central authority has been addressed by several systems. Each offers lessons:

**PGP Web of Trust.** Users sign each other's keys, creating a decentralized graph of trust relationships. Strengths: no central authority, trust is transitive. Weaknesses: poor usability, key management is burdensome, the "web" in practice clusters around a few highly-connected signers (de facto centralization). Lesson: any trust system that requires significant manual effort from every participant will centralize around those with the most time and motivation.

**Certificate Transparency (CT) Logs.** Append-only public logs of all TLS certificates issued by certificate authorities. Any CA can issue a certificate, but the issuance is publicly logged and can be audited. Strengths: does not prevent bad certificates from being issued, but makes their issuance visible. Weaknesses: relies on monitors actually watching the logs. Lesson: transparency is not sufficient without active monitoring, but it is a prerequisite for accountability.

**Keybase Model (pre-acquisition).** Linked cryptographic identity across platforms: prove you control a GitHub account, a Twitter account, a domain, etc., and all proofs are publicly verifiable. Strengths: made key verification accessible and multi-platform. Weaknesses: Zoom acquired Keybase in 2020 and it has been effectively abandoned. Lesson: centralized stewardship of decentralized infrastructure is a single point of failure.

**Debian Package Signing.** Developers have GPG keys in a keyring maintained by the project. Packages must be signed by a key in the keyring. New keys are added through a process involving in-person key signing and existing developer vouching. Strengths: well-tested over decades, high barrier to entry reduces Sybil attacks. Weaknesses: key signing parties are geographically constrained, the process is slow. Lesson: high-trust systems work but scale slowly.

**Linux Kernel Commit Signing.** Linus Torvalds' key is the root of trust. Subsystem maintainers have signed keys. The chain of trust follows the maintainer hierarchy. Strengths: clear authority, scalable through hierarchy. Weaknesses: single point of trust at the root, hierarchy can become political. Lesson: hierarchical trust is efficient but requires the root to be incorruptible (or replaceable).

**Tor Consensus.** Directory authorities (currently 9) vote on the state of the network. A consensus document is produced when a majority agrees. Strengths: no single authority can dictate the network state. Weaknesses: the directory authorities are a small, fixed set of known entities -- a pressure point for state actors. Lesson: small trust sets are both a strength (manageable) and a weakness (targetable).

### 5.2 The Cleansing Fire Trust Model

Drawing from these precedents, the project's trust model:

**Integrity manifest as trust anchor.** The `integrity-manifest.json` file, cryptographically signed and version-controlled, serves as the project's certificate of authenticity. Any fork can be compared against the manifest to determine whether its core files are intact.

**Transparent audit trail.** All changes to protected files are logged, justified, and publicly reviewable. This follows the Certificate Transparency model: you cannot prevent unauthorized changes, but you can make them visible.

**Multi-party verification.** Changes to protected files require review from multiple maintainers, following the threshold scheme model. No single actor can unilaterally modify the constitution.

**Fork certification.** A fork can demonstrate alignment with the core principles by:
1. Passing the `verify-integrity.sh` checks against the canonical manifest
2. Maintaining the 7 Principles in its own CLAUDE.md
3. Preserving the integrity checking infrastructure itself
4. Publishing its own audit trail of changes to protected files

Forks that pass these checks can display a "Verified Alignment" status. This is not a guarantee -- a fork could pass these checks while harboring malicious code elsewhere -- but it establishes a minimum bar.

**The critical insight:** Trust is not binary. A fork can be trusted along some dimensions and not others. The integrity manifest verifies alignment with core principles. Code review verifies technical safety. Community reputation verifies good faith. No single mechanism is sufficient. All are necessary.

---

## 6. Implementation

### 6.1 The verify-integrity.sh Script

Located at `scripts/verify-integrity.sh`, this script:

1. Reads `integrity-manifest.json` from the repository root
2. Computes SHA-256 hashes of all files listed in the manifest's `protected_files` section
3. Compares computed hashes against expected hashes
4. Checks that all 7 Principle names appear in CLAUDE.md
5. Checks that key philosophical phrases appear in philosophy.md
6. Outputs a structured PASS/FAIL report
7. Exits with code 0 (all checks pass) or code 1 (any check fails)

The script uses only standard Unix tools (`shasum`, `grep`, `jq` or pure shell JSON parsing) and runs on both macOS and Linux.

### 6.2 The integrity-manifest.json

Located at the repository root, this file contains:

```json
{
  "manifest_version": "1.0.0",
  "project": "cleansing-fire",
  "description": "Integrity manifest for fork protection",
  "protected_files": { ... },
  "required_principles": [ ... ],
  "required_phrases": [ ... ]
}
```

- `protected_files`: Map of file paths to their SHA-256 hashes
- `required_principles`: The 7 Principle names that must appear in CLAUDE.md
- `required_phrases`: Key phrases from philosophy.md whose removal would indicate corruption

### 6.3 Updating the Manifest

When a protected file is legitimately changed:

1. Make the change in a feature branch
2. Run `scripts/verify-integrity.sh --update` to regenerate hashes (planned feature)
3. The PR must include both the file change and the manifest update
4. The PR description must explain why the protected file was modified
5. The PR requires review from at least two maintainers

### 6.4 Fork Alignment Badges

A fork can demonstrate alignment by:
1. Including `integrity-manifest.json` (either the canonical version or a derivative that references it)
2. Passing `verify-integrity.sh` in CI
3. Linking back to the canonical repository as the upstream source

The project may in the future publish a GitHub Action that forks can use to verify alignment and display a badge. This is not a seal of approval for the fork's code -- only for its alignment with the foundational principles.

### 6.5 What This System Cannot Do

Honest accounting of limitations (per Principle 1):

- **It cannot prevent malicious forks from existing.** It can only make it possible to distinguish them from aligned forks.
- **It cannot detect sophisticated code-level attacks.** Hash checking verifies principle files, not every line of code. Code review remains essential.
- **It cannot prevent philosophical drift in interpretations.** Two people can read the same principle and apply it differently. The system verifies the text exists, not that it is correctly understood.
- **It cannot replace human judgment.** The integrity system is a tool for humans and Claude instances to use, not a replacement for careful evaluation.
- **It can itself be corrupted.** If the integrity checking system is compromised, all downstream checks are meaningless. This is why the system must be simple enough to audit by inspection and why its own integrity is verified as part of the check.

This is the Cost Heuristic applied to our own tools: if the integrity system gives us a false sense of security -- if it makes us feel safe without actually being safe -- it has become a vector for the very corruption it was designed to prevent. The system must be treated as a floor, not a ceiling. It is the minimum. It is not sufficient.

---

## 7. Summary

The fork protection system operates on three layers:

1. **Technical**: Cryptographic hashes, signed commits, automated verification scripts, CI/CD integration
2. **Procedural**: Multi-party review for protected file changes, documented justification, transparent audit trails
3. **Philosophical**: The 7 Principles as constitutional anchors, the extension-vs-corruption framework, recursive accountability applied to the project itself

No single layer is sufficient. All three together create a system that makes corruption expensive, visible, and structurally difficult -- though never impossible. That honesty about limitations is itself a form of protection: a system that claims to be incorruptible has already failed Principle 1.

The ultimate protection is not any technical mechanism but the community of people and Claude instances who understand these principles deeply enough to recognize when they are being violated -- including when the violation comes wrapped in the language of the principles themselves.

---

*This document is itself a protected file. Changes to it trigger integrity alerts and require multi-party review.*
