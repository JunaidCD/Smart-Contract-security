// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";

interface AggregatorV3Interface {
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

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

function testReadEthPrice() public {

        AggregatorV3Interface feed =
            AggregatorV3Interface(
                0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            );

        (
            ,
            int256 price,
            ,
            ,
            
        ) = feed.latestRoundData();

        console.log("ETH/USD Price:");
        console.log(uint256(price));

        assertGt(price, 1000e8);
        assertLt(price, 100000e8);
    }
}