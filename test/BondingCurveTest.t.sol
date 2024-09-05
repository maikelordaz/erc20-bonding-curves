// SPDX-License-Identifier: MIT

import {Test, console2} from "forge-std/Test.sol";
import {DeployBondingCurve} from "script/DeployBondingCurve.s.sol";
import {BondingCurve} from "src/BondingCurve.sol";

pragma solidity 0.8.26;

contract BondingCurveTest is Test {
    DeployBondingCurve deployer;
    BondingCurve curve;

    function setUp() public {
        deployer = new DeployBondingCurve();
        curve = deployer.run();
    }
}
