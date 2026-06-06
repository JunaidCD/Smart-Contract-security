# Week 2 Day 2 - Function Selectors and Proxies

## Goal

Understand how function selectors work, how proxy contracts use delegatecall, and why storage collisions and selector clashes can break upgradeable contracts.

---

# Function Selectors

A function selector is the first 4 bytes of:

keccak256(function signature)

Formula:

Selector = bytes4(keccak256("functionName(parameterTypes)"))

Example:

transfer(address,uint256)

↓

keccak256(...)

↓

Take the first 4 bytes

↓

0xa9059cbb

The EVM uses the selector to determine which function should be executed.

Without selectors, the EVM would not know whether a user wants to call transfer(), approve(), balanceOf(), or any other function.

---

# Selectors Generated

### transfer(address,uint256)

Selector:

0xa9059cbb

Command:

cast sig "transfer(address,uint256)"

---

### approve(address,uint256)

Selector:

0x095ea7b3

Command:

cast sig "approve(address,uint256)"

---

### balanceOf(address)

Selector:

0x70a08231

Command:

cast sig "balanceOf(address)"

---

# Important Observation

The selector depends on the entire function signature.

Example:

transfer(address,uint256)

and

transfer(address,uint8)

produce different selectors because the parameter types are different.

Even though the function name is the same, the signature changes and therefore the hash changes.

---

# Proxy Architecture

A proxy pattern separates storage from logic.

Users interact with the proxy contract.

The proxy forwards calls to an implementation contract using delegatecall.

Structure:

Users
↓
Proxy
↓ delegatecall
Implementation

The implementation contains the business logic.

The proxy contains the actual storage and state.

---

# Why delegatecall Matters

delegatecall executes another contract's code while using the caller's storage.

This means:

Implementation code

*

Proxy storage

When implementation code updates variables, it actually modifies the proxy's storage slots.

This is why upgrades are possible while keeping the same contract address and state.

---

# Storage Collision

A storage collision happens when an upgraded implementation changes the storage layout.

Example:

V1

address owner;   // slot 0
uint256 balance; // slot 1

V2

uint256 balance; // slot 0
address owner;   // slot 1

The proxy still contains the old data, but the new implementation interprets those slots differently.

As a result:

* owner may become garbage data
* balance may become garbage data
* contract state becomes corrupted

## Lesson

Never reorder storage variables in upgradeable contracts.

Only append new variables at the end.

---

# Selector Clash

A selector clash happens when:

* A proxy function
* An implementation function

share the same selector.

When a call arrives, the proxy may route it incorrectly because both functions appear identical at the selector level.

This can cause:

* User calls reaching proxy admin functions
* Admin calls reaching implementation functions
* Unexpected behavior

## Why Transparent Proxies Exist

Transparent proxies separate admin calls from user calls.

If caller is admin:

Proxy functions execute.

If caller is not admin:

Calls are forwarded to the implementation.

This prevents selector clashes from affecting normal users.

---

# Key Concepts Learned

1. Function selectors are the first 4 bytes of keccak256(function signature).
2. Different parameter types produce different selectors.
3. Proxies store state while implementations store logic.
4. delegatecall executes implementation code using proxy storage.
5. Storage collisions corrupt state after upgrades.
6. Selector clashes can route calls incorrectly.
7. Transparent proxies separate admin and user interactions to avoid clashes.

---

# One-Line Definitions

Storage Collision:

The storage layout changed after an upgrade, causing variables to read incorrect storage slots and corrupt state.

Selector Clash:

A proxy function and an implementation function share the same selector, causing calls to be routed incorrectly.
