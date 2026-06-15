// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract EscrowTest is Test {

    Escrow public escrow;

    address buyer = address(this);
    address seller = address(1);
    address arbiter = address(2);

    function setUp() public {
        escrow = new Escrow(
            seller,
            arbiter
        );
    }

    function testDeposit() public {

        escrow.deposit{value: 1 ether}();

        assertEq(
            address(escrow).balance,
            1 ether
        );

        assertTrue(
            escrow.funded()
        );
    }

    function testRelease() public {

        escrow.deposit{value: 1 ether}();

        uint256 sellerBalanceBefore =
            seller.balance;

        escrow.release();

        uint256 sellerBalanceAfter =
            seller.balance;

        assertEq(
            sellerBalanceAfter -
            sellerBalanceBefore,
            1 ether
        );

        assertTrue(
            escrow.released()
        );
    }

    function testResolveDispute() public {

        escrow.deposit{value: 1 ether}();

        uint256 sellerBalanceBefore =
            seller.balance;

        vm.prank(arbiter);

        escrow.resolveDispute();

        uint256 sellerBalanceAfter =
            seller.balance;

        assertEq(
            sellerBalanceAfter -
            sellerBalanceBefore,
            1 ether
        );

        assertTrue(
            escrow.released()
        );
    }

    function testRefund() public {

        escrow.deposit{value: 1 ether}();

        uint256 buyerBalanceBefore =
            address(this).balance;

        escrow.refund();

        uint256 buyerBalanceAfter =
            address(this).balance;

        assertTrue(
            escrow.refunded()
        );

        assertGt(
            buyerBalanceAfter,
            buyerBalanceBefore
        );
    }
}