// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract ClaimIssuerTrick {
    function isClaimValid(
        address _identity,
        uint256,
        bytes calldata,
        bytes calldata
    ) public view returns (bool) {
        if (msg.sender == _identity) {
            return true;
        }

        revert("ERROR");
    }
}
