# Week 4 Day 2 - Linear Vesting Contract and Core Security Concepts

## Objective

Today's goal was divided into two parts:

1. Implement a Linear Vesting Contract with:

   * Cliff period
   * Linear token release
   * Revocation mechanism

2. Explain four important smart contract security concepts:

   * delegatecall
   * Function Selectors
   * Reentrancy
   * Oracle Manipulation

---

# Part 1 - Linear Vesting Contract

## What is Vesting?

Vesting is a mechanism where tokens are released gradually over time instead of being transferred all at once.

It is commonly used for:

* Team token allocation
* Employee compensation
* Investor lockups
* DAO treasury distributions

---

## Example

Suppose:

```text id="2y3m3v"
Beneficiary = Alice

Total Tokens = 1000

Cliff = 1 Year

Duration = 4 Years
```

Token release:

```text id="3dvw9w"
0 - 1 Year      : 0 Tokens

2 Years         : 250 Tokens

3 Years         : 500 Tokens

4 Years         : 750 Tokens

5 Years         : 1000 Tokens
```

---

# Cliff Period

A cliff is the minimum waiting period before any tokens can be claimed.

Before cliff:

```text id="r7r5v0"
vestedAmount = 0
```

No tokens can be released.

---

# Linear Release

After the cliff period:

```text id="gmwr4u"
vestedAmount

=

totalAmount

×

timePassed

/

duration
```

Example:

```text id="x3pmq1"
Total Tokens = 1000

Duration = 4 years

Time Passed = 2 years

Vested

=

1000 × 2 / 4

=

500 Tokens
```

---

# Revocation

The contract owner can revoke the vesting schedule.

After revocation:

```text id="2j1i7u"
revoked = true
```

No more tokens are vested.

---

# Important State Variables

```solidity id="6a0trn"
address beneficiary;

uint256 totalAmount;

uint256 start;

uint256 cliff;

uint256 duration;

uint256 released;

bool revoked;
```

---

# Required Functions

## vestedAmount()

Returns:

```text id="ojc2mb"
How many tokens
should be unlocked
at the current time.
```

---

## release()

Transfers vested tokens to:

```text id="u87fzb"
beneficiary
```

and updates:

```text id="yl14jv"
released
```

---

## revoke()

Stops vesting permanently.

Only owner can call:

```text id="jlwmcg"
revoke()
```

---

# Test Cases

### testBeforeCliff()

Expected:

```text id="jl6iq1"
vestedAmount() == 0
```

---

### testAfterCliff()

Expected:

```text id="e6rfr0"
Partial vesting
```

---

### testAfterDuration()

Expected:

```text id="9opjlwm"
100% vested
```

---

### testRevoke()

Expected:

```text id="jlwm7x"
revoked == true
```

---

# Part 2 - delegatecall

## Definition

delegatecall executes code from another contract but uses:

```text id="vwg1kg"
Caller Storage

Caller Address

Caller Balance
```

The called contract's storage is NOT used.

---

## Use Cases

* Proxy Contracts
* Upgradeable Contracts
* Shared Logic Contracts

---

## Risk

If storage layouts differ:

```text id="x3r2yf"
Storage Corruption
```

can occur.

Incorrect delegatecall usage may allow:

```text id="jlwmu2"
Ownership takeover

Protocol compromise
```

---

# Function Selectors

A function selector is:

```text id="jlwm3x"
First 4 bytes

of

keccak256(
"functionSignature"
)
```

Example:

```text id="jlwm1u"
transfer(address,uint256)
```

Hash:

```text id="jlwmz8"
keccak256(...)
```

Selector:

```text id="jlsmw7"
0xa9059cbb
```

---

## Why Important?

Used for:

* External calls
* ABI encoding
* Proxy routing
* Low level calls

---

# Reentrancy

## Vulnerable Flow

```text id="jlwmu5"
Withdraw()

↓

Send ETH

↓

Attacker Fallback

↓

Withdraw Again

↓

Repeat

↓

Drain Contract
```

---

## Root Cause

External call before updating state.

---

## Fix

Checks-Effects-Interactions:

```text id="jlwm44"
Check Conditions

↓

Update State

↓

External Call
```

Or:

```text id="jlwmg0"
ReentrancyGuard
```

---

# Oracle Manipulation

## Vulnerable Pattern

```solidity id="jlwm8o"
pair.getReserves()
```

Protocol trusts:

```text id="jlwm77"
Reserve Ratio

=

Token Price
```

---

## Attack

Attacker:

```text id="jlwmfi"
Manipulates Reserves

↓

Fake Price

↓

Collateral Drops

↓

Borrow Cheaply

↓

Drain Protocol
```

---

## Fix

Use:

```solidity id="jlwm76"
oracle.latestRoundData()
```

Additional checks:

* Price > 0
* Not stale
* Valid round

---

# Lessons Learned

1. Vesting contracts are time-based state machines.
2. Cliff prevents early token claims.
3. Linear release distributes tokens gradually.
4. delegatecall executes foreign code in local storage.
5. Function selectors route external calls.
6. Reentrancy results from unsafe external interactions.
7. Oracle security is critical in DeFi.
8. Economic vulnerabilities can be as dangerous as coding bugs.

---

# Summary

Today I implemented a vesting mechanism with cliff and linear release logic and reviewed four important smart contract security concepts:

* delegatecall
* Function Selectors
* Reentrancy
* Oracle Manipulation

This improved both implementation skills and the ability to explain security concepts under pressure.
