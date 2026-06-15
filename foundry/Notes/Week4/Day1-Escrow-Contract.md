# Week 4 Day 1 - Escrow Contract Implementation

## Objective

The goal of today's exercise was to implement a simple escrow smart contract and write tests under time constraints.

The escrow contract acts as a trusted intermediary between a buyer and a seller. Instead of sending funds directly to the seller, the buyer deposits ETH into the contract. The funds remain locked until either the buyer releases them or an arbiter resolves a dispute.

---

# Escrow Workflow

## Participants

### Buyer

The buyer deposits ETH into the escrow contract.

### Seller

The seller receives the funds after successful completion of the agreement.

### Arbiter

The arbiter acts as a neutral third party and can resolve disputes if the buyer and seller disagree.

---

# Contract State Variables

```solidity
address public buyer;
address public seller;
address public arbiter;

uint256 public amount;

bool public funded;
bool public released;
bool public refunded;
```

### Purpose

* buyer → person paying for the service
* seller → person receiving payment
* arbiter → dispute resolver
* amount → ETH deposited
* funded → indicates deposit completed
* released → indicates payment released
* refunded → indicates refund completed

---

# Contract Functions

## deposit()

```solidity
function deposit() external payable
```

### Purpose

Allows the buyer to deposit ETH into the contract.

### Checks

* Caller must be buyer
* Contract must not already be funded
* ETH amount must be greater than zero

### State Changes

```text
funded = true
amount = msg.value
```

---

## release()

```solidity
function release() external
```

### Purpose

Allows the buyer to release payment to the seller after successful delivery.

### Checks

* Caller must be buyer
* Contract must be funded
* Payment must not already be released
* Refund must not already exist

### State Changes

```text
released = true
```

### Fund Movement

```text
Escrow Contract
        ↓
      Seller
```

---

## resolveDispute()

```solidity
function resolveDispute() external
```

### Purpose

Allows the arbiter to resolve a dispute and release funds to the seller.

### Checks

* Caller must be arbiter
* Contract must be funded
* Funds must not already be released
* Funds must not already be refunded

### State Changes

```text
released = true
```

### Fund Movement

```text
Escrow Contract
        ↓
      Seller
```

---

## refund()

```solidity
function refund() external
```

### Purpose

Allows the buyer to recover funds if the seller fails to deliver.

### Checks

* Caller must be buyer
* Contract must be funded
* Funds must not already be released
* Funds must not already be refunded

### State Changes

```text
refunded = true
```

### Fund Movement

```text
Escrow Contract
        ↓
       Buyer
```

---

# Test Cases

## testDeposit()

### Goal

Verify that buyer can deposit ETH.

### Assertions

```solidity
assertEq(address(escrow).balance, 1 ether);
assertTrue(escrow.funded());
```

---

## testRelease()

### Goal

Verify seller receives ETH after buyer releases payment.

### Assertions

```solidity
assertTrue(escrow.released());
```

Seller balance increases by deposited amount.

---

## testResolveDispute()

### Goal

Verify arbiter can release payment.

### Assertions

```solidity
assertTrue(escrow.released());
```

Seller receives ETH.

---

## testRefund()

### Goal

Verify buyer receives ETH back.

### Assertions

```solidity
assertTrue(escrow.refunded());
assertGt(buyerBalanceAfter, buyerBalanceBefore);
```

---

# Issue Encountered During Testing

The refund test initially failed.

Error:

```text
Refund failed
```

### Root Cause

The buyer address was:

```solidity
address buyer = address(this);
```

The test contract could not receive ETH because it lacked a payable receive() function.

When refund() attempted to transfer ETH back to the buyer, the transfer reverted.

### Resolution

Use a dedicated buyer address:

```solidity
address buyer = address(10);
```

and fund it with:

```solidity
vm.deal(buyer, 10 ether);
```

This more closely simulates a real externally owned account (EOA).

---

# Key Lessons Learned

1. Smart contracts should validate state transitions carefully.
2. Escrow systems are state machines.
3. Access control is critical.
4. Tests should verify both state changes and fund movement.
5. Foundry prank and deal cheatcodes are useful for simulating different users.
6. EOAs and contracts behave differently when receiving ETH.
7. Debugging failing tests is often more educational than writing the contract itself.

---

# Future Improvements

Possible enhancements:

* Arbiter can choose seller or buyer as winner.
* Support partial refunds.
* Add dispute creation mechanism.
* Add timeout-based refunds.
* Support ERC20 tokens.
* Add events for tracking escrow activity.

---

# Summary

Today I implemented a complete escrow contract with:

* Buyer deposits
* Seller payment release
* Arbiter dispute resolution
* Buyer refund path
* Four Foundry tests

The exercise reinforced access control, state management, ETH transfers, and smart contract testing practices.
