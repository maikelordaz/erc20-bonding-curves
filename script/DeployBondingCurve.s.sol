// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {BondingCurve} from "src/BondingCurve.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

pragma solidity 0.8.27;

contract DeployBondingCurve is Script {
    function run() public returns (BondingCurve) {
        HelperConfig helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory config = helperConfig
            .getConfigByChainId(block.chainid);

        vm.startBroadcast();
        BondingCurve curve = new BondingCurve(config.tokenAdmin);
        vm.stopBroadcast();

        return curve;
    }
}
