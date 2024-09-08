// SPDX-License-Identifier: MIT

import {Test, console2} from "forge-std/Test.sol";
import {DeployEscrow} from "script/DeployEscrow.s.sol";
import {Escrow} from "src/Escrow.sol";

pragma solidity 0.8.27;

contract EscrowTest is Test {
    DeployEscrow deployer;
    Escrow escrow;

    function setUp() public {
        deployer = new DeployEscrow();
        escrow = deployer.run();
    }
}
