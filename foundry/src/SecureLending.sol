// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract SecureLending {

    IERC20 public immutable token;
    AggregatorV3Interface public immutable oracle;

    constructor(
        address _token,
        address _oracle
    ) {
        token = IERC20(_token);
        oracle = AggregatorV3Interface(_oracle);
    }

    function getPrice()
        public
        view
        returns (uint256)
    {
        (
            uint80 roundId,
            int256 answer,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = oracle.latestRoundData();

        require(answer > 0, "Invalid price");

        require(
            answeredInRound >= roundId,
            "Incomplete round"
        );

        require(
            block.timestamp - updatedAt < 1 days,
            "Stale price"
        );

        return uint256(answer);
    }

    function requiredCollateral(
        uint256 tokenAmount
    )
        public
        view
        returns (uint256)
    {
        uint256 price = getPrice();

        return
            (tokenAmount * price * 2)
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

        require(
            token.transfer(
                msg.sender,
                tokenAmount
            ),
            "Transfer failed"
        );
    }
}