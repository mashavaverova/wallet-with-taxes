// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/IFeeDistributor.sol";

/// @title Triolith Marketplace (ERC-1155 + TRI token)
/// @author MashaVaverova
/// @notice A fixed-price ERC-1155 marketplace using TRI tokens, with built-in fee distribution.
/// @dev Buyers pay in TRI tokens; sellers receive TRI minus a 5% fee (capped at 100 TRI).
/// Fee is sent to a FeeDistributor contract that handles protocol revenue and SAFU allocations.

/// @custom:future development.
/// add canselation by admin in case of fraud or so 
/// Missing Royalty Support (ERC2981), probably add later
/// No Expiry on Listings add in future?? 
/// add possibility to pause/unpause on list(), buy(), cancel()?
/// Adding a TaxEventLogged or TradeReported event

contract Marketplace is AccessControl, ReentrancyGuard {
    /// @notice Admin role for managing contract permissions
    bytes32 public constant ADMIN_ROLE = DEFAULT_ADMIN_ROLE;

    /// @notice Platform fee in basis points (e.g., 500 = 5%)
    uint256 public constant FEE_BPS = 500;

    /// @notice Maximum fee that can be charged per transaction (100 TRI max)
    uint256 public constant FEE_CAP = 100 ether;

    /// @notice The TRI token used for payments
    IERC20 public immutable tri;

    /// @notice The fee distribution contract that handles revenue splits
    IFeeDistributor public feeDistributor;

    /// @notice Listing details for an NFT item
    struct Listing {
        address seller;         ///< The seller's address
        address token;          ///< The ERC-1155 token address
        uint256 tokenId;        ///< Token ID listed
        uint256 amount;         ///< Quantity of tokens listed
        uint256 pricePerUnit;   ///< Fixed price per unit in TRI
    }

    /// @notice ID assigned to the next listing
    uint256 public nextListingId;

    /// @notice Mapping from listing ID to Listing info
    mapping(uint256 => Listing) public listings;

    /// @notice Emitted when a new item is listed
    /// @param listingId The ID assigned to the new listing
    /// @param seller The address of the seller
    /// @param token The ERC-1155 token contract address
    /// @param tokenId The token ID listed
    /// @param amount Number of tokens listed
    /// @param pricePerUnit Fixed price per unit in TRI
    event Listed(uint256 indexed listingId, address indexed seller, address indexed token, uint256 tokenId, uint256 amount, uint256 pricePerUnit);

    /// @notice Emitted when a listing is cancelled by its seller
    /// @param listingId The ID of the listing cancelled
    event Cancelled(uint256 indexed listingId);

    /// @notice Emitted when a listing is purchased
    /// @param listingId The ID of the listing purchased
    /// @param buyer The address of the buyer
    /// @param amount Number of units bought
    /// @param totalPrice Total TRI paid (including fee)
    /// @param fee TRI taken as fee
    event Purchased(uint256 indexed listingId, address indexed buyer, uint256 amount, uint256 totalPrice, uint256 fee);

    /// @notice Deploys the marketplace contract
    /// @param _tri The TRI token address used for purchases
    /// @param _feeDistributor The fee distributor contract address
    constructor(address _tri, address _feeDistributor) {
        tri = IERC20(_tri);
        feeDistributor = IFeeDistributor(_feeDistributor);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /// @notice List an ERC-1155 token for sale at a fixed price per unit
    /// @dev Transfers the listed tokens to the marketplace contract
    /// @param token The address of the ERC-1155 contract
    /// @param tokenId The token ID to list
    /// @param amount Number of tokens to list
    /// @param pricePerUnit Price per token in TRI
    function list(address token, uint256 tokenId, uint256 amount, uint256 pricePerUnit) external nonReentrant {
        require(amount > 0 && pricePerUnit > 0, "Invalid listing");

        IERC1155(token).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");

        listings[nextListingId] = Listing({
            seller: msg.sender,
            token: token,
            tokenId: tokenId,
            amount: amount,
            pricePerUnit: pricePerUnit
        });

        emit Listed(nextListingId, msg.sender, token, tokenId, amount, pricePerUnit);
        nextListingId++;
    }

    /// @notice Cancel an existing listing (must be the seller)
    /// @dev Returns unsold tokens back to the seller
    /// @param listingId The ID of the listing to cancel
    function cancel(uint256 listingId) external nonReentrant {
        Listing memory l = listings[listingId];
        require(msg.sender == l.seller, "Not your listing");

        delete listings[listingId];
        IERC1155(l.token).safeTransferFrom(address(this), l.seller, l.tokenId, l.amount, "");
        emit Cancelled(listingId);
    }

    /// @notice Buy a specific amount from a listing using TRI
    /// @dev Transfers TRI to seller and feeDistributor, ERC-1155 to buyer
    /// @param listingId The ID of the listing to buy from
    /// @param purchaseAmount The quantity of tokens to purchase
    function buy(uint256 listingId, uint256 purchaseAmount) external nonReentrant {
        Listing storage l = listings[listingId];
        require(purchaseAmount > 0 && purchaseAmount <= l.amount, "Invalid amount");

        uint256 totalPrice = l.pricePerUnit * purchaseAmount;
        uint256 fee = (totalPrice * FEE_BPS) / 10000;
        if (fee > FEE_CAP) fee = FEE_CAP;

        uint256 sellerProceeds = totalPrice - fee;

        tri.transferFrom(msg.sender, address(feeDistributor), fee);
        feeDistributor.distribute(fee);

        tri.transferFrom(msg.sender, l.seller, sellerProceeds);

        IERC1155(l.token).safeTransferFrom(address(this), msg.sender, l.tokenId, purchaseAmount, "");
        l.amount -= purchaseAmount;

        if (l.amount == 0) {
            delete listings[listingId];
        }

        emit Purchased(listingId, msg.sender, purchaseAmount, totalPrice, fee);
    }

    /// @notice Allows receiving ERC-1155 tokens (single transfer)
    /// @dev Required by ERC-1155 to accept transfers
    function onERC1155Received(address, address, uint256, uint256, bytes calldata) public pure returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    /// @notice Allows receiving ERC-1155 tokens (batch transfer)
    /// @dev Required by ERC-1155 to accept batch transfers
    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) public pure returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    
}
