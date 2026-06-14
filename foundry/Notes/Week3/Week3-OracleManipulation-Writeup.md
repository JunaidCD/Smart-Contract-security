# Breaking a Lending Protocol Through Oracle Manipulation: From Exploit to Fix

## Introduction

Oracle design is one of the most critical security components in decentralized finance. A protocol can have perfectly written Solidity code and still be vulnerable if it relies on incorrect pricing assumptions.

In this article, I demonstrate a simplified oracle manipulation attack against a lending protocol that derives token prices directly from a liquidity pool's reserves. I then show how the protocol can be secured using a trusted oracle feed and validation checks.

The proof-of-concept was implemented and tested using Foundry. The vulnerable contract, exploit test, patched contract, and defense validation test are available in the linked repository.

---

# 1. Vulnerable Pattern

The core vulnerability in VulnerableLending is that the protocol derives its token price directly from a single liquidity pool's reserve ratio. The lending contract assumes that the reserves returned by the liquidity pair accurately represent the market price of the token.

```solidity
function getPrice()
    public
    view
    returns (uint256)
{
    (
        uint112 reserveToken,
        uint112 reserveETH,

    ) = pair.getReserves();

    return
        (uint256(reserveETH) * 1e18)
        / uint256(reserveToken);
}
```

The problem is that liquidity pool reserves are not a trustworthy price source. An attacker can temporarily manipulate reserves through large swaps or flash-loan-funded trades. Since the protocol blindly trusts the values returned by `getReserves()`, any reserve manipulation directly affects the reported token price.

As a result, the protocol's collateral calculations become dependent on a value that an attacker can control.

---

# 2. Contract Setup

The vulnerable system consists of three main components:

1. An ERC20 token that can be borrowed.
2. A liquidity pair that provides reserve information.
3. The VulnerableLending contract.

The lending protocol uses the liquidity pair as its price oracle. Instead of using a trusted oracle such as Chainlink, it calculates price directly from the reserve ratio.

The collateral requirement is calculated using the following function:

```solidity
function requiredCollateral(
    uint256 tokenAmount
)
    public
    view
    returns (uint256)
{
    uint256 price = getPrice();

    return (tokenAmount * price * 2)
        / 1e18;
}
```

The protocol requires borrowers to provide collateral worth approximately twice the value of the borrowed tokens. This design appears safe at first glance, but the security of the entire system depends on the correctness of the price returned by `getPrice()`.

Borrowing is performed through the following function:

```solidity
function borrow(
    uint256 tokenAmount
)
    external
    payable
{
    uint256 collateral =
        requiredCollateral(
            tokenAmount
        );

    require(
        msg.value >= collateral,
        "Not enough collateral"
    );

    token.transfer(
        msg.sender,
        tokenAmount
    );
}
```

If the calculated collateral becomes artificially small, an attacker can borrow a large amount of tokens while depositing very little ETH.

---

# 3. Exploit Walkthrough

The attack begins by manipulating the liquidity pool reserves.

Assume the original reserves are:

```text
1000 TOKEN
100 ETH
```

The protocol calculates price as:

```text
Price = reserveETH / reserveToken
Price = 100 / 1000
Price = 0.1 ETH per token
```

Under these conditions, borrowing a large number of tokens requires a large amount of collateral.

The attacker then performs a large swap, often funded by a flash loan, to drastically increase the token reserves in the pool.

After manipulation:

```text
100,000,000 TOKEN
100 ETH
```

The protocol now calculates:

```text
Price = 100 / 100,000,000
Price = 0.000001 ETH per token
```

Because the lending contract trusts this manipulated value, the collateral requirement drops significantly.

The attacker now calls:

```solidity
borrow(tokenAmount);
```

The protocol computes collateral using the manipulated price and accepts a much smaller ETH deposit than intended.

As a result, the attacker is able to borrow all available protocol tokens while providing only a fraction of the collateral that should have been required.

To validate the vulnerability, I implemented a proof-of-concept exploit in Foundry. The test manipulated the liquidity pool reserves, reduced the collateral requirement, borrowed all available protocol tokens, and verified that the lending contract's token balance became zero.

The attack succeeds because reserve manipulation changes the price used by the lending protocol, and that manipulated price directly influences collateral calculations.


## Attack Flow

![Oracle Manipulation Attack Flow](images/oracle-attack-flow.png)

*Figure 1: Oracle manipulation attack against VulnerableLending.*

---

# 4. Why The Exploit Works

The exploit succeeds because the lending protocol trusts a price source that can be manipulated by external users. The contract assumes that the reserve ratio returned by the liquidity pair always reflects the true market price of the token.

From a technical perspective, the protocol blindly trusts the output of `getReserves()` when calculating token price. The contract never verifies whether the reserves were recently manipulated or whether the reported price is reasonable.

```solidity
function getPrice()
    public
    view
    returns (uint256)
{
    (
        uint112 reserveToken,
        uint112 reserveETH,

    ) = pair.getReserves();

    return
        (uint256(reserveETH) * 1e18)
        / uint256(reserveToken);
}
```

Because the collateral requirement depends directly on this value, any manipulation of the reserves immediately affects how much collateral must be deposited.

From an economic perspective, the attacker creates a false market price. By drastically increasing the token reserves while keeping the ETH reserves unchanged, the attacker makes the token appear significantly cheaper than it actually is. The lending protocol treats this artificial price as legitimate and therefore underestimates the collateral required for borrowing.

The protocol does not fail because of a Solidity bug or access control issue. Instead, it fails because it relies on a flawed economic assumption: that a single liquidity pool's reserve ratio always represents a trustworthy market price.

---

# 5. The Fix

The root cause of the vulnerability is the use of a manipulable spot price derived from liquidity pool reserves. To prevent this attack, the protocol must obtain pricing information from a source that cannot be directly influenced through reserve manipulation.

In the patched version, the protocol replaces the reserve-based pricing mechanism with a trusted oracle feed.

Instead of using:

```solidity
pair.getReserves()
```

the protocol retrieves price information from an oracle through:

```solidity
oracle.latestRoundData()
```

Unlike liquidity pool reserves, Chainlink-style oracle feeds aggregate pricing information from external sources and are not directly affected by reserve manipulation in a single pool.

Additional validation checks are also performed before accepting oracle data:

* The reported price must be greater than zero.
* The oracle round must be complete.
* The oracle data must not be stale.

These checks help ensure that the protocol only uses valid and up-to-date pricing information.

With this design, manipulating liquidity pool reserves no longer affects the value used for collateral calculations. As a result, the attack path used against the vulnerable version is eliminated.

---

# 6. Reviewer's Checklist

When reviewing a lending protocol or collateralized borrowing system, the following questions can help identify similar vulnerabilities.

## Price Source

* Where does the protocol obtain its price data?
* Does the protocol rely on a single liquidity pool for pricing?
* Is a trusted oracle or TWAP used instead of a spot price?

## Manipulation Risk

* Can an attacker influence the reported price through large trades?
* Can flash loans be used to temporarily manipulate reserves?
* Does the protocol perform any validation on the returned price?

## Oracle Security

* Are stale oracle values rejected?
* Are incomplete oracle rounds rejected?
* Does the protocol verify that the reported price is valid?

## Collateral Logic

* Does collateral calculation depend directly on the reported price?
* What happens if the price suddenly drops or increases?
* Can incorrect pricing allow users to borrow assets with insufficient collateral?

Reviewing these areas can help identify oracle manipulation vulnerabilities before they can be exploited in production systems.

---

# Conclusion

This vulnerability demonstrates the danger of using a single liquidity pool as a price oracle for lending protocols. By manipulating pool reserves, an attacker can distort the reported token price and force the protocol to accept insufficient collateral.

In this case, the issue was not caused by a Solidity programming error but by an incorrect economic assumption about how prices should be obtained. The smart contract executed exactly as written, but the pricing model itself was flawed.

Replacing the spot-price mechanism with a trusted oracle feed eliminates the attack path and significantly improves protocol security. This exercise highlights why oracle design remains one of the most important aspects of decentralized finance security.
