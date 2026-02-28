# Game Theory, Mechanism Design, and Incentive Structures for Cleansing Fire

## Designing Systems Where Cooperation Dominates Defection and Power Distributes Rather Than Concentrates

Research Date: 2026-02-28

---

## Table of Contents

1. [Part I: Classical Game Theory -- When Does Cooperation Emerge?](#part-i-classical-game-theory----when-does-cooperation-emerge)
2. [Part II: Mechanism Design -- Engineering Incentive Structures](#part-ii-mechanism-design----engineering-incentive-structures)
3. [Part III: Real-World Mechanism Design -- What Actually Works](#part-iii-real-world-mechanism-design----what-actually-works)
4. [Part IV: Network Effects and Power Laws](#part-iv-network-effects-and-power-laws)
5. [Part V: Cryptoeconomics -- Lessons From the Field](#part-v-cryptoeconomics----lessons-from-the-field)
6. [Part VI: The Cleansing Fire Mechanisms (Original Designs)](#part-vi-the-cleansing-fire-mechanisms-original-designs)
7. [Part VII: Impossibility Results and Design Constraints](#part-vii-impossibility-results-and-design-constraints)
8. [Part VIII: Implementation Roadmap](#part-viii-implementation-roadmap)

---

## Part I: Classical Game Theory -- When Does Cooperation Emerge?

The central question for Cleansing Fire is not "How do we make people good?" but "How do we design systems where the rational self-interested move IS the cooperative move?" This is the question game theory was built to answer.

### 1.1 The Prisoner's Dilemma and Its Lessons

The Prisoner's Dilemma (PD) is the canonical model of the tension between individual rationality and collective welfare.

**The Stage Game:**

|              | Cooperate (C) | Defect (D)    |
|--------------|---------------|---------------|
| **Cooperate** | (R, R)        | (S, T)        |
| **Defect**    | (T, S)        | (P, P)        |

Where T > R > P > S (Temptation > Reward > Punishment > Sucker's payoff), and additionally 2R > T + S (mutual cooperation is more efficient than alternating exploitation).

**Standard parameterization:** T = 5, R = 3, P = 1, S = 0.

In the one-shot game, defection is the dominant strategy for both players. Both players defect, receiving payoff (1, 1) instead of the mutually-preferred (3, 3). This is the fundamental tragedy: individual rationality produces collective irrationality.

**The insight for Cleansing Fire:** The one-shot PD is the model for every interaction where parties cannot verify behavior, cannot punish defection, and cannot build reputation. The goal is to transform institutional interactions from one-shot games into repeated games with observable actions.

### 1.2 Axelrod's Tournaments: What Wins?

Robert Axelrod's computer tournaments (1980, 1984) asked: in a repeated Prisoner's Dilemma, what strategy performs best against a diverse field of opponents?

**Key results:**

The winner, submitted by Anatol Rapoport, was **Tit-for-Tat (TFT)**: cooperate on the first move, then copy whatever the opponent did on the previous move. TFT won both tournaments.

**Why TFT wins -- four properties:**

1. **Nice:** Never the first to defect. This avoids unnecessary conflict.
2. **Retaliatory:** Immediately punishes defection. This discourages exploitation.
3. **Forgiving:** Returns to cooperation after a single retaliatory defection. This prevents vendetta spirals.
4. **Clear:** Its behavior is easily understood by opponents. This facilitates coordination.

**Subsequent refinements:**

- **Generous Tit-for-Tat (GTFT):** Cooperates on the first move, copies the opponent's last move, but occasionally cooperates even after the opponent defects (with probability p, typically 0.05-0.33). This breaks error cascades in noisy environments.

- **Win-Stay-Lose-Shift (WSLS, also called Pavlov):** Repeat your previous action if the outcome was favorable (R or T); switch if unfavorable (P or S). In noise-free environments, WSLS can outperform TFT because it can exploit unconditional cooperators while still maintaining mutual cooperation.

**The deeper lesson:** The most robust strategies are not maximally exploitative. They are strategies that create an environment in which cooperation is the best response. TFT does not "win" by beating opponents -- it wins by eliciting cooperation from them. The strategy's success depends on the ecology of other strategies present.

A 2025 reproduction of Axelrod's second tournament using the original surviving Fortran implementations, compiled with modern tools and verified against the Axelrod-Python library, confirmed the original findings: TFT prevails, and successful play tends to be cooperative, responsive to defection, and willing to forgive.

**For Cleansing Fire:** Design systems where the "nice + retaliatory + forgiving + clear" strategy profile is structurally rewarded. Make defection observable, punishment swift, forgiveness available, and rules transparent.

### 1.3 Nowak's Five Mechanisms for the Evolution of Cooperation

Martin Nowak (Science, 2006) identified five distinct mechanisms by which natural selection can favor cooperation over defection. For each mechanism, cooperation evolves when the benefit-to-cost ratio b/c exceeds a critical threshold.

**Mechanism 1: Kin Selection (Hamilton's Rule)**

Cooperation evolves when:

```
b/c > 1/r
```

where r is the coefficient of genetic relatedness. For siblings, r = 1/2, so cooperation evolves when b > 2c.

*Applicability to Cleansing Fire:* Limited directly (we are not designing for genetic relatives), but the principle generalizes: cooperation is easier among parties with shared "fitness" -- i.e., parties whose success is correlated. Design systems where participants' outcomes are structurally linked.

**Mechanism 2: Direct Reciprocity**

Cooperation evolves when:

```
b/c > 1/w
```

where w is the probability of another encounter between the same two individuals. When w is high (repeated interaction is likely), cooperation can be sustained.

*Applicability:* This is the core mechanism. Design systems where participants interact repeatedly, where exit is possible but costly, and where the shadow of the future is long.

**Mechanism 3: Indirect Reciprocity**

Cooperation evolves when:

```
b/c > 1/q
```

where q is the probability that the recipient's reputation is known to the donor. Cooperation is sustained by reputation: "I help you not because you helped me, but because you helped others."

*Applicability:* This is the mechanism behind the Trust Calculus (Section 6.3). Design systems with transparent reputation tracking where a node's history of cooperative behavior is visible to potential partners.

**Mechanism 4: Network Reciprocity (Spatial Selection)**

Cooperation evolves when:

```
b/c > k
```

where k is the average number of neighbors in the network. On sparse networks (low k), clusters of cooperators can form and outcompete defectors because cooperators interact primarily with other cooperators.

*Applicability:* This is critical for network topology design. Dense, fully-connected networks make cooperation harder. Sparse, clustered networks make cooperation easier. Design for small-world topology: high clustering, short path lengths, moderate connectivity.

**Mechanism 5: Group Selection (Multilevel Selection)**

Cooperation evolves when:

```
b/c > 1 + (n/m)
```

where n is the group size and m is the number of groups. Groups with more cooperators outcompete groups with more defectors, but within groups, defectors outcompete cooperators.

*Applicability:* Design systems with multiple competing groups (guilds, working groups, chapters) where inter-group competition rewards cooperation within groups. The Seasonal Reset (Section 6.6) leverages this by periodically reorganizing group boundaries.

### 1.4 The Folk Theorem: Why Iteration Changes Everything

**Formal Statement:** In an infinitely repeated game (or a game with unknown endpoint), any feasible payoff profile that strictly dominates the minimax payoff profile can be sustained as a subgame perfect Nash equilibrium, provided the discount factor delta is sufficiently close to 1.

**Mathematically:** For a stage game with minimax payoff vector m = (m_1, ..., m_n), the set of subgame perfect equilibrium payoff vectors of the infinitely repeated game is:

```
E(delta) = {v in F : v_i >= m_i for all i}
```

when delta -> 1, where F is the set of feasible payoff vectors (the convex hull of stage-game payoff profiles).

**What this means in plain language:** In a one-shot game, defection may be the only equilibrium. In a repeated game with patient players, virtually ANY outcome between mutual cooperation and mutual defection can be sustained as an equilibrium -- including mutual cooperation.

**The crucial condition:** The discount factor delta must be high enough. Delta represents how much players value future payoffs relative to present ones. When delta is close to 1 (the future matters almost as much as the present), cooperation can be sustained. When delta is close to 0 (the future is heavily discounted), only the one-shot equilibrium survives.

For the standard PD with T=5, R=3, P=1, S=0, cooperation via a grim trigger strategy (cooperate until the opponent defects, then defect forever) is sustainable when:

```
delta >= (T - R) / (T - P) = (5 - 3) / (5 - 1) = 1/2
```

**For Cleansing Fire:** Design systems where the shadow of the future is long. This means:
- Make interactions repeated and ongoing (not one-shot)
- Make exit costly but not impossible (some exit cost keeps delta high)
- Ensure that future benefits of cooperation exceed present benefits of defection
- Make the end of the game uncertain (known endpoints cause backward-induction unraveling)

### 1.5 Schelling Focal Points: Coordination Without Communication

Thomas Schelling (1960) demonstrated that people can coordinate their behavior without explicit communication by converging on "focal points" -- solutions that are salient, prominent, or natural given the shared context.

**Classic example:** "You must meet a stranger in New York City tomorrow. You cannot communicate beforehand. Where and when do you go?" Most respondents answered: "Noon at Grand Central Terminal." There is nothing game-theoretically special about this answer -- it is made special by shared cultural knowledge.

**The formal structure:** In a pure coordination game (where all parties want to coordinate but have no dominant strategy), payoffs are:

|              | Strategy A | Strategy B |
|--------------|------------|------------|
| **Strategy A** | (1, 1)     | (0, 0)     |
| **Strategy B** | (0, 0)     | (1, 1)     |

Both (A, A) and (B, B) are Nash equilibria. Schelling points determine WHICH equilibrium is selected, based on salience rather than payoff structure.

**For Cleansing Fire:** Protocol design creates Schelling points. When the protocol specifies a default behavior, a standard format, a canonical process, it creates focal points that enable decentralized coordination without requiring centralized command. The protocol IS the Schelling point. This is why "not a platform -- a protocol" is the correct architectural choice. Platforms require centralized coordination. Protocols create focal points for decentralized coordination.

---

## Part II: Mechanism Design -- Engineering Incentive Structures

Mechanism design is "reverse game theory." Instead of analyzing a given game, we design the game so that the equilibrium we want is the one that rational agents will play.

### 2.1 The Revelation Principle and Incentive Compatibility

**The Revelation Principle:** For any mechanism in which an equilibrium outcome is achieved by agents playing some (possibly complex) strategy, there exists a direct mechanism in which agents simply report their true types and the mechanism produces the same outcome.

This is powerful because it means we can restrict attention to **truthful direct mechanisms** -- mechanisms where telling the truth is optimal -- without loss of generality.

**Incentive Compatibility (IC):** A mechanism (f, p) is incentive compatible if for every player i, for every type profile v, and for every alternative report v'_i:

```
u_i(v_i, f(v), p_i(v)) >= u_i(v_i, f(v'_i, v_{-i}), p_i(v'_i, v_{-i}))
```

In words: no agent can improve their outcome by lying about their preferences.

Two strengths of IC:

- **Dominant Strategy Incentive Compatible (DSIC):** Truth-telling is optimal regardless of what others do. The strongest guarantee.
- **Bayesian-Nash Incentive Compatible (BNIC):** Truth-telling is optimal given correct beliefs about others' types. Weaker but more achievable.

### 2.2 The Vickrey-Clarke-Groves (VCG) Mechanism

The VCG mechanism is the foundational result in mechanism design. It achieves two things simultaneously: **allocative efficiency** (the outcome maximizes total welfare) and **dominant strategy incentive compatibility** (truth-telling is optimal for each agent regardless of others' behavior).

**How it works:**

1. Each agent i reports their valuation v_i(a) for each possible outcome a.
2. The mechanism selects the outcome a* that maximizes total reported value:

```
a* = argmax_a SUM_i v_i(a)
```

3. Each agent i pays a "Clarke tax" equal to the externality they impose on others:

```
p_i = max_a SUM_{j != i} v_j(a) - SUM_{j != i} v_j(a*)
```

The payment is the difference between what the other agents WOULD have gotten without agent i and what they actually get.

**Key properties:**
- **Allocatively efficient:** Selects the outcome that maximizes total value.
- **DSIC:** Each agent's dominant strategy is to report truthfully.
- **Not budget-balanced:** The mechanism may extract surplus (the Clarke taxes may not sum to zero).

**Second-price (Vickrey) auction as special case:** In a single-item auction, VCG reduces to the second-price sealed-bid auction. The highest bidder wins but pays the second-highest bid. Truth-telling is dominant because: if you bid below your true value, you might lose an auction you should have won; if you bid above your true value, you might win and pay more than the item is worth to you.

**For Cleansing Fire:** VCG provides a template for any system where agents must reveal private information (their valuations, priorities, or capabilities) and the mechanism must aggregate this information into a collective decision. The lesson: you can get honest revelation by charging agents for the costs they impose on others.

### 2.3 Quadratic Voting (QV)

Proposed by Glen Weyl, quadratic voting addresses a fundamental flaw in one-person-one-vote: it treats all preferences as equally intense. A person who mildly prefers option A and a person whose life depends on option A both get one vote.

**The mechanism:**

Each voter receives a budget of "voice credits." To cast v_i votes on an issue, the voter pays v_i^2 voice credits.

```
cost(v_i) = v_i^2
```

**Why quadratic?** The marginal cost of an additional vote is:

```
d/dv_i (v_i^2) = 2v_i
```

This is linear in votes purchased. Since a rational agent purchases votes until marginal cost equals marginal value, and marginal value is proportional to the agent's true valuation, the number of votes purchased is proportional to the square root of the agent's valuation:

```
v_i* = u_i / (2 * price_per_marginal_vote)
```

This means the aggregate vote count approximates the sum of square roots of valuations, which under reasonable conditions is a better measure of social welfare than a simple vote count.

**Properties:**
- Minority protection: A small group with intense preferences can outweigh a large group with weak preferences by concentrating voice credits.
- Budget constraint: No voter can dominate all issues. Spending heavily on one issue means less influence on others.
- Asymptotically optimal: As the number of voters grows, the mechanism approaches the welfare-maximizing outcome.

**Worked example:**

100 voters, binary issue (A or B).
- 80 voters mildly prefer A (valuation = 1 voice credit each).
- 20 voters strongly prefer B (valuation = 16 voice credits each).

Under one-person-one-vote: A wins 80-20.

Under QV:
- Each mild-A voter buys 1 vote for 1 credit. Total A votes: 80.
- Each strong-B voter buys 4 votes for 16 credits. Total B votes: 80.

Result: a tie, reflecting the fact that total intensity is equal. The strong minority is not overridden by the indifferent majority.

**For Cleansing Fire:** QV is a candidate mechanism for governance decisions where intensity of preference matters. It prevents tyranny of the majority while maintaining the democratic principle that every participant has equal access to voice credits.

### 2.4 Quadratic Funding (QF)

Proposed by Vitalik Buterin, Zoe Hitzig, and Glen Weyl (2018), quadratic funding extends the quadratic principle to public goods provision.

**The mechanism:**

Individual contributors donate to projects. A matching pool supplements each project's funding. The total funding for project p is:

```
F_p = (SUM_i sqrt(c_{i,p}))^2
```

where c_{i,p} is the contribution of individual i to project p.

**Why this works:**

The funding grows with the SQUARE of the number of contributors, not the square of the total amount. A project with 100 contributors each giving $1 receives:

```
F = (100 * sqrt(1))^2 = 100^2 = $10,000
```

while a project with 1 contributor giving $100 receives:

```
F = (1 * sqrt(100))^2 = 10^2 = $100
```

Same total individual contributions ($100), but the broadly-supported project gets 100x more matching funds.

**The matching shortfall:** The total funding exceeds total individual contributions by the matching amount, which must come from somewhere (a matching pool). The required subsidy for project p is:

```
subsidy_p = F_p - SUM_i c_{i,p}
```

In the example above: $10,000 - $100 = $9,900 in matching funds needed.

**For Cleansing Fire:** QF is the natural mechanism for funding public goods within the network -- shared infrastructure, maintenance work, documentation, tooling. It rewards broad support over concentrated wealth and directly addresses the problem of funding boring-but-essential work (because many small contributions to maintenance generate large matching, while a single large donation to a flashy project generates little matching).

### 2.5 Harberger Taxes (COST -- Common Ownership Self-Assessed Tax)

Proposed by Eric Posner and Glen Weyl, the Harberger tax (also called Common Ownership Self-Assessed Tax or COST) creates a mechanism for efficient allocation of scarce resources without traditional property rights.

**The mechanism:**

1. Each owner self-assesses the value of their asset.
2. The owner pays a periodic tax proportional to their self-assessed value: tax = tau * V, where tau is the tax rate and V is the self-assessed value.
3. Anyone can purchase the asset at the self-assessed price at any time, forcing a sale.

**The incentive tension:**

- **Incentive to under-assess:** Lower declared value means lower tax payments.
- **Incentive to over-assess:** Lower declared value means higher risk of a forced sale at below true value.

**Equilibrium:** The owner's optimal declared value V* satisfies:

```
V* = V_true * (1 - tau / (tau + lambda))
```

where lambda is the probability of a buyer arriving in a given period. When tau = lambda, the owner declares V* = V_true. The optimal tax rate equals the expected turnover rate.

**For Cleansing Fire:** Harberger taxes apply to scarce positions within the system -- moderator roles, committee seats, resource allocation slots. Instead of granting permanent ownership of positions, holders self-assess the value of their position, pay a tax, and face the possibility that someone who values the position more can purchase it. This prevents entrenchment while maintaining stability (the tax rate controls the turnover speed).

---

## Part III: Real-World Mechanism Design -- What Actually Works

Theory is necessary but not sufficient. The following real-world implementations demonstrate what survives contact with actual human behavior.

### 3.1 Spectrum Auctions (FCC)

The FCC's spectrum auctions, designed with input from mechanism design theorists including Paul Milgrom and Robert Wilson (2020 Nobel Prize), have allocated over $200 billion in spectrum rights since 1994.

**Key design features:**
- Simultaneous ascending auction: all licenses auctioned simultaneously, allowing bidders to assemble efficient packages.
- Activity rules: bidders must maintain a minimum level of bidding activity, preventing "sniping" and late manipulation.
- Transparency: bid amounts and identities are public, enabling price discovery.

**Lesson for Cleansing Fire:** Even in high-stakes adversarial environments, well-designed mechanisms produce efficient outcomes. The keys are transparency (all bids visible), activity requirements (preventing passive observation), and simultaneity (preventing sequential manipulation).

### 3.2 Kidney Exchange Markets (Roth)

Alvin Roth (2012 Nobel Prize) designed matching mechanisms for kidney exchanges, saving thousands of lives.

**The problem:** Patient A needs a kidney. Donor A is willing to donate to Patient A but is incompatible. Patient B and Donor B face the same problem. But Donor A is compatible with Patient B, and Donor B is compatible with Patient A. A swap would save both patients, but bilateral negotiation is impractical and ethically fraught.

**The mechanism:** The Top Trading Cycles (TTC) algorithm and the National Kidney Registry create chains and cycles of exchanges, including non-simultaneous extended altruistic donor chains.

**Lesson for Cleansing Fire:** Mechanism design can create value from relationships that bilateral negotiation cannot capture. The kidney exchange works because the mechanism identifies beneficial trades across the entire network, not just between pairs. This is directly applicable to resource allocation in the Cleansing Fire network.

### 3.3 School Choice (Deferred Acceptance)

The Gale-Shapley Deferred Acceptance algorithm, implemented in New York City and Boston school choice systems:

1. Each student submits a ranked list of preferred schools.
2. Each school has a priority ordering over students.
3. In each round, unmatched students "propose" to their highest-ranked remaining school.
4. Schools tentatively accept their highest-priority applicants up to capacity, rejecting others.
5. Rejected students propose to their next choice.
6. Repeat until no student is rejected.

**Properties:**
- **Strategy-proof for students:** Ranking schools truthfully is a dominant strategy (no student can benefit from misrepresenting preferences).
- **Stable:** No student-school pair would prefer to be matched to each other over their current match.
- **Student-optimal:** Among all stable matchings, this one is best for students.

**Lesson for Cleansing Fire:** Task assignment and role matching in the network can use deferred acceptance. Agents rank tasks by preference, tasks have priority orderings over agents, and the algorithm produces a stable, strategy-proof matching.

### 3.4 Ostrom's Eight Principles for Commons Governance

Elinor Ostrom (2009 Nobel Prize) studied hundreds of real-world commons -- fisheries, forests, irrigation systems, pastures -- and identified eight design principles present in all successful commons governance:

1. **Clearly defined boundaries:** Who has access rights and what are the resource limits.
2. **Congruence between rules and local conditions:** Rules fit the specific ecology and social context.
3. **Collective choice arrangements:** Most individuals affected by rules can participate in modifying them.
4. **Monitoring:** Monitors are accountable to the appropriators or are the appropriators themselves.
5. **Graduated sanctions:** Violators face sanctions that start mild and escalate with repeated offenses.
6. **Conflict resolution mechanisms:** Low-cost, accessible arenas for resolving disputes.
7. **Minimal recognition of rights to organize:** External authorities do not challenge the right of appropriators to create their own institutions.
8. **Nested enterprises:** For large-scale commons, governance is organized in multiple nested layers.

**Why these matter more than theory:** Ostrom's principles are empirically derived from real-world success. They are not optimal in any formal sense -- they are robust. They work across cultures, resource types, and time periods.

**For Cleansing Fire:** Every Ostrom principle maps to a design requirement:

| Ostrom Principle | Cleansing Fire Implementation |
|-----------------|-------------------------------|
| Clear boundaries | Defined membership, explicit resource limits |
| Local rule fit | Parameters adjustable per community/working group |
| Collective choice | Governance participation by all affected parties |
| Monitoring | Transparent, on-chain/on-protocol behavior tracking |
| Graduated sanctions | The Trust Calculus (Section 6.3) with graduated responses |
| Conflict resolution | Low-cost dispute resolution protocol |
| Self-organization right | No external authority can override local governance |
| Nested enterprises | Multi-scale governance: working groups -> communities -> network |

### 3.5 Prediction Markets

Prediction markets aggregate distributed private information into probability estimates. Key examples:

- **Polymarket:** Cryptocurrency-based prediction market. Has demonstrated remarkably accurate forecasting on political, economic, and scientific questions.
- **Metaculus:** Community prediction platform emphasizing calibration and track records.

**How they work:** A contract pays $1 if event E occurs and $0 otherwise. If the market price is $0.70, the market's implied probability of E is 70%. Traders with private information that E is more (or less) likely can profit by buying (or selling), which moves the price toward the true probability.

**The formal result (Hanson, 2003):** Under logarithmic market scoring rules, a prediction market is equivalent to Bayesian updating by a "market mind" that aggregates all traders' private information.

**For Cleansing Fire:** Prediction markets can be used for:
- Estimating the likely impact of proposed policy changes (Futarchy -- see Section 5.5)
- Detecting early warnings of systemic risk (a declining prediction market for "this system remains uncaptured" is an alarm)
- Evaluating the quality of contributors (prediction markets on whether a contribution will prove valuable)

---

## Part IV: Network Effects and Power Laws

### 4.1 Why Networks Centralize: The Barabasi-Albert Model

The Barabasi-Albert (BA) model explains why networks naturally tend toward centralization through preferential attachment.

**The model:**

Start with m_0 connected nodes. At each time step, a new node arrives and connects to m existing nodes, with probability of connecting to node i proportional to node i's degree:

```
P(connect to i) = k_i / SUM_j k_j
```

where k_i is the degree (number of connections) of node i.

**The result:** The degree distribution follows a power law:

```
P(k) ~ k^(-gamma)
```

with gamma = 3 for the standard BA model.

**What this means:** A small number of nodes (hubs) accumulate a disproportionate share of connections. The rich get richer. This is the structural explanation for why social networks, financial markets, and political systems all tend toward concentration: new connections preferentially attach to already-well-connected nodes.

**The numbers are stark:** In a power-law network with gamma = 3, the top 1% of nodes hold approximately 50% of all connections. The top 0.1% hold approximately 20%.

### 4.2 Breaking Preferential Attachment: Anti-Centralization Topologies

To resist centralization, we must break the preferential attachment mechanism. Several approaches:

**Approach 1: Connection Caps**

Impose a maximum degree k_max. Once a node reaches k_max connections, new nodes cannot connect to it. This truncates the power law distribution.

```
P(connect to i) = k_i / SUM_j k_j  if k_i < k_max
P(connect to i) = 0                  if k_i >= k_max
```

**Problem:** Nodes near the cap still accumulate disproportionate influence. And caps can be gamed by creating proxy nodes.

**Approach 2: Anti-Preferential Attachment**

Reverse the attachment probability: make it INVERSELY proportional to degree.

```
P(connect to i) = (1/k_i) / SUM_j (1/k_j)
```

This produces a uniform or even inverse power law distribution. But it is economically irrational -- why would you preferentially connect to poorly-connected nodes?

**Approach 3: Decaying Influence (Our approach)**

Make attachment probability proportional to RECENT connections rather than total connections. This naturally applies the Decay Function (Section 6.1):

```
P(connect to i) = k_i(t) / SUM_j k_j(t)
```

where k_i(t) = SUM_{connections c} e^{-lambda * (t - t_c)} is the time-decayed degree, with t_c being the time each connection was formed and lambda being the decay constant.

Old connections contribute less to attachment probability. A node that was highly connected five years ago but has few recent connections is treated similarly to a node with moderate persistent activity.

**Approach 4: Small-World Design**

The Watts-Strogatz small-world model achieves high clustering (neighbors of neighbors are likely neighbors) with short path lengths (any two nodes are connected by a short chain). Parameters:

- Start with a ring lattice of N nodes, each connected to K nearest neighbors.
- With probability p, rewire each edge to a random node.

For p between 0.01 and 0.1, the network has:
- High clustering coefficient C (almost as high as a regular lattice)
- Short average path length L (almost as short as a random graph)

This topology supports network reciprocity (Nowak's mechanism 4) because of high clustering, while maintaining efficient information flow because of short paths.

**For Cleansing Fire:** The network topology should be designed as a small-world network with decaying influence. Specifically:

```
Target parameters:
- Clustering coefficient C >= 0.3
- Average path length L <= log(N) / log(K)
- Maximum degree k_max = O(sqrt(N))
- Decay half-life for degree influence: 6 months
```

### 4.3 Measuring Centralization: The Nakamoto Coefficient and Beyond

**The Nakamoto Coefficient:** The minimum number of entities that must collude to compromise the system. For Bitcoin, it is approximately 4 (mining pools). For Ethereum proof-of-stake, it is approximately 3-5 (staking providers).

**The Herfindahl-Hirschman Index (HHI):** Used in antitrust economics to measure market concentration:

```
HHI = SUM_i s_i^2
```

where s_i is the market share of entity i (as a fraction). HHI ranges from 1/N (perfect equality) to 1 (monopoly). The DOJ considers markets with HHI above 0.25 to be highly concentrated.

**The Gini Coefficient:** Measures inequality of a distribution, from 0 (perfect equality) to 1 (maximum inequality):

```
Gini = (SUM_i SUM_j |x_i - x_j|) / (2 * N * SUM_i x_i)
```

**For Cleansing Fire:** Define explicit concentration thresholds:

```
System health requires:
- Nakamoto coefficient >= max(10, sqrt(N))
- HHI for influence distribution <= 0.05
- Gini coefficient for contribution credit <= 0.4
- No single node holds > 2% of total network influence
```

These are not aspirational targets -- they are protocol-enforced constraints. If any threshold is breached, the Anti-Capture Mechanism (Section 6.5) activates.

---

## Part V: Cryptoeconomics -- Lessons From the Field

Cryptoeconomics is the experimental laboratory for mechanism design. Some mechanisms work in theory but fail in practice. Some work in practice despite lacking theoretical justification. The following synthesizes what has survived contact with adversarial agents and real money.

### 5.1 Token Bonding Curves

A bonding curve defines a functional relationship between token supply and token price:

```
price(supply) = f(supply)
```

Common curves:

- **Linear:** f(s) = m * s + b. Price increases linearly with supply. Simple, predictable.
- **Polynomial:** f(s) = a * s^n. For n > 1, price increases accelerate as supply grows. Creates strong incentives for early participation.
- **Sigmoid:** f(s) = L / (1 + e^{-k(s - s_0)}). Price is low initially, rises steeply in the middle, and plateaus at L. Models an adoption S-curve.

**The buy-sell mechanism:**

To mint a new token, a buyer pays the current price. The payment goes into a reserve. To burn a token, a seller receives the current price from the reserve. Because price is monotonically increasing in supply, early buyers pay less and can sell for more (if supply increases).

**Reserve ratio:** The ratio of reserve to market cap. For a power-law curve f(s) = s^n, the reserve ratio is 1/(n+1). A linear curve (n=1) has a 50% reserve ratio. A quadratic curve (n=2) has a 33% reserve ratio.

**For Cleansing Fire:** Bonding curves are NOT used for speculation in this system. They are used for influence staking: contributors stake tokens into the system, receiving influence proportional to their stake. The bonding curve ensures that:
- Early contributors are rewarded (price is lower)
- The cost of accumulating disproportionate influence increases superlinearly
- There is always liquidity for exit (the reserve guarantees a sell price)

### 5.2 Staking and Slashing

**Staking:** Participants lock up resources (tokens, reputation, or computational resources) as collateral against their commitments. The stake is at risk if the participant behaves badly.

**Slashing:** If a participant is detected violating protocol rules, some or all of their stake is destroyed ("slashed").

**The incentive structure:**

A rational participant stakes if and only if:

```
E[reward from staking] > E[cost of slashing] + opportunity_cost
```

Which expands to:

```
r * S > p_slash * f_slash * S + r_alt * S
```

where r is the staking reward rate, S is the stake size, p_slash is the probability of being slashed, f_slash is the fraction of stake that is slashed, and r_alt is the alternative return.

For the system to be secure, we need:

```
p_slash * f_slash > r - r_alt
```

for any participant who is considering defecting. In other words, the expected cost of getting caught defecting must exceed the net benefit of the staking reward.

**For Cleansing Fire:** Staking-and-slashing applies to any role that involves trust -- moderators, validators, committee members. To take on a trusted role, you stake reputation (and potentially resources). If you abuse the role, your stake is slashed. The slashing must be:
- **Graduated** (Ostrom's principle 5): first offense is mild, repeated offenses escalate
- **Transparent** (Pyrrhic Lucidity principle 3): all slashing decisions and reasons are public
- **Appealable** (Ostrom's principle 6): a conflict resolution process exists

### 5.3 Retroactive Public Goods Funding (RetroPGF)

Optimism's Retroactive Public Goods Funding is based on a simple insight: "It is easier to agree on what was useful than to predict what will be useful."

**The mechanism:**

1. Builders create public goods (open-source software, documentation, infrastructure, education).
2. Periodically, a pool of funding is allocated.
3. A group of "badgeholders" (citizens with voting rights) evaluates past contributions and distributes the pool retroactively based on demonstrated impact.
4. The core equation: **impact = profit**. Contributions are rewarded proportionally to the value they created, but only after the value is demonstrated.

**Why it works better than prospective funding:**
- Eliminates the problem of picking winners ex ante.
- Rewards actual impact, not grant-writing skill or social connections.
- Creates a market for "impact certificates" -- tokens that represent a share of a project's future retroactive funding.

**For Cleansing Fire:** RetroPGF is the natural mechanism for the Contribution Protocol (Section 6.2). Instead of trying to predict which contributions will be valuable, fund contributions retroactively based on demonstrated impact. This directly solves the problem of funding "boring but essential" maintenance work -- if the infrastructure works, the maintainers get paid.

### 5.4 Conviction Voting

Developed by the Commons Stack and formalized by Michael Zargham at Block Science, conviction voting is a continuous decision-making mechanism where support for proposals builds over time.

**The mechanism:**

Each participant allocates their tokens to proposals they support. The "conviction" (accumulated support) for proposal p at time t is:

```
y_p(t) = alpha * y_p(t-1) + x_p(t)
```

where:
- y_p(t) is the conviction for proposal p at time t
- alpha is the decay constant (typically 0.9), determining how quickly conviction dissipates when support is withdrawn
- x_p(t) is the total tokens currently allocated to proposal p

A proposal passes when its conviction exceeds a threshold:

```
y_p(t) >= threshold(requested_amount)
```

The threshold is typically a function of the requested amount relative to the available funding pool:

```
threshold(r) = rho * S / (1 - r/F)
```

where rho is a sensitivity parameter, S is the total token supply, r is the requested amount, and F is the available funding pool. As a proposal requests more of the pool, the threshold increases sharply.

**Properties:**
- **Continuous:** No discrete voting periods. Participants can update their preferences at any time.
- **Gradual:** Proposals cannot pass instantly -- they require sustained support over time.
- **Sybil-resistant:** Splitting tokens across identities does not increase total conviction.
- **Resistant to vote-buying:** An attacker must maintain influence over time, making attacks expensive.
- **Allows concurrent proposals:** Multiple proposals compete for attention simultaneously.

**For Cleansing Fire:** Conviction voting is the primary governance mechanism for resource allocation. Its continuous, gradual nature aligns with Pyrrhic Lucidity's preference for reversible decisions, and its resistance to flash attacks aligns with the anti-capture requirement.

### 5.5 Futarchy: Governance by Prediction Markets

Robin Hanson's proposal: "Vote on values, bet on beliefs."

**The mechanism:**

1. The community votes democratically to define a **welfare metric** -- a measurable quantity that reflects collective well-being.
2. When a policy proposal is made, two conditional prediction markets are created:
   - Market A: "What will the welfare metric be if the policy IS adopted?"
   - Market B: "What will the welfare metric be if the policy is NOT adopted?"
3. If Market A's price > Market B's price (prediction markets believe the policy will improve welfare), the policy is adopted.
4. The losing market's trades are unwound. The winning market settles based on the actual welfare metric.

**The formal structure:** Let W be the welfare metric. For policy P:

```
Adopt P  iff  E[W | P adopted] > E[W | P not adopted]
```

where the conditional expectations are estimated by prediction market prices.

**Strengths:**
- Separates values (what we want) from beliefs (what works) -- democracy for the former, markets for the latter.
- Aggregates distributed expertise: anyone with relevant knowledge can profit by trading, which moves prices toward truth.
- Reduces political posturing: you can vote your values sincerely while letting the market determine policy efficacy.

**Weaknesses:**
- Welfare metric definition is itself a political decision subject to capture.
- Thin markets may be easily manipulated.
- Complex policies may not have cleanly separable counterfactual markets.

**For Cleansing Fire:** Futarchy is a candidate mechanism for policy decisions at the network level, with the welfare metric tied to the system's own health indicators (Nakamoto coefficient, Gini coefficient, participation rate, contribution volume). However, the welfare metric itself must be determined through quadratic voting, not through prediction markets (avoiding the circularity of markets determining their own success criteria).

---

## Part VI: The Cleansing Fire Mechanisms (Original Designs)

The following six mechanisms are original designs for the Cleansing Fire system, synthesizing the theoretical foundations from Parts I-V with the philosophical commitments of Pyrrhic Lucidity. Each mechanism is specified with sufficient mathematical precision for implementation.

### 6.1 The Decay Function

**The core insight from Pyrrhic Lucidity:** "Power should have built-in depreciation -- all authority should expire by default and require active renewal" (philosophy.md, Domain 2: Institutional Design).

**Definition:** The Decay Function D(t) maps accumulated power/influence to its effective value at time t:

```
D(t) = D_0 * e^{-lambda * t}
```

where:
- D_0 is the initial value at the time of accumulation
- lambda is the decay constant
- t is the elapsed time since accumulation
- The half-life T_{1/2} = ln(2) / lambda

**The design question is: what is the correct half-life?**

Different forms of accumulation decay at different rates, reflecting their different relationships to ongoing contribution:

| Accumulation Type | Half-Life | Rationale |
|------------------|-----------|-----------|
| Voting weight from past contributions | 6 months | Influence should reflect RECENT contribution, not historical wealth |
| Reputation score | 12 months | Trust takes longer to build and should not evaporate instantly |
| Committee/role tenure | 18 months | Institutional memory has value, but entrenchment is worse |
| Resource allocation rights | 3 months | Resources should flow to active need, not historical claims |
| Governance proposal weight | 1 month | Proposals should reflect current conditions |

**The composite influence function:** A node i's effective influence at time t is:

```
I_i(t) = SUM_k w_k * SUM_j a_{i,j,k} * e^{-lambda_k * (t - t_j)}
```

where:
- k indexes accumulation types (contributions, reputation, roles, etc.)
- j indexes individual accumulation events within type k
- a_{i,j,k} is the raw amount of accumulation event j of type k
- t_j is the time of event j
- lambda_k is the decay constant for type k
- w_k is the weight of accumulation type k

**Worked example:**

Node A made major contributions 2 years ago (contribution weight 100, t=24 months ago) and minor contributions recently (weight 10, t=1 month ago).

Node B made moderate contributions consistently (weight 5 per month for 12 months).

Using lambda = ln(2)/6 (6-month half-life for contributions), w_contribution = 1:

```
I_A(now) = 100 * e^{-0.1155 * 24} + 10 * e^{-0.1155 * 1}
         = 100 * 0.0625 + 10 * 0.891
         = 6.25 + 8.91
         = 15.16

I_B(now) = SUM_{m=1}^{12} 5 * e^{-0.1155 * m}
         = 5 * (e^{-0.1155} + e^{-0.231} + ... + e^{-1.386})
         = 5 * (0.891 + 0.794 + 0.707 + 0.630 + 0.561 + 0.500 + 0.445 + 0.397 + 0.354 + 0.315 + 0.281 + 0.250)
         = 5 * 6.125
         = 30.63
```

Node B, with consistent moderate contributions (total: 60), has twice the effective influence of Node A, whose larger total contributions (110) are mostly stale. **The system rewards ongoing participation over historical accumulation.**

**Anti-gaming provisions:**

1. **No decay reset:** You cannot "refresh" old contributions by relabeling or resubmitting them. The timestamp is immutable.
2. **Contribution verification:** Contributions are verified by independent reviewers before they enter the influence calculation. Gaming requires collusion.
3. **Diminishing returns within period:** Within any given time window, influence from contributions exhibits diminishing returns:

```
marginal_influence(n) = 1 / (1 + beta * n)
```

where n is the number of contributions in the current window and beta controls the diminishing rate. This prevents "contribution spam" -- submitting many low-quality contributions to accumulate influence.

### 6.2 The Contribution Protocol

**Problem:** How do nodes contribute to the network and receive credit, in a way that prevents both free-riding (contributing nothing, extracting value) and over-accumulation (a few nodes dominating credit)?

**Design principles:**
1. Credit is proportional to RECENT contributions (Decay Function applied)
2. Breadth of support matters more than depth (Quadratic Funding principle)
3. Impact is assessed retroactively, not prospectively (RetroPGF principle)
4. Maintenance and infrastructure work is valued equally with new feature work

**The protocol has three phases:**

**Phase 1: Contribution Registration**

Any node can register a contribution by:
1. Declaring the work done (description, evidence, category)
2. Having at least one independent node verify the work exists (not validate quality -- just existence)
3. The contribution enters a "pending" state with zero credit

**Phase 2: Peer Valuation**

Other nodes signal the value of contributions through a modified quadratic mechanism:

```
credit_p = (SUM_i sqrt(s_{i,p}))^2 * category_multiplier_p
```

where:
- s_{i,p} is the signal (stake) that node i allocates to contribution p
- category_multiplier_p adjusts for contribution category

Category multipliers address the "boring but essential" problem:

| Category | Multiplier | Rationale |
|----------|-----------|-----------|
| Infrastructure maintenance | 1.5x | Chronically undervalued, essential for system health |
| Security review | 1.5x | Invisible when done well, catastrophic when absent |
| Documentation | 1.3x | Public good with high positive externality |
| New feature | 1.0x | Intrinsically motivating, does not need subsidy |
| Governance participation | 1.2x | Essential but tedious, needs incentive |

**Phase 3: Retroactive Assessment**

Every quarter (configurable), a retroactive assessment cycle occurs:

1. A panel of randomly selected nodes (minimum 7, maximum 21) reviews contributions from the previous quarter.
2. Each panelist independently scores each contribution on a 0-10 impact scale.
3. The median score becomes the "impact multiplier" for that contribution.
4. Final credit:

```
final_credit_p = credit_p * impact_multiplier_p * decay(t - t_p)
```

5. Panelists themselves receive contribution credit for serving on the panel (governance participation category).

**Free-riding prevention:**

Nodes that receive benefits from the network (access to resources, participation in governance) but contribute nothing face a "participation tax":

```
participation_cost_i(t) = base_cost * (1 + gamma * max(0, avg_consumption_i - contributions_i(t)))
```

where gamma controls the penalty strength. Nodes that consume more than they contribute pay higher costs for participation. This is not punitive -- it is the internalization of externalities. Consumption without contribution imposes costs on others; the participation tax makes those costs visible.

**Over-accumulation prevention:**

This is handled by the Decay Function (Section 6.1) and a contribution cap:

```
max_influence_share = min(0.02, 1/sqrt(N))
```

where N is the total number of active nodes. No single node can hold more than 2% of total influence (or 1/sqrt(N), whichever is smaller). Once a node reaches this cap, additional contributions still receive credit (for retroactive assessment purposes) but do not increase the node's effective influence.

### 6.3 The Trust Calculus

**Problem:** Build a formal system for assessing trust in a decentralized network that is:
- Based on behavior, not identity
- Sybil-resistant
- Allows for reputation recovery after mistakes
- Does not create permanent underclasses

**The Trust Score:**

Each node i has a trust score T_i(t) that is a function of its behavioral history:

```
T_i(t) = T_base + SUM_j w_j * e^{-mu * (t - t_j)} * sigma_j
```

where:
- T_base is the baseline trust for any node (> 0 to allow new participants to engage)
- j indexes trust-relevant events (contributions, verifications, governance participation, violations)
- w_j is the weight of event j (positive for trust-building, negative for trust-damaging)
- mu is the temporal decay constant for trust events
- t_j is the time of event j
- sigma_j is the "social verification multiplier" -- how many independent nodes confirmed this event

**Setting T_base:** T_base should be high enough that new nodes can participate meaningfully but low enough that a single Sybil identity cannot significantly impact the system:

```
T_base = SUM_i T_i(t) / (N * K)
```

where K is a "dilution factor" (typically K = 10-20). A new node has 1/K of the average trust. This is enough to participate but not enough to influence governance decisions alone.

**Sybil Resistance:**

The Trust Calculus resists Sybil attacks through three mechanisms:

**Mechanism 1: Social Verification Graph.** Trust events receive a "social verification multiplier" sigma_j proportional to the number of independent, established nodes that verify the event. Independence is determined by graph distance in the trust network:

```
sigma_j = SUM_{verifiers v} (T_v(t) / T_avg) * independence(v, i)
```

where independence(v, i) = 1 if distance(v, i) in the trust graph >= 3, and decreases for closer nodes. This prevents a cluster of Sybil identities from mutually verifying each other -- they are too close in the graph to provide independent verification.

**Mechanism 2: Behavioral Consistency Analysis.** Trust events are weighted by behavioral consistency:

```
consistency_i(t) = 1 - std(behavior_i, window) / mean(behavior_i, window)
```

where behavior is measured across a sliding window. Nodes with erratic behavior patterns (characteristic of Sybil identities controlled by a single actor attempting to simulate independence) receive lower trust multipliers.

**Mechanism 3: Cost of Identity.** Creating a new identity has a non-trivial cost: a waiting period (e.g., 30 days) during which the identity can participate but cannot gain trust faster than T_base + epsilon per day. An attacker creating 100 Sybil identities must wait 30 days for each to become minimally effective, and the total trust of all 100 identities after 30 days is still less than the trust of a single established identity.

**Reputation Recovery:**

The Trust Calculus allows recovery through a specific mechanism:

```
T_recovery_rate(t) = T_base_recovery * (1 - e^{-nu * t_since_last_violation})
```

After a violation, a node's trust decreases by the violation weight. Recovery begins after a "cooling period" (proportional to the severity of the violation). During recovery:

1. The node can contribute normally, but trust-building events have a reduced weight:

```
w_j_recovery = w_j * recovery_fraction(t)
```

where recovery_fraction starts at 0.1 (immediately after cooling period) and asymptotically approaches 1.0.

2. Full trust restoration requires both time AND positive contributions. You cannot simply wait out a violation -- you must actively rebuild.

3. Recovery progress is public. All nodes can see that node i is recovering from a specific violation and what progress has been made.

**Worked example:**

Node X has operated for 2 years with consistent positive contributions. Trust score: 85.

Node X commits a governance violation (weight: -30). New trust score: 55. Cooling period: 60 days.

After the cooling period, Node X resumes contributing. Each positive contribution (normally worth +2 trust) is worth:
- Day 61-90: +0.2 (10% recovery fraction)
- Day 91-180: +0.6 (30% recovery fraction)
- Day 181-360: +1.2 (60% recovery fraction)
- Day 361+: +1.8 (90% recovery fraction)

At 1 contribution per week, Node X reaches trust score 75 after approximately 8 months of post-violation activity. Full recovery to 85 takes approximately 14 months. The violation is never erased from the record, but its weight decays over time along with all other events.

**The design philosophy:** Trust is earned slowly, lost quickly, and rebuilt at moderate pace. This mirrors how trust actually works in human relationships. It is asymmetric by design -- the asymmetry is itself a deterrent against violation.

### 6.4 The Coordination Game

**Problem:** How do distributed agents decide what to work on? Two failure modes:
1. **Tragedy of the commons:** Everyone waits for someone else to do the work. Nothing gets done.
2. **Tyranny of the urgent:** Only exciting, visible work gets attention. Infrastructure rots.

**The mechanism:** A modified conviction voting system with maintenance guarantees and anti-crowding incentives.

**Layer 1: Maintenance Floor**

Before any discretionary allocation occurs, a fixed fraction f_m (initially 30%) of all resources is reserved for maintenance work. Maintenance is defined as:
- Infrastructure upkeep
- Security updates
- Documentation updates
- Bug fixes in existing systems
- Performance optimization

Maintenance tasks are identified by a combination of:
1. Automated monitoring (systems detect their own degradation)
2. Community reporting (any node can flag maintenance needs)
3. Scheduled reviews (periodic audits of system health)

Maintenance resources are allocated by a first-come-first-served queue with priority weighting:

```
priority_m = severity * age * affected_nodes / claimed_efforts
```

where severity is a 1-5 scale, age is how long the issue has existed, affected_nodes is the count of nodes impacted, and claimed_efforts is the estimated work required.

**Layer 2: Conviction-Allocated Resources**

The remaining (1 - f_m) fraction of resources is allocated via conviction voting (Section 5.4) with modifications:

**Anti-crowding:** When a proposal already has significant support, additional tokens provide diminishing marginal conviction:

```
y_p(t) = alpha * y_p(t-1) + x_p(t) / (1 + eta * x_p(t) / S)
```

where eta is the crowding parameter and S is the total token supply. When a proposal already has a large share of total tokens, additional support provides less conviction. This naturally distributes attention across multiple proposals rather than concentrating it on one popular proposal.

**Long-term bias:** Proposals for long-term work (with estimated completion > 6 months) receive a conviction bonus:

```
long_term_multiplier = 1 + delta_lt * min(1, estimated_duration / 24_months)
```

where delta_lt (typically 0.3) rewards long-term thinking. A 2-year project receives 30% more conviction per token-month than an equivalent 1-month project. This counteracts the natural bias toward short-term, visible work.

**Layer 3: Serendipity Allocation**

A small fraction f_s (initially 5%) of resources is allocated randomly to proposals that have not yet achieved conviction threshold. Each period, one unconvicted proposal is randomly selected (weighted by token support, but any nonzero support qualifies) and funded as a pilot.

**Rationale:** Conviction voting, like all aggregation mechanisms, has a conservative bias -- it tends to fund proposals that are already popular. The serendipity allocation creates space for novel, unpopular, or early-stage ideas that might not survive conviction voting but could prove transformative. It is the institutional analog of biological mutation -- most mutations are neutral or harmful, but without mutation, evolution stops.

**Evaluation:** Serendipity-funded pilots are evaluated after completion. If the retroactive assessment (Phase 3 of the Contribution Protocol) scores them above the median of conviction-funded projects, the serendipity allocation increases by 1 percentage point (up to a maximum of 10%). If they consistently score below median, it decreases by 1 percentage point (down to a minimum of 2%).

### 6.5 The Anti-Capture Mechanism

**Problem:** Design a formal, game-theoretic mechanism that detects and resists capture of the system by concentrated interests. This is the immune system of the institution.

**What is capture?** Capture occurs when a subset of nodes gains disproportionate influence over system decisions, in a way that serves the subset's interests at the expense of the broader network. Formally:

```
The system is captured if there exists a coalition C with |C| < N/4 such that
the coalition's effective influence exceeds 50% of total:

SUM_{i in C} I_i(t) > 0.5 * SUM_{j in N} I_j(t)
```

This is a formal version of Pyrrhic Lucidity's principle that "power concentrated beyond justification" is illegitimate.

**Detection Layer: The Capture Index**

The system continuously monitors a "Capture Index" CI(t) composed of multiple indicators:

```
CI(t) = w_1 * gini(I(t)) + w_2 * (1 - nakamoto(t)/sqrt(N)) + w_3 * corr(voting(t)) + w_4 * entropy_deficit(t)
```

where:
- gini(I(t)): Gini coefficient of the influence distribution (0 = perfect equality, 1 = maximum concentration)
- nakamoto(t): Nakamoto coefficient (minimum nodes to achieve 51% influence)
- corr(voting(t)): Average pairwise correlation of voting behavior (high correlation suggests coordinated behavior)
- entropy_deficit(t): The difference between maximum entropy and actual entropy of the influence distribution:

```
entropy_deficit = log(N) - (-SUM_i (I_i/I_total) * log(I_i/I_total))
```

**Weights** (initial, subject to calibration): w_1 = 0.25, w_2 = 0.25, w_3 = 0.25, w_4 = 0.25.

CI ranges from 0 (no capture) to 1 (total capture). The system maintains three thresholds:

| CI Level | Threshold | Response |
|----------|-----------|----------|
| **Green** | CI < 0.3 | Normal operation |
| **Yellow** | 0.3 <= CI < 0.6 | Warning: increased monitoring, public alerts |
| **Red** | CI >= 0.6 | Active countermeasures |

**Response Layer: Graduated Countermeasures**

**Yellow Alert (0.3 <= CI < 0.6):**

1. **Transparency increase:** All governance decisions require enhanced justification. The decision record must explicitly address why the decision serves the broad network, not just the proposing coalition.
2. **Voting boost for underrepresented nodes:** Nodes with below-median influence receive a temporary quadratic boost to their governance weight:

```
boosted_weight_i = weight_i * (1 + kappa * max(0, I_median - I_i) / I_median)
```

where kappa is calibrated so the total boost reduces CI by approximately 0.1.

3. **Cooling period for major proposals:** Proposals affecting system governance or resource allocation face a doubled conviction threshold, requiring broader and more sustained support.

**Red Alert (CI >= 0.6):**

All Yellow countermeasures, plus:

4. **Influence cap reduction:** The maximum influence share is reduced from 2% to 1%.
5. **Emergency Seasonal Reset trigger:** A Seasonal Reset (Section 6.6) is triggered immediately, regardless of the regular schedule.
6. **Coalition scrutiny:** Any coalition of nodes whose combined influence exceeds 15% is automatically subjected to adversarial review. The coalition must publicly justify why their coordinated behavior serves the network. This is not suppression of coordination -- it is the demand for transparency that Pyrrhic Lucidity applies to all concentrated power.
7. **Fork right activation:** If CI remains above 0.6 for three consecutive assessment periods despite countermeasures, the network's "fork right" is activated: any subset of nodes can create an independent instance of the network, taking with them a proportional share of the shared resources. This is the nuclear option -- the guarantee that capture cannot be permanent because the captured system can be abandoned.

**Game-theoretic analysis of the Anti-Capture Mechanism:**

Consider a potential capturing coalition C contemplating whether to pursue capture.

**Without the Anti-Capture Mechanism:**

Expected payoff of capture = P(success) * V_capture - P(failure) * C_attempt

where V_capture is the value of controlling the system and C_attempt is the cost of the attempt.

**With the Anti-Capture Mechanism:**

Expected payoff of capture = P(success | countermeasures) * V_capture * (1 - P(fork)) - P(failure) * C_attempt - monitoring_costs

The mechanism makes capture less attractive by:
1. Reducing P(success) through countermeasures
2. Reducing V_capture through the fork right (even successful capture may trigger fork, leaving the capturers in control of a depopulated system)
3. Increasing C_attempt through monitoring costs (coordinated behavior is more expensive when it must be hidden from correlation detectors)

**The key insight:** The Anti-Capture Mechanism does not need to PREVENT capture with certainty. It needs to make the expected value of capture negative. In game-theoretic terms, it makes "attempt capture" a dominated strategy -- one that is worse than "cooperate" regardless of what others do.

### 6.6 The Seasonal Reset

**Problem:** Even with decay functions and anti-capture mechanisms, power accumulation has dynamics that can outrun continuous countermeasures. Periodic resets provide a structural check that continuous mechanisms cannot.

**The analogy:** Ecological systems depend on periodic disturbances -- fires, floods, winters -- to prevent any single species from dominating. The Seasonal Reset is the controlled burn that prevents the catastrophic wildfire of revolution.

**When does a Reset occur?**

Resets are triggered by two independent mechanisms:

**Mechanism 1: Scheduled Resets.** Every 12 months (configurable), a regular Seasonal Reset occurs regardless of system state. This is the equivalent of a mandatory election: power must be reaffirmed, not merely inherited.

**Mechanism 2: Emergency Resets.** Triggered when the Capture Index remains at Red level for three consecutive assessment periods (as described in Section 6.5).

**What gets redistributed?**

Not everything resets. The Reset operates on a tiered system:

| Tier | What Resets | How |
|------|-------------|-----|
| **Tier 1: Governance roles** | All committee seats, moderator positions, and special authority roles | Roles are vacated. Incumbents may re-apply but receive no incumbency advantage. |
| **Tier 2: Voting weight** | Accumulated governance weight | Reduced by 50% (not zeroed). Remaining weight still decays normally. |
| **Tier 3: Contribution credit** | Historical contribution credit | The Decay Function is applied with a one-time acceleration: effective_lambda = 2 * lambda for the reset period. Contributions older than 2 half-lives lose approximately 75% of remaining value. |
| **Tier 4: Trust scores** | NOT reset | Trust survives resets. This is deliberate: trust reflects behavioral patterns over time and should not be periodically erased. Only specific violations reduce trust. |

**The Reapplication Process:**

After a reset, governance roles are filled through a modified deferred acceptance algorithm:

1. Each vacant role specifies required competencies.
2. Eligible nodes (trust score above minimum, no active violations) submit applications ranking preferred roles.
3. A randomly selected committee (different from the previous committee) evaluates applications.
4. The deferred acceptance algorithm matches nodes to roles based on mutual preferences.
5. The new committee serves until the next reset.

**Anti-gaming provisions:**

**Problem:** If resets are predictable, nodes will game them -- accumulating resources just before a reset, or sandbagging contributions to deploy immediately after.

**Countermeasure 1: Fuzzy timing.** The scheduled reset date is drawn from a uniform distribution over a 60-day window centered on the 12-month mark. Nodes know a reset will occur "sometime in months 11-13" but not the exact date. This prevents pre-reset gaming.

**Countermeasure 2: Reset-spanning evaluation.** The retroactive assessment (Phase 3 of the Contribution Protocol) explicitly evaluates contributions across reset boundaries. A contribution made just before a reset is evaluated for its post-reset impact, and vice versa. There is no advantage to timing contributions relative to the reset.

**Countermeasure 3: Continuity penalty.** If a node held a governance role in the previous period AND applies for the same role in the new period, it receives a small penalty in the matching process (equivalently, other applicants receive a small bonus). This creates a structural rotation incentive without prohibiting continuity when no better candidate exists:

```
matching_score_incumbent = raw_score * (1 - phi)
```

where phi (typically 0.1-0.2) is the continuity penalty. An incumbent with a raw score of 90 competes as if they had a score of 72-81, depending on phi. A challenger with a raw score of 85 would be preferred. But a dramatically better incumbent (raw score 100 vs challenger 70) still retains the role. The penalty is structural preference for rotation, not an absolute ban on continuity.

---

## Part VII: Impossibility Results and Design Constraints

No mechanism design document is complete without acknowledging what CANNOT be achieved. The following impossibility results constrain the design space.

### 7.1 Arrow's Impossibility Theorem

**Statement:** No social choice function over 3+ alternatives can simultaneously satisfy:
1. Unrestricted domain (any preference ordering is admissible)
2. Pareto efficiency (if everyone prefers A to B, the social choice prefers A to B)
3. Independence of irrelevant alternatives (the social ranking of A vs B depends only on individual rankings of A vs B)
4. Non-dictatorship (no single individual determines the social choice)

**Implication for Cleansing Fire:** We cannot design a "perfect" voting mechanism. All mechanisms involve tradeoffs. Quadratic voting violates IIA. Conviction voting violates unrestricted domain (by constraining the temporal structure of preference expression). We must be explicit about which properties we sacrifice and why.

**Our response:** We sacrifice IIA (independence of irrelevant alternatives) in favor of intensity-sensitivity (quadratic voting) and temporal stability (conviction voting). The justification is that IIA, while theoretically elegant, treats all preferences as binary and context-free, which is empirically false. Real preferences have intensity, context, and temporal structure, and our mechanisms capture this.

### 7.2 The Gibbard-Satterthwaite Theorem

**Statement:** Any deterministic voting rule over 3+ alternatives that is not dictatorial is manipulable -- there exists some preference profile under which some voter benefits from misrepresenting their preferences.

**Implication:** No mechanism can be perfectly strategy-proof in all cases. Some voters will always have an incentive to vote strategically rather than sincerely.

**Our response:** We do not aim for perfect strategy-proofness. We aim for **approximate strategy-proofness** -- making strategic voting sufficiently difficult and costly that it is not worth the effort for most participants. Quadratic voting achieves this: the cost of strategic manipulation scales quadratically, making manipulation expensive relative to honest voting for most preference profiles.

### 7.3 The Myerson-Satterthwaite Impossibility

**Statement:** No mechanism can simultaneously achieve:
1. Bayesian-Nash incentive compatibility (truth-telling is a Bayesian Nash equilibrium)
2. Individual rationality (no participant is worse off than not participating)
3. Budget balance (the mechanism does not require external subsidy)
4. Efficiency (the outcome maximizes total welfare)

when parties have private information about their valuations and those valuations could overlap.

**Implication:** The Contribution Protocol cannot simultaneously be perfectly truthful (people accurately report their contributions), individually rational (everyone benefits from participation), budget-balanced (no external funding required), and efficient (resources go to their highest-value use). Something must give.

**Our response:** We sacrifice budget balance. The system requires external funding (through the matching pool for quadratic funding, through base rewards for maintenance work). This is an explicit design choice: the alternative -- sacrificing efficiency or individual rationality -- would undermine the system's core purpose.

### 7.4 The CAP Theorem of Governance (Informal)

By analogy with distributed systems, we conjecture that a governance system cannot simultaneously achieve:
1. **Consistency:** All participants see the same state of governance decisions.
2. **Availability:** Any participant can participate in governance at any time.
3. **Partition tolerance:** The system continues to function when communication is disrupted.

**Implication:** In a decentralized system with intermittent connectivity, governance decisions may be temporarily inconsistent across partitions. The Cleansing Fire protocol prioritizes partition tolerance (the system must work in adverse conditions) and eventual consistency (partitions reconcile when communication is restored), accepting temporary availability limitations (some participants may be temporarily unable to participate in time-critical decisions).

---

## Part VIII: Implementation Roadmap

### 8.1 Computational Representation

Each mechanism described above can be implemented with the following data structures:

**Node State:**
```python
class Node:
    id: str
    trust_score: float          # Section 6.3
    influence: float            # Section 6.1, computed from events
    contribution_events: list   # [(timestamp, amount, category, verified_by)]
    trust_events: list          # [(timestamp, weight, sigma)]
    governance_roles: list      # [(role, start_time, end_time)]
    token_allocations: dict     # {proposal_id: amount}  for conviction voting
```

**System State:**
```python
class SystemState:
    nodes: dict                 # {node_id: Node}
    proposals: dict             # {proposal_id: Proposal}
    capture_index: float        # Section 6.5
    alert_level: str            # "green" | "yellow" | "red"
    last_reset: timestamp       # Section 6.6
    next_reset_window: (timestamp, timestamp)
    maintenance_pool: float     # Reserved for maintenance
    conviction_pool: float      # Available for conviction allocation
    serendipity_pool: float     # Available for random allocation
```

### 8.2 Update Cycle

The system updates on two timescales:

**Continuous updates (every block/epoch):**
- Influence recalculation (Decay Function application)
- Conviction accumulation for all proposals
- Capture Index recalculation
- Proposal threshold checks

**Periodic updates (configurable, default weekly):**
- Retroactive assessment panels selected
- Maintenance priority queue reordering
- Serendipity allocation lottery
- System health metrics publication

### 8.3 Parameter Governance

All parameters described in this document (decay half-lives, category multipliers, conviction thresholds, capture index weights, reset schedules, etc.) are themselves subject to governance through the quadratic voting mechanism. This creates a meta-governance layer:

1. Any node can propose a parameter change.
2. The proposal enters the conviction voting system.
3. If it achieves threshold, the parameter change is implemented.
4. The change is reversible -- a counter-proposal can revert it.

**Bootstrap problem:** Initial parameter values are set by the founding team. This is an acknowledged centralization that the system is designed to dissolve: as the network grows, parameter governance migrates from founders to the community. The founders' influence decays according to the same Decay Function as everyone else's.

### 8.4 Simulation Requirements

Before deployment, each mechanism must be validated through agent-based simulation:

1. **Cooperative equilibrium test:** Simulate 1000 agents using cooperative strategies. Verify that the system is stable and produces near-optimal outcomes.
2. **Adversarial robustness test:** Simulate with 10-30% adversarial agents using various attack strategies (Sybil, collusion, contribution spam, governance manipulation). Verify that the system degrades gracefully and countermeasures activate correctly.
3. **Parameter sensitivity analysis:** Vary each parameter over its plausible range and measure system health metrics. Identify parameters with outsized impact (these require tighter governance controls).
4. **Long-run dynamics:** Simulate 100+ reset cycles. Verify that the system does not exhibit long-run drift toward capture or collapse.

---

## Synthesis: How the Mechanisms Interlock

The six mechanisms are not independent -- they form an interlocking system where each mechanism reinforces the others:

```
Decay Function ──────────> Contribution Protocol
(prevents accumulation)    (rewards recent work)
       │                          │
       │                          ▼
       │                   Trust Calculus
       │                   (behavior-based reputation)
       │                          │
       ▼                          ▼
Seasonal Reset <────────── Coordination Game
(periodic redistribution)  (decides what to work on)
       │                          │
       │                          ▼
       └──────────────────> Anti-Capture Mechanism
                            (immune system)
```

- The **Decay Function** ensures that influence in the **Contribution Protocol** reflects recent work, not historical wealth.
- The **Contribution Protocol** feeds into the **Trust Calculus** by generating verifiable behavioral data.
- The **Trust Calculus** determines who can participate in the **Coordination Game** and with what weight.
- The **Coordination Game** allocates resources, including resources for maintaining the **Anti-Capture Mechanism**.
- The **Anti-Capture Mechanism** can trigger a **Seasonal Reset** when capture is detected.
- The **Seasonal Reset** re-initializes the **Decay Function** by accelerating the decay of accumulated power.

The system's resilience comes not from any single mechanism but from their mutual reinforcement. An attacker who circumvents one mechanism (e.g., gaming the Contribution Protocol) still faces the others (the Trust Calculus detects behavioral anomalies, the Anti-Capture Mechanism detects influence concentration, the Seasonal Reset periodically redistributes accumulated advantage).

This is the game-theoretic embodiment of Pyrrhic Lucidity's core commitment: **the design of the system matters more than the character of those who operate within it.** The mechanisms are designed so that the rational self-interested move -- for any individual node, including an adversarial one -- is the cooperative move. Not because cooperation is virtuous, but because the system makes defection expensive and cooperation profitable.

The fire does not ask whether the wood deserves to burn. It burns what is dead. These mechanisms burn accumulated power -- automatically, continuously, and without regard for the character of those who hold it.

---

*This document is version 0.1. The mechanisms described here are theoretical designs pending simulation, adversarial review, and iterative refinement. The commitment is not to the correctness of these specific parameters but to the process of transparent, adversarially-tested mechanism design. The parameters will change. The commitment to making power visible, bounded, and accountable will not.*
