// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TestPatterns, Unauthorized} from "../src/TestPatterns.sol";

contract TestPatternsTest is Test {
    TestPatterns pattern;

    address owner = address(this);
    address alice = address(1);
    address bob = address(2);

    event NumberChanged(address indexed user, uint256 newNumber);

    function setUp() public {
        pattern = new TestPatterns();
    }

    function testPrankOwnerCanSetNumber() public {
        vm.prank(owner);

        pattern.setNumber(100);

        assertEq(pattern.number(), 100);
    }

    function testPrankUnauthorizedUser() public {
        vm.prank(alice);

        vm.expectRevert(Unauthorized.selector);

        pattern.setNumber(100);
    }

    function testStartPrank() public {
        vm.startPrank(owner);

        pattern.setNumber(10);
        pattern.setNumber(20);
        pattern.setNumber(30);

        vm.stopPrank();

        assertEq(pattern.number(), 30);
    }

    function testDeal() public {
        vm.deal(alice, 10 ether);

        assertEq(alice.balance, 10 ether);
    }

    function testExpectRevertString() public {
        vm.expectRevert(bytes("Number must be positive"));

        pattern.setPositiveNumber(0);
    }

    function testExpectRevertCustomError() public {
        vm.prank(alice);

        vm.expectRevert(Unauthorized.selector);

        pattern.setNumber(500);
    }

    function testExpectEmit() public {
        vm.expectEmit(true, true, true, true);

        emit NumberChanged(owner, 500);

        vm.prank(owner);

        pattern.setNumber(500);
    }

    function testWarp() public {
        uint256 future = block.timestamp + 30 days;

        vm.warp(future);

        assertEq(pattern.getTime(), future);
    }

    function testRoll() public {
        vm.roll(1000);

        assertEq(pattern.getBlockNumber(), 1000);
    }
}