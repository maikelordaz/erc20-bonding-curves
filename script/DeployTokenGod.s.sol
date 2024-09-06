// SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {TokenGod} from "src/TokenGod.sol";

pragma solidity 0.8.27;

contract DeployTokenGod is Script {
    function run() public returns (TokenGod) {
        HelperConfig helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory config = helperConfig
            .getConfigByChainId(block.chainid);

        vm.startBroadcast();
        TokenGod token = new TokenGod(config.tokenAdmin);
        vm.stopBroadcast();

        return token;
    }
}
