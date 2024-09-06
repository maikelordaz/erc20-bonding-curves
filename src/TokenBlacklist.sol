// SPDX-License-Identifier: MIT

/// @title TokenBlacklist
/// @author Maikel Ordaz
/// @notice This contract is a simple ERC20 token that allows the owner to blacklist addresses
/// @notice Contract with academic purposes

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

pragma solidity 0.8.27;

contract TokenBlacklist is ERC20, Ownable2Step {
    mapping(address user => bool isBlacklisted) public isBlacklisted;

    error TokenBlacklist__AddressBlacklisted();

    /// @param admin Contract's owner
    constructor(address admin) ERC20("TokenBlacklist", "TBL") Ownable(admin) {}

    /**
     * @notice Blacklist an address
     * @param user Address to be blacklisted
     * @dev Only the owner can blacklist an address
     */
    function blacklist(address user) external onlyOwner {
        isBlacklisted[user] = true;
    }

    /**
     * @notice override transfer function to check if the sender or receiver is blacklisted
     */
    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        require(
            !isBlacklisted[msg.sender] && !isBlacklisted[to],
            TokenBlacklist__AddressBlacklisted()
        );
        return super.transfer(to, value);
    }

    /**
     * @notice override transferFrom function to check if the sender or receiver is blacklisted
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        require(
            !isBlacklisted[from] && !isBlacklisted[to],
            TokenBlacklist__AddressBlacklisted()
        );
        return super.transferFrom(from, to, value);
    }
}
