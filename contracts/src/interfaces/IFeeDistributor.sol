// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title IFeeDistributor - Interface for Triolith fee splitter logic
/// @author MashaVaverova
interface IFeeDistributor {
    /// @notice Distribute TRI tokens across dev, platform, and staker wallets
    /// @param amount Total TRI amount to split
    function distribute(uint256 amount) external;
}
