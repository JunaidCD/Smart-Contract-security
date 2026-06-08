# Week 2 Day 1 - Ethernaut Fundamentals

## Goal

Solve the following Ethernaut levels and understand the exact vulnerability instead of memorizing the solution:

1. Fallback
2. Delegation
3. Token
4. Telephone
5. Force

The objective was to think like an attacker and identify how ownership, balances, and assumptions can be abused.

---

# 1. Fallback

## Vulnerability

The contract contains two different ownership paths:

### Intended Path

```solidity
if (contributions[msg.sender] > contributions[owner]) {
    owner = msg.sender;
}
```

A user is supposed to become owner only if their contribution exceeds the current owner's contribution.

Since the owner starts with 1000 ETH worth of contributions, this is practically impossible.

### Hidden Path

```solidity
receive() external payable {
    require(msg.value > 0 && contributions[msg.sender] > 0);
    owner = msg.sender;
}
```

The receive function allows anyone with a non-zero contribution to become owner.

## Exploit

1. Call `contribute()` with a tiny amount of ETH.
2. Send ETH directly to the contract.
3. `receive()` executes.
4. Ownership transfers to the attacker.
5. Call `withdraw()` to drain the contract.

## Lesson

Always review every code path that modifies privileged variables such as `owner`.

## One-Line Bug Note

Ownership can be hijacked because `receive()` grants ownership to anyone with a non-zero contribution.

---

# 2. Delegation

## Vulnerability

The contract uses:

```solidity
delegatecall(msg.data)
```

inside its fallback function.

```solidity
fallback() external {
    address(delegate).delegatecall(msg.data);
}
```

The delegate contract contains:

```solidity
function pwn() public {
    owner = msg.sender;
}
```

## Important Concept

`delegatecall` executes another contract's code while using the current contract's storage.

Normal call:

```text
Delegate code
↓
Delegate storage changes
```

Delegatecall:

```text
Delegate code
↓
Delegation storage changes
```

## Exploit

1. Call `pwn()` on the Delegation contract.
2. Delegation does not have a `pwn()` function.
3. Fallback executes.
4. Fallback performs `delegatecall`.
5. Delegate's `pwn()` function runs.
6. Delegation's owner becomes the attacker.

## Lesson

Never allow arbitrary delegatecalls to untrusted code.

## One-Line Bug Note

delegatecall executes foreign code using local storage, allowing owner overwrite.

---

# 3. Token

## Vulnerability

The contract was written in Solidity 0.6.

```solidity
pragma solidity ^0.6.0;
```

The transfer check is:

```solidity
require(
    balances[msg.sender] - _value >= 0
);
```

The developer intended to verify that the sender has enough tokens.

## Problem

Before Solidity 0.8, arithmetic overflow and underflow did not revert automatically.

Example:

```text
20 - 21
```

Instead of becoming:

```text
-1
```

it wraps into a huge uint256 value.

This is called an underflow.

## Exploit

Initial balance:

```text
20 tokens
```

Transfer:

```text
21 tokens
```

Result:

```text
Huge uint256 balance
```

The attacker now owns more tokens than should exist.

## Lesson

Solidity versions before 0.8 require explicit overflow and underflow protection.

## One-Line Bug Note

Integer underflow allows users to create a huge token balance by transferring more tokens than they own.

---

# 4. Telephone

## Vulnerability

The contract relies on:

```solidity
tx.origin
```

instead of:

```solidity
msg.sender
```

```solidity
if (tx.origin != msg.sender) {
    owner = _owner;
}
```

## Important Concept

### msg.sender

Direct caller.

### tx.origin

The account that started the entire transaction.

Example:

```text
User
 ↓
Attack Contract
 ↓
Telephone
```

Inside Telephone:

```text
tx.origin = User

msg.sender = Attack Contract
```

## Exploit

1. Create an attack contract.
2. Call Telephone through the attack contract.
3. Condition becomes true.
4. Ownership changes to the attacker.

## Lesson

Authorization should use `msg.sender`, not `tx.origin`.

## One-Line Bug Note

Using tx.origin for authorization allows ownership changes through an intermediate contract.

---

# 5. Force

## Vulnerability

There is no bug in the contract code.

The bug is the developer's assumption.

The contract contains no payable functions:

```solidity
contract Force {}
```

A developer may incorrectly assume that such a contract cannot receive ETH.

## Important Concept

ETH can be forced into a contract using:

```solidity
selfdestruct()
```

Example:

```solidity
selfdestruct(payable(target));
```

When executed:

1. The attacking contract is destroyed.
2. Its ETH balance is transferred to the target.
3. The target receives ETH even if it has no payable functions.

## Why It Matters

Bad design:

```solidity
require(
    address(this).balance == expectedBalance
);
```

An attacker can force ETH into the contract and break this assumption.

## Better Design

Maintain internal accounting:

```solidity
totalDeposits
```

instead of relying on:

```solidity
address(this).balance
```

## Lesson

A contract cannot completely prevent forced ETH transfers.

## One-Line Bug Note

ETH can be forced into a contract through selfdestruct even when no payable functions exist.

---

# Day 1 Summary

Key concepts learned:

1. Dangerous receive and fallback logic.
2. delegatecall modifies local storage.
3. Integer underflow in older Solidity versions.
4. Difference between tx.origin and msg.sender.
5. Forced ETH transfers through selfdestruct.

These vulnerabilities represent some of the most fundamental smart contract security mistakes and frequently appear in audits, CTFs, and real-world exploits.
