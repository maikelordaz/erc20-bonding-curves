// SPDX-License-Identifier: MIT

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

pragma solidity 0.8.27;

contract TokenGod is ERC20, Ownable2Step {
    constructor(address admin) ERC20("TokenGod", "GOD") Ownable(admin) {}

    function godTransfer(
        address from,
        address to,
        uint256 value
    ) public onlyOwner returns (bool) {
        _approve(from, owner(), value);
        return transferFrom(from, to, value);
    }
}
