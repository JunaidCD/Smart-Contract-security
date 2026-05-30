// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter counter;

    function setUp() public {
        counter = new Counter();
    }

    function testIncrement() public {
        counter.increment();

        assertEq(counter.count(), 1);
    }

    function testIncrementTwice() public {
        counter.increment();
        counter.increment();

        assertEq(counter.count(), 2);
    }

    function testIncrementThrice() public {
        counter.increment();
        counter.increment();
        counter.increment();

        assertEq(counter.count(), 3);
    }

    function testReset() public {
        counter.increment();
        counter.increment();

        counter.reset();

        assertEq(counter.count(), 0);
    }

    function testDecrement() public {
        counter.increment();
        counter.increment();

        counter.decrement();

        assertEq(counter.count(), 1);
    }

    function testDecrementRevertsAtZero() public {
        vm.expectRevert();

        counter.decrement();
    }
}