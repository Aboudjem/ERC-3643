// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

import "@onchain-id/solidity/contracts/interface/IClaimIssuer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IClaimIssuersRegistry.sol";

/// @title ERC-3643 - ClaimIssuersRegistry
/// @dev This contract maintains a registry of claim issuers and their associated claim topics for the ERC-3643 standard.
contract ClaimIssuersRegistry is IClaimIssuersRegistry, Ownable {
    /// @dev Array containing all ClaimIssuers identity contract address.
    IClaimIssuer[] private _claimIssuers;

    /// @dev Mapping between a claim issuer address and its corresponding claimTopics.
    mapping(IClaimIssuer => uint256[]) private _claimIssuerClaimTopics;

    /// @dev Mapping between a claim topic and the allowed claim issuers for it.
    mapping(uint256 => IClaimIssuer[]) private _claimTopicToClaimIssuers;

    /// @notice Adds a claim issuer to the Claim Issuers Registry.
    /// @param _claimIssuer The address of the claim issuer.
    /// @param _claimTopics An array of claim topics associated with the claim issuer.
    /// Requirements:
    /// - The caller must be the owner of the contract.
    /// - The claim issuer address must not be zero.
    /// - The claim issuer must not already exist in the registry.
    /// - The claim topics array must not be empty.
    /// - It is recommended to add a reasonable number of claim issuers at once.
    /// Emits a ClaimIssuerAdded event.
    function addClaimIssuer(
        IClaimIssuer _claimIssuer,
        uint256[] calldata _claimTopics
    ) external onlyOwner {
        require(
            address(_claimIssuer) != address(0),
            "ERC-3643: Invalid zero address"
        );
        require(
            _claimIssuerClaimTopics[_claimIssuer].length == 0,
            "ERC-3643: Issuer already exists"
        );
        uint length = _claimTopics.length;
        require(length != 0, "ERC-3643: Empty claim topics");

        _claimIssuers.push(_claimIssuer);
        _claimIssuerClaimTopics[_claimIssuer] = _claimTopics;

        for (uint256 i = 0; i < length; ) {
            _claimTopicToClaimIssuers[_claimTopics[i]].push(_claimIssuer);
            unchecked {
                ++i;
            }
        }

        emit ClaimIssuerAdded(_claimIssuer, _claimTopics);
    }

    /// @notice Removes a claim issuer from the Claim Issuers Registry.
    /// @param _claimIssuer The address of the claim issuer to be removed.
    /// Requirements:
    /// - The caller must be the owner of the contract.
    /// - The claim issuer must exist in the registry.
    /// Emits a ClaimIssuerRemoved event.
    function removeClaimIssuer(IClaimIssuer _claimIssuer) external onlyOwner {
        uint claimIssuerTopicsLength = _claimIssuerClaimTopics[_claimIssuer]
            .length;
        require(claimIssuerTopicsLength != 0, "ERC-3643: Not a claim issuer");
        uint256 claimIssuerlength = _claimIssuers.length;
        for (uint256 i = 0; i < claimIssuerlength; ) {
            if (_claimIssuers[i] == _claimIssuer) {
                _claimIssuers[i] = _claimIssuers[claimIssuerlength - 1];
                _claimIssuers.pop();
                break;
            }
            unchecked {
                ++i;
            }
        }

        _removeClaimIssuerFromAllClaimTopics(
            _claimIssuer,
            claimIssuerTopicsLength
        );

        delete _claimIssuerClaimTopics[_claimIssuer];
        emit ClaimIssuerRemoved(_claimIssuer);
    }

    /// @notice Updates the claim topics associated with a claim issuer.
    /// @param _claimIssuer The address of the claim issuer.
    /// @param _claimTopics An array of claim topics to be associated with the claim issuer.
    /// Requirements:
    /// - The caller must be the owner of the contract.
    /// - The claim issuer must exist in the registry.
    /// - The claim topics array must not be empty.
    /// Emits a ClaimTopicsUpdated event.
    function updateIssuerClaimTopics(
        IClaimIssuer _claimIssuer,
        uint256[] calldata _claimTopics
    ) external onlyOwner {
        uint claimIssuerTopicsLength = _claimIssuerClaimTopics[_claimIssuer]
            .length;
        require(claimIssuerTopicsLength != 0, "ERC-3643: Not a claim issuer");
        require(_claimTopics.length != 0, "ERC-3643: No claim topics");

        _updateIssuerAcrossAllTopics(_claimIssuer);

        _claimIssuerClaimTopics[_claimIssuer] = _claimTopics;

        emit ClaimTopicsUpdated(_claimIssuer, _claimTopics);
    }

    /// @notice Returns an array of all claim issuers in the registry.
    /// @return A memory array of claim issuers.
    function getClaimIssuers() external view returns (IClaimIssuer[] memory) {
        return _claimIssuers;
    }

    /// @notice Returns an array of all claim issuers associated with a specific claim topic.
    /// @param claimTopic The claim topic to find associated claim issuers for.
    /// @return A memory array of claim issuers.
    function getClaimIssuersForClaimTopic(
        uint256 claimTopic
    ) external view returns (IClaimIssuer[] memory) {
        return _claimTopicToClaimIssuers[claimTopic];
    }

    /// @notice Checks if an address is a claim issuer in the registry.
    /// @param _issuer The address to check.
    /// @return True if the address is a claim issuer, false otherwise.
    function isClaimIssuer(IClaimIssuer _issuer) external view returns (bool) {
        return _isClaimIssuer(_issuer);
    }

    /// @notice Returns an array of claim topics associated with a specific claim issuer.
    /// @param _claimIssuer The claim issuer to find associated claim topics for.
    /// @return A memory array of claim topics.
    function getClaimIssuerClaimTopics(
        IClaimIssuer _claimIssuer
    ) external view returns (uint256[] memory) {
        require(_isClaimIssuer(_claimIssuer), "ERC-3643: Issuer doesn't exist");
        return _claimIssuerClaimTopics[_claimIssuer];
    }

    /// @notice Checks if a claim issuer has a specific claim topic.
    /// @dev This function checks if a specific claim topic is associated with a claim issuer.
    /// @param _issuer The claim issuer to check.
    /// @param _claimTopic The claim topic to check.
    /// @return bool True if the claim issuer has the claim topic, otherwise false.
    function hasClaimTopic(
        IClaimIssuer _issuer,
        uint256 _claimTopic
    ) external view returns (bool) {
        uint256 length = _claimIssuerClaimTopics[_issuer].length;
        uint256[] memory claimTopics = _claimIssuerClaimTopics[_issuer];
        for (uint256 i = 0; i < length; ) {
            if (claimTopics[i] == _claimTopic) {
                return true;
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /// @dev Removes a claim issuer from all associated claim topics.
    /// @param claimIssuer The claim issuer to be removed.
    /// @param length The number of claim topics associated with the claim issuer.
    function _removeClaimIssuerFromAllClaimTopics(
        IClaimIssuer claimIssuer,
        uint length
    ) private {
        for (uint256 i = 0; i < length; ) {
            uint256 claimTopic = _claimIssuerClaimTopics[claimIssuer][i];

            _removeIssuerFromTopic(claimIssuer, claimTopic);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Updates a claim issuer across all associated claim topics.
    ///      The function removes the claim issuer from each topic, and then adds it back.
    /// @param claimIssuer The claim issuer to be updated.
    function _updateIssuerAcrossAllTopics(IClaimIssuer claimIssuer) private {
        uint256[] memory claimTopics = _claimIssuerClaimTopics[claimIssuer];
        uint length = claimTopics.length;

        for (uint256 i = 0; i < length; ) {
            uint256 claimTopic = claimTopics[i];

            _removeIssuerFromTopic(claimIssuer, claimTopic);
            _claimTopicToClaimIssuers[claimTopics[i]].push(claimIssuer);
            unchecked {
                ++i;
            }
        }
    }

    /// @dev Removes a claim issuer from a specific claim topic.
    ///      The function identifies and replaces the claim issuer with the last element in the list
    ///      then removes the last element, effectively removing the issuer from the list.
    /// @param claimIssuer The claim issuer to be removed.
    /// @param claimTopic The claim topic identifier from which the issuer is to be removed.
    function _removeIssuerFromTopic(
        IClaimIssuer claimIssuer,
        uint claimTopic
    ) private {
        IClaimIssuer[] memory claimIssuers = _claimTopicToClaimIssuers[
            claimTopic
        ];
        uint length = claimIssuers.length;

        for (uint j = 0; j < length; ) {
            if (claimIssuers[j] == claimIssuer) {
                _claimTopicToClaimIssuers[claimTopic][j] = claimIssuers[
                    length - 1
                ];
                _claimTopicToClaimIssuers[claimTopic].pop();
                break;
            }
            unchecked {
                ++j;
            }
        }
    }

    /// @dev Checks if an address is a claim issuer.
    /// @param _issuer The address to check.
    /// @return bool Returns true if the address is a claim issuer, and false otherwise.
    function _isClaimIssuer(IClaimIssuer _issuer) private view returns (bool) {
        return (_claimIssuerClaimTopics[_issuer].length != 0);
    }
}
