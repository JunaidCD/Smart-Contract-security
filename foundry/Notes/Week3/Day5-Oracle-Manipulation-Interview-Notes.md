# Day 5 - Oracle Manipulation Interview Notes

## Checkpoint 1 - Explain the Vulnerability

### What is Oracle Manipulation?

Oracle manipulation occurs when an attacker influences the price source used by a protocol. If a protocol relies on a manipulable source such as a single liquidity pool, the attacker can temporarily change the reported price and force the protocol to make incorrect decisions.

### Why is using getReserves() dangerous?

The `getReserves()` function returns the current reserves of a liquidity pool. These reserves can be changed through large swaps or flash-loan-funded trades. If a protocol uses these reserves directly as a price oracle, an attacker can manipulate the price calculation.

### Why can a flash loan make the attack cheap?

A flash loan allows an attacker to borrow a large amount of capital without upfront funds, as long as the loan is repaid within the same transaction. This makes reserve manipulation extremely cheap because the attacker does not need to permanently own the capital used for the attack.

### How does the collateral calculation become incorrect?

The lending protocol calculates collateral requirements using the manipulated price. When the attacker makes the token appear cheaper than it actually is, the protocol believes less collateral is required and allows borrowing with insufficient collateral.

### Why is this an economic vulnerability instead of a Solidity bug?

The Solidity code executes exactly as written. The failure occurs because the protocol assumes that a single liquidity pool always provides a trustworthy price. The vulnerability comes from flawed economic assumptions rather than a coding error.

---

## Checkpoint 2 - Explain the Fix

### Why does Chainlink prevent this attack?

Chainlink-style oracle feeds obtain pricing information from multiple external sources rather than a single liquidity pool. Manipulating one pool does not affect the oracle price used by the protocol.

### What does latestRoundData() return?

`latestRoundData()` returns information about the latest oracle update, including:

* Round ID
* Price (answer)
* Started At timestamp
* Updated At timestamp
* Answered In Round

The protocol uses this information to verify the validity of the oracle data.

### Why check for stale prices?

A stale price may no longer reflect current market conditions. Using outdated prices can cause incorrect collateral calculations and create additional risk for the protocol.

### Why check round completeness?

The protocol should verify that the oracle round has been completed successfully. Incomplete rounds may contain invalid or unreliable data.

### What could still go wrong even with an oracle?

Even with a secure oracle, risks remain:

* Oracle outages
* Stale data
* Misconfigured feeds
* Incorrect decimal handling
* Integration mistakes within the protocol

Oracle security reduces manipulation risk but does not eliminate all risks.

---

# Interview Revision Sheet

## Vulnerability

The protocol derives token prices directly from a liquidity pool's reserve ratio using `getReserves()`.

## Root Cause

The protocol trusts a manipulable spot price from a single liquidity pool.

## Impact

An attacker can artificially lower collateral requirements and borrow assets with insufficient collateral, potentially draining protocol funds.

## Exploit Path

1. Manipulate pool reserves.
2. Report a false token price.
3. Reduce collateral requirement.
4. Borrow protocol assets.
5. Drain protocol liquidity.

## Fix

Replace reserve-based pricing with a trusted oracle feed and validate:

* Price > 0
* Round completeness
* Freshness of data

## Lessons Learned

* Spot prices are easily manipulated.
* Flash loans make manipulation inexpensive.
* Oracle design is critical in DeFi security.
* Economic assumptions can be as dangerous as coding mistakes.
* Trusted oracles and validation checks significantly improve protocol security.
