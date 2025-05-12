// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title SAFU - Secure Asset Fund for Users (Triolith Insurance Vault)
/// @author MashaVaverova
/// @notice Receives TRI from protocol fees or treasury and allows admin-managed user compensations.
/// @dev Only ADMIN_ROLE can send out funds. Deposits must be made via transfer + `deposit()` logging.

/// @custom:future development.
/// Automated Claim System (High Value!!!!)
/// Add cooldowns, locks, or compensation limits in case of abuse or so 
/// Role Separation? probably worth to add 
/// Internal Ledger / User Balances? (Track user balances internally and allow withdraw() instead of compensate(): need mapping(address => uint256) public userCredit;
///    plus Add creditUser(address, amount) (admin-only) and Users call withdrawCredit())
/// Add Native ETH Support?
/// Governance Integration (DAO-Ready)?
/// Public Audit Trail or IPFS-linked Justifications
contract SAFU is AccessControl {
    /// @notice Role identifier for admin permissions
    bytes32 public constant ADMIN_ROLE = DEFAULT_ADMIN_ROLE;

    /// @notice The TRI token held by this SAFU vault
    IERC20 public immutable tri;

    /// @notice Emitted when TRI is deposited into the SAFU vault
    /// @param from The address that initiated the deposit
    /// @param amount The amount of TRI deposited
    event Deposited(address indexed from, uint256 amount);

    /// @notice Emitted when an admin compensates a user from SAFU
    /// @param to The recipient of the compensation
    /// @param amount The amount of TRI sent
    /// @param reason A short reason or identifier for the compensation
    event Compensated(address indexed to, uint256 amount, string reason);

    /// @notice Deploys the SAFU vault
    /// @param _tri The TRI token address
    constructor(address _tri) {
        tri = IERC20(_tri);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /// @notice Notify and log a deposit of TRI into SAFU
    /// @dev Caller must have already transferred TRI to this contract before calling.
    /// This function does not move tokens, it only logs the action.
    /// @param amount The amount of TRI assumed to have been deposited
    function deposit(uint256 amount) external {
        require(tri.balanceOf(address(this)) >= amount, "SAFU: deposit not reflected in balance");
        emit Deposited(msg.sender, amount);
    }

    /// @notice Compensates a user from the SAFU reserve (admin only)
    /// @dev Sends TRI directly to the user. Make sure to log a reason.
    /// @param to The user receiving compensation
    /// @param amount The amount of TRI to send
    /// @param reason A short string describing why the compensation occurred
    function compensate(address to, uint256 amount, string calldata reason) external onlyRole(ADMIN_ROLE) {
        require(tri.transfer(to, amount), "Transfer failed");
        emit Compensated(to, amount, reason);
    }

    /// @notice Returns the current TRI balance of the SAFU vault
    /// @return The number of TRI tokens held
    function balance() external view returns (uint256) {
        return tri.balanceOf(address(this));
    }
}
