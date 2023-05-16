// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

interface ICompliance {
    /**
     *  this event is emitted when a token has been bound to the compliance contract
     *  the event is emitted by the bindToken function
     *  `_token` is the address of the token to bind
     */
    event TokenBound(address _token);

    /**
     *  this event is emitted when a token has been unbound from the compliance contract
     *  the event is emitted by the unbindToken function
     *  `_token` is the address of the token to unbind
     */
    event TokenUnbound(address _token);

    /**
     *  @dev binds a token to the compliance contract
     *  @param _token address of the token to bind
     *  Emits a TokenBound event
     */
    function bindToken(address _token) external;

    /**
     *  @dev unbinds a token from the compliance contract
     *  @param _token address of the token to unbind
     *  Emits a TokenUnbound event
     */
    function unbindToken(address _token) external;

    /**
     *  @dev function called whenever tokens are transferred
     *  from one wallet to another
     *  this function can update state variables in the compliance contract
     *  these state variables being used by `canTransfer` to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the compliance smart contract
     *  @param _from The address of the sender
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     */
    function transferred(address _from, address _to, uint256 _amount) external;

    /**
     *  @dev function called whenever tokens are created
     *  on a wallet
     *  this function can update state variables in the compliance contract
     *  these state variables being used by `canTransfer` to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the compliance smart contract
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     */
    function created(address _to, uint256 _amount) external;

    /**
     *  @dev function called whenever tokens are destroyed
     *  this function can update state variables in the compliance contract
     *  these state variables being used by `canTransfer` to decide if a transfer
     *  is compliant or not depending on the values stored in these state variables and on
     *  the parameters of the compliance smart contract
     *  @param _from The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     */
    function destroyed(address _from, uint256 _amount) external;

    /**
     *  @dev Returns true if the address given corresponds to a token that is bound with the Compliance contract
     *  @param _token address of the token
     */
    function isTokenBound(address _token) external view returns (bool);

    /**
     *  @dev checks that the transfer is compliant.
     *  default compliance always returns true
     *  READ ONLY FUNCTION, this function cannot be used to increment
     *  counters, emit events, ...
     *  @param _from The address of the sender
     *  @param _to The address of the receiver
     *  @param _amount The amount of tokens involved in the transfer
     */
    function canTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool);
}
