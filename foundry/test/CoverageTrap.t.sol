// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CoverageTrap.sol";


contract CoverageTrapTest is Test {

    CoverageTrap trap;
    receive() external payable {}
    fallback() external payable {}

    function setUp() public {

        trap = new CoverageTrap();
    }

    function testDeposit() public {

        trap.deposit{value: 1 ether}();

        assertEq(
            trap.balanceOf(address(this)),
            999900000000000000
        );
    }

    function testWithdraw() public {

        trap.deposit{value: 1 ether}();

        trap.withdraw(
            999900000000000000
        );

        assertEq(
            trap.balanceOf(address(this)),
            0
        );
    }

    function testWithdrawRevert() public {

        vm.expectRevert();

        trap.withdraw(1 ether);
    }
}