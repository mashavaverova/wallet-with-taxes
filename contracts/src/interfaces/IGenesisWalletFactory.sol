// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGenesisWalletFactory {
    /// @notice Deploys a new GenesisWallet for a user
    /// @param owner The address who will own the wallet
    /// @return wallet The address of the deployed wallet
    function createWallet(address owner) external returns (address wallet);

    /// @notice Checks if a wallet has already been deployed for an address
    /// @param owner The user's address
    /// @return wallet Address of their GenesisWallet (zero if not created)
    function getWallet(address owner) external view returns (address wallet);
} 
