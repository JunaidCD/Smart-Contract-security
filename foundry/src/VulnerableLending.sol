// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPair {
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32
        );
}

contract VulnerableLending {

    IERC20 public immutable token;
    IPair public immutable pair;

    constructor(
        address _token,
        address _pair
    ) {
        token = IERC20(_token);
        pair = IPair(_pair);
    }

    /// reserve0 = TOKEN
    /// reserve1 = ETH
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
}