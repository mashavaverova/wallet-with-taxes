// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title Triolith Collectibles (ERC-1155)
/// @author MashaVaverova
/// @notice In-game item contract for Triolith, supporting minting by game devs and burning by players.
/// @dev Uses role-based access via AccessControl and follows the ERC-1155 standard.


/// @custom:future development.
/// Add a separate contract may be deployed in the future to handle player-side minting logic,
/// such as crafting, rewards, or gameplay-based item generation. This contract will be granted the
/// `GAME_DEV_ROLE` and serve as a permissioned proxy for minting tokens to players, based on
/// game-defined rules. 


contract Collectibles is ERC1155, AccessControl {
    using Strings for uint256;

    /// @notice Role identifier for game developers allowed to mint tokens
    bytes32 public constant GAME_DEV_ROLE = keccak256("GAME_DEV_ROLE");

    /// @notice Base URI for metadata files (e.g., https://example.com/metadata/)
    string private baseMetadataURI;

    /// @notice Token collection name (e.g., shown in UIs)
    string public name = "Triolith Collectibles";

    /// @notice Token collection symbol
    string public symbol = "TRLC";

    /// @notice Total supply mapping for each token ID
    mapping(uint256 => uint256) public totalSupply;

    /// @notice Deploys the Collectibles contract with an initial metadata URI
    /// @param _baseURI The base URI for token metadata (appended with {id}.json)
    constructor(string memory _baseURI) ERC1155("") {
        baseMetadataURI = _baseURI;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GAME_DEV_ROLE, msg.sender);
    }

    /// @notice Mints new tokens to a player (single token type)
    /// @dev Only callable by accounts with `GAME_DEV_ROLE`
    /// @param to The address receiving the minted tokens
    /// @param id The token ID to mint
    /// @param amount The number of tokens to mint
    /// @param data Optional data passed to receiver (if a contract)
    function mint(address to, uint256 id, uint256 amount, bytes memory data)
        external
        onlyRole(GAME_DEV_ROLE)
    {
        _mint(to, id, amount, data);
        totalSupply[id] += amount;
    }

    /// @notice Mints multiple token types in a single call
    /// @dev Only callable by accounts with `GAME_DEV_ROLE`
    /// @param to The address receiving the minted tokens
    /// @param ids Array of token IDs to mint
    /// @param amounts Array of amounts for each token ID
    /// @param data Optional data passed to receiver (if a contract)
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external
        onlyRole(GAME_DEV_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
        for (uint256 i = 0; i < ids.length; ++i) {
            totalSupply[ids[i]] += amounts[i];
        }
    }

    /// @notice Burns tokens from a player's wallet (single token type)
    /// @dev Caller must be the token holder or approved operator
    /// @param from The address whose tokens will be burned
    /// @param id The token ID to burn
    /// @param amount The number of tokens to burn
    function burn(address from, uint256 id, uint256 amount) external {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Not approved to burn");
        _burn(from, id, amount);
        totalSupply[id] -= amount;
    }

    /// @notice Burns multiple token types from a player's wallet
    /// @dev Caller must be the token holder or approved operator
    /// @param from The address whose tokens will be burned
    /// @param ids Array of token IDs to burn
    /// @param amounts Array of amounts for each token ID
    function burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) external {
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "Not approved to burn");
        _burnBatch(from, ids, amounts);
        for (uint256 i = 0; i < ids.length; ++i) {
            totalSupply[ids[i]] -= amounts[i];
        }
    }

    /// @notice Returns the metadata URI for a given token ID
    /// @param id The token ID to query
    /// @return A URI pointing to the token's metadata (e.g., JSON file)
    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(baseMetadataURI, id.toString(), ".json"));
    }

    /// @notice Updates the base URI for all token metadata
    /// @dev Only callable by accounts with `DEFAULT_ADMIN_ROLE`
    /// @param newuri The new base URI (should end with slash `/`)
    function setBaseURI(string memory newuri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseMetadataURI = newuri;
    }

    /// @notice Checks which interfaces this contract supports (ERC165)
    /// @param interfaceId The interface ID to check (e.g., ERC1155, AccessControl)
    /// @return True if the contract supports the interface
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
