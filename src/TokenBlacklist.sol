// SPDX-License-Identifier: MIT

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

pragma solidity 0.8.26;

contract TokenBlacklist is ERC20, Ownable2Step {
    mapping(address user => bool isBlacklisted) public isBlacklisted;

    error TokenBlacklist__AddressBlacklisted();

    constructor(address admin) ERC20("TokenBlacklist", "TBL") Ownable(admin) {}

    function blacklist(address user) external onlyOwner {
        isBlacklisted[user] = true;
    }

    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        if (isBlacklisted[msg.sender] || isBlacklisted[to]) {
            revert TokenBlacklist__AddressBlacklisted();
        }
        return super.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        if (isBlacklisted[from] || isBlacklisted[to]) {
            revert TokenBlacklist__AddressBlacklisted();
        }
        return super.transferFrom(from, to, value);
    }
}
