// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "@onchain-id/solidity/contracts/interface/IClaimIssuer.sol";

interface IClaimIssuersRegistry {
    /**
     *  this event is emitted when a claim issuer is added in the registry.
     *  the event is emitted by the addClaimIssuer function
     *  `claimIssuer` is the address of the claim issuer's ClaimIssuer contract
     *  `claimTopics` is the set of claims that the claim issuer is allowed to emit
     */
    event ClaimIssuerAdded(
        IClaimIssuer indexed claimIssuer,
        uint256[] claimTopics
    );

    /**
     *  this event is emitted when a claim issuer is removed from the registry.
     *  the event is emitted by the removeClaimIssuer function
     *  `claimIssuer` is the address of the claim issuer's ClaimIssuer contract
     */
    event ClaimIssuerRemoved(IClaimIssuer indexed claimIssuer);

    /**
     *  this event is emitted when the set of claim topics is changed for a given claim issuer.
     *  the event is emitted by the updateIssuerClaimTopics function
     *  `claimIssuer` is the address of the claim issuer's ClaimIssuer contract
     *  `claimTopics` is the set of claims that the claim issuer is allowed to emit
     */
    event ClaimTopicsUpdated(
        IClaimIssuer indexed claimIssuer,
        uint256[] claimTopics
    );

    /**
     *  @dev registers a ClaimIssuer contract as claim claim issuer.
     *  Requires that a ClaimIssuer contract doesn't already exist
     *  Requires that the claimTopics set is not empty
     *  Requires that there is no more than 15 claimTopics
     *  Requires that there is no more than 50 Claim issuers
     *  @param _claimIssuer The ClaimIssuer contract address of the claim claim issuer.
     *  @param _claimTopics the set of claim topics that the claim issuer is allowed to emit
     *  This function can only be called by the owner of the Claim Issuers Registry contract
     *  emits a `ClaimIssuerAdded` event
     */
    function addClaimIssuer(
        IClaimIssuer _claimIssuer,
        uint256[] calldata _claimTopics
    ) external;

    /**
     *  @dev Removes the ClaimIssuer contract of a claim claim issuer.
     *  Requires that the claim issuer contract to be registered first
     *  @param _claimIssuer the claim issuer to remove.
     *  This function can only be called by the owner of the Claim Issuers Registry contract
     *  emits a `ClaimIssuerRemoved` event
     */
    function removeClaimIssuer(IClaimIssuer _claimIssuer) external;

    /**
     *  @dev Updates the set of claim topics that a claim issuer is allowed to emit.
     *  Requires that this ClaimIssuer contract already exists in the registry
     *  Requires that the provided claimTopics set is not empty
     *  Requires that there is no more than 15 claimTopics
     *  @param _claimIssuer the claim issuer to update.
     *  @param _claimTopics the set of claim topics that the claim issuer is allowed to emit
     *  This function can only be called by the owner of the Claim Issuers Registry contract
     *  emits a `ClaimTopicsUpdated` event
     */
    function updateIssuerClaimTopics(
        IClaimIssuer _claimIssuer,
        uint256[] calldata _claimTopics
    ) external;

    /**
     *  @dev Function for getting all the claim claim issuers stored.
     *  @return array of all claim issuers registered.
     */
    function getClaimIssuers() external view returns (IClaimIssuer[] memory);

    /**
     *  @dev Function for getting all the claim issuer allowed for a given claim topic.
     *  @param claimTopic the claim topic to get the claim issuers for.
     *  @return array of all claim issuer addresses that are allowed for the given claim topic.
     */
    function getClaimIssuersForClaimTopic(
        uint256 claimTopic
    ) external view returns (IClaimIssuer[] memory);

    /**
     *  @dev Checks if the ClaimIssuer contract is claim
     *  @param _issuer the address of the ClaimIssuer contract
     *  @return true if the issuer is claim, false otherwise.
     */
    function isClaimIssuer(IClaimIssuer _issuer) external view returns (bool);

    /**
     *  @dev Function for getting all the claim topic of claim claim issuer
     *  Requires the provided ClaimIssuer contract to be registered in the claim issuers registry.
     *  @param _claimIssuer the claim issuer concerned.
     *  @return The set of claim topics that the claim issuer is allowed to emit
     */
    function getClaimIssuerClaimTopics(
        IClaimIssuer _claimIssuer
    ) external view returns (uint256[] memory);

    /**
     *  @dev Function for checking if the claim claim issuer is allowed
     *  to emit a certain claim topic
     *  @param _issuer the address of the claim issuer's ClaimIssuer contract
     *  @param _claimTopic the Claim Topic that has to be checked to know if the `issuer` is allowed to emit it
     *  @return true if the issuer is claim for this claim topic.
     */
    function hasClaimTopic(
        IClaimIssuer _issuer,
        uint256 _claimTopic
    ) external view returns (bool);
}
