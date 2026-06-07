// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/ImmutableConstant.sol";

contract ImmutableConstantTest is Test {

    ImmutableConstant ic;

    function setUp() public {
        ic = new ImmutableConstant(address(this));
    }

    function testIncrement() public {
        ic.increment();
    }

    function testReadConstant() public view {
        ic.MAX_SUPPLY();
    }

    function testReadImmutable() public view {
        ic.owner();
    }
}