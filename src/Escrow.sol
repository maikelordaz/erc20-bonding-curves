// SPDX-License-Identifier: MIT

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

pragma solidity 0.8.27;

contract Escrow {
    using SafeERC20 for IERC20;

    uint256 public constant ESCROW_TIME = 3 days;
    uint256 public escrowId;
    uint256 private bidId;

    struct EscrowData {
        uint256 id;
        address seller;
        address buyer;
        uint256 balance;
        address token;
        uint256 expirationDate;
    }

    struct BidData {
        uint256 id;
        uint256 escrowId;
        address buyer;
        IERC20 token;
        uint256 amount;
    }

    mapping(uint256 escrowId => EscrowData) public idToEscrow;
    mapping(uint256 escrowId => mapping(uint256 bidId => BidData))
        public idToBid;

    event EscrowCreated(
        uint256 indexed escrowId,
        address indexed seller,
        uint256 indexed expirationDate
    );
    event BidCreated(
        uint256 indexed bidId,
        uint256 indexed escrowId,
        address indexed buyer,
        IERC20 token,
        uint256 amount
    );
    event BidAccepted(
        uint256 indexed escrowId,
        uint256 indexed bidId,
        address indexed seller,
        address buyer,
        uint256 amount,
        address token
    );

    error Escrow__EscrowExpired();
    error Escrow__NotValidEscrow();
    error Escrow__EscrowActive();
    error Escrow__NotValidBid();
    error Escrow__NotYourBid();

    function createEscrow() external returns (EscrowData memory escrow) {
        uint256 currentTimestamp = block.timestamp;
        escrowId++;

        escrow = EscrowData({
            id: escrowId,
            seller: msg.sender,
            buyer: address(0),
            balance: 0,
            token: address(0),
            expirationDate: currentTimestamp + ESCROW_TIME
        });

        idToEscrow[escrowId] = escrow;

        emit EscrowCreated(escrowId, msg.sender, escrow.expirationDate);
    }

    function depositToEscrow(
        uint256 escrowToBidId,
        IERC20 token,
        uint256 amount
    ) external {
        uint256 currentTimestamp = block.timestamp;
        EscrowData memory escrowToBid = idToEscrow[escrowToBidId];
        require(
            currentTimestamp < escrowToBid.expirationDate,
            Escrow__EscrowExpired()
        );
        require(
            escrowToBid.seller != msg.sender &&
                escrowToBid.seller != address(0) &&
                escrowToBid.buyer == address(0),
            Escrow__NotValidEscrow()
        );

        bidId++;

        BidData memory bid = BidData({
            id: bidId,
            escrowId: escrowToBidId,
            buyer: msg.sender,
            token: token,
            amount: amount
        });

        idToBid[escrowToBidId][bidId] = bid;

        token.safeTransferFrom(msg.sender, address(this), amount);

        emit BidCreated(bidId, escrowToBidId, msg.sender, token, amount);
    }

    function acceptBid(
        uint256 escrowToCheckId,
        uint256 bidToAcceptId
    ) external {
        uint256 currentTimestamp = block.timestamp;
        EscrowData memory escrowToCheck = idToEscrow[escrowToCheckId];

        require(
            msg.sender == escrowToCheck.seller &&
                escrowToCheck.buyer == address(0),
            Escrow__NotValidEscrow()
        );
        require(
            currentTimestamp > escrowToCheck.expirationDate,
            Escrow__EscrowActive()
        );

        BidData memory bidToAccept = idToBid[escrowToCheckId][bidToAcceptId];

        require(bidToAccept.buyer != address(0), Escrow__NotValidBid());

        escrowToCheck.buyer = bidToAccept.buyer;
        escrowToCheck.balance = bidToAccept.amount;
        escrowToCheck.token = address(bidToAccept.token);

        bidToAccept.token.safeTransfer(
            escrowToCheck.seller,
            bidToAccept.amount
        );

        emit BidAccepted(
            escrowToCheckId,
            bidToAcceptId,
            escrowToCheck.seller,
            escrowToCheck.buyer,
            escrowToCheck.balance,
            escrowToCheck.token
        );
    }

    function withdrawNotAcceptedBid(
        uint256 escrowBiddenId,
        uint256 bidToCheckId
    ) external {
        EscrowData memory escrowToCheck = idToEscrow[escrowBiddenId];
        require(
            escrowToCheck.buyer != address(0) &&
                escrowToCheck.buyer != msg.sender,
            Escrow__NotValidEscrow()
        );

        BidData memory bidToWithdraw = idToBid[escrowBiddenId][bidToCheckId];

        require(bidToWithdraw.buyer == msg.sender, Escrow__NotYourBid());

        idToBid[escrowBiddenId][bidToCheckId].amount = 0;
        idToBid[escrowBiddenId][bidToCheckId].buyer = address(0);
        idToBid[escrowBiddenId][bidToCheckId].token = IERC20(address(0));

        bidToWithdraw.token.safeTransfer(
            bidToWithdraw.buyer,
            bidToWithdraw.amount
        );
    }
}
