// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ITaxProcessor - Interface for on-chain tax logging (Swedish model)
interface ITaxProcessor {
    struct TaxEvent {
        address user;
        uint256 timestamp;
        int256 gainOrLossSEK;
        string metadata;
    }

    /// @notice Log a taxable event in SEK for a user
    /// @param user Wallet address
    /// @param gainOrLossSEK Net gain/loss in SEK
    /// @param metadata Description of the transaction
    function logTaxEvent(address user, int256 gainOrLossSEK, string calldata metadata) external;

    /// @notice Get total number of events
    function eventCount() external view returns (uint256);

    /// @notice Get a specific tax event
    function getEvent(uint256 index) external view returns (TaxEvent memory);
} 