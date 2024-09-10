// SPDX-License-Identifier: MIT

import {Test, console2} from "forge-std/Test.sol";
import {DeployTokenBlacklist} from "script/DeployTokenBlacklist.s.sol";
import {TokenBlacklist} from "src/TokenBlacklist.sol";

pragma solidity 0.8.27;

contract TokenBlacklistTest is Test {
    DeployTokenBlacklist deployer;
    TokenBlacklist token;
    address notBlacklisted = makeAddr("notBlacklisted");
    address blacklisted = makeAddr("blacklisted");
    address alice = makeAddr("alice");

    event Blacklisted(address indexed user);
    event RemoveFromBlacklist(address indexed user);

    function setUp() public {
        deployer = new DeployTokenBlacklist();
        token = deployer.run();

        deal(address(token), notBlacklisted, 100 ether);
        deal(address(token), blacklisted, 100 ether);
    }

    function test_blacklist() public {
        assert(!token.isBlacklisted(blacklisted));

        vm.prank(token.owner());
        vm.expectEmit(true, false, false, false, address(token));
        emit Blacklisted(blacklisted);
        token.blacklist(blacklisted);

        assert(token.isBlacklisted(blacklisted));

        vm.prank(token.owner());
        vm.expectEmit(true, false, false, false, address(token));
        emit RemoveFromBlacklist(blacklisted);
        token.removeFromBlacklist(blacklisted);

        assert(!token.isBlacklisted(blacklisted));
    }

    function test_notBlacklistedCanTransfer() public {
        assertEq(token.balanceOf(alice), 0);

        vm.prank(notBlacklisted);
        token.transfer(alice, 1 ether);

        assertEq(token.balanceOf(alice), 1 ether);
    }

    function test_notBlacklistedCanTransferFrom() public {
        assertEq(token.balanceOf(alice), 0);

        vm.prank(notBlacklisted);
        token.approve(address(this), 1 ether);

        vm.prank(address(this));
        token.transferFrom(notBlacklisted, alice, 1 ether);

        assertEq(token.balanceOf(alice), 1 ether);
    }

    modifier blacklist() {
        vm.prank(token.owner());
        token.blacklist(blacklisted);
        _;
    }

    function test_blacklistedCanNotTransfer() public blacklist {
        vm.prank(blacklisted);
        vm.expectRevert(
            TokenBlacklist.TokenBlacklist__AddressBlacklisted.selector
        );
        token.transfer(notBlacklisted, 1 ether);
    }

    function test_notBlacklistedCanNotTransferFrom() public blacklist {
        vm.prank(notBlacklisted);
        token.approve(address(this), 1 ether);

        vm.prank(blacklisted);
        token.approve(address(this), 1 ether);

        vm.startPrank(address(this));
        vm.expectRevert(
            TokenBlacklist.TokenBlacklist__AddressBlacklisted.selector
        );
        token.transferFrom(notBlacklisted, blacklisted, 100);

        vm.expectRevert(
            TokenBlacklist.TokenBlacklist__AddressBlacklisted.selector
        );
        token.transferFrom(notBlacklisted, blacklisted, 100);
        vm.stopPrank();
    }
}
