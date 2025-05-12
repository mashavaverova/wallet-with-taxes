// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGenesisWallet {
    /// @notice Transfer ERC1155 tokens owned by this wallet
    function claimERC1155(address token, uint256 id, uint256 amount) external;

    /// @notice Transfer ERC721 tokens owned by this wallet
    function claimERC721(address token, uint256 id) external;

    /// @notice Withdraw TRI tokens owned by this wallet
    function withdrawTRI(address token, uint256 amount) external;

    /// @notice Receive function for ETH
    receive() external payable;
} 
