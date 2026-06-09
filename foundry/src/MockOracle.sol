// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockOracle {

    int256 private price;
    uint80 private roundId;
    uint256 private updatedAt;

    constructor(int256 _price) {
        price = _price;
        roundId = 1;
        updatedAt = block.timestamp;
    }

    function setPrice(int256 _price) external {
        price = _price;
        roundId++;
        updatedAt = block.timestamp;
    }

    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        return (
            roundId,
            price,
            updatedAt,
            updatedAt,
            roundId
        );
    }
}