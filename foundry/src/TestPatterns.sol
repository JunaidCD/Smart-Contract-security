// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

error Unauthorized();

contract TestPatterns {
    address public owner;
    uint256 public number;

    event NumberChanged(address indexed user, uint256 newNumber);

    constructor() {
        owner = msg.sender;
    }

    function setNumber(uint256 _number) public {
        if (msg.sender != owner) {
            revert Unauthorized();
        }

        number = _number;
        emit NumberChanged(msg.sender, _number);
    }

    function setPositiveNumber(uint256 _number) public {
        require(_number > 0, "Number must be positive");
        number = _number;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }
}