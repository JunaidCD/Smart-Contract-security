# Smart Contract Security Journey

A hands-on smart contract security repository built using Foundry. This repository documents my learning journey through Solidity security concepts, exploit development, protocol analysis, and defensive smart contract design.

---

# Repository Overview

This repository contains:

* Solidity security exercises
* Vulnerable smart contracts
* Exploit proof-of-concepts
* Patched implementations
* Security notes and writeups
* Foundry-based tests

The primary case study currently included is an Oracle Manipulation Attack against a vulnerable lending protocol and its secure remediation.

---

# Oracle Manipulation Case Study

## Summary

This project demonstrates how a lending protocol can be drained when it relies on a manipulable spot price derived directly from a liquidity pool's reserves.

The repository includes:

* Vulnerable lending protocol
* Oracle manipulation exploit
* Secure oracle implementation
* Defense validation tests

---

# Vulnerable Flow

```text
Attacker
    │
    ▼
Manipulate Pool Reserves
    │
    ▼
getReserves()
Returns Fake Price
    │
    ▼
Collateral Requirement Drops
    │
    ▼
Borrow Protocol Tokens
    │
    ▼
Protocol Drained
```

---

# Secure Flow

```text
Attacker
    │
    ▼
Manipulate Pool Reserves
    │
    ▼
Pool Price Changes
    │
    ▼
Chainlink Oracle Price Unchanged
    │
    ▼
Collateral Requirement Unchanged
    │
    ▼
Attack Fails
```

---

# Project Structure

```text
foundry
│
├── src
│   ├── VulnerableLending.sol
│   ├── SecureLending.sol
│   ├── MockOracle.sol
│   ├── MockPair.sol
│   ├── MockERC20.sol
│   ├── ImmutableConstant.sol
│   ├── CoverageTrap.sol
│   └── FinBridgeLending.sol
│
├── test
│   ├── Exploit.t.sol
│   ├── SecureExploit.t.sol
│   ├── ImmutableConstant.t.sol
│   ├── CoverageTrap.t.sol
│   ├── CoverageTrapInvariant.t.sol
│   ├── Fork.t.sol
│   └── FinBridgeTest.t.sol
│
├── Notes
│   ├── Week1
│   ├── Week2
│   └── Week3
│
└── image
    └── oracle-attack-flow.png
```

---

# Key Contracts

## VulnerableLending.sol

A deliberately vulnerable lending protocol that calculates token prices directly from liquidity pool reserves.

### Vulnerability

```solidity
price = reserveETH / reserveToken
```

Because liquidity pool reserves can be manipulated, the protocol accepts incorrect collateral values.

---

## SecureLending.sol

Patched version of the lending protocol.

### Security Improvements

* Uses oracle pricing
* Validates oracle response
* Rejects stale data
* Rejects invalid rounds

This prevents reserve manipulation attacks from affecting collateral calculations.

---

# Tests

## Exploit Test

```bash
forge test --match-contract ExploitTest -vvvv
```

Demonstrates:

* Reserve manipulation
* Price distortion
* Collateral reduction
* Protocol drain

Expected Result:

```text
Protocol balance before:
1000000000000000000000000

Protocol balance after:
0
```

---

## Secure Defense Test

```bash
forge test --match-contract SecureExploitTest -vvvv
```

Demonstrates:

* Oracle manipulation attempt
* Collateral remains correct
* Attack fails

Expected Result:

```text
Attack prevented
Protocol balance unchanged
```

---

# Writeups

## Oracle Manipulation Attack

Article:

https://dev.to/junaidmollah01/breaking-a-lending-protocol-through-oracle-manipulation-from-exploit-to-fix-3p2o

Repository Case Study:

* Vulnerable implementation
* Exploit proof-of-concept
* Secure implementation
* Defense validation

---

# Learning Notes

## Week 1

* Ethernaut Fundamentals
* Solidity Basics
* Security Foundations

## Week 2

* Function Selectors
* Proxies
* Storage Layout
* Oracle Manipulation
* Oracle Defenses

## Week 3

* Security Writeups
* Exploit Documentation
* Public Research Publication

---

# Running Locally

## Build

```bash
forge build
```

## Run All Tests

```bash
forge test
```

## Run Exploit

```bash
forge test --match-contract ExploitTest -vvvv
```

## Run Secure Defense Test

```bash
forge test --match-contract SecureExploitTest -vvvv
```

---

# Tech Stack

* Solidity
* Foundry
* OpenZeppelin
* Chainlink Oracle Pattern
* Git & GitHub

---

# Future Work

Planned topics:

* Reentrancy Attacks
* Flash Loan Attacks
* Governance Attacks
* Signature Replay Issues
* Upgradeability Vulnerabilities
* Formal Verification
* Advanced Audit Findings

---

# Disclaimer

This repository is intended for educational and research purposes only.

All vulnerable contracts are intentionally insecure and should never be used in production environments.

---

# Author

Junaid

Smart Contract Security Research Journey

GitHub:
https://github.com/JunaidCD

LinkedIn:
https://www.linkedin.com/in/junaid-mollah-a59150319/

X:
https://x.com/JunaidMollah5
