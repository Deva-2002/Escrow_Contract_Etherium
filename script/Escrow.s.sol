// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Escrow} from "src/Escrow.sol";

contract CounterScript is Script {
    Escrow public escrow;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        escrow = new Escrow();

        vm.stopBroadcast();
    }
}
