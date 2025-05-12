// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ISAFU - Interface for the Secure Asset Fund for Users
interface ISAFU {
    /// @notice Deposit TRI tokens into the SAFU reserve
    /// @param amount The amount to deposit
    function deposit(uint256 amount) external;

    /// @notice Admin compensates a user
    /// @param to Recipient address
    /// @param amount Amount in TRI
    /// @param reason Reason for compensation
    function compensate(address to, uint256 amount, string calldata reason) external;

    /// @notice Returns the current balance in SAFU
    function balance() external view returns (uint256);
} 