// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/CoverageTrap.sol";

contract CoverageTrapInvariantTest is Test {

    CoverageTrap trap;

    address alice =
        address(1);

    address bob =
        address(2);

    function setUp() public {

        trap = new CoverageTrap();

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        vm.prank(alice);
        trap.deposit{value: 1 ether}();

        vm.prank(bob);
        trap.deposit{value: 1 ether}();
    }

    function testInvariant_TotalBalancesNeverExceedContractBalance()
        public
    {
        uint256 totalUserBalances =
            trap.balanceOf(alice)
            +
            trap.balanceOf(bob);

        uint256 contractBalance =
            address(trap).balance;

        assertLe(
            totalUserBalances,
            contractBalance
        );
    }
}