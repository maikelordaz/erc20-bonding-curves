// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {Escrow} from "src/Escrow.sol";

pragma solidity 0.8.27;

contract DeployEscrow is Script {
    function run() public returns (Escrow) {
        vm.startBroadcast();
        Escrow escrow = new Escrow();
        vm.stopBroadcast();

        return escrow;
    }
}
