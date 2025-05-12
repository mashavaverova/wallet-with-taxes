// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IMarketplace - Interface for Triolith Marketplace
/// @author MashaVaverova
interface IMarketplace {
    struct Listing {
        address seller;
        address token;
        uint256 tokenId;
        uint256 amount;
        uint256 pricePerUnit;
    }

    /// @notice Create a listing for an ERC-1155 token
    /// @param token The address of the token contract
    /// @param tokenId The ID of the token to sell
    /// @param amount The amount of tokens to list
    /// @param pricePerUnit The price per unit in TRI
    function list(address token, uint256 tokenId, uint256 amount, uint256 pricePerUnit) external;

    /// @notice Cancel an existing listing
    /// @param listingId The ID of the listing to cancel
    function cancel(uint256 listingId) external;

    /// @notice Purchase a quantity of tokens from a listing
    /// @param listingId The listing ID
    /// @param purchaseAmount The amount to purchase
    function buy(uint256 listingId, uint256 purchaseAmount) external;

    /// @notice View a listing
    /// @param listingId The listing ID
    function listings(uint256 listingId) external view returns (Listing memory);

    /// @notice View the current fee recipient
    function feeRecipient() external view returns (address);

    /// @notice Admin-only: update the fee recipient address
    function setFeeRecipient(address newRecipient) external;
} 
