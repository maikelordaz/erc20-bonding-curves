// SPDX-License-Identifier: MIT

import {Test, console2} from "forge-std/Test.sol";
import {DeployBondingCurve} from "script/DeployBondingCurve.s.sol";
import {BondingCurve} from "src/BondingCurve.sol";

pragma solidity 0.8.27;

contract BondingCurveTest is Test {
    DeployBondingCurve deployer;
    BondingCurve curve;

    address alice = makeAddr("alice");

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        deployer = new DeployBondingCurve();
        curve = deployer.run();
        deal(alice, 1 ether);
    }

    function testAmountToPay() public {
        uint256 amount = 10;
        uint256 paymentAmount = curve.getPaymentAmount(amount);
        assertEq(paymentAmount, 55);
    }

    function testMintMustRevertIfAmountIsZero() public {
        vm.prank(alice);
        vm.expectRevert(BondingCurve.InvalidAmount.selector);
        curve.mint(0);
    }

    function testMintMustRevertIfEthSendIsNotEnough() public {
        uint256 ethSent = 1 wei;
        uint256 tokenAmountExpected = 2;
        uint256 ethNeeded = curve.getPaymentAmount(tokenAmountExpected);

        vm.prank(alice);
        vm.expectRevert(
            abi.encodeWithSelector(
                BondingCurve.NotEnoughEthSent.selector,
                ethSent,
                ethNeeded
            )
        );
        curve.mint{value: ethSent}(tokenAmountExpected);
    }

    function testMintTokens() public {
        uint256 tokenAmount = 10;
        uint256 ethToSend = curve.getPaymentAmount(tokenAmount);

        vm.prank(alice);
        vm.expectEmit(true, true, false, false, address(curve));
        emit Transfer(address(0), alice, tokenAmount);
        curve.mint{value: ethToSend}(tokenAmount);

        uint256 newPrice = curve.getCurrentPrice();

        assertEq(curve.balanceOf(alice), tokenAmount);
        assertEq(newPrice, tokenAmount + 1);
    }

    function testMintReimburseExtraEthSent() public {
        uint256 tokenAmount = 10;
        uint256 ethToSend = curve.getPaymentAmount(tokenAmount);
        uint256 ethSent = ethToSend + 1;
        uint256 aliceBalanceBefore = address(alice).balance;

        vm.prank(alice);
        curve.mint{value: ethSent}(tokenAmount);

        uint256 aliceBalanceAfter = address(alice).balance;

        assertEq(curve.balanceOf(alice), tokenAmount);
        assertEq(aliceBalanceAfter, aliceBalanceBefore - ethToSend);
    }

    function testBurn() public {
        uint256 tokenAmount = 10;
        uint256 ethToSend = curve.getPaymentAmount(tokenAmount);

        vm.prank(alice);
        curve.mint{value: ethToSend}(tokenAmount);

        uint256 newPrice = curve.getCurrentPrice();

        assertEq(newPrice, tokenAmount + 1);
        assertEq(curve.balanceOf(alice), tokenAmount);

        vm.prank(alice);
        curve.burn(tokenAmount / 2);

        newPrice = curve.getCurrentPrice();

        assertEq(newPrice, (tokenAmount / 2) + 1);
        assertEq(curve.balanceOf(alice), tokenAmount / 2);
    }
}
