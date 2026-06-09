# Week 2 Day 5 - Oracle Defense

## Goal

The objective of Day 5 was to fix the vulnerable lending protocol created on Day 4 and prove that the same oracle manipulation attack can no longer drain funds.

The vulnerable protocol trusted a spot price derived directly from a liquidity pool's reserves. Since reserves can be manipulated through large trades or flash loans, the reported price could be artificially changed, causing collateral requirements to become incorrect.

The secure protocol replaces the manipulable spot price with a trusted oracle price source and includes additional validation checks.

---

## Day 4 Recap

The vulnerable protocol calculated token price using:

price = reserveETH / reserveToken

The value was obtained from:

pair.getReserves()

Attack flow:

1. Attacker manipulates pool reserves.
2. Reserve ratio changes.
3. Reported token price collapses.
4. Required collateral becomes extremely low.
5. Attacker borrows a large amount of tokens.
6. Protocol is drained.

The root cause was trusting a manipulable spot price.

---

## Why Spot Prices Are Dangerous

A liquidity pool only represents the current reserve ratio inside that pool.

An attacker can temporarily change reserves by performing large swaps or using flash loans.

Because the protocol directly trusts those reserves, it also trusts the manipulated price.

As a result:

Manipulated reserves → Manipulated price → Incorrect collateral → Protocol loss

---

## Why Flash Loans Make Attacks Cheap

Flash loans allow an attacker to borrow a large amount of capital without owning it beforehand.

The attacker:

1. Borrows funds.
2. Manipulates the pool.
3. Exploits the protocol.
4. Repays the flash loan.
5. Keeps the profit.

Because the capital only exists during one transaction, the attack can be executed with very little starting capital.

The flash loan is not the vulnerability.

The real vulnerability is trusting a manipulable price source.

---

## MockOracle.sol

A MockOracle contract was created to simulate a Chainlink price feed.

The oracle stores:

* price
* roundId
* updatedAt

The oracle exposes:

latestRoundData()

which returns information in the same format used by Chainlink price feeds.

Purpose:

Allow SecureLending to obtain prices from an oracle instead of a liquidity pool.

---

## SecureLending.sol

SecureLending is the patched version of VulnerableLending.

Major change:

Instead of reading:

pair.getReserves()

it reads:

oracle.latestRoundData()

The protocol now relies on oracle data rather than liquidity pool reserves.

This prevents reserve manipulation from affecting collateral calculations.

---

## Oracle Security Checks

### 1. Positive Price Check

require(answer > 0)

Purpose:

Reject invalid oracle values such as:

* 0
* Negative prices

The protocol should never accept a non-positive price.

---

### 2. Round Completeness Check

require(answeredInRound >= roundId)

Purpose:

Ensure the oracle update is complete.

Without this check, the protocol could accidentally use incomplete oracle data.

---

### 3. Staleness Check

require(block.timestamp - updatedAt < 1 days)

Purpose:

Ensure the price data is recent.

Old oracle data can become inaccurate and create opportunities for incorrect collateral calculations.

The protocol rejects stale prices.

---

## Why The Day 4 Attack No Longer Works

Day 4 attack:

Manipulate reserves

↓

Price changes

↓

Collateral changes

↓

Protocol drained

Day 5:

Manipulate reserves

↓

Oracle price unchanged

↓

Collateral unchanged

↓

Attack fails

The attacker can still modify the liquidity pool reserves, but the lending protocol no longer uses those reserves for pricing.

Therefore the manipulation has no effect on borrowing requirements.

---

## Security Improvement

Old design:

Price Source:

* Liquidity pool reserves

Risk:

* Manipulable

Result:

* Protocol drain possible

New design:

Price Source:

* Oracle feed

Risk:

* Much harder to manipulate

Result:

* Reserve manipulation no longer affects protocol pricing

---

## Key Lessons Learned

1. A single DEX spot price should not be used as a lending oracle.

2. Liquidity pool reserves can be manipulated temporarily.

3. Flash loans provide cheap temporary capital for attacks.

4. Chainlink-style oracle feeds reduce manipulation risk.

5. Oracle data should be validated before use.

6. Freshness checks and round-completeness checks are critical.

7. A secure oracle breaks the attack path used in Day 4.

---

## Final Takeaway

The Day 4 exploit succeeded because the protocol trusted a manipulable spot price derived from pool reserves.

The Day 5 patch replaced the spot price with a secure oracle feed and added validation checks.

As a result, manipulating pool reserves no longer changes collateral calculations, preventing the lending protocol from being drained through the same attack.
