// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vesting.sol";

contract VestingTest is Test {

    Vesting vesting;

    address beneficiary = address(1);

    uint256 total = 1000 ether;

    uint256 start;

    uint256 cliff = 365 days;

    uint256 duration = 4 * 365 days;

    function setUp() public {

        start = block.timestamp;

        vesting = new Vesting(
            beneficiary,
            total,
            start,
            cliff,
            duration
        );
    }

    function testBeforeCliff() public {

        vm.warp(start + 180 days);

        uint256 vested = vesting.vestedAmount();

        assertEq(vested, 0);
    }

    function testAfterCliff() public {

        vm.warp(start + 2 * 365 days);

        uint256 vested = vesting.vestedAmount();

        uint256 expected =
            (total * (2 * 365 days))
            / duration;

        assertEq(vested, expected);
    }

    function testAfterDuration() public {

        vm.warp(start + duration + 1);

        uint256 vested = vesting.vestedAmount();

        assertEq(vested, total);
    }

    function testRelease() public {

        vm.warp(start + 2 * 365 days);

        vesting.release();

        assertEq(
            vesting.released(),
            vesting.vestedAmount()
        );
    }

    function testRevoke() public {

        vesting.revoke();

        assertEq(
            vesting.revoked(),
            true
        );
    }
}