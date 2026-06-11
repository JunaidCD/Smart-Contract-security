# Oracle Manipulation Attack on VulnerableLending

## 1. Vulnerable Pattern

* The lending protocol calculates collateral requirements using a spot price derived from a single liquidity pool.
* The protocol assumes the reserve ratio always represents the true market price.
* An attacker can manipulate pool reserves and influence the reported price.

---

## 2. Contract Setup

* The system consists of a vulnerable lending contract, a liquidity pair, and an ERC20 token.
* The lending contract uses the pair's reserves to determine token price and collateral requirements.
* The lending protocol holds a large amount of tokens available for borrowing.

---

## 3. Exploit Walkthrough

* The attacker manipulates the liquidity pool reserves to distort the reported token price.
* The manipulated reserves cause the protocol to calculate an artificially low token price.
* The reduced token price significantly lowers the collateral required for borrowing.
* The attacker supplies the reduced collateral amount and borrows all available protocol tokens.
* As a result, the lending contract is drained while the attacker spends only a small amount of collateral.


---

## 4. Why The Exploit Works

* At the smart contract level, the protocol blindly trusts the value returned by getReserves().
* No validation exists to determine whether the reserves were manipulated.
* Economically, reserve manipulation creates an artificial market price that benefits the attacker.

---

## 5. The Fix

* Replace the reserve-based spot price with a trusted oracle feed.
* Add validation checks for stale or incomplete oracle data.
* Ensure collateral calculations depend on an external price source that cannot be manipulated through reserve changes.

---

## 6. Reviewer's Checklist

* Does the protocol use a DEX spot price for collateral or lending decisions?
* Can an attacker manipulate reserves using large trades or flash loans?
* Does the protocol use a secure oracle or TWAP instead of a single pool price?
* Are oracle freshness and validity checks implemented before using price data?
