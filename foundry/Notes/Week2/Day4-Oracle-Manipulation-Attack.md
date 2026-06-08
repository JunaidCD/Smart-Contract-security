# Week 2 Day 4 - Oracle Manipulation Attack

## Goal

Learn how a lending protocol can be drained when it trusts a manipulable spot price from a liquidity pool instead of a secure oracle.

---

## Contracts Built

### MockERC20.sol

A simple ERC20 token used as the asset stored in the lending protocol.

Key points:

* Inherits from OpenZeppelin ERC20.
* Includes a mint function for creating tokens during tests.
* Represents the valuable asset that the attacker wants to steal.

---

### MockPair.sol

A simplified Uniswap-style pair contract.

Key points:

* Stores reserveToken and reserveEth.
* Exposes getReserves() similar to a real AMM pair.
* Includes manipulatePrice() to simulate reserve changes.

Purpose:

* Acts as the protocol's price oracle.
* Demonstrates how reserve manipulation affects price calculations.

---

### VulnerableLending.sol

A lending protocol that calculates collateral requirements from a spot price.

Price calculation:

price = reserveETH / reserveToken

Collateral calculation:

requiredCollateral =
tokenAmount × price × 2

Key vulnerability:

The protocol trusts getReserves() from a single liquidity pool and assumes the resulting spot price is correct.

---

## Initial State

Liquidity Pair:

* 1000 TOKEN
* 100 ETH

Price:

1 TOKEN = 0.1 ETH

Lending Protocol:

* 1,000,000 TOKEN available to borrow

Attacker:

* 100 ETH

---

## Attack Process

### Step 1

Attacker becomes the caller using:

vm.startPrank(attacker)

This makes all subsequent calls execute as the attacker.

---

### Step 2

Manipulate the pair reserves.

Original reserves:

1000 TOKEN
100 ETH

Manipulated reserves:

100,000,000 TOKEN
100 ETH

---

### Step 3

Price calculation changes.

Original price:

100 / 1000

= 0.1 ETH per TOKEN

Manipulated price:

100 / 100,000,000

= 0.000001 ETH per TOKEN

The protocol now believes the token is nearly worthless.

---

### Step 4

Collateral requirements collapse.

Before manipulation:

Borrowing all protocol tokens would require an enormous amount of ETH.

After manipulation:

requiredCollateral()

returns only 2 ETH.

---

### Step 5

Borrow all protocol tokens.

The attacker sends the manipulated collateral amount and receives every token held by the protocol.

---

### Step 6

Verify protocol drain.

Before attack:

Protocol balance = 1,000,000 TOKEN

After attack:

Protocol balance = 0 TOKEN

Assertion:

assertEq(afterBalance, 0)

The exploit succeeds.

---

## Vulnerability

The protocol derives collateral requirements directly from a spot price calculated using a single liquidity pool reserve ratio.

An attacker can manipulate reserves and force the protocol to use an incorrect price.

---

## Why Flash Loans Matter

Flash loans are not the vulnerability.

The real vulnerability is trusting a manipulable spot price.

Flash loans simply provide enough capital to perform the manipulation.

---

## Security Lesson

Never use:

getReserves()

from a single liquidity pool as the sole price oracle for lending, collateral, borrowing, liquidation, or treasury calculations.

Safer approaches include:

* Chainlink Price Feeds
* TWAP (Time-Weighted Average Price)
* Multiple independent oracle sources

---

## Key Takeaway

A lending protocol that trusts a manipulable spot price can be drained because reserve manipulation causes collateral requirements to become artificially low.
