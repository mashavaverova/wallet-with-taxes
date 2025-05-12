// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title TaxProcessor - On-chain gain/loss logger (Sweden-style) for Triolith users
/// @author MashaVaverova
/// @notice Stores taxable events and assists the backend in estimating Swedish crypto tax liability per user.
/// @dev Only OPERATOR_ROLE can log new tax events. Events store gain/loss in SEK and optional metadata.


/// custom:future development.
///  Per-user Index Mapping !!! Need to add this.
/// Batch Logging (logTaxEvents)
/// Enum Reason Codes (Structured Metadata)
///  Data Privacy & Archiving (needs for GDPR)

contract TaxProcessor is AccessControl {
    /// @notice Role allowed to log tax events (e.g., backend or trusted automation)
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    /// @notice Struct representing a taxable gain or loss event
    /// @param user Wallet address affected by the event
    /// @param timestamp Time when the event was recorded
    /// @param gainOrLossSEK Net gain or loss in SEK (positive or negative)
    /// @param metadata Optional description of the event (e.g., sale or swap)
    struct TaxEvent {
        address user;
        uint256 timestamp;
        int256 gainOrLossSEK;
        string metadata;
    }

    /// @notice All logged tax events (stored on-chain)
    TaxEvent[] public events;

    /// @notice Emitted when a new tax event is logged
    /// @param user The user affected by the taxable event
    /// @param gainOrLossSEK The signed gain or loss in SEK
    /// @param metadata Optional context string (e.g., sale description)
    /// @param timestamp Block timestamp when the event was logged
    event TaxLogged(address indexed user, int256 gainOrLossSEK, string metadata, uint256 timestamp);

    /// @notice Deploys the TaxProcessor contract and assigns roles to the deployer
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    /// @notice Logs a taxable event for a specific user
    /// @dev Only callable by OPERATOR_ROLE (e.g., backend services)
    /// @param user The wallet address affected by the event
    /// @param gainOrLossSEK The net gain or loss in SEK (signed integer)
    /// @param metadata Optional descriptive message (e.g., "Sold NFT #1024 for 150 TRI")
    function logTaxEvent(address user, int256 gainOrLossSEK, string calldata metadata) external onlyRole(OPERATOR_ROLE) {
        events.push(TaxEvent({
            user: user,
            timestamp: block.timestamp,
            gainOrLossSEK: gainOrLossSEK,
            metadata: metadata
        }));

        emit TaxLogged(user, gainOrLossSEK, metadata, block.timestamp);
    }

    /// @notice Returns the number of tax events stored
    /// @return The total count of events in the system
    function eventCount() external view returns (uint256) {
        return events.length;
    }

    /// @notice Retrieves a tax event by index
    /// @param index The index of the event in the events array
    /// @return The `TaxEvent` struct at the specified index
    function getEvent(uint256 index) external view returns (TaxEvent memory) {
        return events[index];
    }
}
