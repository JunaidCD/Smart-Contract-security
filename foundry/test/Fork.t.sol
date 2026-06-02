// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

contract ForkTest is Test {

    function setUp() public {

        vm.createSelectFork(
            vm.envString("MAINNET_RPC_URL"),
            25230215
        );
    }

    function testForkWorks() public {

        assertEq(
            block.number,
            25230215
        );
    }
}