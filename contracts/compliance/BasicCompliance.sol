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

import "./interface/ICompliance.sol";
import "../token/IToken.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BasicCompliance is ICompliance, AccessControl {
    /// Mapping between agents and their statuses
    mapping(address => bool) private _tokenAgentsList;
    /// Mapping of tokens linked to the compliance contract
    IToken public tokenBound;

    // keccak256(ADMIN_ROLE)
    bytes32 public constant ADMIN_ROLE =
        0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775;

    // keccak256(TOKEN_ROLE)
    bytes32 public constant TOKEN_ROLE =
        0xa7197c38d9c4c7450c7f2cd20d0a17cbe7c344190d6c82a6b49a146e62439ae4;

    constructor() {
        _grantRole(0x00, _msgSender());
        _grantRole(ADMIN_ROLE, _msgSender());
    }

    /**
     *  @dev See {ICompliance-bindToken}.
     */
    function bindToken(address _token) external override {
        require(
            hasRole(ADMIN_ROLE, _msgSender()) ||
                hasRole(ADMIN_ROLE, _msgSender()) ||
                address(tokenBound) == address(0),
            "only owner or token can call"
        );
        tokenBound = IToken(_token);
        emit TokenBound(_token);
    }

    /**
     *  @dev See {ICompliance-unbindToken}.
     */
    function unbindToken(address _token) external override {
        require(
            hasRole(ADMIN_ROLE, _msgSender()) ||
                hasRole(TOKEN_ROLE, _msgSender()),
            "only owner or token can call"
        );
        require(_token == address(tokenBound), "This token is not bound");
        delete tokenBound;
        emit TokenUnbound(_token);
    }

    /*
     *  @dev See {ICompliance-transferred}.
     */
    function transferred(
        address _from,
        address _to,
        uint256 _value
    ) external override {}

    /**
     *  @dev See {ICompliance-created}.
     */

    function created(address _to, uint256 _value) external override {}

    /**
     *  @dev See {ICompliance-destroyed}.
     */
    // solhint-disable-next-line no-empty-blocks
    function destroyed(address _from, uint256 _value) external override {}

    /**
     *  @dev See {ICompliance-canTransfer}.
     */
    function canTransfer(
        address /*_from*/,
        address /*_to*/,
        uint256 /*_value*/
    ) external view override returns (bool) {
        return true;
    }

    /**
     *  @dev See {ICompliance-isTokenBound}.
     */
    function isTokenBound(
        address _token
    ) external view override returns (bool) {
        return (_token == address(tokenBound));
    }

    /**
     *  @dev Returns the ONCHAINID (Identity) of the _userAddress
     *  @param _userAddress Address of the wallet
     *  internal function, can be called only from the functions of the Compliance smart contract
     */
    function _getIdentity(
        address _userAddress
    ) internal view returns (address) {
        return address(tokenBound.identityRegistry().identity(_userAddress));
    }

    /**
     *  @dev Returns the country of residence of the _userAddress
     *  @param _userAddress Address of the wallet
     *  internal function, can be called only from the functions of the Compliance smart contract
     */
    function _getCountry(address _userAddress) internal view returns (uint16) {
        return tokenBound.identityRegistry().investorCountry(_userAddress);
    }
}
