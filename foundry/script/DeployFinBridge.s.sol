// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/FinBridgeLending.sol";

contract DeployFinBridge is Script {

    function run() external {

        vm.startBroadcast();

        FinBridgeLending finBridge =
            new FinBridgeLending();

        vm.stopBroadcast();
    }
}