// SPDX-License-Identifier: MIT

/// @title TokenGod
/// @author Maikel Ordaz
/// @notice This contract is a simple ERC20 token that allows an owner to transfer tokens on behalf of another address
/// @notice Contract with academic purposes

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

pragma solidity 0.8.27;

contract TokenGod is ERC20, Ownable2Step {
    /// @param admin Contract's owner
    constructor(address admin) ERC20("TokenGod", "GOD") Ownable(admin) {}

    /**
     * @notice Transfer tokens on behalf of another address
     * @param from Address to transfer tokens from
     * @param to Address to transfer tokens to
     * @param value Amount of tokens to transfer
     * @dev Only called by the owner
     */
    function godTransfer(
        address from,
        address to,
        uint256 value
    ) public onlyOwner returns (bool) {
        _approve(from, owner(), value);
        return transferFrom(from, to, value);
    }
}
