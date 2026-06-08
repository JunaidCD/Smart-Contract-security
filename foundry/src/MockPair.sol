// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockPair {

    uint112 public reserveToken;
    uint112 public reserveEth;

    constructor(
        uint112 _reserveToken,
        uint112 _reserveEth
    ) {
        reserveToken = _reserveToken;
        reserveEth = _reserveEth;
    }

    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        )
    {
        return (
            reserveToken,
            reserveEth,
            0
        );
    }

    function manipulatePrice(
        uint112 _reserveToken,
        uint112 _reserveEth
    ) external {
        reserveToken = _reserveToken;
        reserveEth = _reserveEth;
    }
}