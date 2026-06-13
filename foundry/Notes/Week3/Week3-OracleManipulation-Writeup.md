# Oracle Manipulation Attack on VulnerableLending

## 1. Vulnerable Pattern

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

The problem is that liquidity pool reserves are not a trustworthy price source. An attacker can temporarily manipulate reserves through large trades or flash loans. Since the protocol blindly trusts the values returned by `getReserves()`, any reserve manipulation directly affects the reported token price.

As a result, the protocol's collateral calculations become dependent on a value that an attacker can control.

---

## 2. Contract Setup

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

## 3. Exploit Walkthrough

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

The attacker then performs a large trade or uses a flash loan to drastically increase the token reserves in the pool.

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

The attack succeeds because reserve manipulation changes the price used by the lending protocol, and that manipulated price directly influences collateral calculations.
