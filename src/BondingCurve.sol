// SPDX-License-Identifier: MIT

/**
* @title BondingCurve
* @author Maikel Ordaz
* @notice Contract with academic purposes   
* @dev The bonding curve core invariant will be 'y = x' (linear bonding curve)
         This means that the price of the token will increase linearly with the supply
         Example: 1 token = 1 wei, 2 tokens = 2 wei, 3 tokens = 3 wei, and so on. Or
         in other words, the price of the token will be equal to the supply.
* @dev core invariant 'priceToPay = ((2 * totalSupply) + amount + 1) * amount / 2'
*/

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

pragma solidity 0.8.27;

contract BondingCurve is ERC20, Ownable2Step {
    uint256 private lastPrice;

    error NotEnoughEthSent(uint256 ethSent, uint256 ethNeeded);
    error ReimburseFailed();
    error InvalidAmount();

    modifier notZeroAmount(uint256 amount) {
        require(amount > 0, InvalidAmount());
        _;
    }

    /// @param admin Contract's owner
    constructor(
        address admin
    ) ERC20("Bonding Curve Token", "BCT") Ownable(admin) {}

    receive() external payable {}

    /**
     * @notice Method to mint tokens to the caller
     * @dev The user will pay the needed amount for the tokens to mint
     * @param amount Amount of tokens to mint
     */
    function mint(uint256 amount) external payable notZeroAmount(amount) {
        uint256 paymentAmount = _getPaymentAmount(amount);
        require(
            msg.value >= paymentAmount,
            NotEnoughEthSent({ethSent: msg.value, ethNeeded: paymentAmount})
        );

        _mint(msg.sender, amount);

        if (msg.value > paymentAmount) {
            (bool success, ) = payable(msg.sender).call{
                value: msg.value - paymentAmount
            }("");
            require(success, ReimburseFailed());
        }
    }

    /**
     * @notice Method to burn tokens from the caller
     */
    function burn(uint256 amount) external notZeroAmount(amount) {
        _burn(msg.sender, amount);
    }

    /**
     * @notice Method to calculate how much a user will pay for a certain amount of tokens
     * @dev It uses the core invariant 'y = x' to calculate the price
     * @dev Will need the latest price (this is equal to the current supply) and the amount of tokens to buy
     * @param amount Amount of tokens to buy
     * @return paymentAmount Amount in wei that the user will pay
     */
    function getPaymentAmount(uint256 amount) public view returns (uint256) {
        return _getPaymentAmount(amount);
    }

    function _getPaymentAmount(
        uint256 _amount
    ) internal view returns (uint256 paymentAmount_) {
        uint256 currentPrice = totalSupply() + 1; // This is the price for the next token to buy
        uint256 maxPriceToPay = currentPrice + _amount - 1; // This is the price for the last token to buy
        paymentAmount_ = ((currentPrice + maxPriceToPay) * _amount) / 2; // Sum of an arithmetic progression
    }

    /**
     * @notice The current price of the token is equal to the current supply
     */
    function getCurrentPrice() public view returns (uint256) {
        return totalSupply();
    }
}
