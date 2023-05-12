// SPDX-License-Identifier: GPL-3.0
//
//                                             :+#####%%%%%%%%%%%%%%+
//                                         .-*@@@%+.:+%@@@@@%%#***%@@%=
//                                     :=*%@@@#=.      :#@@%       *@@@%=
//                       .-+*%@%*-.:+%@@@@@@+.     -*+:  .=#.       :%@@@%-
//                   :=*@@@@%%@@@@@@@@@%@@@-   .=#@@@%@%=             =@@@@#.
//             -=+#%@@%#*=:.  :%@@@@%.   -*@@#*@@@@@@@#=:-              *@@@@+
//            =@@%=:.     :=:   *@@@@@%#-   =%*%@@@@#+-.        =+       :%@@@%-
//           -@@%.     .+@@@     =+=-.         @@#-           +@@@%-       =@@@@%:
//          :@@@.    .+@@#%:                   :    .=*=-::.-%@@@+*@@=       +@@@@#.
//          %@@:    +@%%*                         =%@@@@@@@@@@@#.  .*@%-       +@@@@*.
//         #@@=                                .+@@@@%:=*@@@@@-      :%@%:      .*@@@@+
//        *@@*                                +@@@#-@@%-:%@@*          +@@#.      :%@@@@-
//       -@@%           .:-=++*##%%%@@@@@@@@@@@@*. :@+.@@@%:            .#@@+       =@@@@#:
//      .@@@*-+*#%%%@@@@@@@@@@@@@@@@%%#**@@%@@@.   *@=*@@#                :#@%=      .#@@@@#-
//      -%@@@@@@@@@@@@@@@*+==-:-@@@=    *@# .#@*-=*@@@@%=                 -%@@@*       =@@@@@%-
//         -+%@@@#.   %@%%=   -@@:+@: -@@*    *@@*-::                   -%@@%=.         .*@@@@@#
//            *@@@*  +@* *@@##@@-  #@*@@+    -@@=          .         :+@@@#:           .-+@@@%+-
//             +@@@%*@@:..=@@@@*   .@@@*   .#@#.       .=+-       .=%@@@*.         :+#@@@@*=:
//              =@@@@%@@@@@@@@@@@@@@@@@@@@@@%-      :+#*.       :*@@@%=.       .=#@@@@%+:
//               .%@@=                 .....    .=#@@+.       .#@@@*:       -*%@@@@%+.
//                 +@@#+===---:::...         .=%@@*-         +@@@+.      -*@@@@@%+.
//                  -@@@@@@@@@@@@@@@@@@@@@@%@@@@=          -@@@+      -#@@@@@#=.
//                    ..:::---===+++***###%%%@@@#-       .#@@+     -*@@@@@#=.
//                                           @@@@@@+.   +@@*.   .+@@@@@%=.
//                                          -@@@@@=   =@@%:   -#@@@@%+.
//                                          +@@@@@. =@@@=  .+@@@@@*:
//                                          #@@@@#:%@@#. :*@@@@#-
//                                          @@@@@%@@@= :#@@@@+.
//                                         :@@@@@@@#.:#@@@%-
//                                         +@@@@@@-.*@@@*:
//                                         #@@@@#.=@@@+.
//                                         @@@@+-%@%=
//                                        :@@@#%@%=
//                                        +@@@@%-
//                                        :#%%=
//
/**
 *     NOTICE
 *
 *     The T-REX software is licensed under a proprietary license or the GPL v.3.
 *     If you choose to receive it under the GPL v.3 license, the following applies:
 *     T-REX is a suite of smart contracts implementing the ERC-3643 standard and
 *     developed by Tokeny to manage and transfer financial assets on EVM blockchains
 *
 *     Copyright (C) 2023, Tokeny sàrl.
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@onchain-id/solidity/contracts/interface/IClaimIssuer.sol";
import "@onchain-id/solidity/contracts/interface/IIdentity.sol";
import "./interface/IClaimTopicsRegistry.sol";
import "./interface/IClaimIssuersRegistry.sol";
import "./interface/IIdentityRegistry.sol";
import "./interface/IIdentityRegistryStorage.sol";

contract IdentityRegistry is IIdentityRegistry, AccessControl {
    /// @dev Address of the ClaimTopicsRegistry Contract
    IClaimTopicsRegistry private _tokenTopicsRegistry;

    /// @dev Address of the ClaimIssuersRegistry Contract
    IClaimIssuersRegistry private _tokenIssuersRegistry;

    /// @dev Address of the IdentityRegistryStorage Contract
    IIdentityRegistryStorage private _tokenIdentityStorage;

    // keccak256(AGENT_ROLE)
    bytes32 public constant AGENT_ROLE =
        0xcab5a0bfe0b79d2c4b1c2e02599fa044d115b7511f9659307cb4276950967709;

    // keccak256(OWNER_ROLE)
    bytes32 public constant OWNER_ROLE =
        0xb19546dff01e856fb3f010c267a7b1c60363cf8a4664e21cc89c26224620214e;

    /**
     *  @dev the constructor initiates the Identity Registry smart contract
     *  @param _claimIssuersRegistry the claim issuers registry linked to the Identity Registry
     *  @param _claimTopicsRegistry the claim topics registry linked to the Identity Registry
     *  @param _identityStorage the identity registry storage linked to the Identity Registry
     *  emits a `ClaimTopicsRegistrySet` event
     *  emits a `ClaimIssuersRegistrySet` event
     *  emits an `IdentityStorageSet` event
     */
    constructor(
        address _claimIssuersRegistry,
        address _claimTopicsRegistry,
        address _identityStorage
    ) {
        require(
            _claimIssuersRegistry != address(0) &&
                _claimTopicsRegistry != address(0) &&
                _identityStorage != address(0),
            "ERC-3643: Invalid zero address"
        );
        _grantRole(bytes32(0), _msgSender());
        _grantRole(OWNER_ROLE, _msgSender());
        _tokenTopicsRegistry = IClaimTopicsRegistry(_claimTopicsRegistry);
        _tokenIssuersRegistry = IClaimIssuersRegistry(_claimIssuersRegistry);
        _tokenIdentityStorage = IIdentityRegistryStorage(_identityStorage);
        emit ClaimTopicsRegistrySet(_claimTopicsRegistry);
        emit ClaimIssuersRegistrySet(_claimIssuersRegistry);
        emit IdentityStorageSet(_identityStorage);
    }

    /**
     *  @dev See {IIdentityRegistry-batchRegisterIdentity}.
     */
    function batchRegisterIdentity(
        address[] calldata _userAddresses,
        IIdentity[] calldata _identities,
        uint16[] calldata _countries
    ) external override {
        for (uint256 i = 0; i < _userAddresses.length; i++) {
            registerIdentity(_userAddresses[i], _identities[i], _countries[i]);
        }
    }

    /**
     *  @dev See {IIdentityRegistry-updateIdentity}.
     */
    function updateIdentity(
        address _userAddress,
        IIdentity _identity
    ) external override onlyRole(AGENT_ROLE) {
        IIdentity oldIdentity = identity(_userAddress);
        _tokenIdentityStorage.modifyStoredIdentity(_userAddress, _identity);
        emit IdentityUpdated(oldIdentity, _identity);
    }

    /**
     *  @dev See {IIdentityRegistry-updateCountry}.
     */
    function updateCountry(
        address _userAddress,
        uint16 _country
    ) external override onlyRole(AGENT_ROLE) {
        _tokenIdentityStorage.modifyStoredInvestorCountry(
            _userAddress,
            _country
        );
        emit CountryUpdated(_userAddress, _country);
    }

    /**
     *  @dev See {IIdentityRegistry-deleteIdentity}.
     */
    function deleteIdentity(
        address _userAddress
    ) external override onlyRole(AGENT_ROLE) {
        IIdentity oldIdentity = identity(_userAddress);
        _tokenIdentityStorage.removeIdentityFromStorage(_userAddress);
        emit IdentityRemoved(_userAddress, oldIdentity);
    }

    /**
     *  @dev See {IIdentityRegistry-setIdentityRegistryStorage}.
     */
    function setIdentityRegistryStorage(
        address _identityRegistryStorage
    ) external override onlyRole(OWNER_ROLE) {
        _tokenIdentityStorage = IIdentityRegistryStorage(
            _identityRegistryStorage
        );
        emit IdentityStorageSet(_identityRegistryStorage);
    }

    /**
     *  @dev See {IIdentityRegistry-setClaimTopicsRegistry}.
     */
    function setClaimTopicsRegistry(
        address _claimTopicsRegistry
    ) external override onlyRole(OWNER_ROLE) {
        _tokenTopicsRegistry = IClaimTopicsRegistry(_claimTopicsRegistry);
        emit ClaimTopicsRegistrySet(_claimTopicsRegistry);
    }

    /**
     *  @dev See {IIdentityRegistry-setClaimIssuersRegistry}.
     */
    function setClaimIssuersRegistry(
        address _claimIssuersRegistry
    ) external override onlyRole(OWNER_ROLE) {
        _tokenIssuersRegistry = IClaimIssuersRegistry(_claimIssuersRegistry);
        emit ClaimIssuersRegistrySet(_claimIssuersRegistry);
    }

    /**
     *  @dev See {IIdentityRegistry-isVerified}.
     */
    // solhint-disable-next-line code-complexity
    function isVerified(
        address _userAddress
    ) external view override returns (bool) {
        if (address(identity(_userAddress)) == address(0)) {
            return false;
        }
        uint256[] memory requiredClaimTopics = _tokenTopicsRegistry
            .getClaimTopics();
        if (requiredClaimTopics.length == 0) {
            return true;
        }

        uint256 foundClaimTopic;
        uint256 scheme;
        address issuer;
        bytes memory sig;
        bytes memory data;
        uint256 claimTopic;
        for (
            claimTopic = 0;
            claimTopic < requiredClaimTopics.length;
            claimTopic++
        ) {
            IClaimIssuer[] memory claimIssuers = _tokenIssuersRegistry
                .getClaimIssuersForClaimTopic(requiredClaimTopics[claimTopic]);

            if (claimIssuers.length == 0) {
                return false;
            }

            bytes32[] memory claimIds = new bytes32[](claimIssuers.length);
            for (uint256 i = 0; i < claimIssuers.length; i++) {
                claimIds[i] = keccak256(
                    abi.encode(claimIssuers[i], requiredClaimTopics[claimTopic])
                );
            }

            for (uint256 j = 0; j < claimIds.length; j++) {
                (foundClaimTopic, scheme, issuer, sig, data, ) = identity(
                    _userAddress
                ).getClaim(claimIds[j]);

                if (foundClaimTopic == requiredClaimTopics[claimTopic]) {
                    try
                        IClaimIssuer(issuer).isClaimValid(
                            identity(_userAddress),
                            requiredClaimTopics[claimTopic],
                            sig,
                            data
                        )
                    returns (bool _validity) {
                        if (_validity) {
                            j = claimIds.length;
                        }
                        if (!_validity && j == (claimIds.length - 1)) {
                            return false;
                        }
                    } catch {
                        if (j == (claimIds.length - 1)) {
                            return false;
                        }
                    }
                } else if (j == (claimIds.length - 1)) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     *  @dev See {IIdentityRegistry-investorCountry}.
     */
    function investorCountry(
        address _userAddress
    ) external view override returns (uint16) {
        return _tokenIdentityStorage.storedInvestorCountry(_userAddress);
    }

    /**
     *  @dev See {IIdentityRegistry-issuersRegistry}.
     */
    function issuersRegistry()
        external
        view
        override
        returns (IClaimIssuersRegistry)
    {
        return _tokenIssuersRegistry;
    }

    /**
     *  @dev See {IIdentityRegistry-topicsRegistry}.
     */
    function topicsRegistry()
        external
        view
        override
        returns (IClaimTopicsRegistry)
    {
        return _tokenTopicsRegistry;
    }

    /**
     *  @dev See {IIdentityRegistry-identityStorage}.
     */
    function identityStorage()
        external
        view
        override
        returns (IIdentityRegistryStorage)
    {
        return _tokenIdentityStorage;
    }

    /**
     *  @dev See {IIdentityRegistry-contains}.
     */
    function contains(
        address _userAddress
    ) external view override returns (bool) {
        if (address(identity(_userAddress)) == address(0)) {
            return false;
        }
        return true;
    }

    /**
     *  @dev See {IIdentityRegistry-registerIdentity}.
     */
    function registerIdentity(
        address _userAddress,
        IIdentity _identity,
        uint16 _country
    ) public override onlyRole(AGENT_ROLE) {
        _tokenIdentityStorage.addIdentityToStorage(
            _userAddress,
            _identity,
            _country
        );
        emit IdentityRegistered(_userAddress, _identity);
    }

    /**
     *  @dev See {IIdentityRegistry-identity}.
     */
    function identity(
        address _userAddress
    ) public view override returns (IIdentity) {
        return _tokenIdentityStorage.storedIdentity(_userAddress);
    }
}
