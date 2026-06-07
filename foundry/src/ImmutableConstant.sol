// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ImmutableConstant {

    uint256 public constant MAX_SUPPLY = 1000000;

    address public immutable owner;

    uint256 public counter;

    constructor(address _owner) {
        owner = _owner;
    }

    function increment() public {
        counter++;
    }
}