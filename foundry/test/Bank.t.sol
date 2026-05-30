// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import{Test} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract BankTest is Test{
    Bank bank;
    receive() external payable {}


    function setUp() public{
        bank = new Bank();
    }
    function testDeposit() public{
        bank.deposit{value: 1 ether}();
        assertEq(bank.balanceOf(address (this)) , 1 ether );
    }

    function testMultipleDeposit() public{
        bank.deposit{value: 1 ether}();
        bank.deposit{value: 2 ether}();
        assertEq(bank.balanceOf(address(this)), 3 ether);
    }

    function testWithdraw() public{
        bank.deposit{value: 3 ether}();
        bank.withdraw(1 ether);

        assertEq(bank.balanceOf(address(this)), 2 ether);
    }

    function testWithdrawFullBalance() public{
        bank.deposit{value: 5 ether}();
        bank.withdraw(5 ether);

        assertEq(bank.balanceOf(address(this)) , 0 );

    }

    function testOverWithdrawReverts() public{
        bank.deposit{value: 1 ether}();
        vm.expectRevert();
        bank.withdraw(2 ether);
    }

    function testBalanceStartsAtZero() public{
        assertEq(bank.balanceOf(address(this)) , 0 );
    }
}