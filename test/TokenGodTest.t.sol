// SPDX-License-Identifier: MIT

import {Test, console2} from "forge-std/Test.sol";
import {DeployTokenGod} from "script/DeployTokenGod.s.sol";
import {TokenGod} from "src/TokenGod.sol";

pragma solidity 0.8.26;

contract TokenGodTest is Test {
    DeployTokenGod deployer;
    TokenGod token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        deployer = new DeployTokenGod();
        token = deployer.run();

        deal(address(token), alice, 100 ether);
    }

    function testGodTransfer() public {
        assertEq(token.balanceOf(bob), 0);

        vm.prank(token.owner());
        token.godTransfer(alice, bob, 10 ether);

        assertEq(token.balanceOf(bob), 10 ether);
    }
}
