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

import "@onchain-id/solidity/contracts/interface/IClaimIssuer.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IClaimIssuersRegistry.sol";

contract ClaimIssuersRegistry is IClaimIssuersRegistry, Ownable {
    /// @dev Array containing all ClaimIssuers identity contract address.
    IClaimIssuer[] internal _claimIssuers;

    /// @dev Mapping between a claim issuer address and its corresponding claimTopics.
    mapping(address => uint256[]) internal _claimIssuerClaimTopics;

    /// @dev Mapping between a claim topic and the allowed claim issuers for it.
    mapping(uint256 => IClaimIssuer[]) internal _claimTopicsToClaimIssuers;

    /**
     *  @dev See {IClaimIssuersRegistry-addClaimIssuer}.
     */
    function addClaimIssuer(
        IClaimIssuer _claimIssuer,
        uint256[] calldata _claimTopics
    ) external onlyOwner {
        require(
            address(_claimIssuer) != address(0),
            "ERC-3643: Invalid zero address"
        );
        require(
            _claimIssuerClaimTopics[address(_claimIssuer)].length == 0,
            "claim Issuer already exists"
        );
        require(_claimTopics.length > 0, "claim claim topics cannot be empty");
        require(
            _claimTopics.length <= 15,
            "cannot have more than 15 claim topics"
        );
        require(
            _claimIssuers.length < 50,
            "cannot have more than 50 claim issuers"
        );
        _claimIssuers.push(_claimIssuer);
        _claimIssuerClaimTopics[address(_claimIssuer)] = _claimTopics;
        for (uint256 i = 0; i < _claimTopics.length; i++) {
            _claimTopicsToClaimIssuers[_claimTopics[i]].push(_claimIssuer);
        }
        emit ClaimIssuerAdded(_claimIssuer, _claimTopics);
    }

    /**
     *  @dev See {IClaimIssuersRegistry-removeClaimIssuer}.
     */
    function removeClaimIssuer(
        IClaimIssuer _claimIssuer
    ) external override onlyOwner {
        require(
            address(_claimIssuer) != address(0),
            "ERC-3643: Invalid zero address"
        );
        require(
            _claimIssuerClaimTopics[address(_claimIssuer)].length != 0,
            "NOT a claim issuer"
        );
        uint256 length = _claimIssuers.length;
        for (uint256 i = 0; i < length; i++) {
            if (_claimIssuers[i] == _claimIssuer) {
                _claimIssuers[i] = _claimIssuers[length - 1];
                _claimIssuers.pop();
                break;
            }
        }
        for (
            uint256 claimTopicIndex = 0;
            claimTopicIndex <
            _claimIssuerClaimTopics[address(_claimIssuer)].length;
            claimTopicIndex++
        ) {
            uint256 claimTopic = _claimIssuerClaimTopics[address(_claimIssuer)][
                claimTopicIndex
            ];
            uint256 topicsLength = _claimTopicsToClaimIssuers[claimTopic]
                .length;
            for (uint256 i = 0; i < topicsLength; i++) {
                if (_claimTopicsToClaimIssuers[claimTopic][i] == _claimIssuer) {
                    _claimTopicsToClaimIssuers[claimTopic][
                        i
                    ] = _claimTopicsToClaimIssuers[claimTopic][
                        topicsLength - 1
                    ];
                    _claimTopicsToClaimIssuers[claimTopic].pop();
                    break;
                }
            }
        }
        delete _claimIssuerClaimTopics[address(_claimIssuer)];
        emit ClaimIssuerRemoved(_claimIssuer);
    }

    /**
     *  @dev See {IClaimIssuersRegistry-updateIssuerClaimTopics}.
     */
    function updateIssuerClaimTopics(
        IClaimIssuer _claimIssuer,
        uint256[] calldata _claimTopics
    ) external override onlyOwner {
        require(
            address(_claimIssuer) != address(0),
            "ERC-3643: Invalid zero address"
        );
        require(
            _claimIssuerClaimTopics[address(_claimIssuer)].length != 0,
            "NOT a claim issuer"
        );
        require(
            _claimTopics.length <= 15,
            "cannot have more than 15 claim topics"
        );
        require(_claimTopics.length > 0, "claim topics cannot be empty");

        for (
            uint256 i = 0;
            i < _claimIssuerClaimTopics[address(_claimIssuer)].length;
            i++
        ) {
            uint256 claimTopic = _claimIssuerClaimTopics[address(_claimIssuer)][
                i
            ];
            uint256 topicsLength = _claimTopicsToClaimIssuers[claimTopic]
                .length;
            for (uint256 j = 0; j < topicsLength; j++) {
                if (_claimTopicsToClaimIssuers[claimTopic][j] == _claimIssuer) {
                    _claimTopicsToClaimIssuers[claimTopic][
                        j
                    ] = _claimTopicsToClaimIssuers[claimTopic][
                        topicsLength - 1
                    ];
                    _claimTopicsToClaimIssuers[claimTopic].pop();
                    break;
                }
            }
        }
        _claimIssuerClaimTopics[address(_claimIssuer)] = _claimTopics;
        for (uint256 i = 0; i < _claimTopics.length; i++) {
            _claimTopicsToClaimIssuers[_claimTopics[i]].push(_claimIssuer);
        }
        emit ClaimTopicsUpdated(_claimIssuer, _claimTopics);
    }

    /**
     *  @dev See {IClaimIssuersRegistry-getClaimIssuers}.
     */
    function getClaimIssuers()
        external
        view
        override
        returns (IClaimIssuer[] memory)
    {
        return _claimIssuers;
    }

    /**
     *  @dev See {IClaimIssuersRegistry-getClaimIssuersForClaimTopic}.
     */
    function getClaimIssuersForClaimTopic(
        uint256 claimTopic
    ) external view override returns (IClaimIssuer[] memory) {
        return _claimTopicsToClaimIssuers[claimTopic];
    }

    /**
     *  @dev See {IClaimIssuersRegistry-isClaimIssuer}.
     */
    function isClaimIssuer(
        address _issuer
    ) external view override returns (bool) {
        if (_claimIssuerClaimTopics[_issuer].length > 0) {
            return true;
        }
        return false;
    }

    /**
     *  @dev See {IClaimIssuersRegistry-getClaimIssuerClaimTopics}.
     */
    function getClaimIssuerClaimTopics(
        IClaimIssuer _claimIssuer
    ) external view override returns (uint256[] memory) {
        require(
            _claimIssuerClaimTopics[address(_claimIssuer)].length != 0,
            "claim Issuer doesn't exist"
        );
        return _claimIssuerClaimTopics[address(_claimIssuer)];
    }

    /**
     *  @dev See {IClaimIssuersRegistry-hasClaimTopic}.
     */
    function hasClaimTopic(
        address _issuer,
        uint256 _claimTopic
    ) external view override returns (bool) {
        uint256 length = _claimIssuerClaimTopics[_issuer].length;
        uint256[] memory claimTopics = _claimIssuerClaimTopics[_issuer];
        for (uint256 i = 0; i < length; i++) {
            if (claimTopics[i] == _claimTopic) {
                return true;
            }
        }
        return false;
    }
}
