// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {BondingCurve} from "src/BondingCurve.sol";

pragma solidity 0.8.27;

contract DeployBondingCurve is Script {
    function run() public returns (BondingCurve) {
        vm.startBroadcast();
        BondingCurve curve = new BondingCurve();
        vm.stopBroadcast();

        return curve;
    }
}
