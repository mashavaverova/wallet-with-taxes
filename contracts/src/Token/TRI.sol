// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title TRI Token - Native Currency for Triolith Ecosystem
/// @author MashaVaverova
/// @notice ERC-20 token used for trading game assets, paying marketplace fees, and off-ramping to fiat.
/// @dev Minting and burning are role-based. Uses AccessControl for permissioning.

/// @custom:future development.
/// Pausable Token Transfers? here or in Collectibles? think more about it.
/// Allow users to approve spending via signed messages (EIP-2612)? 
/// ERC20Snapshot Support?
/// Extend mint/burn with optional tag or reason (e.g., 'gift', 'sale', 'reward', 'staking')?
/// Add logic for locking TRI (e.g., for team, partners, investors). (Create a companion vesting contract or time-lock vault)
/// Cross-Chain Compatibility / Bridge Hooks (if we want to support other blockchains and create a bridge contract)


contract TRI is ERC20, AccessControl {
    /// @notice Role that allows minting of TRI tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Role that allows burning of TRI tokens
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @notice Deploys the TRI token with initial roles granted to the deployer
    constructor() ERC20("Triolith Token", "TRI") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
    }

    /// @notice Mints new TRI tokens to a specified address
    /// @dev Only callable by addresses with MINTER_ROLE
    /// @param to The recipient of the newly minted TRI
    /// @param amount The amount to mint (in wei, where 1e18 = 1 TRI)
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice Burns TRI tokens from a specified address
    /// @dev Only callable by addresses with BURNER_ROLE
    /// @param from The address to burn tokens from
    /// @param amount The amount to burn (in wei)
    function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }
}
