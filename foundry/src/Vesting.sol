// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Vesting {
    address public owner;
    address public beneficiary;

    uint256 public totalAmount;
    uint256 public start;
    uint256 public cliff;
    uint256 public duration;

    uint256 public released;

    bool public revoked;

    constructor(
        address _beneficiary,
        uint256 _totalAmount,
        uint256 _start,
        uint256 _cliffDuration,
        uint256 _duration
    ) {
        owner = msg.sender;
        beneficiary = _beneficiary;

        totalAmount = _totalAmount;

        start = _start;

        cliff = start + _cliffDuration;

        duration = _duration;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function vestedAmount() public view returns (uint256) {

        if (revoked) {
            return released;
        }

        if (block.timestamp < cliff) {
            return 0;
        }

        if (block.timestamp >= start + duration) {
            return totalAmount;
        }

        uint256 timePassed = block.timestamp - start;

        return (totalAmount * timePassed) / duration;
    }

    function release() public {

        uint256 vested = vestedAmount();

        uint256 unreleased = vested - released;

        require(unreleased > 0, "No tokens to release");

        released += unreleased;

        // In a real contract:
        // token.transfer(beneficiary, unreleased);
    }

    function revoke() external onlyOwner {

        require(!revoked, "Already revoked");

        revoked = true;
    }
}