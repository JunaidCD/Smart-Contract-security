// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {FinBridgeLending} from "../src/FinBridgeLending.sol";

contract FinBridgeTest is Test {

    FinBridgeLending finbridge;

    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        finbridge = new FinBridgeLending();

        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
    }

    function testConnectWallet() public {
        vm.prank(alice);

        finbridge.connectWallet();

        assertTrue(
            finbridge.isWalletConnected(alice)
        );
    }

    function testCreateLoanRequest() public {
        vm.startPrank(alice);

        finbridge.connectWallet();

        finbridge.createLoanRequest(
            1 ether,
            30 days
        );

        FinBridgeLending.LoanRequest memory loan =
            finbridge.getLoanRequest(1);

        assertEq(loan.id, 1);
        assertEq(loan.borrower, alice);
        assertEq(loan.amount, 1 ether);
        assertTrue(loan.isActive);
        assertTrue(!loan.isFunded);

        vm.stopPrank();
    }
}