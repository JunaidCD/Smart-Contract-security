// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {
    address public buyer;
    address public seller;
    address public arbiter;

    uint256 public amount;

    bool public funded;
    bool public released;
    bool public refunded;

    constructor(address _seller, address _arbiter) {
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
    }

    function deposit() external payable {
        require(msg.sender == buyer, "Not buyer");
        require(!funded, "Already funded");
        require(msg.value > 0, "No ETH sent");

        amount = msg.value;
        funded = true;
    }

    function release() external {
        require(msg.sender == buyer, "Not buyer");
        require(funded, "Not funded");
        require(!released, "Already released");
        require(!refunded, "Already refunded");

        released = true;

        (bool success, ) = seller.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function resolveDispute() external {
        require(msg.sender == arbiter, "Not arbiter");
        require(funded, "Not funded");
        require(!released, "Already released");
        require(!refunded, "Already refunded");

        released = true;

        (bool success, ) = seller.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function refund() external {
        require(msg.sender == buyer, "Not buyer");
        require(funded, "Not funded");
        require(!released, "Already released");
        require(!refunded, "Already refunded");

        refunded = true;

        (bool success, ) = buyer.call{value: amount}("");
        require(success, "Refund failed");
    }
}