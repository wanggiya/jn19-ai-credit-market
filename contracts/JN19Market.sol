// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title JN19Market
/// @notice Tiny marketplace: a seller escrows fake JN19 AI credits; a buyer pays fake USDC to buy them.
/// @dev This is for hackathon simulation only. Do not represent it as resale of real OpenAI/Claude/Gemini credits.
contract JN19Market is ReentrancyGuard {
    using SafeERC20 for IERC20;

    enum Status {
        None,
        Active,
        Sold,
        Cancelled
    }

    struct Listing {
        address seller;
        uint256 creditAmount;
        uint256 paymentAmount;
        Status status;
    }

    IERC20 public immutable jn19;
    IERC20 public immutable paymentToken;
    Listing[] private listings;

    event ListingCreated(
        uint256 indexed listingId,
        address indexed seller,
        uint256 creditAmount,
        uint256 paymentAmount
    );
    event ListingBought(uint256 indexed listingId, address indexed buyer);
    event ListingCancelled(uint256 indexed listingId);

    constructor(address jn19_, address paymentToken_) {
        require(jn19_ != address(0), "Bad JN19 token");
        require(paymentToken_ != address(0), "Bad payment token");
        jn19 = IERC20(jn19_);
        paymentToken = IERC20(paymentToken_);
    }

    function createListing(uint256 creditAmount, uint256 paymentAmount)
        external
        nonReentrant
        returns (uint256 listingId)
    {
        require(creditAmount > 0, "Credit amount is zero");
        require(paymentAmount > 0, "Payment amount is zero");

        jn19.safeTransferFrom(msg.sender, address(this), creditAmount);

        listingId = listings.length;
        listings.push(
            Listing({
                seller: msg.sender,
                creditAmount: creditAmount,
                paymentAmount: paymentAmount,
                status: Status.Active
            })
        );

        emit ListingCreated(listingId, msg.sender, creditAmount, paymentAmount);
    }

    function buyListing(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.status == Status.Active, "Listing not active");
        require(msg.sender != listing.seller, "Seller cannot buy own listing");

        listing.status = Status.Sold;

        paymentToken.safeTransferFrom(msg.sender, listing.seller, listing.paymentAmount);
        jn19.safeTransfer(msg.sender, listing.creditAmount);

        emit ListingBought(listingId, msg.sender);
    }

    function cancelListing(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.status == Status.Active, "Listing not active");
        require(msg.sender == listing.seller, "Only seller");

        listing.status = Status.Cancelled;
        jn19.safeTransfer(listing.seller, listing.creditAmount);

        emit ListingCancelled(listingId);
    }

    function getListing(uint256 listingId) external view returns (Listing memory) {
        return listings[listingId];
    }

    function listingCount() external view returns (uint256) {
        return listings.length;
    }

    function getListings() external view returns (Listing[] memory) {
        return listings;
    }
}
