// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {TokenBlacklist} from "src/TokenBlacklist.sol";

pragma solidity 0.8.27;

contract DeployTokenBlacklist is Script {
    function run() public returns (TokenBlacklist) {
        HelperConfig helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory config = helperConfig
            .getConfigByChainId(block.chainid);

        vm.startBroadcast();
        TokenBlacklist token = new TokenBlacklist(config.tokenAdmin);
        vm.stopBroadcast();

        return token;
    }
}
