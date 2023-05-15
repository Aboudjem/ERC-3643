// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@onchain-id/solidity/contracts/interface/IIdentity.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./interface/IIdentityRegistryStorage.sol";

/// @title ERC-3643 - IdentityRegistryStorage
/// @notice Stores user identities and their respective countries.
contract IdentityRegistryStorage is IIdentityRegistryStorage, AccessControl {
    /// @dev struct containing the identity contract and the country of the user
    struct Identity {
        /// @dev Identity contract of the user
        IIdentity identityContract;
        /// @dev Country of the user
        uint16 investorCountry;
    }

    // keccak256(AGENT_ROLE)
    bytes32 public constant AGENT_ROLE =
        0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709;

    // keccak256(OWNER_ROLE)
    bytes32 public constant OWNER_ROLE =
        0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e;

    /// @dev Mapping between a user address and the corresponding identity
    mapping(address => Identity) internal _identities;

    /// @dev Array of Identity Registries linked to this storage
    address[] internal _identityRegistries;

    constructor() {
        _grantRole(bytes32(0), _msgSender());
        _grantRole(AGENT_ROLE, _msgSender());
        _grantRole(OWNER_ROLE, _msgSender());
    }

    /// @notice Adds a new identity to the storage
    /// @param _userAddress User's address
    /// @param _identity Identity contract of the user
    /// @param _country Country of the user
    function addIdentityToStorage(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external onlyRole(AGENT_ROLE) {
        require(
            _userAddress != address(0) && address(_identity) != address(0),
            "ERC-3643: Invalid zero address"
        );
        require(
            address(_identities[_userAddress].identityContract) == address(0),
            "ERC-3643: Already stored"
        );
        _identities[_userAddress].identityContract = _identity;
        _identities[_userAddress].investorCountry = _country;
        emit IdentityStored(_userAddress, _identity);
    }

    /// @notice Modifies the stored identity of a user
    /// @param _userAddress User's address
    /// @param _identity New identity contract of the user
    function modifyStoredIdentity(
        address _userAddress,
        IIdentity _identity
    ) external onlyRole(AGENT_ROLE) {
        require(
            _userAddress != address(0) && address(_identity) != address(0),
            "ERC-3643: Invalid zero address"
        );
        require(
            address(_identities[_userAddress].identityContract) != address(0),
            "ERC-3643: Address not stored"
        );
        IIdentity oldIdentity = _identities[_userAddress].identityContract;
        _identities[_userAddress].identityContract = _identity;
        emit IdentityModified(oldIdentity, _identity);
    }

    /// @notice Modifies the stored investor country of a user
    /// @param _userAddress User's address
    /// @param _country New country of the user
    function modifyStoredInvestorCountry(
        address _userAddress,
        uint16 _country
    ) external onlyRole(AGENT_ROLE) {
        require(_userAddress != address(0), "ERC-3643: Invalid zero address");
        require(
            address(_identities[_userAddress].identityContract) != address(0),
            "ERC-3643: Address not stored"
        );
        _identities[_userAddress].investorCountry = _country;
        emit CountryModified(_userAddress, _country);
    }

    /// @notice Removes a user identity from the storage
    /// @param _userAddress User's address
    function removeIdentityFromStorage(
        address _userAddress
    ) external onlyRole(AGENT_ROLE) {
        require(_userAddress != address(0), "ERC-3643: Invalid zero address");
        require(
            address(_identities[_userAddress].identityContract) != address(0),
            "ERC-3643: Address not stored"
        );
        IIdentity oldIdentity = _identities[_userAddress].identityContract;
        delete _identities[_userAddress];
        emit IdentityUnstored(_userAddress, oldIdentity);
    }

    /// @notice Links an identity registry to this storage
    /// @param _identityRegistry Address of the identity registry
    function bindIdentityRegistry(
        address _identityRegistry
    ) external onlyRole(OWNER_ROLE) {
        require(
            _identityRegistry != address(0),
            "ERC-3643: Invalid zero address"
        );
        _grantRole(AGENT_ROLE, _identityRegistry);
        _identityRegistries.push(_identityRegistry);
        emit IdentityRegistryBound(_identityRegistry);
    }

    /// @notice Unlinks an identity registry from this storage
    /// @param _identityRegistry Address of the identity registry
    function unbindIdentityRegistry(
        address _identityRegistry
    ) external onlyRole(OWNER_ROLE) {
        require(
            _identityRegistry != address(0),
            "ERC-3643: Invalid zero address"
        );
        require(
            _identityRegistries.length != 0,
            "ERC-3643: No identity registry"
        );
        uint256 length = _identityRegistries.length;
        for (uint256 i = 0; i < length; ) {
            if (_identityRegistries[i] == _identityRegistry) {
                _identityRegistries[i] = _identityRegistries[length - 1];
                _identityRegistries.pop();
                break;
            }
            unchecked {
                ++i;
            }
        }
        _revokeRole(AGENT_ROLE, _identityRegistry);
        emit IdentityRegistryUnbound(_identityRegistry);
    }

    /// @notice Returns all linked identity registries
    /// @return Array of addresses of the linked identity registries
    function linkedIdentityRegistries()
        external
        view
        returns (address[] memory)
    {
        return _identityRegistries;
    }

    /// @notice Returns the stored identity of a user
    /// @param _userAddress User's address
    /// @return User's identity contract
    function storedIdentity(
        address _userAddress
    ) external view returns (IIdentity) {
        return _identities[_userAddress].identityContract;
    }

    /// @notice Returns the stored investor country of a user
    /// @param _userAddress User's address
    /// @return User's country
    function storedInvestorCountry(
        address _userAddress
    ) external view returns (uint16) {
        return _identities[_userAddress].investorCountry;
    }
}
