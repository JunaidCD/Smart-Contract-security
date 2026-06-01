// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CoverageTrap {

    mapping(address => uint256) public balances;

    function deposit() public payable {

        uint256 fee =
            msg.value * 1 / 10000;

        uint256 credited =
            msg.value - fee;

        balances[msg.sender] += credited;
    }

    function withdraw(uint256 amount) public {

        require(
            balances[msg.sender] >= amount,
            "Insufficient balance"
        );

        balances[msg.sender] -= amount;

        payable(msg.sender).transfer(amount);
    }

    function balanceOf(address user)
        public
        view
        returns (uint256)
    {
        return balances[user];
    }
}