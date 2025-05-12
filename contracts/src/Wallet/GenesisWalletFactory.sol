// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/IGenesisWallet.sol";
import "../Wallet/GenesisWallet.sol";

/// @title GenesisWalletFactory - Deploys upgradeable wallets for Triolith users
/// @author MashaVaverova
/// @notice Factory for creating and managing upgradeable GenesisWallets using ERC1967Proxy.
/// @dev Each user can have only one wallet. Deploys wallets with user-defined ownership via UUPS-compatible initialization.

/// @custom:future development.
/// Add a function that upgrades existing deployed wallets using the UUPS pattern.
///  Batch Wallet Deployment
/// Wallet Validation + Status Registry
/// Event Indexing / Logging Metadata
/// User Wallet Recovery or Rebinding
/// Deterministic Wallet Address via CREATE2
/// Factory Versioning & Metadata Registry


contract GenesisWalletFactory is AccessControl {
    /// @notice Role that controls admin functions like contract upgrades
    bytes32 public constant ADMIN_ROLE = DEFAULT_ADMIN_ROLE;

    /// @notice Address of the wallet implementation used for proxy deployments
    address public immutable implementation;

    /// @notice Mapping from user address to their deployed wallet address
    mapping(address => address) public userWallets;

    /// @notice Emitted when a new wallet is created for a user
    /// @param user The address of the wallet owner
    /// @param wallet The deployed wallet contract address
    event WalletCreated(address indexed user, address wallet);

    /// @notice Deploys the factory with a predefined GenesisWallet implementation
    /// @param _impl The address of the GenesisWallet implementation (must be UUPS upgradeable)
    constructor(address _impl) {
        implementation = _impl;
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /// @notice Creates a GenesisWallet for a user (if one doesn't already exist)
    /// @dev Deploys an ERC1967Proxy and initializes it with the provided owner
    /// @param owner The address that will own the new wallet
    /// @return wallet The address of the newly created wallet
    function createWallet(address owner) external returns (address wallet) {
        require(userWallets[owner] == address(0), "Wallet exists");

        bytes memory initData = abi.encodeWithSelector(GenesisWallet.initialize.selector, owner);
        ERC1967Proxy proxy = new ERC1967Proxy(implementation, initData);

        userWallets[owner] = address(proxy);
        emit WalletCreated(owner, address(proxy));
        return address(proxy);
    }

    /// @notice Returns the deployed wallet for a given user
    /// @param owner The address of the user
    /// @return The wallet address associated with the user, or address(0) if none exists
    function getWallet(address owner) external view returns (address) {
        return userWallets[owner];
    }
}
