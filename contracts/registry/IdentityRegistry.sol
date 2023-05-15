// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@onchain-id/solidity/contracts/interface/IClaimIssuer.sol";
import "@onchain-id/solidity/contracts/interface/IIdentity.sol";
import "./interface/IClaimTopicsRegistry.sol";
import "./interface/IClaimIssuersRegistry.sol";
import "./interface/IIdentityRegistry.sol";
import "./interface/IIdentityRegistryStorage.sol";

/// @title ERC-3643 - IdentityRegistry
/// @dev This contract is used to manage identities in the ERC-3643 standard.
/// It allows for the registration, updating and deletion of identities associated with user addresses.
/// It also supports the management of claim topics and claim issuers.
contract IdentityRegistry is IIdentityRegistry, AccessControl {
    /// @notice The address of the ClaimTopicsRegistry contract.
    IClaimTopicsRegistry private _tokenTopicsRegistry;

    /// @notice The address of the ClaimIssuersRegistry contract.
    IClaimIssuersRegistry private _tokenIssuersRegistry;

    /// @notice The address of the IdentityRegistryStorage contract.
    IIdentityRegistryStorage private _tokenIdentityStorage;

    // keccak256(AGENT_ROLE)
    bytes32 public constant AGENT_ROLE =
        0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709;

    // keccak256(OWNER_ROLE)
    bytes32 public constant OWNER_ROLE =
        0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e;

    /// @dev Constructor of the IdentityRegistry contract.
    /// @param _claimIssuersRegistry The address of the claim issuers registry contract.
    /// @param _claimTopicsRegistry The address of the claim topics registry contract.
    /// @param _identityStorage The address of the identity registry storage contract.
    /// @notice This constructor sets the initial state of the IdentityRegistry contract.
    constructor(
        IClaimIssuersRegistry _claimIssuersRegistry,
        IClaimTopicsRegistry _claimTopicsRegistry,
        IIdentityRegistryStorage _identityStorage
    ) {
        require(
            address(_claimIssuersRegistry) != address(0) &&
                address(_claimTopicsRegistry) != address(0) &&
                address(_identityStorage) != address(0),
            "ERC-3643: Invalid zero address"
        );
        _grantRole(bytes32(0), _msgSender());
        _grantRole(OWNER_ROLE, _msgSender());
        _tokenTopicsRegistry = _claimTopicsRegistry;
        _tokenIssuersRegistry = _claimIssuersRegistry;
        _tokenIdentityStorage = _identityStorage;
        emit ClaimTopicsRegistrySet(_claimTopicsRegistry);
        emit ClaimIssuersRegistrySet(_claimIssuersRegistry);
        emit IdentityStorageSet(_identityStorage);
    }

    /// @notice Register an identity associated with a user address.
    /// @param _userAddress The address of the user.
    /// @param _identity The identity of the user.
    /// @param _country The country code of the user.
    /// @dev Only an agent can register an identity.
    function registerIdentity(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) external onlyRole(AGENT_ROLE) {
        _registerIdentity(_userAddress, _identity, _country);
    }

    /// @notice Register multiple identities associated with multiple user addresses.
    /// @param _userAddresses The array of user addresses.
    /// @param _identities The array of identities.
    /// @param _countries The array of country codes.
    /// @dev Only an agent can register identities in batch.
    function batchRegisterIdentity(
        address[] calldata _userAddresses,
        IIdentity[] calldata _identities,
        uint16[] calldata _countries
    ) external onlyRole(AGENT_ROLE) {
        uint length = _userAddresses.length;
        require(length == _identities.length, "ERC-3643: Array size mismatch");
        require(length == _countries.length, "ERC-3643: Array size mismatch");
        for (uint256 i = 0; i < length; ) {
            _registerIdentity(_userAddresses[i], _identities[i], _countries[i]);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Update the identity associated with a user address.
    /// @param _userAddress The address of the user.
    /// @param _identity The new identity of the user.
    /// @dev Only an agent can update an identity.
    function updateIdentity(
        address _userAddress,
        IIdentity _identity
    ) external onlyRole(AGENT_ROLE) {
        IIdentity oldIdentity = _getIdentity(_userAddress);
        _tokenIdentityStorage.modifyStoredIdentity(_userAddress, _identity);
        emit IdentityUpdated(oldIdentity, _identity);
    }

    /// @notice Update the country code associated with a user address.
    /// @param _userAddress The address of the user.
    /// @param _country The new country code of the user.
    /// @dev Only an agent can update a country code.
    function updateCountry(
        address _userAddress,
        uint16 _country
    ) external onlyRole(AGENT_ROLE) {
        _tokenIdentityStorage.modifyStoredInvestorCountry(
            _userAddress,
            _country
        );
        emit CountryUpdated(_userAddress, _country);
    }

    /// @notice Delete the identity associated with a user address.
    /// @param _userAddress The address of the user.
    /// @dev Only an agent can delete an identity.
    function deleteIdentity(
        address _userAddress
    ) external onlyRole(AGENT_ROLE) {
        IIdentity oldIdentity = _getIdentity(_userAddress);
        _tokenIdentityStorage.removeIdentityFromStorage(_userAddress);
        emit IdentityRemoved(_userAddress, oldIdentity);
    }

    /// @notice Set the IdentityRegistryStorage contract.
    /// @param _identityRegistryStorage The address of the new IdentityRegistryStorage contract.
    /// @dev Only the owner can set the IdentityRegistryStorage contract.
    function setIdentityRegistryStorage(
        IIdentityRegistryStorage _identityRegistryStorage
    ) external onlyRole(OWNER_ROLE) {
        _tokenIdentityStorage = _identityRegistryStorage;
        emit IdentityStorageSet(_identityRegistryStorage);
    }

    /// @notice Set the ClaimTopicsRegistry contract.
    /// @param _claimTopicsRegistry The address of the new ClaimTopicsRegistry contract.
    /// @dev Only the owner can set the ClaimTopicsRegistry contract.
    function setClaimTopicsRegistry(
        IClaimTopicsRegistry _claimTopicsRegistry
    ) external onlyRole(OWNER_ROLE) {
        _tokenTopicsRegistry = _claimTopicsRegistry;
        emit ClaimTopicsRegistrySet(_claimTopicsRegistry);
    }

    /// @notice Set the ClaimIssuersRegistry contract.
    /// @param _claimIssuersRegistry The address of the new ClaimIssuersRegistry contract.
    /// @dev Only the owner can set the ClaimIssuersRegistry contract.
    function setClaimIssuersRegistry(
        IClaimIssuersRegistry _claimIssuersRegistry
    ) external onlyRole(OWNER_ROLE) {
        _tokenIssuersRegistry = _claimIssuersRegistry;
        emit ClaimIssuersRegistrySet(_claimIssuersRegistry);
    }

    /// @notice Checks if a user is verified based on their identity, claim topics, and claim issuers.
    /// @param _userAddress The address of the user to check.
    /// @return A boolean indicating if the user is verified.
    function isVerified(address _userAddress) external view returns (bool) {
        // Get the identity of the user from the given address
        IIdentity userIdentity = _getIdentity(_userAddress);

        // If the user identity is not set (address is 0), return false
        if (address(userIdentity) == address(0)) return false;

        // Get the required claim topics for the token
        uint256[] memory claimTopics = _tokenTopicsRegistry.getClaimTopics();
        uint claimTopicsLength = claimTopics.length;

        // If there are no required claim topics, return true
        if (claimTopicsLength == 0) return true;

        // Loop over all required claim topics
        for (uint256 i = 0; i < claimTopicsLength; i++) {
            if (!_isClaimValid(userIdentity, claimTopics[i])) {
                return false;
            }
        }
        // If all checks pass, return true
        return true;
    }

    /// @notice Get the country of an investor.
    /// @param _userAddress The address of the investor.
    /// @return The country of the investor.
    function investorCountry(
        address _userAddress
    ) external view returns (uint16) {
        return _tokenIdentityStorage.storedInvestorCountry(_userAddress);
    }

    /// @notice Get the issuers registry.
    /// @return The current issuers registry.
    function issuersRegistry() external view returns (IClaimIssuersRegistry) {
        return _tokenIssuersRegistry;
    }

    /// @notice Get the topics registry.
    /// @return The current topics registry.
    function topicsRegistry() external view returns (IClaimTopicsRegistry) {
        return _tokenTopicsRegistry;
    }

    /// @notice Get the identity storage.
    /// @return The current identity storage.
    function identityStorage()
        external
        view
        returns (IIdentityRegistryStorage)
    {
        return _tokenIdentityStorage;
    }

    /// @notice Check if an address is contained in the registry.
    /// @param _userAddress The address to check.
    /// @return A boolean indicating if the address is in the registry.
    function contains(address _userAddress) external view returns (bool) {
        return address(identity(_userAddress)) == address(0) ? false : true;
    }

    /// @notice Get the identity of a user.
    /// @param _userAddress The address of the user.
    /// @return The identity of the user.
    function identity(address _userAddress) public view returns (IIdentity) {
        return _tokenIdentityStorage.storedIdentity(_userAddress);
    }

    /// @notice Register a new identity.
    /// @param _userAddress The address of the user.
    /// @param _identity The identity of the user.
    /// @param _country The country of the user.
    function _registerIdentity(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) private {
        _tokenIdentityStorage.addIdentityToStorage(
            _userAddress,
            _identity,
            _country
        );
        emit IdentityRegistered(_userAddress, _identity);
    }

    /// @notice Get the identity of a user.
    /// @param _userAddress The address of the user.
    /// @return The identity of the user.
    function _getIdentity(
        address _userAddress
    ) private view returns (IIdentity) {
        return _tokenIdentityStorage.storedIdentity(_userAddress);
    }

    function _isClaimValid(
        IIdentity userIdentity,
        uint256 claimTopic
    ) private view returns (bool) {
        IClaimIssuer[] memory claimIssuers = _tokenIssuersRegistry
            .getClaimIssuersForClaimTopic(claimTopic);
        uint claimIssuersLength = claimIssuers.length;

        if (claimIssuersLength == 0) {
            return false;
        }

        bytes32[] memory claimIds = new bytes32[](claimIssuersLength);

        for (uint256 i = 0; i < claimIssuersLength; i++) {
            claimIds[i] = keccak256(abi.encode(claimIssuers[i], claimTopic));
        }

        for (uint256 j = 0; j < claimIds.length; j++) {
            (
                uint256 foundClaimTopic,
                ,
                address issuer,
                bytes memory sig,
                bytes memory data,

            ) = userIdentity.getClaim(claimIds[j]);

            if (foundClaimTopic == claimTopic) {
                if (
                    _isIssuerClaimValid(
                        userIdentity,
                        issuer,
                        claimTopic,
                        sig,
                        data
                    )
                ) {
                    return true;
                }
            } else if (j == claimIds.length - 1) {
                return false;
            }
        }

        return false;
    }

    /// @param userIdentity The identity contract related to the claim.
    /// @param issuer The address of the claim issuer.
    /// @param claimTopic The claim topic of the claim.
    /// @param sig The signature of the claim.
    /// @param data The data field of the claim.
    /// @return claimValid True if the claim is valid, false otherwise.
    function _isIssuerClaimValid(
        IIdentity userIdentity,
        address issuer,
        uint claimTopic,
        bytes memory sig,
        bytes memory data
    ) private view returns (bool) {
        try
            IClaimIssuer(issuer).isClaimValid(
                userIdentity,
                claimTopic,
                sig,
                data
            )
        returns (bool _validity) {
            return _validity;
        } catch {
            return false;
        }
    }
}
