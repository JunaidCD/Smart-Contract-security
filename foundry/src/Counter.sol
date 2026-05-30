// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 public count;

    function increment() public {
        count++;
    }

    function decrement() public {
        require(count > 0, "Counter cannot go below zero");
        count--;
    }

    function reset() public {
        count = 0;
    }
}