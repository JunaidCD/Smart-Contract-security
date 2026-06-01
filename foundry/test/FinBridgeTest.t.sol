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

    
function testFundLoan() public {
    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.stopPrank();

    vm.startPrank(bob);

    finbridge.connectWallet();

    finbridge.fundLoan{value: 1 ether}(1);

    vm.stopPrank();

    FinBridgeLending.LoanRequest memory loan =
        finbridge.getLoanRequest(1);

    assertTrue(loan.isFunded);
    assertEq(loan.lender, bob);
    assertTrue(loan.isActive);
}

function testFundLoanCannotFundOwnLoan() public {
    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.expectRevert();

    finbridge.fundLoan{value: 1 ether}(1);

    vm.stopPrank();
}

function testFundLoanWrongAmount() public {
    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.stopPrank();

    vm.startPrank(bob);

    finbridge.connectWallet();

    vm.expectRevert();

    finbridge.fundLoan{value: 2 ether}(1);

    vm.stopPrank();
}

function testRepayLoan() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.stopPrank();

    vm.startPrank(bob);

    finbridge.connectWallet();

    finbridge.fundLoan{value: 1 ether}(1);

    vm.stopPrank();

    vm.prank(alice);

    finbridge.repayLoan{
        value: 1062000000000000000
    }(1);

    FinBridgeLending.LoanRequest memory loan =
        finbridge.getLoanRequest(1);

    assertTrue(loan.isFunded);

    assertTrue(!loan.isActive);
}

function testRepayLoanWrongAmount() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.stopPrank();

    vm.startPrank(bob);

    finbridge.connectWallet();

    finbridge.fundLoan{value: 1 ether}(1);

    vm.stopPrank();

    vm.startPrank(alice);

    vm.expectRevert();

    finbridge.repayLoan{
        value: 1 ether
    }(1);

    vm.stopPrank();
}

function testInterestAccrual() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.stopPrank();

    vm.startPrank(bob);

    finbridge.connectWallet();

    finbridge.fundLoan{value: 1 ether}(1);

    vm.stopPrank();

    vm.warp(
        block.timestamp + 30 days
    );

    FinBridgeLending.LoanRequest memory loan =
        finbridge.getLoanRequest(1);

    uint256 repayment =
        loan.amount +
        (
            loan.amount *
            loan.interestRate /
            10000
        );

    assertEq(
        repayment,
        1062000000000000000
    );
}
function testSchedulePause() public {

    finbridge.schedulePause();

    assertTrue(
        finbridge.isPauseScheduled()
    );
}

function testPauseTimelock() public {

    finbridge.schedulePause();

    vm.expectRevert(
        bytes("Timelock not expired")
    );

    finbridge.pause();
}

function testPause() public {

    finbridge.schedulePause();

    vm.warp(
        block.timestamp + 1 days
    );

    finbridge.pause();

    assertTrue(
        finbridge.paused()
    );
}

function testUnpause() public {

    finbridge.schedulePause();

    vm.warp(
        block.timestamp + 1 days
    );

    finbridge.pause();

    finbridge.unpause();

    assertTrue(
        !finbridge.paused()
    );
}

function testDisconnectWallet() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.disconnectWallet();

    assertTrue(
        !finbridge.isWalletConnected(alice)
    );

    vm.stopPrank();
}

function testDisconnectWalletNotConnected() public {

    vm.prank(alice);

    vm.expectRevert();

    finbridge.disconnectWallet();
}

function testWithdrawLoanRequest() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    finbridge.withdrawLoanRequest(1);

    FinBridgeLending.LoanRequest memory loan =
        finbridge.getLoanRequest(1);

    assertTrue(!loan.isActive);

    vm.stopPrank();
}

function testWithdrawFundedLoanReverts() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.stopPrank();

    vm.startPrank(bob);

    finbridge.connectWallet();

    finbridge.fundLoan{value: 1 ether}(1);

    vm.stopPrank();

    vm.startPrank(alice);

    vm.expectRevert();

    finbridge.withdrawLoanRequest(1);

    vm.stopPrank();
}

function testGetUserLoanRequests() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    uint256[] memory loans =
        finbridge.getUserLoanRequests(alice);

    assertEq(loans.length, 1);

    assertEq(loans[0], 1);

    vm.stopPrank();
}

function testGetUserFundedLoans() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.stopPrank();

    vm.startPrank(bob);

    finbridge.connectWallet();

    finbridge.fundLoan{value: 1 ether}(1);

    uint256[] memory loans =
        finbridge.getUserFundedLoans(bob);

    assertEq(loans.length, 1);

    assertEq(loans[0], 1);

    vm.stopPrank();
}

function testGetUserStats() public {

    vm.startPrank(alice);

    finbridge.connectWallet();

    finbridge.createLoanRequest(
        1 ether,
        30 days
    );

    vm.stopPrank();

    vm.startPrank(bob);

    finbridge.connectWallet();

    finbridge.fundLoan{value: 1 ether}(1);

    vm.stopPrank();

    (uint256 borrowed, uint256 lent) =
        finbridge.getUserStats(alice);

    assertEq(borrowed, 1 ether);

    (borrowed, lent) =
        finbridge.getUserStats(bob);

    assertEq(lent, 1 ether);
}
 
}






