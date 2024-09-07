// SPDX-License-Identifier: MIT

import {Test, console2} from "forge-std/Test.sol";
import {DeployBondingCurve} from "script/DeployBondingCurve.s.sol";
import {BondingCurve} from "src/BondingCurve.sol";

pragma solidity 0.8.27;

contract BondingCurveFuzzTest is Test {
    DeployBondingCurve deployer;
    BondingCurve curve;

    function setUp() public {
        deployer = new DeployBondingCurve();
        curve = deployer.run();
    }

    function test_fuzz_AmountToPay(uint256 amount) public {
        amount = bound(amount, 0, 100 ether);
        uint256 paymentAmount = curve.getPaymentAmount(amount);
        uint256 expected = (((2 * curve.totalSupply()) + amount + 1) * amount) /
            2;
        assertEq(paymentAmount, expected);
    }
}
