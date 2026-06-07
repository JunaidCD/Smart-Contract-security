# Week 2 Day 3 - Immutable vs Constant vs Storage

## constant

Used when the value is known before deployment and will never change.

Example:

uint256 public constant MAX_SUPPLY = 1000000;

Characteristics:

* Determined at compile time
* Embedded directly into bytecode
* Uses no storage slot
* Cannot be assigned in the constructor
* Cheapest option

---

## immutable

Used when the value is unknown before deployment but becomes fixed forever after deployment.

Example:

address public immutable owner;

constructor(address _owner) {
owner = _owner;
}

Characteristics:

* Assigned exactly once in the constructor
* Embedded into deployed runtime code
* Uses no normal storage slot
* Can accept constructor arguments
* Very gas efficient

---

## Storage Variable

Used when the value must change during the contract's lifetime.

Example:

uint256 public counter;

Characteristics:

* Stored in EVM storage slots
* Can be modified after deployment
* Uses SSTORE when updated
* Most expensive option

---

## Evidence

Storage Layout:

Only `counter` appeared in the storage layout.

This proves:

* `constant` does not use storage.
* `immutable` does not use storage.
* Normal state variables occupy storage slots.

Gas Report:

MAX_SUPPLY() : 303 gas

owner() : 395 gas

increment() : 43,504 gas

This demonstrates that reading constants and immutables is much cheaper than modifying storage.

---

## When To Use Each

constant:
Use when the value is known before deployment and never changes.

immutable:
Use when the value is chosen during deployment and never changes.

storage:
Use when the value must be updated after deployment.
